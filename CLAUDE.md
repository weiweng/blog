# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Chinese-language personal blog built with **Hugo** using the **maupassant** theme. The blog focuses on Go, software architecture, algorithms, and other IT topics. Content is written in Markdown with TOML front matter and deployed to GitHub Pages.

## Build & Deploy

- **Build locally:** `hugo` (outputs to `docs/` directory, configured via `publishDir = "docs"` in config.toml)
- **Local dev server:** `hugo server` (live reload at http://localhost:1313)
- **Deploy to production server:** `./build.sh` (git pull → hugo build → copy docs/ to OpenResty www directory at `/opt/1panel/apps/openresty/openresty/www/sites/weiweng.top/index`)
- **GitHub Pages:** Auto-deploys from `docs/` on push to `main` via `.github/workflows/static.yml`

## Content Structure

All blog content lives under `content/` organized by section:

- `content/post/` — Main blog posts (~130 articles), organized as **page bundles** (each post is a directory with `index.md` + optional images)
- `content/read/` — Book reviews and reading lists
- `content/tools/` — Tool usage guides (git, vim, nginx, shell, etc.)
- `content/about/` — About page
- `content/archives/` — Archives page
- `content/search/` — Search page

### Post Naming Convention

Post directories use the format: `YYYY-MM-DD-title` (e.g., `2025-08-09-设计模式`). Titles with subtopics use `|` as separator (e.g., `2025-07-20-spark|任务调度`).

### Front Matter Format

Posts use **TOML** front matter (delimited by `+++`):

```toml
+++
title="Post Title"
date="2025-08-09T10:00:00+08:00"
categories=["Category Name"]
toc=false
summary = 'Optional summary text'
+++
```

Key front matter fields:
- `categories` — Used for content grouping; maps to `/categories/` URLs
- `toc` — Table of contents toggle (default: false in config, override per-post)
- `summary` — Optional explicit summary

## Configuration

Single config file: `config.toml` at project root. Key settings:
- `baseURL` — Currently set to `https://weiweng.github.io/blog`
- `theme = "maupassant"` — Theme files tracked directly in `themes/maupassant/` (no longer a submodule)
- `publishDir = "docs"` — Build output directory (committed to repo for GitHub Pages)
- `defaultContentLanguage = 'zh-hans'`, `hasCJKLanguage = true`
- Comments via Utteranc (GitHub Issues-based), configured under `[params.utteranc]`
- Code highlighting: GitHub style with line numbers enabled

## Theme

The maupassant theme files are tracked directly in `themes/maupassant/` as part of this repository. Originally forked from `weiweng/maupassant-hugo`, the theme was converted from a git submodule to regular tracked files. No `git submodule` commands are needed after cloning.

## Known Issues

- `build.sh` has a syntax bug: missing `fi` after the directory existence check on line 18. The `if` block is not properly closed before the `hugo` command.

## Static Assets

- `static/` — Contains only `favicon.ico`
- Post images are stored alongside `index.md` in each post's page bundle directory
