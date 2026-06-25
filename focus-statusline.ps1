#!/usr/bin/env pwsh
# Statusline for Claude Code on Windows / native PowerShell.
# Reads the session-state JSON from stdin, looks up the per-session focus
# state file written by /focus, and prints a badge with ANSI color codes.
#
# Install: point "statusCommand" in settings.json to this script.
# State file: $env:USERPROFILE\.claude\.focus-state\<session_id>

$ESC = [char]0x1b
$inputJson = $input | Out-String

# ---- ponytail segment (auto-follows whatever version is installed) ----
$pony = ""
$ponyPs1 = Get-ChildItem "$env:USERPROFILE\.claude\plugins\cache\ponytail\ponytail\*\hooks\ponytail-statusline.ps1" -ErrorAction SilentlyContinue |
  Sort-Object { $_.Directory.Parent.Name -replace '[^\d.]' } |
  Select-Object -Last 1

if ($ponyPs1) {
  $pony = $inputJson | & $ponyPs1.FullName 2>$null
}

# ---- focus segment ----
$sessionId = ""
if ($inputJson -match '"session_id"\s*:\s*"([a-fA-F0-9-]{36})"') {
  $sessionId = $Matches[1]
}

$mode = ""
$stateFile = "$env:USERPROFILE\.claude\.focus-state\$sessionId"
if ($sessionId -and (Test-Path $stateFile)) {
  $mode = (Get-Content $stateFile -Raw).Trim()
}

$badge = switch ($mode) {
  "design" { "${ESC}[1;36m🎨 FOCUS:DESIGN${ESC}[0m" }
  "coding" { "${ESC}[1;33m⚙ FOCUS:CODING${ESC}[0m" }
  default  { "${ESC}[90m○ FOCUS:none${ESC}[0m" }
}

if ($pony) {
  Write-Output "$pony  $badge"
} else {
  Write-Output $badge
}