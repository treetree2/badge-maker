# Náboj de Física 2026: its own templates instead of badge_maker.typ
#   output/badges.pdf   every badge, front + inside (badges.typ)
#   output/mesas.pdf    a sheet for every place at a jury table (mesas.typ)
#   output/equipas.pdf  A6 team sheets, two per team: table + team (equipas.typ)
#   output/mapa.pdf     map of each room and index of the teams by school (mapa.typ)
#   output/certificados.pdf  participation certificates: students and teachers (certificados.typ)
#   output/premios.pdf  winners' certificates (premios.typ)
#   output/amostras.pdf  one certificate of each kind in every design, to choose one (amostras.typ)
#   output/exemplos.pdf  one example of each design: certificates, then badge fronts (exemplos.typ)
#   output/etiquetas.pdf  envelope stickers, one per school, in certificate order (etiquetas.typ)
#   output/enunciados.pdf  labels for each team's envelope of starting problems (enunciados.typ)
# badges and mesas read input/pessoas.csv, the others input/equipas.csv; texts, schedule, venues and roles are in conteudo.yaml.
BADGES =
TARGETS = $(EVENT)/output/badges.pdf $(EVENT)/output/mesas.pdf $(EVENT)/output/equipas.pdf $(EVENT)/output/mapa.pdf \
	$(EVENT)/output/certificados.pdf $(EVENT)/output/premios.pdf $(EVENT)/output/amostras.pdf $(EVENT)/output/exemplos.pdf \
	$(EVENT)/output/etiquetas.pdf \
	$(EVENT)/output/enunciados.pdf

# Rebuilt when anything the template read changes (CSVs, conteudo.yaml, shared .typ, images): see typst_deps in the Makefile
$(EVENT)/output/%.pdf: $(EVENT)/%.typ $(EVENT)/event.mk | $(EVENT)/output $(EVENT)/.deps
	typst compile --font-path "$(EVENT)/fonts" $(call typst_deps,$@) $< $@
	$(call save_deps,$@)
