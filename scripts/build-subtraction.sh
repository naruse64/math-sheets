#!/bin/bash
# 引き算プリント生成スクリプト
# 
# 使用例:
#   ./build-subtraction.sh 1                    # +1 標準版（問題のみ）
#   ./build-subtraction.sh 1 --answer           # +1 標準版（問題+解答）
#   ./build-subtraction.sh 1 --border           # +1 標準版+枠あり版（問題のみ）
#   ./build-subtraction.sh 1 --2up              # +1 標準版+2up版（問題のみ）
#   ./build-subtraction.sh 1 --all              # +1 全バリエーション
#   ./build-subtraction.sh 1 --answer --border --2up  # 複数組み合わせ

set -e

# 使用方法
usage() {
  echo "使用法: $0 <減数> [オプション]"
  echo ""
  echo "引数:"
  echo "  <減数>          1, 2, 3... (必須)"
  echo ""
  echo "オプション:"
  echo "  --answer        解答版も生成"
  echo "  --2up           2up版（A4横）も生成"
  echo "  --border        枠あり版も生成"
  echo "  --all           全バリエーション生成"
  echo ""
  echo "生成されるファイル:"
  echo "  standard/       枠なし（デフォルト）"
  echo "  standard-2up/   枠なし・2up版（--2up時）"
  echo "  border/         枠あり（--border時）"
  echo "  border-2up/     枠あり・2up版（--border --2up時）"
  echo ""
  echo "例:"
  echo "  $0 1                 # 枠なし版のみ"
  echo "  $0 1 --border        # 枠なし版+枠あり版"
  echo "  $0 1 --answer --2up  # 枠なし版+枠なし2up版（問題+解答）"
  echo "  $0 2 --all           # +2 全バリエーション"
  exit 1
}

# 引数チェック
if [ $# -eq 0 ]; then
  usage
fi

ADDEND=$1
shift  # 残りの引数をオプションとして扱う

# 減数が数値かチェック
if ! [[ "$ADDEND" =~ ^[0-9]+$ ]]; then
  echo "エラー: 減数は数値で指定してください"
  usage
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ヘルパースクリプトを呼び出し
"$SCRIPT_DIR/_build-operation.sh" \
  --operation "subtraction" \
  --addend "$ADDEND" \
  "$@"
