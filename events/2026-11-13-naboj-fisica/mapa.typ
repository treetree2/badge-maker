// Room maps of Náboj de Física 2026: one A4 landscape per room with every team in its spot (front at the top,
// row 1 nearest the front), then an index of the teams by school, for check-in.
#import "comum.typ": *

#set page(paper: "a4", flipped: true, margin: 0pt)
#set text(font: "Poppins", fill: navy, lang: "pt")
#set par(spacing: 0pt)

// "Escola Secundária de Camões" → "Camões": the map cells only have room for the distinctive part
#let short_school(name) = {
  for prefix in ("Escola Básica e Secundária ", "Escola Secundária ", "Escola Básica ") {
    if name.starts-with(prefix) { name = name.slice(prefix.len()) }
  }
  for article in ("de ", "do ", "da ", "dos ", "das ") {
    if name.starts-with(article) { name = name.slice(article.len()) }
  }
  name
}

#let swatch(key) = {
  let c = cfg.categorias.at(key)
  box(baseline: 20%, rect(width: 4mm, height: 4mm, radius: 1mm, fill: rgb(c.cor), stroke: none))
  h(1.6mm)
  text(size: 9pt, weight: "semibold", c.titulo)
}

#let room_page(local) = page({
  let sala = cfg.salas.at(local)
  let here = teams.filter(t => t.local == local)
  // The grid fills the page below the header; tiles and their text scale with the room's size
  let gap = 2mm
  let x0 = 19mm
  let y0 = 40mm
  let gw = 297mm - 10mm - x0
  let gh = 210mm - 9mm - y0
  let cw = (gw - gap * (sala.colunas - 1)) / sala.colunas
  let ch = (gh - gap * (sala.filas - 1)) / sala.filas
  let cell = calc.min(cw, ch)

  set text(top-edge: "cap-height", bottom-edge: "baseline")
  place(top + left, dx: 10mm, dy: 9mm, text(size: 8pt, weight: "bold", tracking: 0.16em, fill: muted)[NÁBOJ DE FÍSICA 2026 · 13 NOV])
  place(top + left, dx: 10mm, dy: 14.5mm, text(size: 24pt, weight: "extrabold")[Mapa das equipas #text(fill: blue)[· #cfg.locais.at(local)]])
  place(top + right, dx: -10mm, dy: 9mm, {
    for (i, key) in cfg.categorias.keys().filter(k => here.any(t => t.categoria == k)).enumerate() {
      if i > 0 { h(6mm) }
      swatch(key)
      text(size: 9pt, fill: muted)[ (#here.filter(t => t.categoria == key).len())]
    }
  })
  place(top + right, dx: -10mm, dy: 17.5mm, text(size: 8.5pt, fill: muted)[Lugar: fila × coluna · fila 1 junto ao ecrã · colunas da esquerda para a direita, vistas do fundo])

  place(top + left, dx: x0, dy: 25mm, rect(width: gw, height: 7mm, radius: 1.5mm, fill: rgb("#d5dbe5"), stroke: none,
    align(center + horizon, text(size: 9pt, weight: "bold", tracking: 0.24em, fill: muted)[ECRÃ])))

  for ci in range(sala.colunas) {
    place(top + left, dx: x0 + ci * (cw + gap), dy: y0 - 4.5mm, box(width: cw, align(center, text(size: 9pt, weight: "bold", fill: muted, str(ci + 1)))))
  }
  for fi in range(sala.filas) {
    let y = y0 + fi * (ch + gap)
    place(top + left, dx: 10mm, dy: y, box(width: x0 - 10mm - gap, height: ch, align(center + horizon, text(size: 10pt, weight: "bold", fill: muted, str(fi + 1)))))
    for ci in range(sala.colunas) {
      let x = x0 + ci * (cw + gap)
      let t = here.find(t => t.fila == fi + 1 and t.coluna == ci + 1)
      if t == none {
        place(top + left, dx: x, dy: y, rect(width: cw, height: ch, radius: 2mm, stroke: (paint: rgb("#c9d3e0"), thickness: 0.5pt, dash: "dashed")))
      } else {
        let color = rgb(cfg.categorias.at(t.categoria).cor)
        place(top + left, dx: x, dy: y, rect(width: cw, height: ch, radius: 2mm, fill: color, stroke: none, inset: 2.5mm, {
          text(size: cell * 0.27, weight: "extrabold", fill: white, t.numero)
          place(bottom + left, box(width: cw - 5mm, {
            set par(leading: cell * 0.05)
            text(size: cell * 0.115, weight: "semibold", fill: white)[#short_school(t.escola)#if t.equipa != "" [ · #t.equipa]]
          }))
        }))
      }
    }
  }
})

#for local in cfg.salas.keys() { room_page(local) }

// Index by school, for check-in
#page(margin: (x: 22mm, y: 16mm), {
  text(size: 8pt, weight: "bold", tracking: 0.16em, fill: muted)[NÁBOJ DE FÍSICA 2026 · 13 NOV]
  v(3mm)
  text(size: 22pt, weight: "extrabold")[Equipas por escola]
  v(7mm)
  let order = cfg.categorias.keys()
  let rows = teams.sorted(key: t => t.escola + pad4(order.position(k => k == t.categoria)) + t.equipa)
  set text(size: 9pt)
  table(
    columns: (1fr, auto, auto, auto, auto, auto),
    stroke: (x, y) => if y > 0 { (top: 0.4pt + rgb("#dfe4ec")) },
    inset: (x: 2.5mm, y: 2.4mm),
    align: (x, y) => if x in (2, 5) { center } else { left },
    table.header(..("Escola", "", "Equipa", "Categoria", "Local", "Lugar").map(h => text(size: 7.5pt, weight: "bold", tracking: 0.1em, fill: muted, upper(h)))),
    ..rows.map(t => (
      text(weight: "semibold", t.escola),
      t.equipa,
      text(weight: "bold", t.numero),
      cfg.categorias.at(t.categoria).titulo,
      cfg.locais.at(t.local),
      text(weight: "bold", spot_text(t)),
    )).flatten()
  )
})
