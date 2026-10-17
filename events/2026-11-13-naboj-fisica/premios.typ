// Winners' certificates of Náboj de Física 2026: one per student of each team with a classificacao
// (1, 2 or 3) in input/equipas.csv, by category and place, in the colour of the medal.
#import "certificado.typ": *

#let medals = (
  "1": (rgb("#c9a227"), navy),
  "2": (rgb("#9aa4b1"), navy),
  "3": (rgb("#b8733a"), white),
)

#let order = cfg.categorias.keys()
#let winners = teams.filter(t => t.classificacao != "").sorted(key: t => pad4(order.position(k => k == t.categoria)) + t.classificacao)

#if winners.len() == 0 {
  page(paper: "a4", flipped: true, align(center + horizon, text(font: "Poppins", size: 14pt)[Ainda não há classificações em `input/equipas.csv` (coluna `classificacao`).]))
}

#for t in winners {
  let (medal, ink) = medals.at(t.classificacao)
  let place_text = t.classificacao + ".º lugar"
  for aluno in t.alunos {
    certificate(accent: medal, ink: ink, content([Certificado de mérito], aluno,
      highlight: text(size: 34pt, weight: "extrabold", fill: medal)[#place_text · #category(t)],
      [obteve o #place_text na categoria #category(t) como membro da #team(t, with_category: false) #of_school(t.escola)], t.escola))
  }
}
