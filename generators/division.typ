// +1 割り算問題生成スクリプト
// 1+1 から 100+1 まで、10問ずつのシートを生成

#import "/templates/worksheet.typ": *

// 汎用的な割り算問題生成関数
#let generate-division-problems(start, addend: 1, problems-per-sheet: 10) = {
  let problems = ()
  for i in range(problems-per-sheet) {
    let num = start + i
    problems.push(make-division(num, addend))
  }
  problems
}

// シート番号から開始番号を計算
#let sheet-start-number(sheet-num, problems-per-sheet: 10) = {
  (sheet-num - 1) * problems-per-sheet + 1
}

// 汎用的な割り算問題生成関数
#let create-division-sheet(
  sheet-number,
  addend: 1,
  problems-per-sheet: 10,
  show-answer: false,
  show-border: true
) = {
  let start = sheet-start-number(sheet-number, problems-per-sheet: problems-per-sheet)
  let problems = generate-division-problems(start, addend: addend, problems-per-sheet: problems-per-sheet)  
  
  worksheet(
    title: [わりざん +#addend],
    date: datetime.today().display("[year]年[month]月[day]日"),
    name-field: true,
    problems: problem-grid(
      problems,
      show-answer: show-answer,
      show-border: show-border
    ),
  )
}
