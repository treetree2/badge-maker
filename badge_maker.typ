#import "@preview/one-liner:0.2.0": fit-to-width
#let inp = sys.inputs

// Inputs: persons (CSV), background (PDF); optional font, weight, color, back (PDF of the back of each sheet)
#let back_file = inp.at("back", default: none)

// CSV columns first_name + last_name, or a single name column (first word / last word)
#let split_name(person) = {
  if "first_name" in person { (person.first_name, person.last_name) } else {
    let words = person.name.split(" ").filter(w => w != "")
    (words.first(), if words.len() > 1 { words.last() } else { "" })
  }
}

#let display_name(person) = {
  let (first_name, last_name) = split_name(person)
  [
    #v(6.25cm)
    #first_name<name>
    #v(1fr)
    #last_name<name>
    #v(6.25cm)
  ]
}

#let image_file = inp.background

#set page(paper: "a4", flipped: false, margin: (top:0cm, bottom:0cm, left:0cm, right:0cm), background: image(image_file))

#set align(center)
#set text(weight: inp.at("weight", default: "bold"), fill: rgb(inp.at("color", default: "#000000")))
#set text(font: inp.font) if "font" in inp
#set par(spacing: 0pt)

#show <name>: it => {
  fit-to-width(it, max-text-size:40pt)
}

// Strip the BOM that spreadsheet exports put before the first header
#let persons = csv(inp.persons, row-type : dictionary).map(row => {
  let clean = (:)
  for (key, value) in row { clean.insert(key.trim("\u{feff}").trim(), value.trim()) }
  clean
})

#let first = true

#for pair in persons.chunks(2) {

  if not first [#pagebreak(weak: true)]
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
  // Back of the sheet, for duplex printing (flip on the long edge)
  if back_file != none [#page(background: image(back_file))[]]
}
