# Contributing

These are the default contribution guidelines for
[The Fisher Slopworks Co](https://github.com/The-Fisher-Slopworks-Co)
repositories. Individual projects may ship their own `CONTRIBUTING.md` with
stack-specific setup and test commands — when they do, that file takes
precedence over this one.

## Before you start

- Read the project's `README.md` for how to build, run, and test it.
- Open an issue to discuss anything substantial before sending a large change.
- Keep pull requests focused; add tests for new behavior; make sure the
  project's test command passes.

## License & REUSE compliance

Every Slopworks project is licensed under **AGPL-3.0-or-later** and is
[REUSE](https://reuse.software/)-compliant. By submitting a contribution you
agree that it is licensed under **AGPL-3.0-or-later**.

Every file must carry copyright and license information — either an inline SPDX
header (for source code and YAML) or an entry in the project's `REUSE.toml` (for
JSON, binaries, and docs that can't hold a comment). The inline header is two
lines, using the file language's comment syntax:

```text
SPDX-FileCopyrightText: 2026 The Fisher Slopworks Co
SPDX-License-Identifier: AGPL-3.0-or-later
```

Verify before opening a pull request — CI enforces this on every push:

```bash
reuse lint          # must report "compliant"
```

## Code of Conduct

All participation is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By
participating you are expected to uphold it.

## Reporting bugs & vulnerabilities

- **Bugs / feature requests:** open a GitHub issue on the relevant repository.
- **Security vulnerabilities:** follow [`SECURITY.md`](SECURITY.md) — please do
  **not** open a public issue for security reports.

## Starting a new project

New repositories should be created from the
[`template`](https://github.com/The-Fisher-Slopworks-Co/template) repository,
which ships this licensing and governance baseline ready to go.
