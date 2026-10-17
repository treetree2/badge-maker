// All Náboj de Física 2026 badges in one PDF, role by role (order of funcoes in conteudo.yaml).
// Each A4 holds two people (bottom half turned 180°, as the backgrounds expect) and is followed by its inside,
// for duplex printing with a long-edge flip. Each half folds in the middle: the name on both outer panels,
// the schedule and "A minha função" (role, venue + table, tasks) on the inner ones.
#import "comum.typ": *

#set page(paper: "a4", margin: 0pt)
#set text(font: "Poppins", fill: navy, lang: "pt")
#set par(spacing: 0pt)

// Front: first and last name centred in the background's white box (outer.html: x 9.2–96.7, y 47–101.5 mm
// of each panel), at one size for both lines: the largest up to 40pt at which the longer one fits.
// Lines are measured from cap height to baseline, so accents and descenders don't pull the block off centre.
#let name_box(p) = box(width: 87.5mm, height: 54.5mm, inset: (x: 5mm), align(center + horizon, context {
  let (first, last) = split_name(p.nome)
  set text(weight: "extrabold", top-edge: "cap-height", bottom-edge: "baseline")
  let widest = calc.max(measure(text(size: 40pt, first)).width, measure(text(size: 40pt, last)).width)
  let size = calc.min(40pt, 40pt * (77.5mm / widest))
  set text(size: size)
  stack(spacing: size * 0.38, first, last)
}))

#let front_half(p) = box(width: 210mm, height: 148.5mm, {
  place(top + left, dx: 9.2mm, dy: 47mm, name_box(p))
  place(top + left, dx: 114.2mm, dy: 47mm, name_box(p))
})

#let front(pair) = {
  place(top + left, front_half(pair.at(0)))
  if pair.len() > 1 { place(top + left, dy: 148.5mm, rotate(180deg, front_half(pair.at(1)))) }
}

// Inside: each panel's graph-paper area, between the background's top bar and bottom bar
#let panel(body) = box(width: 105mm, height: 115.5mm, inset: (x: 7mm, top: 5.5mm, bottom: 4mm), {
  set align(left)
  set par(leading: 0.62em)
  body
})
#let label(body) = text(size: 8pt, weight: "bold", tracking: 0.14em, fill: muted, upper(body))

#let tile(fill, accent, head, body) = block(width: 100%, fill: fill, radius: 2mm, inset: (x: 3.2mm, y: 3mm), below: 3.2mm)[
  #text(size: 9.5pt, weight: "bold", fill: accent, head)
  #v(2mm)
  #text(size: 9pt, body)
]

#let schedule_panel(p) = panel[
  #label[Programa]
  #v(5mm)
  #for section in cfg.programa [
    #text(size: 10pt, weight: "bold", fill: blue, section.local)
    #v(3.2mm)
    #grid(
      columns: (26.5mm, 1fr),
      column-gutter: 3mm,
      row-gutter: 3.6mm,
      ..section.itens.map(((time, what)) => (
        align(right, text(size: 9pt, weight: "bold", time)),
        text(size: 9pt, what),
      )).flatten()
    )
    #v(6mm)
  ]
]

#let role_panel(p) = {
  let f = cfg.funcoes.at(p.funcao)
  let color = rgb(f.cor)
  panel[
    #label[A minha função]
    #v(4.5mm)
    #text(size: 28pt, weight: "extrabold", fill: color, f.titulo)
    #v(4mm)
    #box(fill: color, radius: 1.5mm, inset: (x: 3.2mm, y: 2.6mm),
      text(size: 11pt, weight: "bold", tracking: 0.06em, fill: rgb(f.texto), upper(place_text(p))))
    #if is_arbiter(p) and p.mesa != "" [
      #v(3mm)
      #text(size: 10pt, weight: "bold", fill: color, problems_text(p))
    ]
    #v(5mm)
    #if "antes" in f { tile(rgb("#e6f5fc"), rgb("#0077b0"), [Antes da competição], f.antes) }
    #if "durante" in f { tile(rgb("#e4f4ee"), rgb("#0b7a55"), [Durante a competição], f.durante) }
    #if "depois" in f { tile(rgb("#efe9fa"), rgb("#5a35a8"), [Depois da competição], f.depois) }
  ]
}

#let inside_half(p) = box(width: 210mm, height: 148.5mm, {
  place(top + left, dy: 15.5mm, schedule_panel(p))
  place(top + left, dx: 105mm, dy: 15.5mm, role_panel(p))
})

#let inside(pair) = {
  place(top + left, inside_half(pair.at(0)))
  if pair.len() > 1 { place(top + left, dy: 148.5mm, rotate(180deg, inside_half(pair.at(1)))) }
}

// Within a role, by venue, table and name, so the badges come out in hand-out order
#let ordered = people.sorted(key: p => role_index(p) + p.local + mesa_key(p.mesa) + p.nome)

#for key in role_order {
  for pair in ordered.filter(p => p.funcao == key).chunks(2) {
    page(background: image("background/" + key + ".pdf"), front(pair))
    page(background: image("background/" + key + "-back.pdf"), inside(pair))
  }
}
