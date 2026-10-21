// One example of every design, in one PDF (output/exemplos.pdf), to choose between them:
//   certificates (certificado.typ): one student's certificate in each design: grelha, campo, lateral, trajetoria
//   badges (badges.typ): the front of one sheet of two people in each design: grelha, sem-caixa (grelha without the
//   white name box), campo, lateral, trajetoria
// Every example has a different name, in alphabetical order through the PDF: A, B, C… (letters nobody's name starts
// with are skipped). Every colour variant of the certificates is in amostras.pdf.
#import "certificado.typ": designs, student_certificate
#import "badges.typ": front, badge_designs, front_background
#import "comum.typ": *

#let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".clusters()
// The first letter from alphabet.at(from) on with someone in pool whose name starts with it: (its index, that one)
#let pick(pool, from) = {
  for i in range(from, alphabet.len()) {
    let found = pool.find(x => x.nome.starts-with(alphabet.at(i)))
    if found != none { return (i, found) }
  }
  panic("não há nomes por " + alphabet.at(from) + " ou depois")
}
#let next = 0

#let students = teams.map(t => t.alunos.map(a => (nome: a, team: t))).flatten()
#for design in designs {
  let (i, s) = pick(students, next)
  next = i + 1
  student_certificate(s.nome, s.team, design: design)
}

// Everyone on the badges at the table of the first árbitro with one, so the role bands match the background
#let table = people.find(p => is_arbiter(p) and p.mesa != "")
#set page(paper: "a4", margin: 0pt)
#set text(font: "Poppins", fill: navy, lang: "pt")
#set par(spacing: 0pt)
#for design in badge_designs {
  let pair = ()
  for _ in range(2) {
    let (i, p) = pick(people, next)
    next = i + 1
    pair.push(p + (local: table.local, mesa: table.mesa))
  }
  page(background: image(front_background(table_key(table), design)), front(pair))
}
