// Participation certificates of Náboj de Física 2026 (input/equipas.csv), in envelope order (etiquetas.pdf):
// school by school, one per student team by team, then one per accompanying teacher naming all their teams.
#import "certificado.typ": *

#let teacher_certificate(name) = {
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
  if schools.len() == 1 {
    certificate(accent: navy, content([Certificado de participação], name,
      [#lead #label(accompanied) #of_school(schools.first())], schools.first()))
  } else {
    certificate(accent: navy, content([Certificado de participação], name, lead,
      and_list(schools.map(s => label(accompanied.filter(t => t.escola == s)) + " " + of_school(s) + " " + s))))
  }
}

#for envelope in envelopes {
  for t in envelope.equipas {
    for aluno in t.alunos {
      certificate(content([Certificado de participação], aluno,
        [participou como membro da #team(t) #of_school(t.escola)], t.escola))
    }
  }
  for name in envelope.docentes { teacher_certificate(name) }
}
