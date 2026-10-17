# Each event has its own folder in events/ (see readme.md). Example: make EVENT=events/eam-2026-09
ifndef EVENT
all:
	@echo "Usage: make EVENT=events/<event> [category]"
	@echo "Events: $(patsubst %/,%,$(sort $(dir $(wildcard events/*/event.mk))))"
.PHONY: all
else

# Typst writes every file a compile read (CSV, YAML, templates, images) to $(EVENT)/.deps/<pdf>.d, so make rebuilds a
# PDF whenever any of them changes. Each input also gets an empty rule, so a deleted or renamed file doesn't stop make.
# Use in a recipe: $(call typst_deps,$@)
typst_deps = --deps $(EVENT)/.deps/$(notdir $(1)).d --deps-format make
save_deps = tr ' ' '\n' < $(EVENT)/.deps/$(notdir $(1)).d | tail -n +2 | sed 's/$$/:/' >> $(EVENT)/.deps/$(notdir $(1)).d
-include $(wildcard $(EVENT)/.deps/*.d)
.DEFAULT_GOAL := all

# Per-event settings (FONT, WEIGHT, COLOR, BADGES), or the event's own TARGETS and rules
-include $(EVENT)/event.mk

# One category per background/<x>.pdf; background/<x>-back.pdf is the back of <x>, not a category
BADGES ?= $(filter-out %-back,$(basename $(notdir $(wildcard $(EVENT)/background/*.pdf))))
TARGETS ?= $(BADGES)
WEIGHT ?= bold
COLOR ?= \#000000

# Default target
all: $(TARGETS)

# Short targets (what you type)
$(BADGES): %: $(EVENT)/output/%-badges.pdf

# Real build rule. With background/<x>-back.pdf, each sheet is followed by its back (duplex, long-edge flip)
$(EVENT)/output/%-badges.pdf: $(EVENT)/input/%.csv $(EVENT)/background/%.pdf badge_maker.typ | $(EVENT)/output $(EVENT)/.deps
	typst compile $(call typst_deps,$@) \
		--input persons="$(EVENT)/input/$*.csv" \
		--input background="$(EVENT)/background/$*.pdf" \
		$(if $(wildcard $(EVENT)/background/$*-back.pdf),--input back="$(EVENT)/background/$*-back.pdf") \
		$(if $(FONT),--input font="$(FONT)") --input weight="$(WEIGHT)" --input color="$(COLOR)" \
		$(if $(wildcard $(EVENT)/fonts),--font-path "$(EVENT)/fonts") \
		badge_maker.typ $@
	$(call save_deps,$@)

# Ensure output directories exist
$(EVENT)/output $(EVENT)/.deps:
	mkdir -p $@

.PHONY: all $(BADGES)
endif
