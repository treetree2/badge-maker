// Certificate page shared by certificados.typ, premios.typ and amostras.typ. Four designs, picked by `design` in
// conteudo.yaml (certificados) or `--input design=…`:
//   grelha      the look of the badges (outer.html): graph paper, a coloured band with faint physics equations, the
//               Náboj Physics · 13 NOV lockup and the partner logos
//   campo       a classic framed diploma over the field lines of a dipole ("náboj" is Slovak for charge), as in
//               banner design 02; the lines come from t2-design (campaigns/2026-11-13-naboj-fisica/certificados)
//   lateral     a full-height band in the accent colour with the lockup, the text left-aligned beside it
//   trajetoria  a projectile's parabola arching over the text on warm paper, as in banner design 04
// Every design has the same variants, by accent colour: students (blue), teachers (navy) and the medals (premios).
#import "comum.typ": *

#let cert = cfg.certificados
#let designs = ("grelha", "campo", "lateral", "trajetoria")
#let default_design = sys.inputs.at("design", default: cert.at("design", default: "grelha"))
#if default_design not in designs { panic("design desconhecido \"" + default_design + "\" (designs: " + designs.join(", ") + ")") }

#let paper = tiling(size: (10mm, 10mm), {
  for i in range(5) {
    place(dx: 2mm * i, line(length: 10mm, angle: 90deg, stroke: 0.12mm + rgb("#edf1f7")))
    place(dy: 2mm * i, line(length: 10mm, stroke: 0.12mm + rgb("#edf1f7")))
  }
  place(line(length: 10mm, angle: 90deg, stroke: 0.2mm + rgb("#d7e0ec")))
  place(line(length: 10mm, stroke: 0.2mm + rgb("#d7e0ec")))
})

#let equations = ("F = ma", "E = mc²", "E = hν", "λ = h/p", "PV = nRT", "V = RI", "ΔS ≥ 0", "T = 2π√(L/g)",
  "x = x₀ + v₀t + ½at²", "F = kq₁q₂/r²", "Δx Δp ≥ ħ/2", "∇·E = ρ/ε₀", "p = mv", "W = F·d", "n₁ sin θ₁ = n₂ sin θ₂",
  "a = v²/r", "F = −kx", "E = ½mv²")

// A band in color with the equations of the role bands, faint, in rows offset from each other
#let band(height, color, ink) = box(width: 100%, height: height, fill: color, clip: true, {
  set text(font: "STIX Two Text", style: "italic", size: 10pt, fill: ink.transparentize(87%), top-edge: "cap-height", bottom-edge: "baseline")
  for row in range(calc.ceil(height / 5.4mm)) {
    let start = calc.rem(row * 5, equations.len())
    place(top + left, dx: if calc.odd(row) { -9mm } else { 2mm }, dy: 1.6mm + row * 5.4mm,
      box(width: 900mm, (equations.slice(start) + equations.slice(0, start)).join(h(7mm))))
  }
})

#let signature(s) = box(width: 64mm, {
  set align(center)
  line(length: 100%, stroke: 0.4pt + navy)
  v(2.6mm)
  if s.nome != "" { text(size: 11pt, weight: "semibold", s.nome); v(2.4mm) }
  text(size: 10.5pt, weight: "medium", s.cargo)
})
#let signatures(gap: 26mm) = cert.assinaturas.map(signature).join(h(gap))

// "a, b e c"
#let and_list(items) = if items.len() < 2 { items.join() } else { items.slice(0, -1).join(", ") + " e " + items.last() }

// A one-colour SVG (no fills of its own, like the Náboj and TreeTree2 logos) in another colour
#let tinted(path, color, ..args) = image(bytes(read(path).replace("<svg ", "<svg fill=\"" + color.to-hex() + "\" ", count: 1)), ..args)

// The partner logos; a grid centres each logo vertically (inline images would share a baseline, leaving the wordmark low)
#let logos(scale: 1, gutter: 18mm) = grid(
  columns: 3, column-gutter: gutter, align: horizon,
  image("assets/treetree2-logo-black.svg", height: 5.6mm * scale),
  image("assets/df-tecnico.png", height: 14mm * scale),
  image("assets/trojsten-logo-blue.svg", height: 14mm * scale),
)

// "13 NOV" over "NÁBOJ DE FÍSICA 2026", the date half of the lockup
#let date_lockup(date: blue, label: navy, size: 25pt, label_size: none) = {
  set text(top-edge: "cap-height", bottom-edge: "baseline")
  text(size: size, weight: "extrabold", fill: date)[13 NOV]
  v(size * 0.32)
  text(size: if label_size == none { size * 0.38 } else { label_size }, weight: "bold", tracking: 0.12em, fill: label, upper(cert.evento))
}

// "CERTIFICADO DE PARTICIPAÇÃO", small and spaced, with a short rule in the accent colour
#let kicker(kind, accent, rule: true) = {
  set text(top-edge: "cap-height", bottom-edge: "baseline")
  text(size: 10pt, weight: "bold", tracking: 0.28em, fill: navy, upper("Certificado de " + kind))
  if rule { v(4mm); box(width: 18mm, height: 1.2mm, fill: accent) }
}

// Body centred between the lockup and a little above the signatures, which sit as low as they go, just above the
// logo strip, leaving room to sign
#let grelha(accent, ink, kind, body) = {
  place(rect(width: 100%, height: 100%, fill: rgb("#fbfcfe"), stroke: none))
  place(rect(width: 100%, height: 100%, fill: paper, stroke: none))
  // White strips under the lockup and the logos, so the graph paper doesn't run through them
  place(top + left, dy: 16mm, rect(width: 100%, height: 26mm, fill: white, stroke: (bottom: 0.3mm + rgb("#d7e0ec"))))
  place(top + left, dy: 179mm, rect(width: 100%, height: 23mm, fill: white, stroke: (top: 0.3mm + rgb("#d7e0ec"))))
  place(top + left, band(16mm, accent, ink))
  place(bottom + left, band(8mm, accent, ink))

  place(top + left, dx: 24mm, dy: 21.5mm, image("assets/naboj-physics.svg", height: 15mm))
  place(top + right, dx: -24mm, dy: 22.5mm, align(right, date_lockup()))

  place(top + left, dy: 44mm, box(width: 100%, height: 108mm, align(center + horizon, box(width: 250mm, body))))

  place(top + left, dy: 168mm, box(width: 100%, align(center, signatures())))
  place(top + left, dy: 183.5mm, box(width: 100%, height: 15mm, align(center + horizon, logos())))
}

// Charges of the dipole, at the positions of CHARGES in render-campo.mjs (mm)
#let charge(x, y, fill, sign, ink) = place(top + left, dx: x * 1mm - 3.4mm, dy: y * 1mm - 3.4mm,
  circle(radius: 3.4mm, fill: fill, stroke: 1.2mm + white,
    align(center + horizon, text(size: 13pt, weight: "semibold", fill: ink, top-edge: "x-height", bottom-edge: "baseline", sign))))

// A double rule inside the page edge, with the field lines running inside it and fading behind the text
#let campo(accent, ink, kind, body) = {
  let lines = read("assets/campo.svg").replace("stroke=\"#000000\"", "stroke=\"" + accent.to-hex() + "\" stroke-opacity=\"0.34\"")
  place(rect(width: 100%, height: 100%, fill: white, stroke: none))
  place(top + left, dx: 12mm, dy: 12mm, box(width: 273mm, height: 186mm, clip: true,
    place(top + left, dx: -12mm, dy: -12mm, image(bytes(lines), width: 297mm, height: 210mm))))
  place(top + left, dx: 12mm, dy: 12mm, rect(width: 273mm, height: 186mm, stroke: none,
    fill: gradient.radial((white, 0%), (white, 46%), (white.transparentize(100%), 100%))))
  charge(34, 178, accent, "+", ink)
  charge(263, 32, navy, "−", white)
  place(top + left, dx: 8mm, dy: 8mm, rect(width: 281mm, height: 194mm, stroke: 1.6pt + accent))
  place(top + left, dx: 12mm, dy: 12mm, rect(width: 273mm, height: 186mm, stroke: 0.4pt + navy.transparentize(55%)))

  place(top + center, dy: 21mm, image("assets/naboj-physics.svg", height: 15mm))
  place(top + center, dy: 42mm, align(center, kicker(kind, accent)))
  place(top + left, dy: 54mm, box(width: 100%, height: 100mm, align(center + horizon, box(width: 240mm, body))))
  place(top + left, dy: 162mm, box(width: 100%, align(center, signatures())))
  place(top + left, dy: 180.5mm, box(width: 100%, height: 12mm, align(center + horizon, logos(scale: 0.8, gutter: 16mm))))
}

// The lockup in a full-height band of the accent colour; on the rest of the page the text and the logos, flush left.
// No signature line
#let lateral(accent, ink, kind, body) = {
  let side = 64mm
  let x = side + 18mm
  let column = 297mm - x - 20mm
  place(rect(width: 100%, height: 100%, fill: white, stroke: none))
  place(top + left, box(width: side, band(210mm, accent, ink)))
  place(top + left, dx: side, rect(width: 1.4mm, height: 100%, fill: navy.transparentize(if accent == navy { 100% } else { 0% })))
  place(top + left, dx: 12mm, dy: 22mm, tinted("assets/naboj-physics.svg", ink, width: side - 24mm))
  place(bottom + left, dx: 12mm, dy: -24mm, {
    date_lockup(date: ink, label: ink, size: 32pt, label_size: 9.5pt)
  })

  place(top + left, dx: x, dy: 26mm, kicker(kind, accent))
  place(top + left, dx: x, dy: 36mm, box(width: column, height: 136mm, align(left + horizon, body)))
  place(top + left, dx: x, dy: 181mm, line(length: column, stroke: 0.3mm + rgb("#d7e0ec")))
  place(top + left, dx: x, dy: 188mm, box(width: column, height: 14mm, align(left + horizon, logos(scale: 0.85, gutter: 18mm))))
}

// An arrow from (x, y) by (dx, dy), in mm
#let arrow(x, y, dx, dy, color, width: 0.9pt) = {
  let len = calc.sqrt(dx * dx + dy * dy)
  let (ux, uy) = (dx / len, dy / len)
  let (hx, hy) = (x + dx, y + dy)
  place(top + left, line(start: (x * 1mm, y * 1mm), end: ((hx - 1.6 * ux) * 1mm, (hy - 1.6 * uy) * 1mm), stroke: width + color))
  place(top + left, polygon(fill: color, stroke: none,
    (hx * 1mm, hy * 1mm),
    ((hx - 2.6 * ux - 1.2 * uy) * 1mm, (hy - 2.6 * uy + 1.2 * ux) * 1mm),
    ((hx - 2.6 * ux + 1.2 * uy) * 1mm, (hy - 2.6 * uy - 1.2 * ux) * 1mm)))
}

// The parabola y = top + k (x − 148.5)² (mm), launched and landing off the page, with strobe dots at equal times,
// a few velocity vectors along it and g at the top
#let trajetoria(accent, ink, kind, body) = {
  let (top_y, k) = (34, 0.0038)
  let y(x) = top_y + k * calc.pow(x - 148.5, 2)
  place(rect(width: 100%, height: 100%, fill: rgb("#fbfaf6"), stroke: none))
  place(top + left, curve(stroke: (paint: muted.transparentize(35%), thickness: 0.6pt, dash: (0.1pt, 2.4pt), cap: "round"),
    curve.move((0mm, y(0) * 1mm)),
    ..range(1, 298).map(x => curve.line((x * 1mm, y(x) * 1mm)))))
  for i in range(-6, 7) {
    let x = 148.5 + 21.5 * i
    place(top + left, dx: x * 1mm - 1.7mm, dy: y(x) * 1mm - 1.7mm,
      circle(radius: 1.7mm, fill: if i == 0 { accent } else { navy.transparentize(if calc.abs(i) > 3 { 10% } else { 0% }) }, stroke: none))
    // Velocity: constant across, 2k (x − 148.5) times that up or down
    if calc.abs(i) in (2, 5) {
      let vx = 9
      arrow(x, y(x), vx, vx * 2 * k * (x - 148.5), accent)
    }
  }
  arrow(148.5, top_y + 2.6, 0, 10, navy, width: 0.7pt)
  place(top + left, dx: 151.5mm, dy: top_y * 1mm + 8mm, text(font: "STIX Two Text", style: "italic", size: 11pt, fill: navy)[g])
  place(top + left, dx: 156mm, dy: top_y * 1mm - 8mm,
    text(font: "STIX Two Text", style: "italic", size: 10pt, fill: muted)[y = v#sub[0]t − ½gt²])
  place(top + left, dx: 20mm, dy: 176mm, line(length: 257mm, stroke: 0.6pt + navy))

  place(top + left, dx: 22mm, dy: 20mm, image("assets/naboj-physics.svg", height: 14mm))
  place(top + right, dx: -22mm, dy: 21mm, align(right, date_lockup(date: accent, size: 22pt)))
  // The winners' certificates have their place on top instead, and need the room
  if kind == "mérito" {
    place(top + left, dy: 52mm, box(width: 100%, height: 104mm, align(center + horizon, box(width: 240mm, body))))
  } else {
    place(top + center, dy: 58mm, kicker(kind, accent, rule: false))
    place(top + left, dy: 66mm, box(width: 100%, height: 90mm, align(center + horizon, box(width: 240mm, body))))
  }
  place(top + left, dy: 160mm, box(width: 100%, align(center, signatures(gap: 34mm))))
  place(top + left, dy: 181mm, box(width: 100%, height: 14mm, align(center + horizon, logos(scale: 0.85))))
}

// One A4 landscape certificate. kind names it on the designs that say what it is: "participação" or "mérito"
#let certificate(accent: blue, ink: white, kind: "participação", design: default_design, body) = page(paper: "a4", flipped: true, margin: 0pt, {
  set text(font: "Poppins", fill: navy, lang: "pt")
  set par(spacing: 0pt)
  (grelha: grelha, campo: campo, lateral: lateral, trajetoria: trajetoria).at(design)(accent, ink, kind, body)
})

// No line breaks inside "2.ª edição", "1.º lugar", "três equipas" or "13 de novembro de 2026": non-breaking spaces
// after a number (or a number word) and around the "de" of a date
#let months = "janeiro|fevereiro|março|abril|maio|junho|julho|agosto|setembro|outubro|novembro|dezembro"
#let glue(s) = {
  s
    .replace(regex("(\\d+(\\.[ºª])?|uma|duas|três|quatro|cinco|seis|sete|oito|nove) "), m => m.captures.first() + "\u{a0}")
    .replace(regex("[ \u{a0}]de (" + months + "|\\d{4})"), m => "\u{a0}de\u{a0}" + m.captures.first())
}

// The students' and teachers' certificates on the lateral design: "Certificamos que", the name and one sentence
// (statement), then where and when it was signed; the winners' have their place on top. Two sizes: 22pt for the
// place and the name, 14pt for the rest.
#let lateral_statement(name, statement, highlight: none) = {
  set text(size: 14pt, top-edge: "cap-height", bottom-edge: "baseline")
  set par(leading: 0.85em, justify: false)
  if highlight != none { highlight; v(8mm) }
  text(weight: "medium")[Certificamos que]
  v(8mm)
  layout(room => {
    let size = calc.min(22pt, 22pt * (room.width * 1.8 / measure(text(size: 22pt, weight: "extrabold", name)).width))
    block(width: 100%, { set par(leading: 0.45em); text(size: size, weight: "extrabold", name) })
  })
  v(9mm)
  block({ set par(justify: true); set text(hyphenate: false); statement })
  v(7mm)
  glue(cert.assinado)
}

// "na 2.ª edição … — organizada … — que teve lugar na sexta-feira, …, no Instituto Superior Técnico, em Lisboa"
#let lateral_event = [na #glue(cert.edicao) — #cert.organizacao — que teve lugar #glue(cert.quando), no #cert.local]

// The parts every certificate shares: an optional highlight (the place, on premios.pdf), "Certifica-se que", the
// name, then three lines: the sentence up to the school ("… da equipa Júnior do"), the school alone (never split),
// and the event, when and where. Fills the width it is given; long names shrink to fit it. Not on the lateral design,
// which has its own (lateral_statement).
#let content(name, lead, school, highlight: none) = {
  set text(top-edge: "cap-height", bottom-edge: "baseline")
  if highlight != none { highlight; v(12mm) }
  text(size: 16pt, weight: "medium")[Certifica-se que]
  v(10mm)
  layout(room => {
    let size = calc.min(50pt, 50pt * (room.width * 0.92 / measure(text(size: 50pt, weight: "extrabold", name)).width))
    text(size: size, weight: "extrabold", name)
  })
  v(13mm)
  block(width: 100%, {
    set text(size: 16pt, top-edge: "ascender", bottom-edge: "descender")
    set par(leading: 0.8em, justify: false)
    lead
    linebreak()
    box(text(size: 18pt, weight: "bold", school))
  })
  v(8mm)
  text(size: 16pt)[no #cert.evento, a #cert.data, no #cert.local.]
}

// "da Escola …", "do Colégio …"
#let of_school(name) = if ("Escola", "Academia", "Cooperativa").any(w => name.starts-with(w)) { "da" } else { "do" }
// "equipa Sénior A": category and letter, no team code
#let team(t, with_category: true) = "equipa" + (if with_category { " " + category(t) } else { "" }) + (if t.equipa != "" { " " + t.equipa } else { "" })

// The certificates themselves, one page each

#let student_certificate(aluno, t, design: default_design) = if design == "lateral" {
  certificate(design: design, lateral_statement(aluno, [participou, em representação #of_school(t.escola) *#t.escola*,
    #lateral_event, tendo competido no Escalão~#category(t), pelo que lhe é atribuído o presente *CERTIFICADO*.]))
} else {
  certificate(design: design, content(aluno,
    [participou como membro da #team(t) #of_school(t.escola)], t.escola))
}

#let teacher_certificate(name, design: default_design) = {
  let accompanied = teachers.at(name)
  // "as equipas Sénior A, B e C da" + "Escola …"; teams from several schools are named on the school line
  let label(here) = {
    let labels = here.map(category).dedup().map(c => {
      let letters = here.filter(t => category(t) == c and t.equipa != "").map(t => t.equipa)
      if letters.len() == 0 { c } else { c + " " + and_list(letters) }
    })
    (if here.len() == 1 { "a equipa " } else { "as equipas " }) + and_list(labels)
  }
  let schools = accompanied.map(t => t.escola).dedup()
  let lead = [acompanhou, na qualidade de docente,]
  if design == "lateral" {
    // "uma equipa participante", "duas equipas participantes"…; several schools: "da Escola X e do Colégio Y"
    let n = accompanied.len()
    let teams_text = if n == 1 { "uma equipa participante" } else {
      ("duas", "três", "quatro", "cinco", "seis", "sete", "oito", "nove").at(n - 2, default: str(n)) + " equipas participantes"
    }
    certificate(accent: navy, design: design, lateral_statement(name, [acompanhou, em representação
      #and_list(schools.map(s => [#of_school(s) *#s*])), #glue(teams_text) #lateral_event, pelo que lhe é atribuído o
      presente *CERTIFICADO*.]))
  } else if schools.len() == 1 {
    certificate(accent: navy, design: design, content(name,
      [#lead #label(accompanied) #of_school(schools.first())], schools.first()))
  } else {
    certificate(accent: navy, design: design, content(name, lead,
      and_list(schools.map(s => label(accompanied.filter(t => t.escola == s)) + " " + of_school(s) + " " + s))))
  }
}

// Medal colour and the text on it, by place
#let medals = (
  "1": (rgb("#d4af37"), navy),
  "2": (rgb("#9aa4b1"), navy),
  "3": (rgb("#b8733a"), white),
)

// Places are of the Portuguese ranking: "1.º lugar · Júnior" on top, "1.º lugar em Portugal" in the text
#let winner_certificate(aluno, t, design: default_design) = {
  let (medal, ink) = medals.at(t.classificacao)
  let place_text = t.classificacao + ".º lugar"
  if design == "lateral" {
    certificate(accent: medal, ink: ink, kind: "mérito", design: design, lateral_statement(aluno,
      highlight: text(size: 22pt, weight: "extrabold", fill: medal)[#place_text · #category(t)],
      [participou, em representação #of_school(t.escola) *#t.escola*, #lateral_event, tendo obtido o *#glue(place_text) em
      Portugal no Escalão~#category(t)*, pelo que lhe é atribuído o presente *CERTIFICADO*.]))
  } else {
    certificate(accent: medal, ink: ink, kind: "mérito", design: design, content(aluno,
      highlight: text(size: 34pt, weight: "extrabold", fill: medal)[#place_text · #category(t)],
      [obteve o #place_text em Portugal na categoria #category(t) como membro da #team(t, with_category: false) #of_school(t.escola)], t.escola))
  }
}
