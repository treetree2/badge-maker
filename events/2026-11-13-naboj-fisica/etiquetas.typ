// Envelope stickers of Náboj de Física 2026: one per school, for the A4 envelopes the certificates are split into.
// Each lists the school's teams (category and letter) on one line, then its teachers, in the order
// certificados.pdf prints them. Merit certificates (premios.pdf) are printed at the end
// and don't go in. Label sheet in conteudo.yaml (etiquetas); default Avery L7165, 8 per A4.
#import "comum.typ": *

#let sheet = cfg.etiquetas
#let mm(n) = n * 1mm

#set page(paper: "a4", margin: 0pt)
#set text(font: "Poppins", fill: navy, lang: "pt")
#set par(spacing: 0pt)

// "SÉNIOR A" in the category's colour; "DOCENTES" outlined
#let tag(body, fill: none) = box(fill: fill, stroke: if fill == none { 0.5pt + navy } else { none }, radius: 0.8mm,
  inset: (x: 1.8mm, y: 1.4mm), text(size: 9pt, weight: "bold", tracking: 0.08em, fill: if fill == none { navy } else { white }, body))

#let sticker(envelope) = {
  let width = mm(sheet.largura) - 12mm
  {
    set text(top-edge: "cap-height", bottom-edge: "baseline")
    place(top + left, rect(width: 100%, height: 3mm, fill: blue, stroke: none))
    // School, then its teams' tags on one line, then the teachers
    place(top + left, dx: 6mm, dy: 6.8mm, box(width: width, {
      text(size: 6pt, weight: "bold", tracking: 0.16em, fill: muted)[NÁBOJ DE FÍSICA 2026 · CERTIFICADOS]
      v(3mm)
      // The full name at 22pt, to spot at a distance: on one line if it fits, otherwise broken after the kind of
      // school ("Escola Secundária / Pedro Nunes"); a name still too long wraps onto a third line
      context {
        let (kind, rest) = school_split(envelope.escola)
        let one_line = kind == none or measure(text(size: 22pt, weight: "extrabold", envelope.escola)).width <= width
        set par(leading: 22pt * 0.45)
        text(size: 22pt, weight: "extrabold", if one_line { envelope.escola } else [#kind\ #rest])
      }
      v(4.2mm)
      set par(leading: 1.3mm)
      // The teams side by side, each tag with its team code centred below it
      let teams = envelope.equipas
      grid(columns: teams.len(), column-gutter: 2mm, row-gutter: 2.2mm, align: center,
        ..teams.map(t => {
          let c = cfg.categorias.at(t.categoria)
          tag(fill: rgb(c.cor), upper(c.titulo + if t.equipa != "" { " " + t.equipa } else { "" }))
        }),
        ..teams.map(t => text(size: 10pt, weight: "bold", t.numero)))
      if envelope.docentes.len() > 0 {
        v(4mm)
        grid(columns: (auto, 1fr), column-gutter: 2.4mm,
          tag(if envelope.docentes.len() > 1 [DOCENTES] else [DOCENTE]),
          // Each name kept whole, so a long pair breaks between the teachers
          pad(top: 0.9mm, { set par(leading: 2.2mm); text(size: 12pt, weight: "semibold", envelope.docentes.map(box).join([, ])) }))
      }
    }))
  }
}

#label_sheets(sheet, envelopes, sticker)
