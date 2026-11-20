param(
    [Parameter(Mandatory)]
    [string]$TargetPath
)

$ErrorActionPreference = "Stop"
$TargetPath = [System.IO.Path]::GetFullPath($TargetPath)

if (-not (Test-Path -LiteralPath $TargetPath)) {
    $null = New-Item -ItemType Directory -Path $TargetPath -Force
}

$TargetPath = (Resolve-Path -LiteralPath $TargetPath).Path
$created = @()
$updated = @()
$skipped = @()

$directories = @(
    "src",
    "ext",
    "dist",
    "openspec\changes",
    "openspec\specs",
    "openspec\archive",
    "docs",
    "presentations",
    "playwright-screenshots"
)

foreach ($directory in $directories) {
    $path = Join-Path $TargetPath $directory
    if (Test-Path -LiteralPath $path) {
        $skipped += "$directory/"
    } else {
        $null = New-Item -ItemType Directory -Path $path -Force
        $created += "$directory/"
    }
}

$projectFile = Join-Path $TargetPath "openspec\project.md"
if (-not (Test-Path -LiteralPath $projectFile)) {
    $content = "# Project Context`n`nОпишите цели проекта, архитектуру и соглашения разработки.`n"
    Set-Content -LiteralPath $projectFile -Value $content -Encoding UTF8
    $created += "openspec/project.md"
} else {
    $skipped += "openspec/project.md"
}

$ignoreFile = Join-Path $TargetPath ".gitignore"
$rules = @(
    ".v8-project.json",
    "*.log",
    "tmp/",
    "playwright-screenshots/*.png",
    "playwright-screenshots/*.jpg",
    "playwright-screenshots/*.jpeg"
)

$existing = if (Test-Path -LiteralPath $ignoreFile) {
    Get-Content -LiteralPath $ignoreFile -Encoding UTF8
} else {
    @()
}

$missing = @($rules | Where-Object { $existing -notcontains $_ })
if ($missing.Count -gt 0) {
    $lines = @($existing)
    if ($lines.Count -gt 0 -and $lines[-1] -ne "") {
        $lines += ""
    }
    $lines += $missing
    Set-Content -LiteralPath $ignoreFile -Value $lines -Encoding UTF8
    if (Test-Path -LiteralPath $ignoreFile) {
        $updated += ".gitignore"
    }
} else {
    $skipped += ".gitignore"
}

Write-Output "Target: $TargetPath"
Write-Output "Created: $($created.Count)"
$created | ForEach-Object { Write-Output "  + $_" }
Write-Output "Updated: $($updated.Count)"
$updated | ForEach-Object { Write-Output "  ~ $_" }
Write-Output "Unchanged: $($skipped.Count)"
