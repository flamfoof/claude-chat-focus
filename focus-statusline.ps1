#!/usr/bin/env pwsh
# Reads Claude Code's statusline JSON on stdin and prints a per-session focus
# badge. State is written by /focus-mode into $env:USERPROFILE\.claude\.focus-state\<session_id>.

$ESC = [char]0x1b
$inputJson = $input | Out-String

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

Write-Output $badge