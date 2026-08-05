# ECON 7102 — Environmental Economics I

Course website. Quarto, published to GitHub Pages at
<https://caseyjwichman.com/econ7102/>.

Scope is the weekly schedule and the readings. Course policies live in the
syllabus PDF and are not repeated here.

## Contents

| Path | |
|:--|:--|
| `index.qmd` | The whole site. Header, deadlines table, week-by-week schedule. |
| `readings/` | Reading PDFs. |
| `slides/` | Lecture PDFs. Compiled in `slides/` under `_teaching/`, copied here. |
| `styles.scss` | Colors, badges, heading sizes. |
| `_quarto.yml` | Config. The `resources:` key lists what gets copied to `docs/` verbatim. |
| `econ7102_fall2026_syllabus.pdf` | Posted syllabus. Compiled in `syllabus/`, copied here. |
| `econ7102_fall2026_details.pdf` | Course details companion. Compiled in `syllabus/`, copied here. |
| `docs/` | Render output. Committed. Pages serves this directory. |

## Editing

`index.qmd` is markdown. No code, no data file, no build step.

Structure is `## Week N`, then `### <date> --- Class N: <topic>`, then readings
as bullets.

Reading entry:

    - Author Name (2026). "Title of the paper." *Journal Name*. [[PDF](readings/class18_author-2026.pdf)]

Slide link, on its own line under the class heading, before the readings:

    [Slides](slides/class05.pdf)

Markers, appended to the end of a bullet:

    [response due]{.badge-response}
    [discussion]{.badge-discussion}

Reading PDFs follow `class<NN>_<firstauthor>-<year>.pdf`. Slide PDFs follow
`class<NN>.pdf`. Both conventions keep the folders sorted by class. Links must
match filenames exactly, case included.

Slides go up before class, clean. Annotated copies stay off the site.

`<!-- -->` comments stay in the source and do not render. Four are in the file:
the SWEEEP placeholder, the guest lecturers, and the Chapter 7 note from Fall
2025.

To cancel a class, change the heading to `### <date> --- No class` and delete
the bullets.

## Build

Quarto is the only dependency.

    Cmd+Shift+P → Quarto: Render Project

Render Project, not Render, so that `resources:` is recopied. Rendering the
single file skips `readings/` and the PDFs.

First-time setup and publishing: `SETUP.md`.

## Constraints

`syllabus/econ7102_fall2026_public.tex` is the syllabus posted publicly under
the USG rule. It stays near-constant across years. Course material does not go
in it.

Year-to-year changes go in four files: `index.qmd`,
`syllabus/econ7102_fall2026_details.tex`, `syllabus/assignments.tex`,
`syllabus/schedule_table.tex`.

Lecture decks are beamer, compiled with pdflatex, sources in
`_teaching/FALL2026/ECON7102/slides/`. Every deck opens with
`\input{preamble.tex}` and sets its own `\subtitle`. Theme changes go in
`preamble.tex`, once.

No `CNAME` file in this repository. The `cjwichman.github.io` user site already
carries one, and it covers project pages.
