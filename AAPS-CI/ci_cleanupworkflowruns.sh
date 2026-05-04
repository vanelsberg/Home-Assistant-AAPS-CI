#!/bin/bash

# Script to clean up old workflow runs for a specific GitHub Actions workflow.
# Usage:
#   ./cleanup-workflow-runs.sh [WORKFLOW_ID] [--dry-run]
# Example:
#   ./cleanup-workflow-runs.sh --dry-run

# pipefail: exit on error, undefined variable, or failed pipe
set -euo pipefail

# Load configuration variables
source ./ci.config

# Deafault values for pagination and dry-run mode
API="https://api.github.com"
DRY_RUN=false
PER_PAGE=50
page=1

: "${WF_PERSONAL_ACCESS_TOKEN:?Set WF_PERSONAL_ACCESS_TOKEN config var (personal access token with repo/workflow permissions)}"
: "${WF_KEEP:?Set WF_KEEP config var (minimum workflow rund to keep)}"

# Parse commandline arguments
for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=true
            ;;
        ''|*[!0-9]*)
            # ignore non-numeric args except --dry-run
            ;;
        *)
            # numeric argument → workflow ID override
            WORKFLOW_ID="$arg"
            ;;
    esac
done

all_ids=()

echo "Fetching workflow runs for ${OWNER}/${REPO} workflow ${WORKFLOW_ID} ..."
if [[ $DRY_RUN == true ]];
then 
  echo "DRY_RUN only";
fi

while :; do
  # This is a public repro, so no AUTH required for fetching runs; if it were private, we'd need to add an Authorization header here.
  resp=$(curl -sS \
-H "Authorization: Bearer ${WF_PERSONAL_ACCESS_TOKEN}" \
"https://api.github.com/repos/${OWNER}/${REPO}/actions/workflows/${WORKFLOW_ID}/runs?per_page=${PER_PAGE}&page=${page}")

  ids=( $(echo "$resp" | jq -r '.workflow_runs[]?.id') )
  if [[ ${#ids[@]} -eq 0 ]];
	then
    break;
	fi
  echo -e "Runs found: ${page}: ${#ids[@]}";

  all_ids+=( "${ids[@]}" )
  ((page++))
  # small pause to be polite
  sleep 0.5
done

# Log results and check if we have more than $WF_KEEP runs; if not, exit.
total=${#all_ids[@]}
echo -e "Total runs found: $total"
if (( $total <= $WF_KEEP )); then
  echo -e "Nothing to delete (total <= KEEP=$WF_KEEP) or Github access rate limit reached (try later)."
  exit 0
fi

# API returns runs in descending created_at order by default; first elements are newest.
to_delete=( "${all_ids[@]:$WF_KEEP}" )
echo -e "Keeping newest $WF_KEEP runs; deleting ${#to_delete[@]} older runs."

for run_id in "${to_delete[@]}"; do
  if $DRY_RUN; then
    echo "[DRY-RUN] Would delete run id: $run_id"
  else
    echo "Deleting run id: $run_id"
    curl -sS -X DELETE \
      -H "Authorization: Bearer ${WF_PERSONAL_ACCESS_TOKEN}" \
      -H "Accept: application/vnd.github+json" \
      "${API}/repos/${OWNER}/${REPO}/actions/runs/${run_id}" \
      || echo "Warning: failed to delete run ${run_id}"
#      >/dev/null || echo "Warning: failed to delete run ${run_id}"

    # small pause to avoid bursts
    sleep 0.5
  fi
done

echo "Done."
