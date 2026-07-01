BADGES = coordinator instructor student-yes student-no

# Default target
all: $(BADGES)

# Short targets (what you type)
$(BADGES): %: output/%-badges.pdf

# Real build rule
output/%-badges.pdf: input/%.csv background/%.pdf badge_maker.typ | output
	typst compile \
		--input persons="input/$*.csv" \
		--input background="background/$*.pdf" \
		badge_maker.typ $@

# Ensure output directory exists
output:
	mkdir -p output

.PHONY: all $(BADGES)