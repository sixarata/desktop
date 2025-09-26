# Gather Windows build into release/win64/Sixarata
$ErrorActionPreference = "Stop"

# Clean dest
$dst = Join-Path $PSScriptRoot "..\..\release\win64\Sixarata"
if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
New-Item -ItemType Directory -Path $dst | Out-Null

# Prefer NSIS installer, then install silently into $dst
$nsisDir = "src-tauri\target\release\bundle\nsis"
$msiDir  = "src-tauri\target\release\bundle\msi"

$installer = Get-ChildItem $nsisDir -Filter *.exe -ErrorAction SilentlyContinue | Select-Object -First 1
if ($installer) {
  $absDst = (Resolve-Path $dst).Path -replace '/', '\'
  & $installer.FullName /S /D=$absDst
} else {
  # Fallback: copy raw MSI (Steam is happier with a runnable folder; prefer NSIS above)
  $msi = Get-ChildItem $msiDir -Filter *.msi -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($msi) {
    Copy-Item $msi.FullName (Join-Path $dst "Sixarata.msi")
  } else {
    Write-Error "No NSIS or MSI artifacts found."
  }
}