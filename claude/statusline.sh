#!/bin/bash
# Claude Code statusline: model (coloured), dir/branch/PR, ctx bar, cost, rate limits
input=$(cat)

# One jq call; unit-separator delimited so empty fields survive `read`
IFS=$'\x1f' read -r model mid cwd proj used cost dur added removed effort five seven pr_num pr_url pr_state wt cache < <(
  echo "$input" | jq -r '[
    .model.display_name // "?", .model.id // "",
    .workspace.current_dir // .cwd // "", .workspace.project_dir // "",
    .context_window.used_percentage // "", .cost.total_cost_usd // 0,
    .cost.total_duration_ms // 0, .cost.total_lines_added // 0, .cost.total_lines_removed // 0,
    .effort.level // "", .rate_limits.five_hour.used_percentage // "",
    .rate_limits.seven_day.used_percentage // "",
    .pr.number // "", .pr.url // "", .pr.review_state // "",
    .workspace.git_worktree // "", (.prompt_cache.warm // "")
  ] | map(tostring) | join("\u001f")'
)

R=$'\e[0m'; DIM=$'\e[2m'; B=$'\e[1m'
c() { printf '\e[38;5;%sm' "$1"; }

# Model colour: size gradient blue -> sky -> orange -> red (safe for deuteranopia: blue/yellow axis,
# with lightness steps), plus a tier glyph so size is not colour-only.
case "$mid$model" in
  *[Hh]aiku*)  mc=33;  tier="▂" ;; # deep blue
  *[Ss]onnet*) mc=75;  tier="▄" ;; # sky blue
  *[Oo]pus*)   mc=208; tier="▆" ;; # orange
  *[Ff]able*)  mc=196; tier="█" ;; # red
  *)           mc=250; tier="·" ;;
esac

# Threshold colour: green < 50 <= yellow < 75 <= red (blue/orange/red friendly for daltonized themes)
level() { # $1 = pct
  local p=${1%.*}
  if   [ "$p" -ge 75 ]; then c 203
  elif [ "$p" -ge 50 ]; then c 214
  else c 78; fi
}

dir="$(basename "${proj:-$cwd}")${cwd#"${proj:-$cwd}"}"
branch=$(cd "$cwd" 2>/dev/null && git --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)

# Line 1: model, effort, dir, branch, PR
l1="$B$(c $mc)$tier $model$R"
[ -n "$effort" ] && l1="$l1 $DIM$effort$R"
l1="$l1 ${DIM}|$R $dir"
[ -n "$branch" ] && l1="$l1 ${DIM}|$R $(c 141)$branch$R"
[ -n "$wt" ] && l1="$l1 $DIM(wt:$wt)$R"
if [ -n "$pr_num" ]; then
  case "$pr_state" in
    approved) pc=78 ;; changes_requested) pc=203 ;; pending) pc=214 ;; *) pc=245 ;;
  esac
  l1="$l1 ${DIM}|$R$(c $pc)"$'\e]8;;'"$pr_url"$'\a'"#$pr_num${pr_state:+ $pr_state}"$'\e]8;;\a'"$R"
fi

# Line 2: ctx bar, cost, rate limits, time, lines
l2=""
if [ -n "$used" ]; then
  p=$(printf '%.0f' "$used"); filled=$((p / 10)); [ $filled -gt 10 ] && filled=10
  bar=""; for i in 1 2 3 4 5 6 7 8 9 10; do [ $i -le $filled ] && bar="${bar}█" || bar="${bar}░"; done
  l2="ctx $(level "$p")$bar $p%$R"
  [ "$p" -ge 85 ] && l2="$l2 $(c 203)${B}compact!$R"
fi
l2="$l2 ${DIM}|$R $(c 222)\$$(printf '%.2f' "$cost")$R"
for pair in "5h:$five" "7d:$seven"; do
  [ -n "${pair#*:}" ] && { v=$(printf '%.0f' "${pair#*:}"); l2="$l2 ${DIM}|$R ${pair%%:*} $(level "$v")$v%$R"; }
done
m=$((dur / 60000)); l2="$l2 ${DIM}|$R $DIM${m}m$R"
if [ "$added" != 0 ] || [ "$removed" != 0 ]; then
  l2="$l2 ${DIM}|$R$(c 78)+$added$R $(c 203)-$removed$R"
fi
[ "$cache" = "false" ] && l2="$l2 ${DIM}| cache cold$R"

printf '%s\n%s\n' "$l1" "$l2"
