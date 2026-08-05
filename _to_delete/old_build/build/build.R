# ---------------------------------------------------------------------------
# build.R -- generate the site and stage reading PDFs from data/schedule.yml
#
# Open this file in RStudio or VS Code and source it, or run it from a shell
# with `Rscript build/build.R`. Either works. It does two things:
#
#   1. Generates the site includes and LaTeX fragments.
#   2. Copies the assigned reading PDFs out of the course archive into
#      readings/, under stable class-numbered filenames.
#
# Outputs
#   _generated/schedule.md            included by schedule.qmd
#   _generated/readings.md            included by readings.qmd
#   _generated/tex/schedule_table.tex \input by the syllabus
#   _generated/tex/reading_list.tex   \input by the syllabus
#   _generated/readings_manifest.tsv  source path -> served filename mapping
#   readings/*.pdf                    the assigned readings
#
# After running this, render the site (the Render button in RStudio or VS
# Code, or `quarto render`).
# ---------------------------------------------------------------------------

# --- configuration ---------------------------------------------------------

# Where the full course readings archive lives. Only the assigned readings are
# copied into the repository, which is what keeps it a manageable size. Set
# this to "" to skip PDF staging entirely.
READINGS_ARCHIVE <- "~/Dropbox/_teaching/FALL2026/ECON7102/readings"

# ---------------------------------------------------------------------------

library(yaml)

`%||%` <- function(a, b) if (is.null(a)) b else a

# Run from the repository root. If invoked from build/, step up one level.
root <- getwd()
if (!dir.exists(file.path(root, "data")) && dir.exists(file.path(root, "..", "data"))) {
  root <- normalizePath(file.path(root, ".."))
}
if (!file.exists(file.path(root, "data", "schedule.yml"))) {
  stop("Cannot find data/schedule.yml. Run this script from the repository root.")
}

gen_dir <- file.path(root, "_generated")
tex_dir <- file.path(gen_dir, "tex")
dir.create(tex_dir, recursive = TRUE, showWarnings = FALSE)

cfg <- yaml::read_yaml(file.path(root, "data", "schedule.yml"))

# --- helpers ---------------------------------------------------------------

tex_escape <- function(x) {
  if (is.null(x) || is.na(x)) return("")
  x <- gsub("\\\\", "\\\\textbackslash{}", x)
  x <- gsub("([&%$#_{}])", "\\\\\\1", x)
  x <- gsub("~", "\\\\textasciitilde{}", x)
  x <- gsub("\\^", "\\\\textasciicircum{}", x)
  x
}

# Wrap a title in LaTeX quotation marks after escaping.
tex_quote <- function(x) paste0("``", tex_escape(x), end_punct(x), "''")

md_escape <- function(x) {
  if (is.null(x) || is.na(x)) return("")
  gsub("([*_\\[\\]])", "\\\\\\1", x, perl = TRUE)
}

fmt_date <- function(d, fmt = "%d-%b-%Y") {
  gsub("  ", " ", format(as.Date(d), fmt))
}
day_letter <- function(d) c("M", "T", "W", "R", "F", "S", "U")[
  as.integer(format(as.Date(d), "%u"))]

# Slug for the served PDF filename: first author surname plus year.
first_surname <- function(authors) {
  if (is.null(authors)) return("anon")
  a <- sub(",.*$", "", authors)
  a <- sub("\\s+et\\s+al\\.?$", "", a)
  a <- sub("\\s+and\\s+.*$", "", a)
  parts <- strsplit(trimws(a), "\\s+")[[1]]
  surname <- parts[length(parts)]
  surname <- gsub("[^A-Za-z]", "", surname)
  tolower(if (nchar(surname)) surname else "anon")
}

# Served filenames must be unique. A `slug` field in the YAML overrides the
# derived name; otherwise collisions get a -b, -c, ... suffix.
used_names <- new.env(parent = emptyenv())

pdf_name <- function(cls, r) {
  base <- if (!is.null(r$slug)) r$slug else
    sprintf("class%02d_%s-%s", cls, first_surname(r$authors), r$year %||% "nd")
  name <- paste0(base, ".pdf")
  i <- 1L
  while (!is.null(used_names[[name]])) {
    i <- i + 1L
    name <- sprintf("%s-%s.pdf", base, letters[i])
  }
  used_names[[name]] <- TRUE
  name
}

textbook_short <- cfg$course$textbook$short

# Titles already ending in ? or ! do not take an additional period.
end_punct <- function(title) if (grepl("[?!]$", title)) "" else "."

# Rendered citation, one form for markdown and one for LaTeX.
cite_md <- function(r) {
  if (isTRUE(r$textbook)) {
    return(paste0("**", textbook_short, "** ", r$note %||% ""))
  }
  if (identical(r$type, "course")) return(md_escape(r$title))
  paste0(md_escape(r$authors), " (", r$year, "). \"", md_escape(r$title),
         end_punct(r$title), "\" *",
         md_escape(r$outlet), "*.",
         if (!is.null(r$note)) paste0(" ", md_escape(r$note)) else "")
}

cite_tex <- function(r) {
  if (isTRUE(r$textbook)) {
    return(paste0(tex_escape(textbook_short), " (", tex_escape(r$note %||% ""), ")"))
  }
  if (identical(r$type, "course")) return(tex_escape(r$title))
  paste0(tex_escape(r$authors), " (", r$year, "). ", tex_quote(r$title), " \\textit{",
         tex_escape(r$outlet), "}.",
         if (!is.null(r$note)) paste0(" ", tex_escape(r$note)) else "")
}

meetings <- cfg$meetings

# --- 1. schedule.md --------------------------------------------------------

sched_rows <- vapply(meetings, function(m) {
  label <- if (is.null(m$class)) {
    paste0("*", md_escape(m$topic), "*")
  } else {
    topic <- md_escape(m$topic)
    if (isTRUE(m$assessment)) topic <- paste0("**", topic, "**")
    paste0("[Class ", m$class, "](readings.qmd#class-", m$class, "): ", topic)
  }
  sprintf("| %d | %s | %s | %s |", m$week, day_letter(m$date),
          fmt_date(m$date, "%b %e"), label)
}, character(1))

schedule_md <- c(
  "| Week | Day | Date | Topic |",
  "|:--|:--|:--|:-----|",
  sched_rows,
  "",
  ": {.striped .hover tbl-colwidths=\"[8,6,14,72]\"}"
)
writeLines(schedule_md, file.path(gen_dir, "schedule.md"))

# --- 2. readings.md --------------------------------------------------------

manifest <- list()
readings_md <- character(0)

for (m in meetings) {
  if (is.null(m$class)) next

  readings_md <- c(readings_md,
                   sprintf("## Class %d --- %s {#class-%d}", m$class,
                           md_escape(m$topic), m$class),
                   "",
                   sprintf("*%s*", fmt_date(m$date, "%A, %B %e, %Y")),
                   "")

  if (!is.null(m$note)) {
    readings_md <- c(readings_md, paste0("::: {.callout-note collapse=\"true\"}"),
                     "## Instructor note", md_escape(m$note), ":::", "")
  }

  if (isTRUE(m$tbd) && is.null(m$readings)) {
    readings_md <- c(readings_md, "Readings to be announced.", "")
    next
  }
  if (is.null(m$readings)) {
    readings_md <- c(readings_md, "No assigned reading.", "")
    next
  }

  for (r in m$readings) {
    bullet <- paste0("- ", cite_md(r))

    if (!is.null(r$source_pdf)) {
      fn <- pdf_name(m$class, r)
      manifest[[length(manifest) + 1L]] <- c(r$source_pdf, fn)
      bullet <- paste0(bullet, " [[PDF](readings/", fn, ")]")
    }
    if (!is.null(r$url)) bullet <- paste0(bullet, " [[link](", r$url, ")]")
    if (isTRUE(r$response))   bullet <- paste0(bullet, " [response due]{.badge-response}")
    if (isTRUE(r$discussion)) bullet <- paste0(bullet, " [discussion]{.badge-discussion}")

    readings_md <- c(readings_md, bullet)
  }

  if (!is.null(m$discussion_lead)) {
    readings_md <- c(readings_md, "",
                     paste0("*Discussion led by ", md_escape(m$discussion_lead), ".*"))
  }
  readings_md <- c(readings_md, "")
}

writeLines(readings_md, file.path(gen_dir, "readings.md"))

# --- 3. schedule_table.tex -------------------------------------------------

tex_rows <- character(0)
last_week <- -1L
for (m in meetings) {
  wk <- if (m$week != last_week) paste0("Week ", m$week) else ""
  last_week <- m$week
  label <- if (is.null(m$class)) {
    paste0("\\textbf{\\textit{", tex_escape(m$topic), "}}")
  } else {
    topic <- tex_escape(m$topic)
    if (isTRUE(m$assessment)) topic <- paste0("\\underline{\\textbf{", topic, "}}")
    paste0("Class ", m$class, ": ", topic)
  }
  tex_rows <- c(tex_rows, sprintf("%s & %s & %s & %s \\\\", wk,
                                  day_letter(m$date), fmt_date(m$date), label))
}

schedule_tex <- c(
  "% Generated by build/build.R from data/schedule.yml. Do not edit by hand.",
  "\\begin{table}[h!]", "\\centering", "\\begin{tabular}{llll}", "\\hline",
  "\\textbf{Week} & \\textbf{Day} & \\textbf{Class Date} & \\textbf{Topic} \\\\",
  "\\hline", tex_rows, "\\hline", "\\end{tabular}", "\\end{table}"
)
writeLines(schedule_tex, file.path(tex_dir, "schedule_table.tex"))

# --- 4. reading_list.tex ---------------------------------------------------

rl <- c("% Generated by build/build.R from data/schedule.yml. Do not edit by hand.")

for (m in meetings) {
  if (is.null(m$class)) next
  rl <- c(rl, "", sprintf("\\subsection*{Class %d -- %s}", m$class,
                          tex_escape(m$topic)))

  if (isTRUE(m$tbd) && is.null(m$readings)) {
    rl <- c(rl, "\\noindent Readings to be announced.")
    next
  }
  if (is.null(m$readings)) next

  rl <- c(rl, "\\begin{itemize}")
  for (r in m$readings) {
    line <- paste0("\t\\item[$\\square$] ", cite_tex(r))
    if (!is.null(r$url)) {
      line <- paste0(line, " \\href{", r$url, "}{[link]}")
    }
    if (isTRUE(r$response)) line <- paste0(line, " \\hfill \\textbf{[response due]}")
    rl <- c(rl, line)
  }
  rl <- c(rl, "\\end{itemize}")

  if (!is.null(m$discussion_lead)) {
    rl <- c(rl, sprintf("\\noindent \\textit{Discussion led by %s.}",
                        tex_escape(m$discussion_lead)))
  }
}
writeLines(rl, file.path(tex_dir, "reading_list.tex"))

# --- 5. manifest and checks ------------------------------------------------

man <- do.call(rbind, manifest)
colnames(man) <- c("source_pdf", "served_pdf")
write.table(man, file.path(gen_dir, "readings_manifest.tsv"), sep = "\t",
            quote = FALSE, row.names = FALSE)

dupes <- man[duplicated(man[, "served_pdf"]), "served_pdf"]
if (length(dupes)) {
  warning("Duplicate served filenames: ", paste(unique(dupes), collapse = ", "))
}

n_classes <- sum(vapply(meetings, function(m) !is.null(m$class), logical(1)))
flagged <- unlist(lapply(meetings, function(m)
  if (is.null(m$readings)) NULL else
    lapply(m$readings, function(r) if (!is.null(r$check))
      sprintf("Class %d: %s", m$class, r$check))))

cat(sprintf("Meetings: %d (%d class sessions, %d non-meeting days)\n",
            length(meetings), n_classes, length(meetings) - n_classes))
cat(sprintf("Readings with PDFs: %d\n", nrow(man)))
cat(sprintf("Wrote: %s\n", paste(list.files(gen_dir, recursive = TRUE),
                                 collapse = ", ")))
if (length(flagged)) {
  cat("\nItems flagged for manual verification:\n")
  cat(paste0("  - ", flagged, collapse = "\n"), "\n")
}

# --- 6. stage reading PDFs -------------------------------------------------

stage_readings <- function(archive, manifest, dest) {
  archive <- path.expand(archive)
  if (!dir.exists(archive)) {
    cat(sprintf("\nSkipped PDF staging: archive not found at %s\n", archive))
    cat("Set READINGS_ARCHIVE at the top of this script.\n")
    return(invisible(NULL))
  }

  dir.create(dest, showWarnings = FALSE)
  copied <- 0L; unchanged <- 0L; missing <- character(0)

  for (i in seq_len(nrow(manifest))) {
    src <- file.path(archive, manifest[i, "source_pdf"])
    out <- file.path(dest, manifest[i, "served_pdf"])

    if (!file.exists(src)) {
      missing <- c(missing, manifest[i, "source_pdf"])
      next
    }
    # Skip files that are already staged and unchanged. Saves recopying a
    # few hundred megabytes on every build.
    if (file.exists(out) && identical(file.size(src), file.size(out)) &&
        file.mtime(out) >= file.mtime(src)) {
      unchanged <- unchanged + 1L
      next
    }
    file.copy(src, out, overwrite = TRUE, copy.date = TRUE)
    copied <- copied + 1L
  }

  # Remove staged PDFs that are no longer assigned.
  stale <- setdiff(list.files(dest, pattern = "\\.pdf$"),
                   manifest[, "served_pdf"])
  if (length(stale)) file.remove(file.path(dest, stale))

  cat(sprintf("\nReadings staged in %s/: %d copied, %d unchanged, %d removed\n",
              basename(dest), copied, unchanged, length(stale)))
  if (length(missing)) {
    cat("Missing from the archive:\n")
    cat(paste0("  - ", missing, collapse = "\n"), "\n")
  }
  invisible(NULL)
}

if (nzchar(READINGS_ARCHIVE)) {
  stage_readings(READINGS_ARCHIVE, man, file.path(root, "readings"))
}

cat("\nNext: render the site (Render button, or `quarto render`).\n")
