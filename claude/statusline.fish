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

# Token counting - read from transcript if available
set -l transcript_path (echo $json | string match -r '"transcript_path":\s*"([^"]+)"' | tail -1)
set -l tokens "0k"
set -l max_tokens "200k"

# Context windows:
# - Opus 4.5: 450k
# - Opus 4, Sonnet 4.5, Sonnet 4, Sonnet 3.7: 200k (some have 1M beta)
# - Haiku 4.5, Haiku 3.5: 200k
if string match -q "*opus*" $model_short
    set max_tokens "450k"
end

# Estimate tokens from transcript file size (rough: ~4 chars per token)
if test -n "$transcript_path"; and test -f "$transcript_path"
    set -l file_size (wc -c < "$transcript_path" 2>/dev/null | string trim)
    if test -n "$file_size"
        set -l token_count (math "round($file_size / 4 / 100) / 10")
        if test $token_count -ge 1000
            set tokens (math "round($token_count / 100) / 10")"k"
        else if test $token_count -ge 1
            set tokens $token_count"k"
        else
            set tokens "0.1k"
        end
    end
end

# Powerline characters
set -l sep ""      # \ue0b0
set -l branch_icon "" # \ue0a0

# ANSI colors (works in most terminals)
set -l reset "\033[0m"
set -l bold "\033[1m"
set -l dim "\033[2m"

# Build status line
set -l status_line ""

# Model segment
set status_line $status_line$bold$model_short$reset

# Git segment (if available)
if test -n "$git_info"
    set status_line $status_line" $dim$sep$reset $branch_icon$git_info"
end

# Directory segment
set status_line $status_line" $dim$sep$reset $cwd_short"

# Tokens segment
set status_line $status_line" $dim$sep$reset $tokens/$max_tokens"

# Cost segment
set status_line $status_line" $dim$sep$reset \$$cost"

echo -e $status_line
