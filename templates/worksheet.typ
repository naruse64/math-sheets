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
      left: 1.2cm,
      right: 1.2cm,
    ),
  )
  
  // フォント設定: 子どもが読みやすい大きさ
  set text(
    font: "Hiragino Sans",
    size: 11pt,
    lang: "ja",
  )
  
  // // ヘッダー部分
  // grid(
  //   columns: (1fr, 1fr),
  //   [
  //     #text(size: 14pt, weight: "bold")[#title]
  //   ],
  //   [
  //     #if date != none {
  //       text(size: 10pt)[#date]
  //     }
  //   ],
  // )
  
  // v(0.3cm)
  
  // // 名前記入欄
  // if name-field {
  //   box(
  //     width: 100%,
  //     stroke: none,
  //   )[
  //     なまえ: #h(0.5cm) #line(length: 5cm, stroke: 0.5pt) #h(1fr)
  //   ]
  //   v(0.5cm)
  // }
  
  // 問題部分
  problems
}

// 問題レイアウト関数
// 8問を縦に並べる（A5で適切なサイズ）
#let problem-grid(problems) = {
  // 各問題の間隔を調整
  set par(leading: 0.8em)
  
  for (i, prob) in problems.enumerate() {
    grid(
      columns: (auto, 1fr),
      column-gutter: 1em,
      // 問題番号
      // [
      //   #text(size: 12pt, weight: "regular")[#(i + 1).]
      // ],
      // 式
      [
        #text(size: 18pt, font: "Arial")[
          #prob.question #h(0.8em) = #h(0.8em) #box(
            width: 2.5em,
            height: 1.8em,
            stroke: 1pt,
            inset: 0.3em,
          )[]
        ]
      ],
    )
    
    // 問題間のスペース
    v(0.7cm)
  }
}

// 単純な足し算問題を生成
#let make-addition(a, b) = {
  (
    // 被加数は3桁右寄せ
    question: [#box(width: 3em, align(right)[#a]) + #b],
    answer: a + b,
  )
}