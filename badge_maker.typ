#import "@preview/one-liner:0.2.0": fit-to-width 
#let inp = sys.inputs

#let display_name(person) = [
  #v(6.25cm)
  #person.first_name<name>
  #v(1fr)
  #person.last_name<name>
  #v(6.25cm)
]

#let image_file = inp.background

#set page(paper: "a4", flipped: false, margin: (top:0cm, bottom:0cm, left:0cm, right:0cm), background: image(image_file))

#set align(center)
#set text(font: "Nudica", weight:"bold")
#set par(spacing: 0pt)

#show <name>: it => {
  fit-to-width(it, max-text-size:40pt)
}
    
#let persons = csv(inp.persons, row-type : dictionary)

#let first = true

#for pair in persons.chunks(2) {

  if not first [#pagebreak()]
  first = false
  [#table(
  stroke:none,
  columns: (1fr, 1fr),
  rows: (1fr, 1fr),
  inset: (y:0cm, x:1cm),
  display_name(pair.at(0)),
  display_name(pair.at(0)),
  if pair.len() > 1 {rotate(180deg,display_name(pair.at(1)))} else {none},
  if pair.len() > 1 {rotate(180deg,display_name(pair.at(1)))} else {none},
  )]
}