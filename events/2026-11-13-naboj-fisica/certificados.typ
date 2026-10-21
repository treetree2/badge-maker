// Participation certificates of Náboj de Física 2026 (input/equipas.csv), in envelope order (etiquetas.pdf):
// school by school, one per student team by team, then one per accompanying teacher naming all their teams.
#import "certificado.typ": *

#for envelope in envelopes {
  for t in envelope.equipas {
    for aluno in t.alunos { student_certificate(aluno, t) }
  }
  for name in envelope.docentes { teacher_certificate(name) }
}
