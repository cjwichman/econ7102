# Setup

## Dependencies

- Quarto CLI, <https://quarto.org/docs/get-started/>
- GitHub Desktop, <https://desktop.github.com>
- VS Code, Quarto extension by Posit

## Location

Keep the working copy outside Dropbox. Git and Dropbox manage the same
directory and corrupt each other's state.

`~/Documents/GitHub/econ7102` is the current location. macOS gates
`~/Documents` under Privacy & Security → Files and Folders. If VS Code throws
`EPERM` on `_quarto.yml`, either grant it Documents Folder access there, or
move the repository to `~/GitHub/econ7102`, which is not gated.

The Dropbox copy at `_teaching/FALL2026/ECON7102/website/` is the archive.

## First publish

1. Render. `Cmd+Shift+P → Quarto: Render Project`. Confirm `docs/index.html`
   exists.
2. GitHub Desktop → File → Add Local Repository → select the folder. It offers
   to create a repository. Accept. Name it `econ7102`. The folder already has a
   `.gitignore`, so leave those fields alone.
3. Publish repository. Uncheck *Keep this code private*. The first push runs
   about 130 MB and takes a few minutes.
4. On github.com: Settings → Pages → Source: *Deploy from a branch* → `main`
   and `/docs`. Save.
5. Load <https://caseyjwichman.com/econ7102/>.

The `cjwichman.github.io` user site carries a custom domain, so project sites
serve from `caseyjwichman.com` as well. `cjwichman.github.io/econ7102`
redirects there. Cite the `caseyjwichman.com` address. Do not add a `CNAME`
file to this repository.

A 404 after step 5 means either `docs/index.html` is missing from the
repository or `.nojekyll` is missing from the root.

## Routine

1. Edit `index.qmd`.
2. `Cmd+Shift+P → Quarto: Render Project`.
3. GitHub Desktop: summary, Commit to main, Push origin.

Live about a minute after the push.

While editing text, use Preview instead. It refreshes on save. Render Project
before committing, so `readings/` and the PDFs get recopied.

Adding a reading: drop the PDF into `readings/`, add a bullet pointing at it.

## The two PDFs

Both compile in `_teaching/FALL2026/ECON7102/syllabus/`. Neither is connected
to the site beyond the links at the top of `index.qmd`.

`econ7102_fall2026_public.tex` is the posted syllabus. Leave it alone.

`econ7102_fall2026_details.tex` is the living companion. It inputs
`assignments.tex` and `schedule_table.tex` from the same folder.

After recompiling either, copy the PDF into the website folder as
`econ7102_fall2026_syllabus.pdf` or `econ7102_fall2026_details.pdf`, render,
push.

## Annual rollover

The repository is unversioned so the URL survives. The site shows the current
term only.

Freeze the previous term first. On github.com: Releases → Draft a new release →
Choose a tag → type `fall2026` → Create new tag → Publish release. The state as
taught stays browsable from the Releases page.

Then update dates and topics in `index.qmd`, recompile the details PDF, swap
both PDFs in, render, push. The public syllabus normally needs only a date
change.

## Failure modes

| Symptom | Cause |
|:--|:--|
| `EPERM` opening a file | macOS Privacy gating on `~/Documents`. See Location above. |
| Render fails, names a line | Usually a stray character in a markdown table. |
| Reading link 404s on the live site | Filename in the bullet does not match `readings/`. Case matters. |
| PDFs missing after render | Ran Render instead of Render Project. |
| Push rejected, file too large | GitHub caps single files at 100 MB. Compress in Preview: File → Export, Quartz filter *Reduce File Size*. |
