# Math Sheets Generator

4歳〜小学生向けの算数プリントをTypstで自動生成するプロジェクト

## 特徴

- ✅ **高品質な組版** - Typstによる美しいレイアウト
- ✅ **柔軟な問題生成** - 順次/ランダム、各オペランドの範囲指定
- ✅ **Git管理可能** - 問題セットをJSONで保存・共有
- ✅ **複数の出力形式** - A5縦、A4横2up、枠あり/なし、問題/解答
- ✅ **四則演算対応** - 足し算、引き算、掛け算、割り算

## 要件

```bash
# macOS (Homebrew)
brew install typst
brew install ghostscript
brew install --cask basictex
sudo tlmgr install pdfjam

# Python 3（標準搭載）
python3 --version
```

---

## クイックスタート

### 方法1: 順次問題（従来方式）

1コマンドで即座にPDF生成：

```bash
# +1の足し算（1+1, 2+1, ..., 100+1）
./scripts/build-addition.sh 1 --answer --2up

# ×3の掛け算（1×3, 2×3, ..., 100×3）
./scripts/build-multiplication.sh 3 --answer
```

### 方法2: カスタム問題（新方式）

2ステップで柔軟な問題セット生成：

```bash
# Step 1: 問題セット生成
python3 scripts/generate_problems.py \
  --operation addition \
  --first-min 1 --first-max 9 \
  --second-min 1 --second-max 9 \
  --count 100 \
  --description "1桁+1桁のランダム問題" \
  --output problems/addition/1digit-random.json

# Step 2: PDF生成
./scripts/build-from-json.sh \
  problems/addition/1digit-random.json \
  --answer --2up
```

---

## 使い方

### 順次問題（クイック生成）

シンプルな順次問題をすぐに生成：

```bash
# 基本
./scripts/build-addition.sh 1              # 問題版のみ
./scripts/build-addition.sh 1 --answer     # 問題版+解答版
./scripts/build-addition.sh 1 --2up        # 2up版も生成
./scripts/build-addition.sh 1 --all        # 全バリエーション

# 他の演算
./scripts/build-subtraction.sh 2 --answer
./scripts/build-multiplication.sh 5 --all
./scripts/build-division.sh 3 --answer --2up
```

**出力先:** `output/addition/plus-1/`

---

### カスタム問題（柔軟な生成）

#### 1. 問題セット生成

```bash
python3 scripts/generate_problems.py \
  --operation <演算> \
  --first-min <最小値> --first-max <最大値> \
  --second-min <最小値> --second-max <最大値> \
  --count <問題数> \
  --output <出力JSONパス>
```

**オプション:**
- `--operation`: `addition`, `subtraction`, `multiplication`, `division`
- `--first-min/max`: 第1オペランド（被加数、被減数、被乗数、商）の範囲
- `--second-min/max`: 第2オペランド（加数、減数、乗数、除数）の範囲
- `--count`: 生成する問題数
- `--first-serial`: 第1オペランドを順番に生成（ランダムではなく）
- `--second-serial`: 第2オペランドを順番に生成
- `--seed`: 乱数シード（再現性のため）
- `--description`: 問題セットの説明

#### 2. PDF生成

```bash
./scripts/build-from-json.sh <JSONファイル> [オプション]
```

**オプション:**
- `--answer`: 解答版も生成
- `--2up`: A4横2up版も生成
- `--border`: 枠あり版も生成
- `--all`: 全バリエーション

**出力先:** `output/<演算>/<JSONファイル名>/`

---

## 実例

### 例1: 1桁+1桁のランダム問題

```bash
# 問題セット生成
python3 scripts/generate_problems.py \
  --operation addition \
  --first-min 1 --first-max 9 \
  --second-min 1 --second-max 9 \
  --count 100 \
  --description "小学1年生・1桁+1桁" \
  --output problems/addition/grade1-basic.json

# PDF生成
./scripts/build-from-json.sh \
  problems/addition/grade1-basic.json \
  --answer --2up
```

### 例2: 繰り上がりのある足し算

```bash
python3 scripts/generate_problems.py \
  --operation addition \
  --first-min 5 --first-max 9 \
  --second-min 5 --second-max 9 \
  --count 50 \
  --description "繰り上がり練習" \
  --output problems/addition/carry.json

./scripts/build-from-json.sh problems/addition/carry.json --answer
```

### 例3: 九九（順番）

```bash
python3 scripts/generate_problems.py \
  --operation multiplication \
  --first-min 1 --first-max 9 --first-serial \
  --second-min 1 --second-max 9 --second-serial \
  --count 81 \
  --description "九九・順番" \
  --output problems/multiplication/kuku-sequential.json

./scripts/build-from-json.sh \
  problems/multiplication/kuku-sequential.json \
  --all
```

### 例4: 2桁÷1桁（割り切れる）

```bash
python3 scripts/generate_problems.py \
  --operation division \
  --first-min 10 --first-max 20 \
  --second-min 2 --second-max 5 \
  --count 100 \
  --description "小学3年生・2桁÷1桁" \
  --output problems/division/grade3-2digit.json

./scripts/build-from-json.sh problems/division/grade3-2digit.json --answer
```

---

## プロジェクト構成

```
math-sheets/
├── README.md
├── templates/
│   └── worksheet.typ          # 共通テンプレート
├── generators/
│   ├── addition.typ           # 足し算ジェネレーター
│   ├── subtraction.typ        # 引き算ジェネレーター
│   ├── multiplication.typ     # 掛け算ジェネレーター
│   └── division.typ           # 割り算ジェネレーター
├── scripts/
│   ├── generate_problems.py   # 問題セット生成
│   ├── build-from-json.sh     # JSON→PDF変換
│   ├── build-addition.sh      # 足し算クイック生成
│   ├── build-subtraction.sh   # 引き算クイック生成
│   ├── build-multiplication.sh # 掛け算クイック生成
│   ├── build-division.sh      # 割り算クイック生成
│   └── _build-operation.sh    # 内部ヘルパー
├── problems/                  # 問題セットJSON（Git管理）
│   ├── addition/
│   ├── subtraction/
│   ├── multiplication/
│   └── division/
├── sheets/                    # 中間生成物（Git管理外）
└── output/                    # 生成PDF（Git管理外）
```

---

## 出力フォルダ構造

```
output/<演算>/<問題セット名>/
├── standard/          # 枠なし・A5縦（デフォルト）
│   ├── question.pdf
│   └── answer.pdf
├── standard-2up/      # 枠なし・A4横
│   ├── question.pdf
│   └── answer.pdf
├── border/            # 枠あり・A5縦
│   ├── question.pdf
│   └── answer.pdf
└── border-2up/        # 枠あり・A4横
    ├── question.pdf
    └── answer.pdf
```

---

## カスタマイズ

### レイアウト調整

`templates/worksheet.typ` で調整可能：

- ページサイズ: `set page(paper: "a5")`
- マージン: `margin: (top: 1.5cm, ...)`
- 文字サイズ: `text(size: 20pt)`
- 問題間隔: `v(1.2cm)`
- 解答欄サイズ: `answer-box()` 内の `width`, `height`

### フォント変更

```typst
#let problem-text(content) = text(
  font: "Hiragino Sans",  // お好みのフォントに変更
  size: 20pt,
)
```

利用可能なフォント確認:
```bash
typst fonts
```

---

## 開発ワークフロー

### 新しい問題セットの作成

1. 問題セット生成
2. Git管理（再現性のため）
3. PDF生成
4. 配布

```bash
# 1. 生成
python3 scripts/generate_problems.py \
  --operation addition \
  --first-min 10 --first-max 99 \
  --second-min 1 --second-max 9 \
  --count 100 \
  --output problems/addition/grade2-2digit.json

# 2. Git管理
git add problems/addition/grade2-2digit.json
git commit -m "feat: 小学2年生用・2桁+1桁問題セット追加"

# 3. PDF生成（何度でも）
./scripts/build-from-json.sh \
  problems/addition/grade2-2digit.json \
  --all

# 4. 配布
open output/addition/grade2-2digit/standard/question.pdf
```

---

## よくある質問

### Q: 問題セットを再利用できますか？
A: はい。JSONファイルを保存しておけば、いつでも同じ問題セットからPDFを再生成できます。

### Q: 同じランダム問題を再生成できますか？
A: `--seed` オプションで乱数シードを指定すれば、同じ問題セットを再生成できます。

```bash
python3 scripts/generate_problems.py \
  --seed 12345 \
  ... \
  --output problems/test.json
```

### Q: 順次問題とランダム問題の使い分けは？
A: 
- **順次問題**: 系統的な学習、段階的な難易度上昇
- **ランダム問題**: 定着確認、テスト、バリエーション練習

### Q: 割り算で割り切れない問題も作れますか？
A: 現在は割り切れる問題のみ対応しています。将来的に拡張予定です。

---

## ライセンス

MIT

---

## 開発履歴

- Step 1-3: 基本機能（問題版・解答版・枠あり/なし）
- Step 4: 四則演算対応
- Step 5-6: 引き算・掛け算・割り算
- Step 7: Python問題生成スクリプト
- Step 8: JSON→PDF変換

---

## 今後の拡張アイデア

- [ ] 小数・分数の計算
- [ ] 割り切れない割り算（余りあり）
- [ ] 文章題
- [ ] イラスト挿入
- [ ] 難易度自動調整
- [ ] Web UI
