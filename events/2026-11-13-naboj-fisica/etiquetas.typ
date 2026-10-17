// Envelope stickers of Náboj de Física 2026: one per school, for the A4 envelopes the certificates are split into.
// Each lists the school's teams (category and letter) with their students, then its teachers, in the order
// certificados.pdf prints them, with each team's students. Merit certificates (premios.pdf) are printed at the end
// and don't go in. Label sheet in conteudo.yaml (etiquetas); default Avery L7165, 8 per A4.
#import "comum.typ": *

#let sheet = cfg.etiquetas
#let mm(n) = n * 1mm

#set page(paper: "a4", margin: 0pt)
#set text(font: "Poppins", fill: navy, lang: "pt")
#set par(spacing: 0pt)

// "SÉNIOR A" in the category's colour; "DOCENTES" outlined
#let tag(body, fill: none) = box(fill: fill, stroke: if fill == none { 0.5pt + navy } else { none }, radius: 0.8mm,
  inset: (x: 1.4mm, y: 1mm), text(size: 6.5pt, weight: "bold", tracking: 0.08em, fill: if fill == none { navy } else { white }, body))

#let sticker(envelope) = {
  let width = mm(sheet.largura) - 12mm
  {
    set text(top-edge: "cap-height", bottom-edge: "baseline")
    place(top + left, rect(width: 100%, height: 3mm, fill: blue, stroke: none))
    // School, then one row per team (tag, then its students) and one for the teachers
    place(top + left, dx: 6mm, dy: 6.8mm, box(width: width, {
      text(size: 6pt, weight: "bold", tracking: 0.16em, fill: muted)[NÁBOJ DE FÍSICA 2026 · CERTIFICADOS]
      v(3mm)
      // The short name ("ES Pedro Nunes") on one line, at 18pt or smaller if it doesn't fit, to spot at a distance
      context {
        let name = school_short(envelope.escola)
        let size = calc.min(18pt, 18pt * (width / measure(text(size: 18pt, weight: "extrabold", name)).width))
        text(size: size, weight: "extrabold", name)
      }
      v(4.2mm)
      set par(leading: 1.3mm)
      let rows = envelope.equipas.map(t => {
        let c = cfg.categorias.at(t.categoria)
        (tag(fill: rgb(c.cor), upper(c.titulo + if t.equipa != "" { " " + t.equipa } else { "" })), t.alunos.join(", "))
      })
      if envelope.docentes.len() > 0 {
        rows.push((tag(if envelope.docentes.len() > 1 [DOCENTES] else [DOCENTE]), envelope.docentes.join(", ")))
      }
      grid(columns: (17mm, 1fr), column-gutter: 2mm, row-gutter: 2.4mm,
        ..rows.map(((label, names)) => (label, pad(top: 0.9mm, text(size: 8pt, names)))).flatten())
    }))
  }
}

#label_sheets(sheet, envelopes, sticker)
