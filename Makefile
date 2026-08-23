.DEFAULT_GOAL := build

.NOTPARALLEL:

DOC := resume
TEX := $(DOC).tex
PDF := $(DOC).pdf
LOG := $(DOC).log

LATEXMK   ?= latexmk
PDFINFO   ?= pdfinfo
PDFTOTEXT ?= pdftotext

LATEXMK_FLAGS ?= -pdf -pdflatex=pdflatex -interaction=nonstopmode \
                 -halt-on-error -file-line-error

EXPECTED_PAGES ?= 2
EXPECTED_NAME  ?= Serghei Iakovlev
EXPECTED_EMAIL ?= contact@serghei.pl

RESUME_EPOCH ?= 1787443200
export SOURCE_DATE_EPOCH := $(strip $(RESUME_EPOCH))
export FORCE_SOURCE_DATE := 1

.PHONY: help
help:
	@echo 'Targets:'
	@echo '  build   compile $(TEX) into $(PDF) with pdflatex (via latexmk)'
	@echo '  lint    reject self-assessment, cliche and duty names in content/'
	@echo '  check   lint, build, then verify the log, page count, text layer and'
	@echo '          that a rebuild reproduces the committed $(PDF) byte for byte'
	@echo '  watch   rebuild continuously as the sources change'
	@echo '  clean   remove $(PDF) and all LaTeX intermediates'
	@echo '  help    this message'
	@echo
	@echo 'Variables:'
	@echo '  LATEXMK=$(LATEXMK)  PDFINFO=$(PDFINFO)  PDFTOTEXT=$(PDFTOTEXT)'
	@echo '  RESUME_EPOCH=$(RESUME_EPOCH)  FORCE_SOURCE_DATE=1'
	@echo '  EXPECTED_PAGES=$(EXPECTED_PAGES)'

.PHONY: build
build:
	@test -f $(TEX) || { echo 'build: $(TEX) not found in $(CURDIR)' >&2; exit 1; }
	$(LATEXMK) $(LATEXMK_FLAGS) $(TEX)

.PHONY: watch
watch:
	@test -f $(TEX) || { echo 'watch: $(TEX) not found in $(CURDIR)' >&2; exit 1; }
	$(LATEXMK) $(LATEXMK_FLAGS) -pvc $(TEX)

.PHONY: clean
clean:
	$(LATEXMK) -C
	$(RM) $(DOC).bbl $(DOC).run.xml

.PHONY: check
check: lint build check-log check-pages check-text check-repro
	@echo 'check: all checks passed'

.PHONY: lint
lint:
	@./tools/lint-prose.sh

.PHONY: check-log
check-log:
	@test -f $(LOG) || { echo 'check-log: $(LOG) not found; run "make build" first' >&2; exit 1; }
	@n=$$(grep -cF 'Overfull \hbox' $(LOG) || true); \
	if [ "$$n" -ne 0 ]; then \
	    echo "check-log: FAILED -- $$n occurrence(s) of 'Overfull \\hbox' in $(LOG):" >&2; \
	    grep -nF 'Overfull \hbox' $(LOG) >&2; \
	    exit 1; \
	fi; \
	echo 'check-log: ok -- no Overfull \hbox'
	@n=$$(grep -cF 'Undefined' $(LOG) || true); \
	if [ "$$n" -ne 0 ]; then \
	    echo "check-log: FAILED -- $$n occurrence(s) of 'Undefined' in $(LOG):" >&2; \
	    grep -nF 'Undefined' $(LOG) >&2; \
	    exit 1; \
	fi; \
	echo 'check-log: ok -- no Undefined'

.PHONY: check-pages
check-pages:
	@test -f $(PDF) || { echo 'check-pages: $(PDF) not found; run "make build" first' >&2; exit 1; }
	@pages=$$($(PDFINFO) $(PDF) | awk '/^Pages:/ { print $$2 }'); \
	if [ "$$pages" != '$(EXPECTED_PAGES)' ]; then \
	    echo "check-pages: FAILED -- expected $(EXPECTED_PAGES) page(s), got '$$pages'" >&2; \
	    exit 1; \
	fi; \
	echo 'check-pages: ok -- $(EXPECTED_PAGES) pages'

# The strings must survive text extraction verbatim: that is how an applicant
# tracking system reads the document.  Letterspacing the name would break this.
.PHONY: check-text
check-text:
	@test -f $(PDF) || { echo 'check-text: $(PDF) not found; run "make build" first' >&2; exit 1; }
	@txt=$$(mktemp); trap 'rm -f "$$txt"' EXIT; \
	$(PDFTOTEXT) $(PDF) "$$txt" || { echo 'check-text: FAILED -- pdftotext could not read $(PDF)' >&2; exit 1; }; \
	for want in '$(EXPECTED_NAME)' '$(EXPECTED_EMAIL)'; do \
	    grep -qF "$$want" "$$txt" || { \
	        echo "check-text: FAILED -- '$$want' is absent from the text layer of $(PDF)" >&2; \
	        exit 1; \
	    }; \
	done; \
	echo 'check-text: ok -- name and email present in the text layer'

.PHONY: check-repro
check-repro:
	@git rev-parse --git-dir >/dev/null 2>&1 || { echo 'check-repro: FAILED -- not a git checkout' >&2; exit 1; }
	@git ls-files --error-unmatch $(PDF) >/dev/null 2>&1 || { \
	    echo 'check-repro: FAILED -- $(PDF) is not tracked by git; commit the built PDF' >&2; exit 1; }
	@ref=$$(mktemp); trap 'rm -f "$$ref"' EXIT; \
	git show HEAD:$(PDF) > "$$ref" || { echo 'check-repro: FAILED -- cannot read HEAD:$(PDF)' >&2; exit 1; }; \
	$(LATEXMK) -C >/dev/null; \
	$(LATEXMK) $(LATEXMK_FLAGS) $(TEX) >/dev/null || { echo 'check-repro: FAILED -- rebuild errored' >&2; exit 1; }; \
	if ! cmp -s "$$ref" $(PDF); then \
	    echo 'check-repro: FAILED -- the rebuild differs from the committed $(PDF).' >&2; \
	    echo "             reference $$(wc -c < "$$ref") bytes, rebuild $$(wc -c < $(PDF)) bytes" >&2; \
	    echo '             Rebuild with "make build" and commit the result.' >&2; \
	    exit 1; \
	fi; \
	echo 'check-repro: ok -- rebuild is byte-identical to the committed $(PDF)'
