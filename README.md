# ECON 7102 — Environmental Economics I

Course website for ECON 7102 at Georgia Tech, Fall 2026. Built with Quarto,
served from GitHub Pages at <https://caseyjwichman.com/econ7102/>.

This site is the living weekly schedule: what to read, when, and what is due.

Two PDFs are linked from the top of the page and copied into this folder:

- `econ7102_fall2026_syllabus.pdf` --- the syllabus posted publicly under the
  USG rule. Near-constant across years. **Do not edit its source to add course
  material.**
- `econ7102_fall2026_details.pdf` --- the living companion document:
  assignments, deadlines, schedule table. This is where year-to-year changes
  go.

## Files

| Path | Purpose |
|:--|:--|
| `index.qmd` | The whole site. Deadlines table, then week-by-week schedule. |
| `readings/` | Reading PDFs, named `class04_coase-1960.pdf` and so on. |
| `styles.scss` | Styling. |
| `_quarto.yml` | Site config. |
| `econ7102_fall2026_syllabus.pdf` | Posted syllabus, copied in so the site can link to it. |
| `econ7102_fall2026_details.pdf` | Course details companion, same. |
| `docs/` | Rendered site. Committed, served by Pages. |

## Editing

Everything is plain markdown in `index.qmd`. To change a reading, edit the
line. To add one, drop the PDF into `readings/` and add a bullet:

```markdown
- Author Name (2026). "Title of the paper." *Journal Name*. [[PDF](readings/class18_author-2026.pdf)]
```

Optional markers on the end of a bullet:

```markdown
[response due]{.badge-response}
[discussion]{.badge-discussion}
```

`<!-- comments -->` in `index.qmd` are notes to self. They do not appear on
the site.

Then click Render and push. See [SETUP.md](SETUP.md).

## Requirements

[Quarto](https://quarto.org). That is all — no R, no build step.
