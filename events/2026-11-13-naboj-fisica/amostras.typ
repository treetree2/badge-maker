// One certificate of each kind in every design (certificado.typ), to choose between them: per design a student, a
// teacher and the 1st, 2nd and 3rd places, from input/equipas.csv. The longest student name shows how names shrink.
#import "certificado.typ": *

#let student_team = teams.sorted(key: t => -calc.max(..t.alunos.map(a => a.len()))).first()
#let student = student_team.alunos.sorted(key: a => -a.len()).first()
#let teacher = teachers.keys().sorted(key: n => -teachers.at(n).len()).first()
#let podium = ("1", "2", "3").map(p => teams.find(t => t.classificacao == p))

#for design in designs {
  student_certificate(student, student_team, design: design)
  teacher_certificate(teacher, design: design)
  for t in podium.filter(t => t != none) { winner_certificate(t.alunos.first(), t, design: design) }
}
