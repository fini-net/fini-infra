# Activity-graph self-hosting recipes for fini-infra
#
# The activity-graph app is managed by OpenTofu in l7_application/activity-graph/.
# Use `just tf-plan l7_application/activity-graph` and `just tf-apply` to
# manage the deployment. These recipes provide supporting utilities (clone
# the fork for local dev, print the live URL, smoke-test the endpoint).
#
# See chicks-net/www-chicks-net#371 for the self-hosting rationale
# (upstream Vercel deployment is billing-locked).

ag_fork_repo := "fini-net/github-readme-activity-graph"
ag_fork_branch := "deploy"
ag_tf_dir := "l7_application/activity-graph"

# clone (or update) the activity-graph fork locally and print its path
# useful for local development/testing of the fork itself
[group('activity-graph')]
activity-graph-clone:
    #!/usr/bin/env bash
    # shellcheck disable=SC1083
    set -euo pipefail
    CLONE_DIR="{{justfile_directory()}}/.cache/github-readme-activity-graph"
    if [[ -d "$CLONE_DIR/.git" ]]; then
        echo "{{BLUE}}Updating existing clone at $CLONE_DIR{{NORMAL}}" >&2
        git -C "$CLONE_DIR" fetch origin >&2
        git -C "$CLONE_DIR" checkout {{ag_fork_branch}} >&2
        git -C "$CLONE_DIR" reset --hard "origin/{{ag_fork_branch}}" >&2
    else
        echo "{{BLUE}}Cloning {{ag_fork_repo}} (branch {{ag_fork_branch}}) to $CLONE_DIR{{NORMAL}}" >&2
        mkdir -p "$(dirname "$CLONE_DIR")"
        git clone --branch {{ag_fork_branch}} "https://github.com/{{ag_fork_repo}}" "$CLONE_DIR" >&2
    fi
    echo "$CLONE_DIR"

# print the live activity-graph URL (from Terraform output)
[group('activity-graph')]
activity-graph-url:
    #!/usr/bin/env bash
    # shellcheck disable=SC1083
    set -euo pipefail
    just tf-output {{ag_tf_dir}} -raw live_url

# smoke-test the live /graph endpoint (verifies it returns a real SVG, not
# the "Can't fetch any contribution" error-graph)
[group('activity-graph')]
activity-graph-verify username="chicks-net":
    #!/usr/bin/env bash
    # shellcheck disable=SC1083
    set -euo pipefail
    # tf-output prints status messages to stdout; extract just the URL
    # (the last line, which is the -raw output)
    BASE_URL=$(just activity-graph-url 2>/dev/null | tail -1)
    URL="${BASE_URL}/graph?username={{username}}&theme=github-compact"
    echo "{{BLUE}}GET $URL{{NORMAL}}"
    SVG=$(mktemp /tmp/justfile.ag-verify.XXXXXX)
    trap 'rm -f "$SVG"' EXIT
    HTTP_CODE=$(curl -s -o "$SVG" -w '%{http_code}' "$URL")
    echo "  HTTP: $HTTP_CODE"
    if [[ "$HTTP_CODE" != "200" ]]; then
        echo "{{RED}}FAIL: expected 200, got $HTTP_CODE{{NORMAL}}"
        exit 1
    fi
    CT=$(curl -sI "$URL" | awk -F': ' 'tolower($1)=="content-type"{print $2}' | tr -d '\r')
    echo "  Content-Type: $CT"
    case "$CT" in
        image/svg+xml*) ;;
        *) echo "{{RED}}FAIL: expected image/svg+xml, got '$CT'{{NORMAL}}"; exit 1 ;;
    esac
    if grep -q "Can't fetch any contribution" "$SVG"; then
        echo "{{RED}}FAIL: got the 'Can't fetch' error-graph — TOKEN is missing or invalid{{NORMAL}}"
        exit 1
    fi
    echo "{{GREEN}}OK: real contribution-graph SVG returned{{NORMAL}}"
