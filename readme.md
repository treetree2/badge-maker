# Badge Maker

Este repositório contém os scripts que foram utilizados para produzir os badges da Escola Avançada de Matemática do TreeTree2.

## Instalação
Requer ter instalado Typst. Há um makefile (julgo que só funciona em mac/linux) para simplificar o processo de compilação, mas tudo o que aquele ficheiro faz pode ser feito à mão em windows (mesmo em windows acho que há maneiras de correr o makefile). Analisa o makefile ou pede à tua LLM favorita para te explicar como o fazer.

## Utilização

Há quatro categorias de pessoas
- student-yes: aluno com autorização de saída
- student-no: aluno sem autorização de saída
- instructor: instrutor
- coordinator: coordenador

Na pasta input terás 4 ficheiros chamados `x.csv` em que x é uma das categorias. Deves popular cada ficheiro com as pessoas para as quais queres badges. Esses ficheiros têm de ter pelo menos duas colunas: `first_name` e `last_name` (pode ter mais colunas mas não serão utilizadas).

Na pasta background encontras os fiecheiros `x.pdf` que servem de fundo para os badges. Vê os que estão lá para a EAM. Infelizmente tem de ser feito mesmo assim: uma metade ao contrário da outra (é algo que vou ter de corrigir no futuro). Substitui esses ficheros pelos teus. Sugiro que mantenhas o placement de cada coisa mais ou menos no mesmo sítio. Se não vais ter de alterar isso à mão no ficheiro badge_makes.typ.

Para correr a coisa basta fazeres `cd` para a pasta do repositório e correres o comando `make`. Aparecerão na pasta `output` os ficheiros `x-badges.pdf`. Se por alguma razão só quiseres compilar os badges de apenas a categoria x, corre o comando `make x`. O comando `make` só existe em mac/linux, ver o que diz na instalação. 