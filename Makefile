# Each event has its own folder in events/ (see readme.md). Example: make EVENT=events/eam-2026-09
ifndef EVENT
all:
	@echo "Usage: make EVENT=events/<event> [category]"
	@echo "Events: $(patsubst %/,%,$(sort $(dir $(wildcard events/*/event.mk))))"
.PHONY: all
else

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
$(EVENT)/output/%-badges.pdf: $(EVENT)/input/%.csv $(EVENT)/background/%.pdf badge_maker.typ | $(EVENT)/output
	typst compile \
		--input persons="$(EVENT)/input/$*.csv" \
		--input background="$(EVENT)/background/$*.pdf" \
		$(if $(wildcard $(EVENT)/background/$*-back.pdf),--input back="$(EVENT)/background/$*-back.pdf") \
		$(if $(FONT),--input font="$(FONT)") --input weight="$(WEIGHT)" --input color="$(COLOR)" \
		$(if $(wildcard $(EVENT)/fonts),--font-path "$(EVENT)/fonts") \
		badge_maker.typ $@

# Ensure output directory exists
$(EVENT)/output:
	mkdir -p $@

.PHONY: all $(BADGES)
endif
