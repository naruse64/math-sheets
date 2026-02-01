// +1 足し算問題生成スクリプト
// 1+1 から 100+1 まで、10問ずつのシートを生成

#import "/templates/worksheet.typ": *


// シート番号から開始番号を計算
#let sheet-start-number(sheet-num, problems-per-sheet) = {
  (sheet-num - 1) * problems-per-sheet + 1
}

// 汎用的な足し算問題生成関数
#let create-addition-sheet(sheet-number, addend: 1, problems-per-sheet: 10) = {
  let start = sheet-start-number(sheet-number, problems-per-sheet)
  let problems = ()
  
  for i in range(problems-per-sheet) {
    let num = start + i
    problems.push(make-addition(num, addend))
  }
  
  worksheet(
    title: [たしざん +#addend],
    date: datetime.today().display("[year]年[month]月[day]日"),
    name-field: true,
    problems: problem-grid(problems),
  )
}
