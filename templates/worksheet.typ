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
  content
)

// 解答欄ボックス定義
#let answer-box() = box(
  width: 1.8cm,
  height: 1.8cm,
  stroke: 1pt,
  inset: 0.3em,
  baseline: 35%
)[]

// 問題レイアウト関数
// 縦に5問の2列レイアウト
#let problem-grid(problems) = {
  // 各問題の間隔を調整
  set par(leading: 0.1em)
  
  // 2列のグリッドを作成
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.8em,
    // 左列（最初の5問）
    {
      for (i, prob) in problems.slice(0, calc.min(5, problems.len())).enumerate() {
        [
          #problem-text()[
            #prob.question #h(0.2em) = #h(0.2em) #answer-box()
          ]
        ]
        v(1.2cm)
      }
    },
    // 右列（6問目以降）
    {
      if problems.len() > 5 {
        for (i, prob) in problems.slice(5).enumerate() {
          [
            #problem-text()[
              #prob.question #h(0.2em) = #h(0.2em) #answer-box()
            ]
          ]
          v(1.2cm)
        }
      }
    }
  )
}

// 単純な足し算問題を生成
#let make-addition(a, b) = {
  (
    // 被加数は3桁右寄せ
    question: [#box(width: 3em, align(right)[#a]) + #b],
    answer: a + b,
  )
}