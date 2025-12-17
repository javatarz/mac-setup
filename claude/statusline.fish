#!/usr/bin/env fish
# Claude Code Status Line - Powerline style
# Symlink to ~/.claude/statusline.fish

# Read JSON from stdin
set -l json (cat)

# Parse JSON fields using string manipulation (no jq dependency)
# Extract model display name
set -l model (echo $json | string match -r '"display_name":\s*"([^"]+)"' | tail -1)
set -l model_short (echo $model | string replace -r 'Claude \d+(\.\d+)? ' '' | string lower)

# Extract current working directory
set -l cwd (echo $json | string match -r '"cwd":\s*"([^"]+)"' | tail -1)
set -l cwd_short (echo $cwd | string replace $HOME '~')

# Extract cost and format to 2 decimal places
set -l cost_raw (echo $json | string match -r '"total_cost_usd":\s*([0-9.]+)' | tail -1)
if test -z "$cost_raw"
    set cost_raw "0"
end
set -l cost (printf "%.2f" $cost_raw)

# Get git branch if in a repo
set -l git_info ""
if test -d "$cwd/.git"; or git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1
    set -l branch (git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
    if test -n "$branch"
        set git_info " $branch"
    end
end

# Context window - use actual values from Claude Code
set -l context_size (echo $json | string match -r '"context_window_size":\s*([0-9]+)' | tail -1)
set -l input_tokens (echo $json | string match -r '"input_tokens":\s*([0-9]+)' | tail -1)
set -l cache_creation (echo $json | string match -r '"cache_creation_input_tokens":\s*([0-9]+)' | tail -1)
set -l cache_read (echo $json | string match -r '"cache_read_input_tokens":\s*([0-9]+)' | tail -1)

# Default values if not present
test -z "$context_size"; and set context_size 200000
test -z "$input_tokens"; and set input_tokens 0
test -z "$cache_creation"; and set cache_creation 0
test -z "$cache_read"; and set cache_read 0

# Calculate usage
set -l total_tokens (math "$input_tokens + $cache_creation + $cache_read")
set -l context_pct (math "round($total_tokens * 100 / $context_size)")

# Format for display
set -l max_tokens (math "round($context_size / 1000)")"k"
set -l tokens
if test $total_tokens -ge 1000000
    set tokens (printf "%.1fM" (math "$total_tokens / 1000000"))
else if test $total_tokens -ge 1000
    set tokens (math "round($total_tokens / 1000)")"k"
else
    set tokens $total_tokens
end

# Session duration
set -l duration_ms (echo $json | string match -r '"total_duration_ms":\s*([0-9]+)' | tail -1)
set -l duration_str ""
if test -n "$duration_ms"; and test "$duration_ms" -gt 0
    set -l duration_sec (math "round($duration_ms / 1000)")
    if test $duration_sec -ge 3600
        set duration_str (math "floor($duration_sec / 3600)")"h"(math "floor($duration_sec % 3600 / 60)")"m"
    else if test $duration_sec -ge 60
        set duration_str (math "floor($duration_sec / 60)")"m"(math "$duration_sec % 60")"s"
    else
        set duration_str $duration_sec"s"
    end
end

# Code churn (lines added/removed)
set -l lines_added (echo $json | string match -r '"total_lines_added":\s*([0-9]+)' | tail -1)
set -l lines_removed (echo $json | string match -r '"total_lines_removed":\s*([0-9]+)' | tail -1)
test -z "$lines_added"; and set lines_added 0
test -z "$lines_removed"; and set lines_removed 0

# Cache efficiency (percentage of tokens from cache)
set -l cache_pct 0
if test $total_tokens -gt 0
    set cache_pct (math "round($cache_read * 100 / $total_tokens)")
end

# Separators
set -l sep "│"
set -l branch_icon ""

# Bright colors for dark terminals (90-97 range)
set -l reset "\033[0m"
set -l bold "\033[1m"
set -l dim "\033[2m"

set -l white "\033[97m"
set -l gray "\033[90m"
set -l red "\033[91m"
set -l green "\033[92m"
set -l yellow "\033[93m"
set -l blue "\033[94m"
set -l magenta "\033[95m"
set -l cyan "\033[96m"

# Build status line - clean text-based design
set -l status_line ""

# Model (magenta)
set status_line $status_line$magenta$bold"🤖 $model_short"$reset

# Git branch (cyan)
if test -n "$git_info"
    set status_line $status_line" $gray$sep$reset $cyan$branch_icon$git_info"$reset
end

# Directory (blue)
set status_line $status_line" $gray$sep$reset $blue📁 $cwd_short"$reset

# Context with colored percentage
set -l pct_color $green
if test $context_pct -ge 80
    set pct_color $red
else if test $context_pct -ge 50
    set pct_color $yellow
end
set status_line $status_line" $gray$sep$reset $white📊 $tokens/$max_tokens "$pct_color"($context_pct%)"$reset

# Cache (cyan)
set status_line $status_line" $gray$sep$reset $cyan⚡$cache_pct%"$reset

# Code churn (if any)
if test $lines_added -gt 0; or test $lines_removed -gt 0
    set status_line $status_line" $gray$sep$reset $green+$lines_added"$reset"/"$red"-$lines_removed"$reset
end

# Cost (white)
set status_line $status_line" $gray$sep$reset $white💵 \$$cost"$reset

# Duration (if available)
if test -n "$duration_str"
    set status_line $status_line" $gray$sep$reset $white⏱️ $duration_str"$reset
end

echo -e $status_line
