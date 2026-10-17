// Certificate page shared by certificados.typ and premios.typ, in the look of the badges (outer.html):
// graph paper, a coloured band with faint physics equations, the Náboj Physics · 13 NOV lockup and the partner logos.
#import "comum.typ": *

#let cert = cfg.certificados

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

// "a, b e c"
#let and_list(items) = if items.len() < 2 { items.join() } else { items.slice(0, -1).join(", ") + " e " + items.last() }

// One A4 landscape certificate; body is centred between the lockup and the signatures
#let certificate(accent: blue, ink: white, body) = page(paper: "a4", flipped: true, margin: 0pt, {
  set text(font: "Poppins", fill: navy, lang: "pt")
  set par(spacing: 0pt)
  place(rect(width: 100%, height: 100%, fill: rgb("#fbfcfe"), stroke: none))
  place(rect(width: 100%, height: 100%, fill: paper, stroke: none))
  // White strips under the lockup and the logos, so the graph paper doesn't run through them
  place(top + left, dy: 16mm, rect(width: 100%, height: 36mm, fill: white, stroke: (bottom: 0.3mm + rgb("#d7e0ec"))))
  place(top + left, dy: 179mm, rect(width: 100%, height: 23mm, fill: white, stroke: (top: 0.3mm + rgb("#d7e0ec"))))
  place(top + left, band(16mm, accent, ink))
  place(bottom + left, band(8mm, accent, ink))

  place(top + left, dx: 24mm, dy: 25mm, image("assets/naboj-physics.svg", height: 21mm))
  place(top + right, dx: -24mm, dy: 27mm, align(right, {
    set text(top-edge: "cap-height", bottom-edge: "baseline")
    text(size: 32pt, weight: "extrabold", fill: blue)[13 NOV]
    v(3.4mm)
    text(size: 9.5pt, weight: "bold", tracking: 0.12em, upper(cert.evento))
  }))

  place(top + left, dy: 54mm, box(width: 100%, height: 104mm, align(center + horizon, box(width: 250mm, body))))

  place(top + left, dy: 164mm, box(width: 100%, align(center, cert.assinaturas.map(signature).join(h(26mm)))))
  // A grid centres each logo vertically (inline images would share a baseline, leaving the wordmark low)
  place(top + left, dy: 183.5mm, box(width: 100%, height: 15mm, align(center + horizon, grid(
    columns: 3, column-gutter: 18mm, align: horizon,
    image("assets/treetree2-logo-black.svg", height: 5.6mm),
    image("assets/df-tecnico.png", height: 14mm),
    image("assets/trojsten-logo-blue.svg", height: 14mm),
  ))))
})

// The parts every certificate shares: kind, "Certifica-se que", the name, then three lines: the sentence up to
// the school ("… da equipa Júnior do"), the school alone (never split), and the event, when and where
#let content(kind, name, lead, school, highlight: none) = {
  set text(top-edge: "cap-height", bottom-edge: "baseline")
  text(size: 12pt, weight: "bold", tracking: 0.22em, fill: muted, upper(kind))
  if highlight != none { v(7mm); highlight }
  v(10mm)
  text(size: 16pt, weight: "medium")[Certifica-se que]
  v(8mm)
  context {
    let size = calc.min(50pt, 50pt * (230mm / measure(text(size: 50pt, weight: "extrabold", name)).width))
    text(size: size, weight: "extrabold", name)
  }
  v(10mm)
  block(width: 250mm, {
    set text(size: 16pt, top-edge: "ascender", bottom-edge: "descender")
    set par(leading: 0.55em, justify: false)
    lead
    linebreak()
    box(text(size: 18pt, weight: "bold", school))
  })
  v(6mm)
  text(size: 14pt)[no #cert.evento, a #cert.data, no #cert.local.]
}

// "da Escola …", "do Colégio …"
#let of_school(name) = if ("Escola", "Academia", "Cooperativa").any(w => name.starts-with(w)) { "da" } else { "do" }
// "equipa Sénior A": category and letter, no team code
#let team(t, with_category: true) = "equipa" + (if with_category { " " + category(t) } else { "" }) + (if t.equipa != "" { " " + t.equipa } else { "" })
