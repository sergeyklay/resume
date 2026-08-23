<h1 align="center">
    Résumé
</h1>
<p align="center">Serghei Iakovlev's résumé in LaTeX.</p>
<p align="center">
    <a href="https://github.com/sergeyklay/cv/actions/workflows/build.yml">
        <img src="https://github.com/sergeyklay/cv/actions/workflows/build.yml/badge.svg" alt="Build resume" />
    </a>
</p>

A two-page résumé typeset with pdfLaTeX. The document class, `resume.cls`, is
part of this repository; everything else comes from a stock TeX Live
installation. No `.cls`, `.sty` or font files are vendored here.

The built document is committed as [`resume.pdf`](resume.pdf).

## Prerequisites

pdfLaTeX, latexmk, and poppler's `pdfinfo`/`pdftotext` for the checks. The
document loads `geometry`, `libertinus`, `fontenc`, `microtype`, `enumitem`,
`titlesec`, `hyperref`, `xcolor`, `etoolbox`, `tabularx`, `ragged2e` and
`parskip`.

On Debian and Ubuntu:

```sh
sudo apt-get install --no-install-recommends \
    texlive-latex-base texlive-latex-recommended texlive-latex-extra \
    texlive-fonts-recommended texlive-fonts-extra \
    latexmk poppler-utils
```

Which package supplies what:

| Package | Supplies |
| --- | --- |
| `texlive-latex-base` | `geometry`, `hyperref`, `tabularx`, `fontenc` |
| `texlive-latex-recommended` | `microtype`, `etoolbox`, `parskip`, `ragged2e`, `xcolor` |
| `texlive-latex-extra` | `titlesec`, `enumitem` |
| `texlive-fonts-recommended` | standard T1 font support |
| `texlive-fonts-extra` | `libertinus`, including the Type 1 fonts pdfTeX needs |
| `latexmk` | build driver |
| `poppler-utils` | `pdfinfo`, `pdftotext` |

`texlive-fonts-extra` is large (about 1.7 GB installed). It is the only Debian
package that ships Libertinus. `--no-install-recommends` is not optional: without
it, apt also pulls in some forty unrelated font packages and a JRE.

On a full `texlive-full` or upstream TeX Live installation, nothing extra is
needed.

## Building

```sh
make build     # compile resume.tex into resume.pdf
make watch     # recompile on every save
make clean     # remove the PDF and all intermediates
make help      # list targets
```

`make build` is the default target.

Builds are reproducible. The Makefile exports `SOURCE_DATE_EPOCH` together with
`FORCE_SOURCE_DATE=1`, which pin the `/CreationDate`, `/ModDate` and `/ID`
fields pdfTeX would otherwise fill with the current time. Rebuilding unchanged
sources therefore produces the same bytes, on any machine and at any time.

The epoch is the constant `RESUME_EPOCH` in the Makefile, not a git commit date.
A commit date cannot work here: the PDF must be built before the commit that
records it, so the committed PDF always carries the previous commit's date while
a fresh build carries the current one, and reconstructing the right value from
history breaks under rebase, squash and shallow clone. Bump `RESUME_EPOCH` when
the document's recorded date should move, then rebuild and commit the PDF in the
same change.

## Checking

```sh
make check
```

It asserts that:

1. `content/` is free of self-assessment, recruiter cliché, duty names in place
   of outcomes, filler intensifiers, vague quantifiers and American spelling;
2. `latexmk` exits zero;
3. the log contains no `Overfull \hbox`;
4. the log contains no `Undefined`;
5. `pdfinfo` reports exactly two pages;
6. `pdftotext` finds the name and the email address in the text layer, verbatim —
   this is how an applicant tracking system reads the document;
7. a rebuild is byte-identical to the committed `resume.pdf`.

Each is a separate target (`lint`, `check-log`, `check-pages`, `check-text`,
`check-repro`) and each exits non-zero with a message naming what went wrong.

Check 1 is `tools/lint-prose.sh`, which can be run on its own with `make lint`.

CI runs `make check` on every push and pull request, and nightly.

## Layout

```
resume.cls              document class
resume.tex              root document
content/header.tex      name and contact details
content/summary.tex
content/experience.tex
content/opensource.tex
content/education.tex   education, certificates, publication
content/skills.tex
tools/lint-prose.sh     prose checks run by "make lint"
Makefile
README.md
.github/workflows/build.yml
```

## Why pdfLaTeX and not XeLaTeX

XeLaTeX exists to use system OTF and TTF fonts. This document takes its font
from TeX Live, so XeLaTeX buys nothing — and it costs most of `microtype`.

Of `microtype`'s five features, XeTeX supports only protrusion. In
`microtype-xetex.def` the other four are defined as warnings that discard the
setting (lines 398–401):

```latex
\define@key{MTX}{expansion}[true]{\MT@warning{Ignoring expansion setup}}
\define@key{MTX}{tracking}[true]{\MT@warning{Ignoring tracking setup}}
\define@key{MTX}{kerning}[true]{\MT@warning{Ignoring kerning setup}}
\define@key{MTX}{spacing}[true]{\MT@warning{Ignoring spacing setup}}
```

Compiling a document that requests all five confirms it: under pdfLaTeX it
passes silently, under XeLaTeX it emits four errors, including `Font expansion
does not work with xetex`. `microtype-pdftex.def` implements all four for
pdfTeX 1.40 and newer, which is every pdfTeX still in circulation.

Font expansion is what produces an even grey page, and on a résumé squeezed to
two pages it is the difference between a line fitting and not. That decides the
engine.

## Licence

MIT. See [LICENSE](LICENSE).
