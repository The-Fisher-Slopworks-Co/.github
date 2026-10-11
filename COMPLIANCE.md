<!--
SPDX-FileCopyrightText: 2026 The Fisher Slopworks Co
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Compliance standard

How every The Fisher Slopworks Co repository handles **licensing**, **REUSE**, and
**governance** — what each repo must contain, where each piece lives, and how to
add or migrate a project. This is the single reference for licensing. The
machinery that ships the standard lives in one repo:

- [`.github`](https://github.com/The-Fisher-Slopworks-Co/.github) (this repo): the
  org-wide governance defaults, PR and issue templates and reusable workflows,
  inherited or called by every repo.

Everything beyond licensing (CI, PR rules, tooling, Definition of done) is in
[STANDARD.md](STANDARD.md).

## The standard, in one glance

Every project repository must:

1. Be licensed **AGPL-3.0-or-later** — the explicit `-or-later` variant, never bare
   `AGPL-3.0` or `AGPL-3.0-only`.
2. Be **[REUSE](https://reuse.software/) 3.x compliant** — `reuse lint` passes,
   enforced by CI on every push and pull request.
3. Carry the canonical license text and a `REUSE.toml`, copyright
   **`<year> The Fisher Slopworks Co`**.
4. **Not** ship its own Code of Conduct / Security policy / Contributing guide —
   those are inherited from this `.github` repo, as are the PR and issue
   templates (a repo may keep its own issue templates when they ask for
   project-specific details; see [STANDARD.md](STANDARD.md) A6).
5. Keep dependencies and CI actions current via **Dependabot**, configured as in
   [STANDARD.md → Dependabot](STANDARD.md#dependabot).

Genuine third-party files keep their own license — see
[Third-party code](#third-party-code-multiple-licenses). Forks of outside
projects are the one exception to points 1 and 3: they keep their upstream
license and copyright but are still REUSE compliant — see
[Forks of outside projects](#forks-of-outside-projects).

## Where each piece lives

| Requirement | File(s) in the repo | Canonical value |
|---|---|---|
| License text | `LICENSE` (root) **and** `LICENSES/AGPL-3.0-or-later.txt` | `LICENSE` is the output of `reuse download AGPL-3.0-or-later` (official SPDX text); `LICENSES/AGPL-3.0-or-later.txt` is a symlink to `../LICENSE` |
| License declared (machine) | `package.json` `"license"` / `Cargo.toml` `license` | `AGPL-3.0-or-later` |
| License declared (prose) | `README.md` → `## License` section | `AGPL-3.0-or-later. See [LICENSE](LICENSE).` |
| REUSE config | `REUSE.toml` | `**` wildcard, holder `<year> The Fisher Slopworks Co`, `AGPL-3.0-or-later` |
| REUSE CI | `.github/workflows/reuse.yml` | calls this repo's reusable `reuse.yml` |
| Dependabot | `.github/dependabot.yml` | see [STANDARD.md → Dependabot](STANDARD.md#dependabot) |
| Code of Conduct | *(none — inherited)* | this repo's `CODE_OF_CONDUCT.md` |
| Security policy | *(none — inherited)* | this repo's `SECURITY.md` (contact `security@slopworks.org`) |
| Contributing guide | *(none — inherited)* | this repo's `CONTRIBUTING.md` |
| PR / issue templates | *(none — inherited; own issue templates allowed)* | this repo's `.github/pull_request_template.md` and `.github/ISSUE_TEMPLATE/` |

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

name: REUSE
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
permissions:
  contents: read
jobs:
  reuse:
    uses: The-Fisher-Slopworks-Co/.github/.github/workflows/reuse.yml@main
```

`.github/dependabot.yml`: see [STANDARD.md → Dependabot](STANDARD.md#dependabot).

Inline SPDX header for source files (optional but encouraged; use the file's
comment syntax, e.g. `//`, `#`, `--`):

```text
SPDX-FileCopyrightText: 2026 The Fisher Slopworks Co
SPDX-License-Identifier: AGPL-3.0-or-later
```

## Adding a new project

There is no template repository. Create an empty repo, then bring it to the
standard exactly like an existing one: run the `slopworks-standardize` Claude
skill on a branch (or follow
[Migrating an existing project](#migrating-an-existing-project) plus the
[STANDARD.md](STANDARD.md) checklist by hand) and open a PR. Governance docs are
inherited automatically, so **don't add your own**.

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
   reuse download AGPL-3.0-or-later --output LICENSE   # root file, so GitHub detects the license
   mkdir -p LICENSES
   ln -s ../LICENSE LICENSES/AGPL-3.0-or-later.txt      # REUSE reads the text through the link
   ```
4. **Add `REUSE.toml`** and **`.github/workflows/reuse.yml`** (the
   reusable-workflow caller above), and **`.github/dependabot.yml`** as in
   [STANDARD.md → Dependabot](STANDARD.md#dependabot).
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
   This one is a regular file: only the project's own license is a symlink to
   the root `LICENSE`.
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

## Forks of outside projects

A fork of a project the org does not own (today: `cli`, a fork of
[gotd/cli](https://github.com/gotd/cli)) keeps the upstream license and its
upstream copyright holders. It is not relicensed to AGPL, because the bulk of
its code is not the org's to license; our changes there are contributed under
the upstream license.

It still uses REUSE: `reuse lint` passes and CI calls the reusable `reuse.yml`.
`LICENSES/<SPDX-ID>.txt` is a symlink to the upstream root `LICENSE` (for
`cli`: `LICENSES/MIT.txt -> ../LICENSE`), and `REUSE.toml` annotates the
files with the upstream license and the upstream copyright holders instead of
AGPL and the org. For `cli` that is:

```toml
version = 1

[[annotations]]
path = "**"
precedence = "closest"
SPDX-FileCopyrightText = "gotd contributors"
SPDX-License-Identifier = "MIT"
```

The upstream `LICENSE` file stays as it is. The rest of the standard
(workflows, PR rules, Definition of done) applies as usual.

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
- **Licensing / REUSE / CI / Dependabot** reach a repo **only once it is brought
  to the standard** with the steps above; a new repo starts empty. Once there,
  changes to the reusable workflows here reach it automatically.

---

Maintained in the [`.github`](https://github.com/The-Fisher-Slopworks-Co/.github)
repo. Last reviewed 2026-06.
