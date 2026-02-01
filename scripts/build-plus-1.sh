#!/bin/bash
# +1足し算プリント一括ビルド

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"  # scriptsの親ディレクトリ
cd "$PROJECT_ROOT"

mkdir -p output/addition

echo "=== +1足し算プリント生成 ==="
echo ""

# 一時ディレクトリを作成
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# 13シート生成（1+1 から 100+1）
for i in {1..10}; do
    SHEET_NUM=$(printf "%02d" $i)
    SHEET_FILE="sheets/addition/plus-1/sheet-$SHEET_NUM.typ"
    TEMP_PDF="$TEMP_DIR/sheet-$SHEET_NUM.pdf"
    
    # シートファイルが存在しない場合は作成
    if [ ! -f "$SHEET_FILE" ]; then
        cat > "$SHEET_FILE" << EOF
#import "/generators/addition.typ": create-plus-one-sheet

#create-plus-one-sheet($i)
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
   -sOutputFile="$PROJECT_ROOT/output/addition/plus-1-all.pdf" \
   "$TEMP_DIR"/sheet-*.pdf

echo "✓ 完了: output/addition/plus-1-all.pdf (10ページ)"