# `.github/` — repo metadata

Contents of this directory that aren't self-explanatory:

## Social preview card

- [`social-preview.svg`](social-preview.svg) — 1280×640 source. GitHub's
  social preview upload only accepts PNG/JPG, so convert before uploading:

  ```bash
  # with rsvg-convert (librsvg)
  rsvg-convert -w 1280 -h 640 .github/social-preview.svg -o social-preview.png

  # or with Inkscape
  inkscape --export-type=png --export-filename=social-preview.png \
           --export-width=1280 --export-height=640 \
           .github/social-preview.svg

  # or with ImageMagick (v7+; quality varies)
  magick -background '#1a1d29' -density 150 \
         .github/social-preview.svg -resize 1280x640 social-preview.png
  ```

  Then upload: **Repo → Settings → General → Social preview → Upload an image**.

  Recommended: keep the SVG as the source of truth and regenerate the PNG on
  any edit. Don't commit the PNG — it rots.

## Issue and PR templates

- [`ISSUE_TEMPLATE/`](ISSUE_TEMPLATE/) — bug report, feature request, guide
  request, plus a `config.yml` that disables blank issues and surfaces
  Discussions.
- [`PULL_REQUEST_TEMPLATE.md`](PULL_REQUEST_TEMPLATE.md) — checklist tied to
  the style rules in `CONTRIBUTING.md`.

## Workflows

- [`workflows/shellcheck.yml`](workflows/shellcheck.yml)
- [`workflows/markdownlint.yml`](workflows/markdownlint.yml)
- [`workflows/links.yml`](workflows/links.yml)
- [`workflows/lint-claude-md.yml`](workflows/lint-claude-md.yml)
- [`workflows/docs.yml`](workflows/docs.yml) — deploys the mkdocs site to
  GitHub Pages.
- [`workflows/benchmarks.yml`](workflows/benchmarks.yml) — nightly benchmark
  run; commits CSVs and summary back to `main`.
