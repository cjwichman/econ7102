# Setup

## Dependencies

GitHub Desktop, <https://desktop.github.com>. Nothing else. Any text editor
works, including github.com in a browser.

## Location

Keep the working copy outside Dropbox. Git and Dropbox manage the same
directory and corrupt each other's state.

`~/Documents/GitHub/econ7102` is the current location. macOS gates
`~/Documents` under Privacy & Security → Files and Folders. If an editor throws
`EPERM`, either grant it Documents Folder access there, or move the repository
to `~/GitHub/econ7102`, which is not gated.

## First publish

1. GitHub Desktop → File → Add Local Repository → select the folder. It offers
   to create a repository. Accept. Name it `econ7102`. The folder already has a
   `.gitignore`, so leave those fields alone.
2. Publish repository. Uncheck *Keep this code private*. The first push runs
   about 130 MB and takes a few minutes.
3. On github.com: Settings → Pages → Source: *Deploy from a branch* → `main`
   and `/ (root)`. Save.
4. Load <https://caseyjwichman.com/econ7102/>.

Root, not `/docs`. There is no build output directory. `index.html` at the top
of the repository is the page.

The `cjwichman.github.io` user site carries a custom domain, so project sites
serve from `caseyjwichman.com` as well. `cjwichman.github.io/econ7102`
redirects there. Cite the `caseyjwichman.com` address. Do not add a `CNAME`
file to this repository.

A 404 after step 4 means Pages is pointed at the wrong branch or folder.

## Routine

1. Edit `index.html`.
2. GitHub Desktop: summary, Commit to main, Push origin.

Live about a minute later. To check the page first, double-click `index.html`
in Finder — it opens in a browser and renders exactly as it will once pushed,
because there is no build step between the two.

Small edits can be made on github.com without a local checkout: open
`index.html`, click the pencil, commit. Useful from a phone or a borrowed
machine.

## The two PDFs

Both compile in `_teaching/FALL2026/ECON7102/syllabus/`. Neither is connected
to the site beyond the links in the header.

`econ7102_fall2026_public.tex` is the posted syllabus. Leave it alone.

`econ7102_fall2026_details.tex` is the living companion. It inputs
`assignments.tex` and `schedule_table.tex` from the same folder.

After recompiling either, copy the PDF into the repository, commit, push.

## Slides

Decks compile in `_teaching/FALL2026/ECON7102/slides/`. Copy the PDF into
`slides/` as `class06.pdf`, then uncomment that class's slide line in
`index.html`. The line is already written with the right filename.

## Annual rollover

The repository is unversioned so the URL survives. The site shows the current
term only.

Freeze the previous term first. On github.com: Releases → Draft a new release →
Choose a tag → type `fall2026` → Create new tag → Publish release. The state as
taught stays browsable from the Releases page.

Then update dates and topics in `index.html`, including the `data-from` and
`data-to` attributes on each week, recompile the details PDF, swap both PDFs
in, push. The public syllabus normally needs only a date change.

## Failure modes

| Symptom | Cause |
|:--|:--|
| `EPERM` opening a file | macOS Privacy gating on `~/Documents`. See Location above. |
| Page looks broken after an edit | An unclosed tag. Open the file in a browser locally to see where it breaks. |
| A reading or slide link 404s | Filename in the link does not match the file. Case matters. |
| Every week collapsed and none open | The script failed. Weeks carry `open` in the markup, so this only happens if the markup was edited. |
| Push rejected, file too large | GitHub caps single files at 100 MB. Compress in Preview: File → Export, Quartz filter *Reduce File Size*. |
