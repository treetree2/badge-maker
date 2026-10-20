# Badge Maker

Scripts para gerar os badges (e outros materiais impressos) dos eventos da TreeTree2, com [Typst](https://typst.app).

## Instalação

Requer Typst e `make`. Em mac/linux, `make` já existe; em Windows, usa o WSL (ou faz à mão o que o `Makefile` faz: são só chamadas a `typst compile`).

## Estrutura

Cada evento tem a sua pasta em `events/`:

```
events/<evento>/
  event.mk       definições do evento (fonte, cor, ou templates próprios)
  background/    fundos dos badges, um PDF por categoria
  input/         listas de pessoas (CSV)
  fonts/         fontes usadas sem precisar de as instalar (opcional)
  output/        PDFs gerados
```

Na raiz ficam as partes comuns: o `Makefile` e o template genérico `badge_maker.typ`.

## Utilização

```
make                                  # lista os eventos
make EVENT=events/<evento>            # gera tudo
make EVENT=events/<evento> <categoria>  # só uma categoria (template genérico)
```

## Template genérico (`badge_maker.typ`)

- As categorias são os ficheiros `background/x.pdf`; o `input/x.csv` tem as pessoas dessa categoria e gera `output/x-badges.pdf`.
- Os CSV têm `first_name` e `last_name`, ou só uma coluna `name` com o nome completo (usa a primeira e a última palavra, ex.: "Ana Sofia Sousa" → Ana / Sousa). Outras colunas são ignoradas.
- Cada folha A4 tem duas pessoas, a de baixo virada ao contrário, e os fundos têm de seguir esse formato (vê os da EAM). Os nomes ficam por volta dos 62,5–86 mm de cada metade; mantém essa zona livre no fundo, ou ajusta o `badge_maker.typ`.
- Se existir `background/x-back.pdf`, cada folha é seguida do seu verso, para imprimir frente e verso (virar pelo lado maior).
- No `event.mk`: `FONT`, `WEIGHT` e `COLOR` dos nomes.

Um evento pode também ter templates próprios: no `event.mk`, `TARGETS` diz que PDFs gerar e uma regra diz como.

## Eventos

### Escola Avançada de Matemática (`events/eam-2026-09`)

Template genérico, quatro categorias: `student-yes` (aluno com autorização de saída), `student-no` (aluno sem autorização de saída), `instructor` e `coordinator`. Nomes em Nudica (tem de estar instalada).
