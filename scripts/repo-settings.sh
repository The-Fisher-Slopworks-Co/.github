#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 The Fisher Slopworks Co
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# Apply the org's pull request settings to one repository, idempotently.
#
#   scripts/repo-settings.sh <repo> [required check name]...
#
#   scripts/repo-settings.sh any_talker "check / Type check & tests" "REUSE compliance"
#
# What it sets (see STANDARD.md → Pull request settings):
#   - merge: squash only, commit title = PR title, body = PR body,
#     head branch deleted after merge, auto-merge off;
#   - ruleset "main" on the default branch: no deletion, no force-push,
#     changes only through a squash-merged PR with all review threads
#     resolved, and the given status checks green on an up-to-date branch.
#     Repository admins can bypass it.
#
# With no check names, the checks already required by the existing "main"
# ruleset are kept (none on a first run). Needs `gh` signed in as an org
# admin, and `jq`.
set -euo pipefail

ORG=The-Fisher-Slopworks-Co
GITHUB_ACTIONS_APP_ID=15368

if [[ $# -lt 1 ]]; then
  sed -n '6,22p' "$0" | sed 's/^# \{0,1\}//'
  exit 64
fi

repo=$1
shift

if [[ $(gh api "repos/$ORG/$repo" --jq .archived) == true ]]; then
  echo "$ORG/$repo is archived; skipping." >&2
  exit 0
fi

gh api -X PATCH "repos/$ORG/$repo" --silent \
  -F allow_squash_merge=true \
  -F allow_merge_commit=false \
  -F allow_rebase_merge=false \
  -F allow_auto_merge=false \
  -F delete_branch_on_merge=true \
  -f squash_merge_commit_title=PR_TITLE \
  -f squash_merge_commit_message=PR_BODY
echo "$ORG/$repo: merge settings applied"

existing_id=$(gh api "repos/$ORG/$repo/rulesets" --jq '.[] | select(.name == "main") | .id')

if [[ $# -gt 0 ]]; then
  checks=$(printf '%s\n' "$@" | jq -R --argjson app "$GITHUB_ACTIONS_APP_ID" \
    '{context: ., integration_id: $app}' | jq -s .)
elif [[ -n $existing_id ]]; then
  checks=$(gh api "repos/$ORG/$repo/rulesets/$existing_id" \
    --jq '[.rules[] | select(.type == "required_status_checks") | .parameters.required_status_checks[]]')
else
  checks='[]'
fi

ruleset=$(jq -n --argjson checks "$checks" '{
  name: "main",
  target: "branch",
  enforcement: "active",
  conditions: { ref_name: { include: ["~DEFAULT_BRANCH"], exclude: [] } },
  bypass_actors: [{ actor_id: 5, actor_type: "RepositoryRole", bypass_mode: "always" }],
  rules: ([
    { type: "deletion" },
    { type: "non_fast_forward" },
    { type: "pull_request", parameters: {
        allowed_merge_methods: ["squash"],
        required_approving_review_count: 0,
        required_review_thread_resolution: true,
        dismiss_stale_reviews_on_push: false,
        require_code_owner_review: false,
        require_last_push_approval: false,
        require_extra_approval_for_unattributed_changes: false
    } }
  ] + (if ($checks | length) > 0 then [
    { type: "required_status_checks", parameters: {
        strict_required_status_checks_policy: true,
        do_not_enforce_on_create: false,
        required_status_checks: $checks
    } }
  ] else [] end))
}')

if [[ -n $existing_id ]]; then
  gh api -X PUT "repos/$ORG/$repo/rulesets/$existing_id" --input - --silent <<<"$ruleset"
  echo "$ORG/$repo: ruleset \"main\" updated"
else
  gh api -X POST "repos/$ORG/$repo/rulesets" --input - --silent <<<"$ruleset"
  echo "$ORG/$repo: ruleset \"main\" created"
fi

jq -r '.[] | "  required: \(.context)"' <<<"$checks"
