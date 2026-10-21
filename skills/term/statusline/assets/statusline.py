#!/usr/bin/env python3
import json, os, subprocess, sys, time

d = json.load(sys.stdin)

# Catppuccin Mocha
INK, FADED = "#1e1e2e", "#585b70"
MAUVE, BLUE, FLAMINGO = "#cba6f7", "#89b4fa", "#f2cdcd"
TEAL, PEACH, YELLOW, RED = "#94e2d5", "#fab387", "#f9e2af", "#f38ba8"
GREEN = "#a6e3a1"
DEEP_BLUE, DEEP_FLAMINGO = "#3b4a6b", "#5e4853"


def rgb(hex_):
    return ";".join(str(int(hex_[i : i + 2], 16)) for i in (1, 3, 5))


def fg(c):
    return f"\033[38;2;{rgb(c)}m"


def bg(c):
    return f"\033[48;2;{rgb(c)}m"


def pill(color, text, note=None, tail=None, tail_color=None):
    body = f"{bg(color)}{fg(INK)}\033[1m{text}\033[22m"
    if note:
        body += f" {fg(FADED)}{note}"
    end = color
    if tail:
        body += f"{bg(tail_color)}{fg(color)}\033[1m{tail}\033[22m"
        end = tail_color
    return f"\033[0m{fg(color)}{body}\033[0m{fg(end)}\033[0m"


def level(pct, color):
    return RED if pct >= 80 else color


# nf-md-circle_outline + circle_slice_1..8
CIRCLE = ["\U000f0766"] + [chr(0xF0A9E + i) for i in range(8)]


def circle(pct):
    i = 0 if pct <= 0 else min(8, max(1, round(pct / 12.5)))
    return CIRCLE[i]


def until(ts):
    s = max(0, int(ts - time.time()))
    d_, h, m = s // 86400, s % 86400 // 3600, s % 3600 // 60
    return f"{d_}d{h}h" if d_ else f"{h}h{m}m" if h else f"{m}m"


def tokens(n):
    return f"{n / 1e6:.1f}M" if n >= 1e6 else f"{round(n / 1e3)}k"


def branch(cwd):
    try:
        r = subprocess.run(
            ["git", "-C", cwd, "--no-optional-locks", "symbolic-ref", "--short", "-q", "HEAD"],
            capture_output=True, text=True, timeout=1,
        )
        if r.stdout.strip():
            return r.stdout.strip()
        r = subprocess.run(
            ["git", "-C", cwd, "--no-optional-locks", "rev-parse", "--short", "HEAD"],
            capture_output=True, text=True, timeout=1,
        )
        return r.stdout.strip() or None
    except Exception:
        return None


cwd = d.get("workspace", {}).get("current_dir") or d.get("cwd") or os.getcwd()
pills = [pill(MAUVE, f"\U000f06a9 {d.get('model', {}).get('display_name', '?')}")]

cost = d.get("cost") or {}
added, removed = cost.get("total_lines_added") or 0, cost.get("total_lines_removed") or 0
loc = f" {fg(GREEN)}+{added} {fg(RED)}-{removed}" if added or removed else None

home = os.path.expanduser("~")
name = "~" if cwd == home else os.path.basename(cwd.rstrip("/")) or "/"
# lines changed ride on the git pill, or on the folder pill outside a repo
if b := branch(cwd):
    pills.append(pill(BLUE, f" {name}"))
    pills.append(pill(FLAMINGO, f"\uf418 {b}", tail=loc, tail_color=DEEP_FLAMINGO))
else:
    pills.append(pill(BLUE, f" {name}", tail=loc, tail_color=DEEP_BLUE))

cw = d.get("context_window") or {}
if (ctx := cw.get("used_percentage")) is not None:
    u = cw.get("current_usage") or {}
    used = sum(u.get(k) or 0 for k in ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens"))
    pills.append(pill(level(ctx, TEAL), f"{circle(ctx)} {tokens(used)}"))

limits = d.get("rate_limits") or {}
for key, label, color in (("five_hour", "5h", PEACH), ("seven_day", "wk", YELLOW)):
    if (lim := limits.get(key)) and (pct := lim.get("used_percentage")) is not None:
        reset = lim.get("resets_at")
        pills.append(pill(level(pct, color), f"{circle(pct)} {label} {round(pct)}%", until(reset) if reset else None))

print(" ".join(pills))
