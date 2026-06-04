<!--
SPDX-FileCopyrightText: 2026 The Fisher Slopworks Co
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Compliance standard

How every The Fisher Slopworks Co repository handles **licensing**, **REUSE**, and
**governance** — what each repo must contain, where each piece lives, and how to
add or migrate a project. This is the single reference. The machinery that ships
the standard lives in two repos:

- [`template`](https://github.com/The-Fisher-Slopworks-Co/template) — the starting
  point new repos are **created from** (files are copied in).
- [`.github`](https://github.com/The-Fisher-Slopworks-Co/.github) (this repo) — the
  org-wide governance defaults, **inherited** by every repo automatically.

## The standard, in one glance

Every project repository must:

1. Be licensed **AGPL-3.0-or-later** — the explicit `-or-later` variant, never bare
   `AGPL-3.0` or `AGPL-3.0-only`.
2. Be **[REUSE](https://reuse.software/) 3.x compliant** — `reuse lint` passes,
   enforced by CI on every push and pull request.
3. Carry the canonical license text and a `REUSE.toml`, copyright
   **`<year> The Fisher Slopworks Co`**.
4. **Not** ship its own Code of Conduct / Security policy / Contributing guide —
   those are inherited from this `.github` repo.

Genuine third-party files keep their own license — see
[Third-party code](#third-party-code-multiple-licenses).

## Where each piece lives

| Requirement | File(s) in the repo | Canonical value |
|---|---|---|
| License text | `LICENSE` (root) **and** `LICENSES/AGPL-3.0-or-later.txt` | output of `reuse download AGPL-3.0-or-later` (official SPDX text), byte-identical in both |
| License declared (machine) | `package.json` `"license"` / `Cargo.toml` `license` | `AGPL-3.0-or-later` |
| License declared (prose) | `README.md` → `## License` section | `AGPL-3.0-or-later. See [LICENSE](LICENSE).` |
| REUSE config | `REUSE.toml` | `**` wildcard, holder `<year> The Fisher Slopworks Co`, `AGPL-3.0-or-later` |
| REUSE CI | `.github/workflows/reuse.yml` | `fsfe/reuse-action@v6` |
| Code of Conduct | *(none — inherited)* | this repo's `CODE_OF_CONDUCT.md` |
| Security policy | *(none — inherited)* | this repo's `SECURITY.md` (contact `security@slopworks.org`) |
| Contributing guide | *(none — inherited)* | this repo's `CONTRIBUTING.md` |

Rule of thumb: to change a **license** detail, edit the repo. To change a
**governance** doc, edit it **here** once and every repo follows.

## Canonical snippets

`REUSE.toml` — the whole tree under one rule (per-file SPDX headers, where used,
override it via `precedence = "closest"`):

```toml
version = 1

[[annotations]]
path = "**"
precedence = "closest"
SPDX-FileCopyrightText = "2026 The Fisher Slopworks Co"
SPDX-License-Identifier = "AGPL-3.0-or-later"
```

`.github/workflows/reuse.yml`:

```yaml
# SPDX-FileCopyrightText: 2026 The Fisher Slopworks Co
#
# SPDX-License-Identifier: AGPL-3.0-or-later

name: REUSE Compliance
on:
  push:
  pull_request:
permissions:
  contents: read
jobs:
  reuse:
    name: REUSE lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: fsfe/reuse-action@v6
```

Inline SPDX header for source files (optional but encouraged; use the file's
comment syntax, e.g. `//`, `#`, `--`):

```text
SPDX-FileCopyrightText: 2026 The Fisher Slopworks Co
SPDX-License-Identifier: AGPL-3.0-or-later
```

## Adding a new project

1. **Create from the template:** on GitHub click **“Use this template”**, or
   ```bash
   gh repo create The-Fisher-Slopworks-Co/<name> --template The-Fisher-Slopworks-Co/template --public
   ```
2. Clone it and run the initializer once:
   ```bash
   ./scripts/init.sh                 # or: ./scripts/init.sh "My Project" "Tagline."
   ```
   It writes a project `README.md`, deletes itself, and runs `reuse lint`.
3. Build your project. Governance docs are inherited automatically — **don't add
   your own**. Set your stack's license field to `AGPL-3.0-or-later`.

The repo ships `LICENSE`, `LICENSES/`, `REUSE.toml`, and the REUSE CI from the
first commit, and inherits CoC / Security / Contributing from this repo.

## Migrating an existing project

For a repo that predates the standard (no REUSE, or the wrong license variant).
Work on a branch and open a PR.

1. **Branch:** `git checkout -b chore/reuse-agpl-compliance`.
2. **Scan for third-party code first.** The blanket copyright below is only honest
   if every file is the org's own work, and `reuse lint` will **not** catch a
   wrong attribution:
   ```bash
   grep -rIiE "copyright|\(c\)|©|@license|licensed under|\b(MIT|BSD|Apache|MPL|ISC|GPL)\b" . \
     --exclude-dir=.git --exclude-dir=node_modules --exclude=LICENSE
   ```
   Handle any genuine third-party file properly (next section); if you can't
   confidently resolve one, stop and ask rather than blanket over it.
3. **Add the license text:**
   ```bash
   reuse download AGPL-3.0-or-later            # writes LICENSES/AGPL-3.0-or-later.txt
   cp LICENSES/AGPL-3.0-or-later.txt LICENSE   # root copy so GitHub detects the license
   ```
4. **Add `REUSE.toml`** and **`.github/workflows/reuse.yml`** (snippets above).
5. **Declare the license** as `AGPL-3.0-or-later` in the manifest
   (`package.json` / `Cargo.toml`) and the README `## License` section. Replace any
   bare `AGPL-3.0` or `AGPL-3.0-only`.
6. **Remove** any own `CODE_OF_CONDUCT.md` / `SECURITY.md` / `CONTRIBUTING.md` (and,
   if present, a `LICENSES/CC-BY-4.0.txt` + its annotation) — they're inherited
   from this repo now.
7. **Verify:** `reuse lint` must report *compliant*.
8. **Open a PR**, let CI confirm, merge.

## Third-party code (multiple licenses)

Files copied from another project keep **their** license — never relicense them
under the blanket wildcard. For each genuine third-party file:

1. `reuse download <SPDX-ID>` (e.g. `MIT`) to add its text under `LICENSES/`.
2. Add a specific `REUSE.toml` annotation with the **true** holder and license:
   ```toml
   [[annotations]]
   path = ["src/components/ui/button.tsx", "..."]
   precedence = "closest"
   SPDX-FileCopyrightText = "2023 shadcn"
   SPDX-License-Identifier = "MIT"
   ```
3. Confirm with `reuse spdx | grep <file>` that it resolves to the right license.

(In the org today, `xfleet` and `kaban_ops` carry shadcn/ui components as MIT.)

## Verifying & gotchas

- **Authoritative check:** `reuse lint` (REUSE tool ≥ 6). CI runs it on every
  push/PR; a red check blocks the merge.
- `reuse lint` passing means *every file has some copyright + license* — it does
  **not** verify the attribution is correct or the license is AGPL. Those are
  separate, manual judgments (hence the third-party scan).
- The license must be the explicit **`-or-later`** grant. Per AGPLv3 §14, bare
  `AGPL-3.0` binds to version 3 only; the "or any later version" line inside the
  LICENSE body is FSF template text, not a grant the project made.
- Our Code of Conduct is an **original** policy under AGPL — not the Contributor
  Covenant — so repos stay single-license (no CC-BY-4.0).
- Don't rewrite historical `CHANGELOG` entries to match renamed files; they record
  what actually happened.

## What is *not* automatic

- **Governance** reaches every repo — even a blank one — through this repo's
  defaults.
- **Licensing / REUSE / CI** reach a new repo **only if it is created from the
  template**. A repo started from scratch must be migrated with the steps above.

---

Maintained in the [`.github`](https://github.com/The-Fisher-Slopworks-Co/.github)
repo. Last reviewed 2026-06.
