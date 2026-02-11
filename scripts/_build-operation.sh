#!/bin/bash
# 汎用ビルドエンジン
# 直接呼び出し禁止（トップレベルスクリプトから使用）

set -e

# デフォルト値
OPERATION=""
ADDEND=""
BUILD_ANSWER=false
BUILD_2UP=false
BUILD_NO_BORDER=false
BUILD_ALL=false

# 引数パース
while [[ $# -gt 0 ]]; do
  case $1 in
    --operation)
      OPERATION="$2"
      shift 2
      ;;
    --addend)
      ADDEND="$2"
      shift 2
      ;;
    --answer)
      BUILD_ANSWER=true
      shift
      ;;
    --2up)
      BUILD_2UP=true
      shift
      ;;
    --no-border)
      BUILD_NO_BORDER=true
      shift
      ;;
    --all)
      BUILD_ALL=true
      BUILD_ANSWER=true
      BUILD_2UP=true
      BUILD_NO_BORDER=true
      shift
      ;;
    *)
      echo "不明なオプション: $1"
      exit 1
      ;;
  esac
done

# 必須パラメータチェック
if [ -z "$OPERATION" ] || [ -z "$ADDEND" ]; then
  echo "エラー: --operation と --addend は必須です"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# 出力ディレクトリ設定
case $OPERATION in
  addition)
    OUTPUT_BASE="output/addition/plus-$ADDEND"
    OPERATOR_SYMBOL="+"
    ;;
  subtraction)
    OUTPUT_BASE="output/subtraction/minus-$ADDEND"
    OPERATOR_SYMBOL="-"
    ;;
  multiplication)
    OUTPUT_BASE="output/multiplication/times-$ADDEND"
    OPERATOR_SYMBOL="×"
    ;;
  division)
    OUTPUT_BASE="output/division/divide-$ADDEND"
    OPERATOR_SYMBOL="÷"
    ;;
  *)
    echo "エラー: 不明な演算: $OPERATION"
    exit 1
    ;;
esac

# ディレクトリ作成
SHEET_DIR="sheets/$OPERATION/$(basename $OUTPUT_BASE)"
mkdir -p "$OUTPUT_BASE/standard"
mkdir -p "$OUTPUT_BASE/standard-2up"
mkdir -p "$OUTPUT_BASE/no-border"
mkdir -p "$OUTPUT_BASE/no-border-2up"
mkdir -p "$SHEET_DIR"

echo "=== ${OPERATOR_SYMBOL}${ADDEND} プリント生成 ==="
echo ""

# 一時ディレクトリ（PDF用のみ）
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# 生成するモードを決定
MODES=("question")
if [ "$BUILD_ANSWER" = true ] || [ "$BUILD_ALL" = true ]; then
  MODES+=("answer")
fi

# ビルド関数
build_variant() {
  local MODE=$1
  local SHOW_BORDER=$2
  local OUTPUT_DIR=$3
  local VARIANT_NAME=$4
  
  local SHOW_ANSWER="false"
  if [ "$MODE" = "answer" ]; then
    SHOW_ANSWER="true"
  fi
  
  echo "  ${VARIANT_NAME} を生成中..."
  
  # 個別シート生成 → 一時PDF出力
  for i in {1..10}; do
      SHEET_NUM=$(printf "%02d" $i)
      SHEET_FILE="$SHEET_DIR/sheet-$SHEET_NUM.typ"
      TEMP_PDF="$TEMP_DIR/sheet-$SHEET_NUM.pdf"
      
      # Typstファイル生成（毎回上書き）
      cat > "$SHEET_FILE" << EOF
#import "/generators/${OPERATION}.typ": create-${OPERATION}-sheet

#create-${OPERATION}-sheet($i, addend: $ADDEND, show-answer: $SHOW_ANSWER, show-border: $SHOW_BORDER)
EOF
      
      # コンパイル
      if ! typst compile --root "$PROJECT_ROOT" "$SHEET_FILE" "$TEMP_PDF" 2>&1; then
          echo "    ✗ sheet-$SHEET_NUM.pdf (エラー)"
          exit 1
      fi
  done
  
  # PDF結合
  gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite \
     -sOutputFile="$OUTPUT_DIR/$MODE.pdf" \
     "$TEMP_DIR"/sheet-*.pdf
  
  echo "    ✓ $OUTPUT_DIR/$MODE.pdf"
}

# 2up生成関数
build_2up() {
  local MODE=$1
  local OUTPUT_DIR=$2
  local VARIANT_NAME=$3
  
  echo "  ${VARIANT_NAME} (2up) を生成中..."
  
  if command -v pdfjam &> /dev/null; then
    pdfjam --nup 2x1 --landscape --paper a4paper \
           --outfile "$OUTPUT_DIR/$MODE.pdf" \
           "$TEMP_DIR"/sheet-*.pdf 2>/dev/null
    echo "    ✓ $OUTPUT_DIR/$MODE.pdf"
  else
    echo "    ⚠ pdfjamが見つかりません。スキップします。"
  fi
}

# 各モードでビルド
for MODE in "${MODES[@]}"; do
  echo "モード: $MODE"
  
  # 1. 標準版（枠あり・A5縦）- 常に生成
  build_variant "$MODE" "true" "$OUTPUT_BASE/standard" "standard/$MODE.pdf"
  
  # 2. 標準版2up（枠あり・A4横）
  if [ "$BUILD_2UP" = true ] || [ "$BUILD_ALL" = true ]; then
    build_2up "$MODE" "$OUTPUT_BASE/standard-2up" "standard-2up/$MODE.pdf"
  fi
  
  # 3. 枠なし版（枠なし・A5縦）
  if [ "$BUILD_NO_BORDER" = true ] || [ "$BUILD_ALL" = true ]; then
    build_variant "$MODE" "false" "$OUTPUT_BASE/no-border" "no-border/$MODE.pdf"
    
    # 4. 枠なし版2up（枠なし・A4横）
    if [ "$BUILD_2UP" = true ] || [ "$BUILD_ALL" = true ]; then
      build_2up "$MODE" "$OUTPUT_BASE/no-border-2up" "no-border-2up/$MODE.pdf"
    fi
  fi
  
  echo ""
done

echo "完了: $OUTPUT_BASE"