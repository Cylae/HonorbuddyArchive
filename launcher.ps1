# ==============================================================================
# ABSOLUTE EVERYTHING LAUNCHER
# Exécute le script d'archivage EXHAUSTIF pour TOUT
# ==============================================================================

param(
    [ValidateSet("standard", "aggressive", "ultimate")]
    [string]$Mode = "standard",
    [string]$OutputDir = $null,
    [switch]$SkipPrivateServers = $false,
    [switch]$SkipAddons = $false,
    [switch]$SkipMeshes = $false
)

$modes = @{
    "standard" = @{
        CrawlDepth = 5
        Retries = 4
        TimeoutSeconds = 45
        MaxUrlsPerSearch = 150
        Duration = "~45-60 minutes"
        Description = "Complete archive - balanced approach"
    }
    "aggressive" = @{
        CrawlDepth = 6
        Retries = 5
        TimeoutSeconds = 60
        MaxUrlsPerSearch = 200
        Duration = "~75-90 minutes"
        Description = "Maximum coverage - more comprehensive"
    }
    "ultimate" = @{
        CrawlDepth = 7
        Retries = 6
        TimeoutSeconds = 75
        MaxUrlsPerSearch = 250
        Duration = "~120+ minutes"
        Description = "EVERYTHING - no stone left unturned"
    }
}

# ==================== UI ====================

function Show-Banner {
    Write-Host "`n" -NoNewline
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║        HONORBUDDY ABSOLUTE EVERYTHING ARCHIVE SYSTEM           ║" -ForegroundColor Magenta
    Write-Host "║  Every Version • Every Profile • Every Addon • Every Mesh      ║" -ForegroundColor Magenta
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
}

function Show-Modes {
    Write-Host "MODES DISPONIBLES:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. STANDARD (Par défaut)" -ForegroundColor Green
    Write-Host "   Description: $($modes['standard'].Description)" -ForegroundColor Gray
    Write-Host "   Profondeur:  $($modes['standard'].CrawlDepth)" -ForegroundColor Gray
    Write-Host "   Durée:       $($modes['standard'].Duration)" -ForegroundColor Gray
    Write-Host ""

    Write-Host "2. AGGRESSIVE" -ForegroundColor Green
    Write-Host "   Description: $($modes['aggressive'].Description)" -ForegroundColor Gray
    Write-Host "   Profondeur:  $($modes['aggressive'].CrawlDepth)" -ForegroundColor Gray
    Write-Host "   Durée:       $($modes['aggressive'].Duration)" -ForegroundColor Gray
    Write-Host ""

    Write-Host "3. ULTIMATE" -ForegroundColor Green
    Write-Host "   Description: $($modes['ultimate'].Description)" -ForegroundColor Gray
    Write-Host "   Profondeur:  $($modes['ultimate'].CrawlDepth)" -ForegroundColor Gray
    Write-Host "   Durée:       $($modes['ultimate'].Duration)" -ForegroundColor Gray
    Write-Host ""
}

function Show-Options {
    Write-Host "OPTIONS:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Include Private Servers: " -NoNewline -ForegroundColor White
    Write-Host "$(if ($SkipPrivateServers) { '✗ Non' } else { '✓ Oui' })" -ForegroundColor $(if ($SkipPrivateServers) { 'Red' } else { 'Green' })

    Write-Host "  Include Addons:          " -NoNewline -ForegroundColor White
    Write-Host "$(if ($SkipAddons) { '✗ Non' } else { '✓ Oui' })" -ForegroundColor $(if ($SkipAddons) { 'Red' } else { 'Green' })

    Write-Host "  Include Meshes:          " -NoNewline -ForegroundColor White
    Write-Host "$(if ($SkipMeshes) { '✗ Non' } else { '✓ Oui' })" -ForegroundColor $(if ($SkipMeshes) { 'Red' } else { 'Green' })

    Write-Host ""
}

# ==================== MAIN ====================

Show-Banner

if (-not $modes.ContainsKey($Mode)) {
    Write-Host "Mode invalide: $Mode" -ForegroundColor Red
    Show-Modes
    exit 1
}

$config = $modes[$Mode]

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = "C:\Honorbuddy_ABSOLUTE_ARCHIVE_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
}

# Display configuration
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║         CONFIGURATION                                          ║" -ForegroundColor Yellow
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

Write-Host "Mode:              " -NoNewline -ForegroundColor White
Write-Host "$Mode" -ForegroundColor Cyan

Write-Host "Description:       " -NoNewline -ForegroundColor White
Write-Host "$($config.Description)" -ForegroundColor Cyan

Write-Host "Crawl Depth:       " -NoNewline -ForegroundColor White
Write-Host "$($config.CrawlDepth)" -ForegroundColor Cyan

Write-Host "Max Retries:       " -NoNewline -ForegroundColor White
Write-Host "$($config.Retries)" -ForegroundColor Cyan

Write-Host "Timeout (sec):     " -NoNewline -ForegroundColor White
Write-Host "$($config.TimeoutSeconds)" -ForegroundColor Cyan

Write-Host "Max URLs/search:   " -NoNewline -ForegroundColor White
Write-Host "$($config.MaxUrlsPerSearch)" -ForegroundColor Cyan

Show-Options

Write-Host "Output Directory:  " -NoNewline -ForegroundColor White
Write-Host "$OutputDir" -ForegroundColor Cyan

Write-Host "Estimated Duration: " -NoNewline -ForegroundColor White
Write-Host "$($config.Duration)" -ForegroundColor Cyan

Write-Host ""
Write-Host "VERSIONS COUVERTES:" -ForegroundColor Yellow
Write-Host "  ✓ Vanilla (1.12.1)" -ForegroundColor Green
Write-Host "  ✓ Burning Crusade (2.4.3)" -ForegroundColor Green
Write-Host "  ✓ Wrath of the Lich King (3.3.5a)" -ForegroundColor Green
Write-Host "  ✓ Cataclysm (4.3.4)" -ForegroundColor Green
Write-Host "  ✓ Mists of Pandaria (5.4.8)" -ForegroundColor Green
Write-Host "  ✓ Warlords of Draenor (6.2.4)" -ForegroundColor Green
Write-Host "  ✓ Legion (7.3.5)" -ForegroundColor Green
Write-Host "  ✓ Battle for Azeroth (8.3.7)" -ForegroundColor Green
Write-Host "  ✓ Shadowlands (9.2.7)" -ForegroundColor Green
Write-Host "  ✓ Dragonflight (10.2.7)" -ForegroundColor Green

Write-Host ""
Write-Host "ASSET TYPES ARCHIVÉS:" -ForegroundColor Yellow
Write-Host "  ✓ Git Repositories" -ForegroundColor Green
Write-Host "  ✓ Profiles (.hbs + Lua)" -ForegroundColor Green
Write-Host "  ✓ Navigation Meshes (all zones)" -ForegroundColor Green
Write-Host "  ✓ Addons & Scripts" -ForegroundColor Green
Write-Host "  ✓ Installers & Tools" -ForegroundColor Green
Write-Host "  ✓ Server-specific Content" -ForegroundColor Green

Write-Host ""
$confirm = Read-Host "Start archive generation? (O/n)"

if ($confirm -eq "n" -or $confirm -eq "N") {
    Write-Host "Annulé." -ForegroundColor Yellow
    exit 0
}

# ==================== EXECUTION ====================

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Démarrage du système d'archivage ABSOLU..." -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$scriptPath = Join-Path (Split-Path $PSCommandPath) "honorbuddy_absolute_everything.ps1"

if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: Main script not found at $scriptPath" -ForegroundColor Red
    exit 1
}

# Build arguments
$arguments = @(
    "-OutputDir", $OutputDir,
    "-MaxCrawlDepth", $config.CrawlDepth,
    "-MaxRetries", $config.Retries,
    "-TimeoutSeconds", $config.TimeoutSeconds,
    "-MaxUrlsPerSearch", $config.MaxUrlsPerSearch
)

if ($SkipPrivateServers) {
    $arguments += "-IncludePrivateServers:`$false"
} else {
    $arguments += "-IncludePrivateServers:`$true"
}

if ($SkipAddons) {
    $arguments += "-IncludeAddons:`$false"
} else {
    $arguments += "-IncludeAddons:`$true"
}

if ($SkipMeshes) {
    $arguments += "-IncludeMeshes:`$false"
} else {
    $arguments += "-IncludeMeshes:`$true"
}

# Execute main script
& $scriptPath @arguments

$exitCode = $LASTEXITCODE

# Final message
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "Execution terminée" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

if ($exitCode -eq 0) {
    Write-Host "✓ Archive générée dans: $OutputDir" -ForegroundColor Green
    Write-Host ""
    Write-Host "Prochaines étapes:" -ForegroundColor Yellow
    Write-Host "  1. Vérifier VERSION_MAPPING_DATABASE.txt" -ForegroundColor Gray
    Write-Host "  2. Consulter le répertoire par version" -ForegroundColor Gray
    Write-Host "  3. Extraire/organiser selon les besoins" -ForegroundColor Gray
} else {
    Write-Host "✗ Erreur lors de l'exécution (Code: $exitCode)" -ForegroundColor Red
}

Write-Host ""
exit $exitCode
