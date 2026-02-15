#!/bin/bash
# JSON問題セットからPDF生成スクリプト
#
# 使用例:
#   ./build-from-json.sh problems/addition/plus1-sequential.json
#   ./build-from-json.sh problems/addition/plus1-sequential.json --answer
#   ./build-from-json.sh problems/addition/plus1-sequential.json --answer --2up --border

set -e

# 使用方法
usage() {
  echo "使用法: $0 <JSON問題セットファイル> [オプション]"
  echo ""
  echo "引数:"
  echo "  <JSONファイル>   問題セットJSONファイルのパス（必須）"
  echo ""
  echo "オプション:"
  echo "  --answer         解答版も生成"
  echo "  --2up            2up版（A4横）も生成"
  echo "  --border         枠あり版も生成"
  echo "  --all            全バリエーション生成"
  echo ""
  echo "例:"
  echo "  $0 problems/addition/plus1-sequential.json"
  echo "  $0 problems/addition/plus1-sequential.json --answer --2up"
  echo "  $0 problems/multiplication/kuku-all.json --all"
  exit 1
}

# 引数チェック
if [ $# -eq 0 ]; then
  usage
fi

JSON_FILE=$1
shift  # 残りの引数をオプションとして扱う

# JSONファイルの存在チェック
if [ ! -f "$JSON_FILE" ]; then
  echo "エラー: JSONファイルが見つかりません: $JSON_FILE"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# JSONからメタデータを抽出
OPERATION=$(python3 -c "import json; print(json.load(open('$JSON_FILE'))['metadata']['operation'])")
SYMBOL=$(python3 -c "import json; print(json.load(open('$JSON_FILE'))['metadata']['symbol'])")
PROBLEM_COUNT=$(python3 -c "import json; print(json.load(open('$JSON_FILE'))['metadata']['count'])")

# JSON問題セット名（ファイル名から拡張子を除く）
JSON_BASENAME=$(basename "$JSON_FILE" .json)

echo "=== JSON問題セットからPDF生成 ==="
echo "  JSONファイル: $JSON_FILE"
echo "  演算: $OPERATION ($SYMBOL)"
echo "  問題数: $PROBLEM_COUNT"
echo ""

# 出力ディレクトリ
OUTPUT_BASE="output/${OPERATION}/${JSON_BASENAME}"
SHEET_DIR="sheets/${OPERATION}/${JSON_BASENAME}"

mkdir -p "$OUTPUT_BASE/standard"
mkdir -p "$OUTPUT_BASE/standard-2up"
mkdir -p "$OUTPUT_BASE/border"
mkdir -p "$OUTPUT_BASE/border-2up"
mkdir -p "$SHEET_DIR"

# 一時ディレクトリ（PDF用）
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# オプション解析
BUILD_ANSWER=false
BUILD_2UP=false
BUILD_BORDER=false
BUILD_ALL=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --answer)
      BUILD_ANSWER=true
      shift
      ;;
    --2up)
      BUILD_2UP=true
      shift
      ;;
    --border)
      BUILD_BORDER=true
      shift
      ;;
    --all)
      BUILD_ALL=true
      BUILD_ANSWER=true
      BUILD_2UP=true
      BUILD_BORDER=true
      shift
      ;;
    *)
      echo "不明なオプション: $1"
      usage
      ;;
  esac
done

# 生成するモードを決定
MODES=("question")
if [ "$BUILD_ANSWER" = true ] || [ "$BUILD_ALL" = true ]; then
  MODES+=("answer")
fi

# 問題数からシート数を計算（10問/シート）
PROBLEMS_PER_SHEET=10
SHEET_COUNT=$(( ($PROBLEM_COUNT + $PROBLEMS_PER_SHEET - 1) / $PROBLEMS_PER_SHEET ))

echo "シート数: $SHEET_COUNT 枚（${PROBLEMS_PER_SHEET}問/シート）"
echo ""

# Typst生成用のPythonヘルパースクリプトを作成
PYTHON_HELPER="$TEMP_DIR/generate_typst.py"
cat > "$PYTHON_HELPER" << 'PYTHON_EOF'
import json
import sys

def generate_typst(json_file, start_idx, end_idx, show_answer, show_border):
    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    metadata = data['metadata']
    problems = data['problems'][start_idx:end_idx]
    
    operation = metadata['operation']
    
    # タイトル用の記号
    symbol_map = {
        'addition': '+',
        'subtraction': '−',
        'multiplication': '×',
        'division': '÷'
    }
    symbol = symbol_map.get(operation, metadata.get('symbol', ''))
    
    # 演算用語マッピング
    operand_names = metadata['ranges']
    operand2_name = list(operand_names.keys())[1]
    
    # 値の取得（表示用）
    range2 = operand_names[operand2_name]
    
    # シンプルな値表示（範囲が1つの値の場合）
    if range2['min'] == range2['max']:
        value = str(range2['min'])
    else:
        value = f"{range2['min']}-{range2['max']}"
    
    # Typstコード生成
    print('#import "/templates/worksheet.typ": *')
    print()
    print('#let problems = (')
    
    for prob in problems:
        if operation == 'addition':
            print(f'  make-addition({prob["a"]}, {prob["b"]}),')
        elif operation == 'subtraction':
            print(f'  make-subtraction({prob["a"]}, {prob["b"]}),')
        elif operation == 'multiplication':
            print(f'  make-multiplication({prob["a"]}, {prob["b"]}),')
        elif operation == 'division':
            print(f'  make-division({prob["a"]}, {prob["b"]}),')
    
    print(')')
    print()
    
    # タイトル生成
    title_map = {
        'addition': 'たしざん',
        'subtraction': 'ひきざん',
        'multiplication': 'かけざん',
        'division': 'わりざん'
    }
    title = title_map.get(operation, operation)
    
    print('#worksheet(')
    print(f'  title: [{title} {symbol}{value}],')
    print('  date: datetime.today().display("[year]年[month]月[day]日"),')
    print('  name-field: true,')
    print('  problems: problem-grid(')
    print('    problems,')
    print(f'    show-answer: {show_answer},')
    print(f'    show-border: {show_border}')
    print('  ),')
    print(')')

if __name__ == '__main__':
    json_file = sys.argv[1]
    start_idx = int(sys.argv[2])
    end_idx = int(sys.argv[3])
    show_answer = sys.argv[4]
    show_border = sys.argv[5]
    generate_typst(json_file, start_idx, end_idx, show_answer, show_border)
PYTHON_EOF

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
  
  # 各シートのTypstファイルを生成
  for ((sheet_num=1; sheet_num<=$SHEET_COUNT; sheet_num++)); do
    SHEET_NUM_PADDED=$(printf "%02d" $sheet_num)
    SHEET_FILE="$SHEET_DIR/sheet-$SHEET_NUM_PADDED.typ"
    TEMP_PDF="$TEMP_DIR/sheet-$SHEET_NUM_PADDED.pdf"
    
    # 問題のインデックス範囲
    START_IDX=$(( ($sheet_num - 1) * $PROBLEMS_PER_SHEET ))
    END_IDX=$(( $sheet_num * $PROBLEMS_PER_SHEET ))
    if [ $END_IDX -gt $PROBLEM_COUNT ]; then
      END_IDX=$PROBLEM_COUNT
    fi
    
    # Pythonヘルパーでtypstファイル生成
    python3 "$PYTHON_HELPER" "$JSON_FILE" "$START_IDX" "$END_IDX" "$SHOW_ANSWER" "$SHOW_BORDER" > "$SHEET_FILE"
    
    # コンパイル
    if ! typst compile --root "$PROJECT_ROOT" "$SHEET_FILE" "$TEMP_PDF" 2>&1; then
      echo "    ✗ sheet-$SHEET_NUM_PADDED.pdf (エラー)"
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
  
  # 1. 標準版（枠なし・A5縦）- 常に生成
  build_variant "$MODE" "false" "$OUTPUT_BASE/standard" "standard/$MODE.pdf"
  
  # 2. 標準版2up（枠なし・A4横）
  if [ "$BUILD_2UP" = true ] || [ "$BUILD_ALL" = true ]; then
    build_2up "$MODE" "$OUTPUT_BASE/standard-2up" "standard-2up/$MODE.pdf"
  fi
  
  # 3. 枠あり版（枠あり・A5縦）
  if [ "$BUILD_BORDER" = true ] || [ "$BUILD_ALL" = true ]; then
    build_variant "$MODE" "true" "$OUTPUT_BASE/border" "border/$MODE.pdf"
    
    # 4. 枠あり版2up（枠あり・A4横）
    if [ "$BUILD_2UP" = true ] || [ "$BUILD_ALL" = true ]; then
      build_2up "$MODE" "$OUTPUT_BASE/border-2up" "border-2up/$MODE.pdf"
    fi
  fi
  
  echo ""
done

echo "完了: $OUTPUT_BASE"
echo ""
echo "生成されたファイル:"
find "$OUTPUT_BASE" -name "*.pdf" -type f | sort