// ワークシートテンプレート
// 公文式スタイル: A5縦、大きな文字、十分な余白

#let worksheet(
  title: "算数プリント",
  date: none,
  name-field: true,
  problems: (),
) = {
  // ページ設定: A5縦
  set page(
    paper: "a5",
    margin: (
      top: 1.5cm,
      bottom: 1.5cm,
      left: -0.5cm,
      right: 0.5cm,
    ),
  )

  // 問題部分
  problems
}

// 問題用のテキストスタイル関数
#let problem-text(content) = text(
  font: "Hiragino Sans",
  size: 20pt,
  lang: "ja",
  content,
)

// 解答欄ボックス定義
#let answer-box(
  answer: none,
  show-border: true,
  show-answer: false,
) = box(
  width: 1.8cm,
  height: 1.8cm,
  stroke: if show-border { 1pt } else { none },
  inset: 0.3em,
  baseline: 35%,
)[
  #if show-answer and answer != none {
    align(center + horizon)[
      #text(size: 24pt, weight: "bold")[#answer]
    ]
  }
]

// 単一の問題を表示する関数（共通処理）
#let render-problem(prob, show-border: true, show-answer: false) = {
  [
    #problem-text()[
      #prob.question #h(0.2em) = #h(0.2em) #answer-box(answer: prob.answer, show-border: show-border, show-answer: show-answer)
    ]
  ]
  v(1.2cm)
}

// 問題レイアウト関数
// 縦に5問の2列レイアウト
#let problem-grid(problems, show-border: true, show-answer: false) = {
  // 各問題の間隔を調整
  set par(leading: 0.1em)

  // 2列のグリッドを作成
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.8em,
    // 左列（最初の5問）
    {
      for prob in problems.slice(0, calc.min(5, problems.len())) {
        render-problem(prob, show-border: show-border, show-answer: show-answer)
      }
    },
    // 右列（6問目以降）
    {
      if problems.len() > 5 {
        for prob in problems.slice(5) {
          render-problem(prob, show-border: show-border, show-answer: show-answer)
        }
      }
    },
  )
}

// 汎用問題生成関数
#let make-problem(a, b, operation: "add") = {
  // 演算記号と計算関数の決定
  let (symbol, calc-fn) = if operation == "add" {
    ("+", (x, y) => x + y)
  } else if operation == "subtract" {
    ("−", (x, y) => x - y)  // マイナス記号（U+2212）
  } else if operation == "multiply" {
    ("×", (x, y) => x * y)  // 乗算記号（U+00D7）
  } else if operation == "divide" {
    ("÷", (x, y) => calc.quo(x, y))  // 除算記号（U+00F7）
  } else {
    panic("不明な演算: " + operation)
  }
  
  (
    question: [#box(width: 3em, align(right)[#a]) #symbol #b],
    answer: calc-fn(a, b),
  )
}

// 足し算専用関数
#let make-addition(a, b) = {
  make-problem(a, b, operation: "add")
}

// 引き算専用関数
#let make-subtraction(a, b) = {
  make-problem(a, b, operation: "subtract")
}

// 掛け算専用関数
#let make-multiplication(a, b) = {
  make-problem(a, b, operation: "multiply")
}

// 割り算専用関数
#let make-division(a, b) = {
  make-problem(a, b, operation: "divide")
}
