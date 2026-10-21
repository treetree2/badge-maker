// Winners' certificates of Náboj de Física 2026: one per student of each team with a classificacao
// (1, 2 or 3) in input/equipas.csv, by category and place, in the colour of the medal.
#import "certificado.typ": *

#let order = cfg.categorias.keys()
#let winners = teams.filter(t => t.classificacao != "").sorted(key: t => pad4(order.position(k => k == t.categoria)) + t.classificacao)

#if winners.len() == 0 {
  page(paper: "a4", flipped: true, align(center + horizon, text(font: "Poppins", size: 14pt)[Ainda não há classificações em `input/equipas.csv` (coluna `classificacao`).]))
}

#for t in winners {
  for aluno in t.alunos { winner_certificate(aluno, t) }
}
