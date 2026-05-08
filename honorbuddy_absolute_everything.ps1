# ==============================================================================
# HONORBUDDY ABSOLUTE EVERYTHING ARCHIVE SYSTEM
# ===============================================================================
# Archives TOUT pour TOUTES les versions WoW
# - Toutes expansions (Vanilla → Dragonflight)
# - Mappings 3D pour chaque version
# - Profiles compatibles
# - Addons + dépendances
# - Correspondances version-asset complètes
# ==============================================================================

param(
    [int]$MaxCrawlDepth = 6,
    [int]$MaxRetries = 5,
    [int]$TimeoutSeconds = 60,
    [string]$OutputDir = "C:\Honorbuddy_ABSOLUTE_ARCHIVE",
    [int]$MaxUrlsPerSearch = 200,
    [switch]$IncludePrivateServers = $true,
    [switch]$IncludeAddons = $true,
    [switch]$IncludeMeshes = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# ==================== MATRICE COMPLÈTE DES VERSIONS WOW ====================

$WoWVersions = @(
    # Vanilla
    @{ Name = "Vanilla"; Patch = "1.12.1"; Code = "vanilla"; Years = @(2004,2005,2006); ClientVersions = @("1.8","1.9","1.10","1.11","1.12") },

    # Burning Crusade
    @{ Name = "Burning Crusade"; Patch = "2.4.3"; Code = "tbc"; Years = @(2007,2008); ClientVersions = @("2.0","2.1","2.2","2.3","2.4") },

    # Wrath of the Lich King
    @{ Name = "Wrath of the Lich King"; Patch = "3.3.5a"; Code = "wotlk"; Years = @(2008,2009,2010); ClientVersions = @("3.0","3.1","3.2","3.3") },

    # Cataclysm
    @{ Name = "Cataclysm"; Patch = "4.3.4"; Code = "cata"; Years = @(2010,2011); ClientVersions = @("4.0","4.1","4.2","4.3") },

    # Mists of Pandaria
    @{ Name = "Mists of Pandaria"; Patch = "5.4.8"; Code = "mop"; Years = @(2012,2013); ClientVersions = @("5.0","5.1","5.2","5.3","5.4") },

    # Warlords of Draenor
    @{ Name = "Warlords of Draenor"; Patch = "6.2.4"; Code = "wod"; Years = @(2014,2015); ClientVersions = @("6.0","6.1","6.2") },

    # Legion
    @{ Name = "Legion"; Patch = "7.3.5"; Code = "legion"; Years = @(2016,2017); ClientVersions = @("7.0","7.1","7.2","7.3") },

    # Battle for Azeroth
    @{ Name = "Battle for Azeroth"; Patch = "8.3.7"; Code = "bfa"; Years = @(2018,2019); ClientVersions = @("8.0","8.1","8.2","8.3") },

    # Shadowlands
    @{ Name = "Shadowlands"; Patch = "9.2.7"; Code = "sl"; Years = @(2020,2021); ClientVersions = @("9.0","9.1","9.2") },

    # Dragonflight
    @{ Name = "Dragonflight"; Patch = "10.2.7"; Code = "df"; Years = @(2022,2023); ClientVersions = @("10.0","10.1","10.2") }
)

$PrivateServers = @(
    @{ Name = "Northrend"; Type = "WOTLK"; URL = "northrend" },
    @{ Name = "Warmane"; Type = "Multi"; URL = "warmane" },
    @{ Name = "Kronos"; Type = "Vanilla"; URL = "kronos" },
    @{ Name = "Atlantiss"; Type = "Cata"; URL = "atlantiss" },
    @{ Name = "Tauri"; Type = "MOP"; URL = "tauri" }
)

# ==================== LOGGING ====================

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = @{ INFO = "Cyan"; SUCCESS = "Green"; WARNING = "Yellow"; ERROR = "Red"; DISCOVERY = "Magenta" }[$Level]
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

function Write-Progress-Bar {
    param([int]$Current, [int]$Total, [string]$Activity)
    $percent = [math]::Round(($Current / $Total) * 100)
    Write-Host "`r[$Activity] $Current/$Total ($percent%)" -NoNewline -ForegroundColor Cyan
}

# ==================== WEB REQUESTS ====================

function Invoke-WebRequestSafe {
    param([string]$Uri, [int]$Retries = 2, [int]$TimeoutSeconds = 30, [string]$OutputPath = $null)

    for ($i = 1; $i -le $Retries; $i++) {
        try {
            $params = @{
                Uri = $Uri
                TimeoutSec = $TimeoutSeconds
                ErrorAction = "Stop"
                UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0"
                MaximumRedirection = 5
            }

            if ($OutputPath) { $params["OutFile"] = $OutputPath }

            return Invoke-WebRequest @params
        } catch {
            if ($i -lt $Retries) { Start-Sleep -Seconds (1 + $i) }
        }
    }
    return $null
}

# ==================== GENERATION DE REQUÊTES EXHAUSTIVES ====================

function Generate-SearchQueries {
    Write-Log "Generating exhaustive search queries for ALL versions..." "DISCOVERY"

    $queries = @()

    foreach ($version in $WoWVersions) {
        $name = $version.Name
        $patch = $version.Patch
        $code = $version.Code

        # Requêtes par version + variantes
        $queries += @(
            "Honorbuddy $name $patch profiles",
            "$code WoW bot profiles repository",
            "Honorbuddy $name meshes navigation grids",
            "$code quest profiles bot profiles",
            "Honorbuddy $patch daemon profiles",
            "$name $patch profile pack bot",
            "WoW $patch Honorbuddy combat routines",
            "$code .hbs profile files",
            "Honorbuddy $patch installer download",
            "$code dungeon profiles Honorbuddy",
            "Honorbuddy $name PvP profiles",
            "$patch dailies profiles Honorbuddy",
            "Honorbuddy $name leveling 1-max",
            "$code farming profiles bot",
            "Honorbuddy $name garrison profile"
        )
    }

    # Requêtes de meshes spécifiques
    $queries += @(
        "hbmeshes all versions download",
        "Honorbuddy navigation meshes complete archive",
        "WoW navmesh all patches all zones",
        "hbmeshes github archive all",
        "meshcompiler Honorbuddy all versions",
        "navigationmesh bot all expansions",
        "mesh.zip Honorbuddy complete"
    )

    # Requêtes d'addons compatibles
    if ($IncludeAddons) {
        $queries += @(
            "Honorbuddy addons all versions",
            "Wow addons Honorbuddy compatible",
            "bot addons Lua scripts all versions",
            "combat addons Honorbuddy profiles",
            "gathering addons bot integration",
            "addons compatible with Honorbuddy all patches"
        )
    }

    # Requêtes serveurs privés
    if ($IncludePrivateServers) {
        foreach ($server in $PrivateServers) {
            $queries += @(
                "Honorbuddy $($server.Name) profiles $($server.Type)",
                "$($server.Name) bot profiles Honorbuddy",
                "Honorbuddy $($server.Type) server profiles",
                "$($server.Name) Honorbuddy database quests"
            )
        }
    }

    # Requêtes Google Dorking avancées
    $queries += @(
        "site:github.com/brian8544 Honorbuddy",
        "site:github.com Honorbuddy profiles .hbs",
        "site:github.com Singular combat routine WoW",
        "site:ownedcore.com Honorbuddy profiles",
        "site:archive.org Honorbuddy installer",
        "filetype:zip Honorbuddy profiles",
        "filetype:exe Honorbuddy setup",
        "downloads.buddyauth.com archive",
        "bosslandgmbh Honorbuddy downloads",
        "code.google.com/p/hbmeshes files"
    )

    # Requêtes par année (historique)
    foreach ($version in $WoWVersions) {
        foreach ($year in $version.Years) {
            $queries += @(
                "Honorbuddy $($version.Name) $year profiles",
                "WoW bot profiles $year $($version.Patch)"
            )
        }
    }

    # Requêtes de variantes
    $queries += @(
        "Honorbuddy modified profiles custom routines",
        "Honorbuddy profiles optimized speed leveling",
        "Honorbuddy profiles BGing honor farm",
        "Honorbuddy questing profiles fastest",
        "Honorbuddy dungeon profiles speed run",
        "Honorbuddy raid profiles optimized",
        "Honorbuddy farming routes profiles",
        "Honorbuddy multi-boxing profiles",
        "Honorbuddy detection avoidance profiles"
    )

    Write-Log "Generated $(($queries | Measure-Object).Count) total search queries" "SUCCESS"

    return $queries | Sort-Object -Unique
}

# ==================== CRAWLING AVEC MAPPING VERSION ====================

function Extract-VersionFromContent {
    param([string]$Url, [string]$Content)

    $versionMatches = @()

    foreach ($version in $WoWVersions) {
        foreach ($clientVer in $version.ClientVersions) {
            if ($Url -imatch $clientVer -or $Content -imatch $version.Name) {
                $versionMatches += $version
            }
        }

        if ($Url -imatch $version.Code -or $Content -imatch $version.Patch) {
            $versionMatches += $version
        }
    }

    return $versionMatches | Sort-Object -Unique -Property Name
}

function Classify-Asset {
    param([string]$Url, [string]$Content = $null)

    $classification = @{
        Type = "Unknown"
        Versions = @()
        IsProfile = $false
        IsMesh = $false
        IsAddon = $false
        IsInstaller = $false
        IsRepoUrl = $false
    }

    # Type detection
    if ($Url -imatch '\.git$|github\.com/[^/]+/[^/]+(\.git)?$') {
        $classification.Type = "Repository"
        $classification.IsRepoUrl = $true
    } elseif ($Url -imatch '\.(zip|7z|rar)$' -and $Url -imatch 'mesh|nav|grid') {
        $classification.Type = "MeshArchive"
        $classification.IsMesh = $true
    } elseif ($Url -imatch '\.(zip|7z)$' -and $Url -imatch 'profile|hbs') {
        $classification.Type = "ProfileArchive"
        $classification.IsProfile = $true
    } elseif ($Url -imatch '\.(zip|7z)$' -and $Url -imatch 'addon|lua') {
        $classification.Type = "AddonArchive"
        $classification.IsAddon = $true
    } elseif ($Url -imatch '\.(exe|zip|7z)$' -and $Url -imatch 'setup|install|honorbuddy') {
        $classification.Type = "Installer"
        $classification.IsInstaller = $true
    } elseif ($Url -imatch '\.hbs$|\.lua$') {
        $classification.Type = "ScriptFile"
        $classification.IsProfile = $true
    } else {
        $classification.Type = "Archive"
    }

    # Version detection
    $classification.Versions = Extract-VersionFromContent -Url $Url -Content $Content

    return $classification
}

# ==================== PHASE 0: DISCOVERY EXHAUSTIVE ====================

function Start-ExhaustiveDiscovery {
    Write-Log "╔════════════════════════════════════════════════════════════════╗" "INFO"
    Write-Log "║  PHASE 0: EXHAUSTIVE MULTI-STRATEGY DISCOVERY                 ║" "INFO"
    Write-Log "╚════════════════════════════════════════════════════════════════╝" "INFO"

    $allQueries = Generate-SearchQueries
    $allResults = @{}

    Write-Log "Executing $($allQueries.Count) search queries across multiple strategies..." "INFO"

    $searchStrategies = @(
        @{ Name = "GitHub API"; Queries = $allQueries | Where-Object { $_ -notmatch "site:|filetype:" } },
        @{ Name = "Archive.org"; Queries = $allQueries | Where-Object { $_ -imatch "archive|historic|download" } },
        @{ Name = "Wayback CDX"; Queries = $allQueries | Where-Object { $_ -imatch "buddyauth|code.google" } }
    )

    $queryCount = 0

    foreach ($strategy in $searchStrategies) {
        Write-Log "Strategy: $($strategy.Name) - $($strategy.Queries.Count) queries" "DISCOVERY"

        foreach ($query in $strategy.Queries) {
            $queryCount++
            Write-Progress-Bar -Current $queryCount -Total $allQueries.Count -Activity "Discovering"

            try {
                switch ($strategy.Name) {
                    "GitHub API" {
                        $url = "https://api.github.com/search/repositories?q=$([uri]::EscapeDataString($query))&per_page=50&sort=stars"
                        $response = Invoke-WebRequestSafe -Uri $url -TimeoutSeconds 20

                        if ($response) {
                            $json = $response.Content | ConvertFrom-Json
                            foreach ($item in $json.items) {
                                $allResults[$item.clone_url] = @{
                                    Title = $item.full_name
                                    Source = "GitHub"
                                    Stars = $item.stargazers_count
                                    Updated = $item.updated_at
                                    Query = $query
                                }
                            }
                        }
                    }

                    "Archive.org" {
                        $url = "https://archive.org/advancedsearch.php?q=$([uri]::EscapeDataString($query))&output=json&rows=50"
                        $response = Invoke-WebRequestSafe -Uri $url -TimeoutSeconds 20

                        if ($response) {
                            $json = $response.Content | ConvertFrom-Json
                            foreach ($item in $json.response.docs) {
                                $itemUrl = "https://archive.org/details/$($item.identifier)"
                                $allResults[$itemUrl] = @{
                                    Title = $item.title
                                    Source = "Archive.org"
                                    Date = $item.publicdate
                                    Query = $query
                                }
                            }
                        }
                    }

                    "Wayback CDX" {
                        if ($query -imatch 'buddyauth|code.google') {
                            $domain = if ($query -imatch 'buddyauth') { 'downloads.buddyauth.com' } else { 'code.google.com' }
                            $url = "https://web.archive.org/cdx/search/cdx?url=$domain&output=json&fl=timestamp,original&filter=statuscode:200&collapse=urlkey"
                            $response = Invoke-WebRequestSafe -Uri $url -TimeoutSeconds 20

                            if ($response) {
                                $json = $response.Content | ConvertFrom-Json
                                if ($json.Count -gt 1) {
                                    foreach ($row in $json[1..([Math]::Min(20, $json.Count-1))]) {
                                        $itemUrl = "https://web.archive.org/web/$($row[0])/$($row[1])"
                                        $allResults[$itemUrl] = @{
                                            Title = "$($row[1]) [$($row[0])]"
                                            Source = "Wayback Machine"
                                            Timestamp = $row[0]
                                            Query = $query
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } catch {
                # Continue on error
            }

            Start-Sleep -Milliseconds 500
        }
    }

    Write-Host "`n" -NoNewline
    Write-Log "Discovery phase complete: $(($allResults.Count)) unique URLs discovered" "SUCCESS"

    return $allResults
}

# ==================== PHASE 1: INTELLIGENT CRAWLING WITH VERSION MAPPING ====================

function Start-IntelligentCrawling {
    param($DiscoveredUrls)

    Write-Log "╔════════════════════════════════════════════════════════════════╗" "INFO"
    Write-Log "║  PHASE 1: INTELLIGENT CRAWLING WITH VERSION MAPPING            ║" "INFO"
    Write-Log "╚════════════════════════════════════════════════════════════════╝" "INFO"

    $versionedAssets = @{}
    $crawledCount = 0
    $totalUrls = $DiscoveredUrls.Count

    foreach ($urlItem in $DiscoveredUrls.GetEnumerator()) {
        $crawledCount++
        Write-Progress-Bar -Current $crawledCount -Total $totalUrls -Activity "Crawling"

        $url = $urlItem.Key
        $metadata = $urlItem.Value

        try {
            $response = Invoke-WebRequestSafe -Uri $url -TimeoutSeconds 30

            if ($response) {
                $classification = Classify-Asset -Url $url -Content $response.Content

                # Map to versions
                foreach ($version in $classification.Versions) {
                    $versionKey = "$($version.Code)_$($version.Patch)"

                    if (-not $versionedAssets.ContainsKey($versionKey)) {
                        $versionedAssets[$versionKey] = @{
                            Version = $version
                            Assets = @()
                        }
                    }

                    $versionedAssets[$versionKey].Assets += @{
                        URL = $url
                        Type = $classification.Type
                        Title = $metadata.Title
                        Source = $metadata.Source
                    }
                }
            }
        } catch {
            # Continue on error
        }

        Start-Sleep -Milliseconds 300
    }

    Write-Host "`n" -NoNewline
    Write-Log "Crawling complete: Mapped assets to $($versionedAssets.Count) versions" "SUCCESS"

    return $versionedAssets
}

# ==================== PHASE 2: DOWNLOADING & ORGANIZATION ====================

function Start-DownloadPhase {
    param($VersionedAssets, $OutputDir)

    Write-Log "╔════════════════════════════════════════════════════════════════╗" "INFO"
    Write-Log "║  PHASE 2: DOWNLOADING & ORGANIZATION                          ║" "INFO"
    Write-Log "╚════════════════════════════════════════════════════════════════╝" "INFO"

    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
    }

    # Create version-specific directories
    $downloadCount = 0

    foreach ($versionKey in $VersionedAssets.Keys) {
        $versionData = $VersionedAssets[$versionKey]
        $version = $versionData.Version

        $versionDir = Join-Path $OutputDir "$($version.Code)_$($version.Patch)_$($version.Name -replace ' ', '_')"

        if (-not (Test-Path $versionDir)) {
            New-Item -ItemType Directory -Force -Path $versionDir | Out-Null
        }

        # Create subdirectories
        @("Repositories", "Profiles", "Meshes", "Addons", "Installers", "Tools") | ForEach-Object {
            $subdir = Join-Path $versionDir $_
            if (-not (Test-Path $subdir)) {
                New-Item -ItemType Directory -Force -Path $subdir | Out-Null
            }
        }

        # Download assets
        $assetCount = $versionData.Assets.Count
        $assetIndex = 0

        foreach ($asset in $versionData.Assets) {
            $assetIndex++

            $assetType = $asset.Type
            $subDir = switch ($assetType) {
                "Repository" { "Repositories" }
                "ProfileArchive" { "Profiles" }
                "MeshArchive" { "Meshes" }
                "AddonArchive" { "Addons" }
                "Installer" { "Installers" }
                "ScriptFile" { "Profiles" }
                default { "Tools" }
            }

            $targetDir = Join-Path $versionDir $subDir

            # Clone or download
            if ($assetType -eq "Repository" -and $asset.URL -imatch '\.git') {
                $repoName = Split-Path $asset.URL -Leaf -replace '\.git', ''
                $repoPath = Join-Path $targetDir $repoName

                if (-not (Test-Path $repoPath)) {
                    Write-Log "[$($version.Name)] Cloning: $repoName" "INFO"
                    & git clone -q $asset.URL $repoPath 2>&1 | Out-Null

                    if ($LASTEXITCODE -eq 0) {
                        $downloadCount++
                    }
                }
            } else {
                $filename = Split-Path $asset.URL -Leaf
                if (-not $filename -or $filename.Length -lt 3) {
                    $filename = "download_$(Get-Random).bin"
                }

                $outputPath = Join-Path $targetDir $filename

                if (-not (Test-Path $outputPath)) {
                    Write-Log "[$($version.Name)] Downloading: $filename" "INFO"

                    $result = Invoke-WebRequestSafe -Uri $asset.URL -OutputPath $outputPath -Retries 2

                    if (Test-Path $outputPath) {
                        $fileSize = (Get-Item $outputPath).Length / 1MB
                        Write-Log "✓ Downloaded: $filename ($([math]::Round($fileSize, 2)) MB)" "SUCCESS"
                        $downloadCount++
                    }
                }
            }
        }
    }

    Write-Log "Download phase complete: $downloadCount items retrieved" "SUCCESS"
}

# ==================== PHASE 3: GENERATE MAPPING DATABASE ====================

function Create-VersionMappingDatabase {
    param($VersionedAssets, $OutputDir)

    Write-Log "╔════════════════════════════════════════════════════════════════╗" "INFO"
    Write-Log "║  PHASE 3: CREATING VERSION MAPPING DATABASE                   ║" "INFO"
    Write-Log "╚════════════════════════════════════════════════════════════════╝" "INFO"

    $dbPath = Join-Path $OutputDir "VERSION_MAPPING_DATABASE.txt"

    $db = @"
╔════════════════════════════════════════════════════════════════════════════╗
║       HONORBUDDY COMPLETE VERSION MAPPING DATABASE                        ║
║       Every asset mapped to its compatible WoW versions                    ║
╚════════════════════════════════════════════════════════════════════════════╝

ARCHIVE GENERATED: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
TOTAL VERSIONS ARCHIVED: $($VersionedAssets.Count)

────────────────────────────────────────────────────────────────────────────

"@

    foreach ($versionKey in $VersionedAssets.Keys | Sort-Object) {
        $versionData = $VersionedAssets[$versionKey]
        $version = $versionData.Version

        $db += @"
VERSION: $($version.Name) ($($version.Patch))
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Release Years: $($version.Years -join ', ')
Client Versions: $($version.ClientVersions -join ', ')
Total Assets: $($versionData.Assets.Count)

ASSETS:
"@

        $assetsByType = $versionData.Assets | Group-Object -Property Type

        foreach ($typeGroup in $assetsByType) {
            $db += "`n  $($typeGroup.Name): $($typeGroup.Count) items`n"

            foreach ($asset in $typeGroup.Group) {
                $db += "    - $($asset.Title)`n"
                $db += "      URL: $($asset.URL)`n"
                $db += "      Source: $($asset.Source)`n"
            }
        }

        $db += "`n"
    }

    $db | Out-File -FilePath $dbPath -Encoding UTF8 -Force
    Write-Log "Version mapping database created: $dbPath" "SUCCESS"
}

# ==================== MAIN EXECUTION ====================

Write-Log "╔════════════════════════════════════════════════════════════════╗" "INFO"
Write-Log "║  HONORBUDDY ABSOLUTE EVERYTHING ARCHIVE SYSTEM                ║" "INFO"
Write-Log "║  ALL versions, ALL profiles, ALL addons, ALL meshes           ║" "INFO"
Write-Log "╚════════════════════════════════════════════════════════════════╝" "INFO"

Write-Log "Target: COMPLETE ARCHIVE of Honorbuddy for ALL WoW versions" "INFO"
Write-Log "Versions: $($WoWVersions.Count) expansions (Vanilla → Dragonflight)" "INFO"
Write-Log "Output: $OutputDir" "INFO"
Write-Log ""

try {
    # Phase 0: Discovery
    $discoveredUrls = Start-ExhaustiveDiscovery

    # Phase 1: Crawling with version mapping
    $versionedAssets = Start-IntelligentCrawling -DiscoveredUrls $discoveredUrls

    # Phase 2: Download
    Start-DownloadPhase -VersionedAssets $versionedAssets -OutputDir $OutputDir

    # Phase 3: Create database
    Create-VersionMappingDatabase -VersionedAssets $versionedAssets -OutputDir $OutputDir

    # Final report
    Write-Log ""
    Write-Log "╔════════════════════════════════════════════════════════════════╗" "SUCCESS"
    Write-Log "║  ARCHIVE GENERATION COMPLETE                                  ║" "SUCCESS"
    Write-Log "╚════════════════════════════════════════════════════════════════╝" "SUCCESS"
    Write-Log ""
    Write-Log "Archive Location: $OutputDir" "INFO"
    Write-Log "Total Versions Archived: $($versionedAssets.Count)" "INFO"
    Write-Log "Completion Time: $(Get-Date -Format 'HH:mm:ss')" "INFO"
    Write-Log ""
    Write-Log "Next Steps:" "INFO"
    Write-Log "  1. Check VERSION_MAPPING_DATABASE.txt for complete inventory" "INFO"
    Write-Log "  2. Verify version-specific directories are complete" "INFO"
    Write-Log "  3. Extract and organize assets as needed" "INFO"
    Write-Log "  4. Cross-reference profiles with their compatible versions" "INFO"

} catch {
    Write-Log "CRITICAL ERROR: $_" "ERROR"
    exit 1
}

exit 0