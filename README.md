# Résumé

[![Build resume](https://github.com/sergeyklay/resume/actions/workflows/build.yml/badge.svg)](https://github.com/sergeyklay/resume/actions/workflows/build.yml)

This repo contains Serghei Iakovlev's résumé, permissively licensed for others to adapt. The document class `resume.cls` lives in this repository; everything else comes from a stock TeX Live installation. The built document is committed as [`resume.pdf`](resume.pdf).

Building requires `latexmk` and `pdflatex`. `make check` additionally needs poppler's `pdfinfo` and `pdftotext`.

```sh
make build   # compile resume.tex into resume.pdf (default target)
make check   # lint prose, build, then verify log, pages, text layer, reproducibility
make watch   # rebuild on every save
make clean   # remove the PDF and all intermediates
make help    # list targets
```

MIT. See [LICENSE](LICENSE).
