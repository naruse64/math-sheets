# Math Sheets Generator

4歳児向けの算数プリントをTypstで自動生成するプロジェクト

## 特徴

- Typstによる高品質な組版
- プログラムで問題を自動生成
- A5縦サイズ（公文式スタイル）
- Git管理しやすいテキストベース

## 現在利用可能なプリント

### 足し算
- [x] +1（1+1 から 100+1）
- [ ] +2（1+2 から 100+2）
- [ ] +3（1+3 から 100+3）

### 引き算（予定）
- [ ] -1
- [ ] -2

## 使い方

### プリント生成

#### Bashスクリプト使用（推奨）
```bash
# +1足し算プリント（10ページ）
./scripts/build-plus-1.sh

# 出力: output/addition/plus-1-all.pdf
```

#### Pythonスクリプト使用
```bash
# +1足し算プリント（10ページ）
python3 scripts/generate_all.py

# 出力: output/addition/plus-1-all.pdf
```

**依存関係:**
- Bashスクリプト: Ghostscript が必要（`brew install ghostscript`）
- Pythonスクリプト: PyPDF2（推奨）またはGhostscript
```bash
  pip install PyPDF2
  # または
  brew install ghostscript
```

### 開発
```bash
# 個別シートを編集・プレビュー
cd sheets/addition/plus-1
code sheet-01.typ

# コンパイル
typst compile --root ~/math-sheets sheet-01.typ test.pdf
```

## プロジェクト構成
```
math-sheets/
├── templates/       # 共通テンプレート
├── generators/      # 問題生成ロジック
├── sheets/          # シート定義ファイル
│   └── addition/
│       └── plus-1/
├── scripts/         # ビルドスクリプト
└── output/          # 生成されたPDF
    └── addition/
```

## 要件

- Typst
- Ghostscript（PDF結合用）
```bash
brew install typst ghostscript
```

## ライセンス

MIT