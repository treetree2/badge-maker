// Table papers of Náboj de Física 2026: one A4 sheet per place at a table (everyone in the list with a table),
// saying the role, the table and the venue; árbitros also get their problems. Sorted by venue, table and role.
#import "comum.typ": *

#set page(paper: "a4", flipped: true, margin: 0pt)
#set text(font: "Poppins", fill: navy, lang: "pt")
#set par(spacing: 0pt)

#let paper = tiling(size: (5mm, 5mm))[
  #place(line(length: 5mm, stroke: 0.25pt + rgb("#e3e9f2")))
  #place(line(length: 5mm, angle: 90deg, stroke: 0.25pt + rgb("#e3e9f2")))
]

// Largest size up to max at which body fits in width
#let fit(body, width, max) = context {
  let size = calc.min(max, max * (width / measure(text(size: max, body)).width))
  text(size: size, body)
}

// The sheet is pasted on the front of the table and the top may be hidden, so the coloured bar is this much
// taller (from the top edge) and everything else sits this much lower
#let offset = 30mm

#let sheet(p) = {
  let f = cfg.funcoes.at(p.funcao)
  let color = rgb(f.cor)
  set text(top-edge: "cap-height", bottom-edge: "baseline")
  place(rect(width: 100%, height: 100%, fill: paper, stroke: none))
  place(top + left, rect(width: 100%, height: offset + 18mm, fill: color, stroke: none,
    pad(x: 20mm, bottom: 7mm, align(bottom, text(size: 11pt, weight: "bold", tracking: 0.16em, fill: rgb(f.texto))[NÁBOJ DE FÍSICA 2026 · 13 NOV]))))
  place(top + left, dx: 20mm, dy: offset + 32mm, box(width: 257mm, align(center,
    fit(text(weight: "extrabold", fill: color, upper(f.titulo)), 257mm, 96pt))))
  place(top + left, dx: 20mm, dy: offset + 70mm, box(width: 257mm, align(center,
    text(size: 44pt, weight: "bold")[Mesa #p.mesa #text(fill: muted)[·] #cfg.locais.at(p.local)])))
  if is_arbiter(p) {
    place(top + left, dx: 23.5mm, dy: offset + 92mm, box(width: 250mm, height: 56mm, stroke: 1.4mm + color, radius: 5mm,
      align(center + horizon, stack(spacing: 8mm,
        text(size: 42pt, weight: "extrabold", fill: color, problems_text(p)),
        if p.problemas != "" {
          text(size: 20pt, weight: "semibold")[os números com resto #calc.rem(int(p.problemas), 3) na divisão por 3]
        },
      ))))
  }
  place(bottom + right, dx: -14mm, dy: -7mm, image("assets/naboj-physics.svg", height: 11mm))
}

#let seated = people.filter(p => p.mesa != "").sorted(key: p => p.local + mesa_key(p.mesa) + role_index(p) + p.problemas + p.nome)

#for p in seated { page(sheet(p)) }
