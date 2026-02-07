#!/bin/bash
# 足し算プリント汎用ビルドスクリプト
# 使用例: ./build-addition.sh 1
#         ./build-addition.sh 2
#         ./build-addition.sh 99
# 99までレイアウト崩れなく使用可能

set -e

# 引数チェック
if [ $# -ne 1 ]; then
    echo "使用法: $0 <加数>"
    echo "例: $0 1  (+1の足し算プリント生成)"
    echo "    $0 2  (+2の足し算プリント生成)"
    exit 1
fi

ADDEND=$1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"  # scriptsの親ディレクトリ
cd "$PROJECT_ROOT"

mkdir -p "output/addition"
mkdir -p "sheets/addition/plus-$ADDEND"

echo "=== +${ADDEND}足し算プリント生成 ==="
echo ""

# 一時ディレクトリを作成
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# 10シート生成（1+N から 100+N）
for i in {1..10}; do
    SHEET_NUM=$(printf "%02d" $i)
    SHEET_FILE="sheets/addition/plus-$ADDEND/sheet-$SHEET_NUM.typ"
    TEMP_PDF="$TEMP_DIR/sheet-$SHEET_NUM.pdf"
    
    # シートファイルが存在しない場合は作成
    if [ ! -f "$SHEET_FILE" ]; then
        cat > "$SHEET_FILE" << EOF
#import "/generators/addition.typ": create-addition-sheet

#create-addition-sheet($i, addend: $ADDEND)
EOF
    fi
    
    # コンパイル
    if typst compile --root "$PROJECT_ROOT" "$SHEET_FILE" "$TEMP_PDF" 2>/dev/null; then
        echo "✓ sheet-$SHEET_NUM.pdf"
    else
        echo "✗ sheet-$SHEET_NUM.pdf (エラー)"
        exit 1
    fi
done

echo ""
echo "PDFを結合中..."

# PDFを結合
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite \
   -sOutputFile="$PROJECT_ROOT/output/addition/plus-${ADDEND}-all.pdf" \
   "$TEMP_DIR"/sheet-*.pdf

echo "✓ 完了: output/addition/plus-${ADDEND}-all.pdf (10ページ)"