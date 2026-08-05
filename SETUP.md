# Setting up the site

No terminal, no build step. Edit markdown, click Render, push.

---

## Step 1 — Install two things

**Quarto CLI.** macOS installer at <https://quarto.org/docs/get-started/>.

**GitHub Desktop.** <https://desktop.github.com>. Sign in with your GitHub
account. This handles every git operation with buttons.

Also install the **Quarto** extension in VS Code (by Posit). That gives you the
Render and Preview buttons.

---

## Step 2 — Copy the project out of Dropbox

Git and Dropbox both want to manage the same directory and corrupt each
other's state.

In Finder: copy `Dropbox/_teaching/FALL2026/ECON7102/website` into
`Documents/Github/`, then rename the copy to `econ7102`.

---

## Step 3 — Render

Open `index.qmd` in VS Code and click **Render** in the top right. This writes
the site to `docs/`.

**Preview** instead of Render gives you a live browser view that refreshes on
save. That is the better mode for editing.

---

## Step 4 — Publish

In **GitHub Desktop**:

1. **File → Add Local Repository**, choose `~/Documents/Github/econ7102`.
   It will say the folder is not a git repository and offer to **create a
   repository** here. Take that.
2. Name it `econ7102`. Leave the git ignore and license fields alone, the
   folder already has a `.gitignore`.
3. Click **Publish repository**. Uncheck *Keep this code private*.

The first publish is around 130 MB because of the reading PDFs, so give it a
few minutes.

---

## Step 5 — Turn on GitHub Pages

On github.com, in the `econ7102` repository:

**Settings → Pages → Build and deployment → Source: Deploy from a branch**

Set the branch to `main` and the folder to `/docs`. Save.

Wait a minute or two, then load <https://caseyjwichman.com/econ7102/>.

Because your user site `cjwichman.github.io` has a custom domain, project
sites serve from that domain too. `cjwichman.github.io/econ7102` redirects
there. Use the `caseyjwichman.com` address everywhere. Do **not** add a
`CNAME` file to this repository — the user site's CNAME already covers it, and
a second one causes conflicts.

If you get a 404, confirm `docs/index.html` exists in the repository and that
`.nojekyll` sits at the repository root.

---

## The routine

1. Edit `index.qmd`.
2. Click **Render**.
3. In GitHub Desktop: type a summary, **Commit to main**, then **Push origin**.

Live about a minute after the push.

To add a reading: drop the PDF into `readings/` and add a bullet pointing at
it. Naming is a convention, not a rule — `class18_author-2026.pdf` keeps the
folder sorted by class.

---

## The two PDFs

Both live in `Dropbox/_teaching/FALL2026/ECON7102/syllabus/`.

`econ7102_fall2026_public.tex` is the syllabus posted publicly under the USG
rule. It is close to constant across years. **Leave it alone.** Course material
does not go in it.

`econ7102_fall2026_details.tex` is the living companion. It pulls in two
hand-maintained files from the same folder:

```latex
\input{assignments.tex}
\input{schedule_table.tex}
```

Recompile whichever changed, then copy the PDF into this folder as
`econ7102_fall2026_syllabus.pdf` or `econ7102_fall2026_details.pdf`, render,
and push.

---

## Annual rollover

The repository is named `econ7102`, not `econ7102-fall2026`, so the URL stays
right year after year. The site always shows the current term.

Before editing for a new term, freeze the old one. On github.com:

**Releases → Draft a new release → Choose a tag → type `fall2026` → Create new
tag → Publish release**

That marks the state of the site as taught, browsable from the Releases page.
Then update `index.qmd` with new dates and topics, recompile the details PDF,
swap both PDFs in, render, push. The public syllabus usually needs only a date
change.

---

## Troubleshooting

**Render fails.** Usually a stray character in a markdown table. Quarto names
the line.

**A reading link 404s on the live site.** The filename in the bullet does not
match the file in `readings/`. Case matters.

**Push rejected, file too large.** GitHub blocks single files over 100 MB.
Compress the PDF in Preview (File → Export, Quartz filter: Reduce File Size).
