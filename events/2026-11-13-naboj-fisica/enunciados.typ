// Labels for the small envelopes with each team's starting problems, left on the team's table: the spot
// (row × column) in large type with a mini map of the room, the room and jury table in the table's colour (as on
// equipas.pdf), and the team's code and school to check against the team sheet. Same order as equipas.pdf: by room, row and column,
// each room starting on a new sheet so it can go to the people distributing there.
// Label sheet in conteudo.yaml (etiquetas_enunciados); default Avery L7160, 21 per A4.
#import "comum.typ": *

#let sheet = cfg.etiquetas_enunciados

#set text(font: "Poppins", fill: navy, lang: "pt")
#set par(spacing: 0pt)

// Largest size up to max at which body fits in width
#let fit(body, width, max) = context {
  let size = calc.min(max, max * (width / measure(text(size: max, body)).width))
  text(size: size, body)
}

// The room's grid with this team's spot filled in, screen at the top (no numbers: too small to read)
#let mini_map(t, color) = {
  let sala = cfg.salas.at(t.local)
  let cell = 2.25mm
  stack(spacing: 0.8mm,
    rect(width: cell * sala.colunas, height: 2.2mm, radius: 0.5mm, fill: rgb("#d5dbe5"), stroke: none,
      align(center + horizon, text(size: 4pt, weight: "bold", tracking: 0.14em, fill: muted)[ECRÃ])),
    grid(columns: (cell,) * sala.colunas, rows: (cell,) * sala.filas,
      ..range(sala.filas * sala.colunas).map(i => {
        let here = calc.div-euclid(i, sala.colunas) + 1 == t.fila and calc.rem(i, sala.colunas) + 1 == t.coluna
        align(center + horizon, rect(width: cell - 0.5mm, height: cell - 0.5mm, radius: 0.3mm, stroke: none,
          fill: if here { color } else { rgb("#e3e8ef") }))
      })),
  )
}

#let label(t) = {
  let color = table_color(t)
  let ink = table_text(t)
  set text(top-edge: "cap-height", bottom-edge: "baseline")
  place(top + left, rect(width: 100%, height: 7.5mm, fill: color, stroke: none, inset: (x: 4mm, y: 0mm), align(horizon, grid(
    columns: (1fr, auto),
    text(size: 9pt, weight: "extrabold", tracking: 0.06em, fill: ink, upper(cfg.locais.at(t.local))),
    text(size: 9pt, weight: "extrabold", tracking: 0.1em, fill: ink)[MESA #t.mesa],
  ))))
  // Spot on the left, mini map on the right, team code and school below
  place(top + left, dx: 4mm, dy: 11.5mm, box(width: 31mm, align(center,
    fit(text(weight: "extrabold", fill: color, spot_text(t)), 31mm, 30pt))))
  place(top + left, dx: 4mm, dy: 22.5mm, box(width: 31mm, align(center,
    text(size: 5.5pt, weight: "medium", fill: muted)[FILA #t.fila · COLUNA #t.coluna])))
  place(top + right, dx: -4mm, dy: 9.5mm, mini_map(t, color))
  place(top + left, dx: 4mm, dy: 30mm, box(width: sheet.largura * 1mm - 8mm, align(center,
    fit([#text(weight: "extrabold", fill: color, t.numero) #h(0.15em) #text(size: 0.62em, weight: "semibold")[#school_short(t.escola)#if t.equipa != "" [ #t.equipa]]],
      sheet.largura * 1mm - 8mm, 12pt))))
}

#for local in cfg.salas.keys() {
  label_sheets(sheet, teams.filter(t => t.local == local).sorted(key: t => pad4(t.fila) + pad4(t.coluna)), label)
}
