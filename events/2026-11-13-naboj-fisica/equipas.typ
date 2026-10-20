// Team sheets of Náboj de Física 2026: one A6 per team, twice (one pasted on the table, one handed to the team),
// with the team number, school, category, students, jury table, venue and spot (row from the front × column) and a
// small map of the room. Everything in the colour of the team's jury table. Four A6 per A4 landscape: each row is one team's two copies. Sorted by room (order of salas
// in conteudo.yaml) and spot, like enunciados.pdf.
#import "comum.typ": *

#set page(paper: "a4", flipped: true, margin: 0pt)
#set text(font: "Poppins", fill: navy, lang: "pt")
#set par(spacing: 0pt)

#let paper = tiling(size: (5mm, 5mm))[
  #place(line(length: 5mm, stroke: 0.2pt + rgb("#e8edf4")))
  #place(line(length: 5mm, angle: 90deg, stroke: 0.2pt + rgb("#e8edf4")))
]

// Largest size up to max at which body fits in width
#let fit(body, width, max) = context {
  let size = calc.min(max, max * (width / measure(text(size: max, body)).width))
  text(size: size, body)
}

#let label(body) = text(size: 8pt, weight: "bold", tracking: 0.16em, fill: muted, upper(body))

// The room's grid with only this team's spot filled in, front at the top.
// Cells shrink for rooms with more rows or columns than fit.
#let mini_map(t, color) = {
  let sala = cfg.salas.at(t.local)
  let cell = calc.min(4.6mm, 30mm / sala.filas, 50mm / sala.colunas)
  let small(body) = text(size: 5pt, weight: "semibold", fill: muted, body)
  let cells = (none,) + range(sala.colunas).map(c => align(center + horizon, small(str(c + 1))))
  for fi in range(sala.filas) {
    cells.push(align(center + horizon, small(str(fi + 1))))
    for ci in range(sala.colunas) {
      let here = fi + 1 == t.fila and ci + 1 == t.coluna
      cells.push(align(center + horizon, rect(width: cell - 0.9mm, height: cell - 0.9mm, radius: 0.6mm, stroke: none,
        fill: if here { color } else { rgb("#e6eaf1") })))
    }
  }
  stack(spacing: 1.2mm,
    pad(left: 3mm, rect(width: cell * sala.colunas, height: 3.4mm, radius: 0.8mm, fill: rgb("#d5dbe5"), stroke: none,
      align(center + horizon, text(size: 6pt, weight: "bold", tracking: 0.16em, fill: muted)[ECRÃ]))),
    grid(columns: (3mm,) + (cell,) * sala.colunas, rows: (3mm,) + (cell,) * sala.filas, ..cells),
  )
}

// The full school name and team letter, kept 10 mm clear of the Equipa column: on one line if it fits at 14pt,
// otherwise broken after the kind of school ("Escola Secundária / Pedro Nunes · A")
#let school_width = 72mm
#let at14(body) = measure(text(size: 14pt, weight: "bold", body)).width
#let school_lines(t) = {
  let letter = if t.equipa != "" [ #text(fill: muted)[· #t.equipa]]
  let (kind, rest) = school_split(t.escola)
  if kind == none or at14([#t.escola#letter]) <= school_width { ([#t.escola#letter],) } else { ([#kind], [#rest#letter]) }
}
// One size on every sheet: 14pt, or what the longest line of any team needs to fit (call within context)
#let school_size() = calc.min(14pt, ..teams.map(t => 14pt * (school_width / calc.max(..school_lines(t).map(at14)))))

#let card(t) = {
  let c = cfg.categorias.at(t.categoria)
  let color = table_color(t)
  let ink = table_text(t)
  box(width: 148.5mm, height: 105mm, clip: true, {
    set text(top-edge: "cap-height", bottom-edge: "baseline")
    place(rect(width: 100%, height: 100%, fill: paper, stroke: none))
    place(rect(width: 100%, height: 13mm, fill: color, stroke: none, inset: (x: 8mm, y: 0mm), align(horizon, grid(
      columns: (1fr, auto),
      text(size: 8.5pt, weight: "bold", tracking: 0.16em, fill: ink)[NÁBOJ DE FÍSICA 2026 · #upper(c.titulo)],
      text(size: 15pt, weight: "extrabold", tracking: 0.12em, fill: ink)[MESA #t.mesa],
    ))))
    place(top + left, dx: 90mm, dy: 21mm, label[Equipa])
    place(top + left, dx: 90mm, dy: 27mm, box(width: 51mm, stack(spacing: 2.5mm,
      ..t.alunos.map(n => fit(text(weight: "medium", n), 51mm, 9.5pt)))))

    place(top + left, dx: 8mm, dy: 21mm, label[Código])
    place(top + left, dx: 7.5mm, dy: 26.5mm, text(size: 60pt, weight: "extrabold", fill: color, t.numero))
    place(top + left, dx: 8mm, dy: 48mm, box(width: 72mm, context {
      let size = school_size()
      set par(leading: size * 0.5)
      text(size: size, weight: "bold", school_lines(t).join(linebreak()))
    }))

    place(top + left, dx: 8mm, dy: 66mm, label[Lugar])
    place(top + left, dx: 8mm, dy: 71.5mm, text(size: 17pt, weight: "bold")[#cfg.locais.at(t.local) #text(fill: color)[· Mesa #t.mesa]])
    place(top + left, dx: 7.5mm, dy: 80mm, text(size: 34pt, weight: "extrabold", fill: color, spot_text(t)))
    place(top + left, dx: 8mm, dy: 94.5mm, text(size: 9.5pt, weight: "medium", fill: muted)[Fila #t.fila · Coluna #t.coluna])

    place(top + left, dx: 90mm, dy: 58mm, label[Sala · #cfg.locais.at(t.local)])
    place(top + left, dx: 89mm, dy: 62.5mm, mini_map(t, color))
  })
}

#let ordered = teams.sorted(key: t => pad4(cfg.salas.keys().position(k => k == t.local)) + pad4(t.fila) + pad4(t.coluna))

#for pair in ordered.chunks(2) {
  page({
    for (i, t) in pair.enumerate() {
      place(top + left, dy: 105mm * i, card(t))
      place(top + left, dx: 148.5mm, dy: 105mm * i, card(t))
    }
  })
}
