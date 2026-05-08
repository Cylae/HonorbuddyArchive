# ==============================================================================
# HONORBUDDY ABSOLUTE EVERYTHING ARCHIVE SYSTEM - APEX PREDATOR (FINAL FORM)
# ==============================================================================
# Archives EVERYTHING for ALL WoW versions (Vanilla -> Dragonflight).
# Relentlessly optimized with User-Agent rotation, GitHub Token authentication,
# strict build mapping, dual-format database generation, and strict IO sanitization.
# ==============================================================================

param(
    [int]$MaxCrawlDepth = 7,
    [int]$MaxRetries = 6,
    [int]$TimeoutSeconds = 75,
    [string]$OutputDir = "C:\Honorbuddy_ABSOLUTE_ARCHIVE",
    [int]$MaxUrlsPerSearch = 250,
    [string]$GitHubToken = "", # Highly recommended to prevent API rate limiting
    [switch]$IncludePrivateServers = $true,
    [switch]$IncludeAddons = $true,
    [switch]$IncludeMeshes = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# ==================== GLOBAL CONFIGURATION ====================

$UserAgents = @(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Safari/605.1.15",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/110.0",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0"
)

# ==================== COMPLETE WOW VERSION MATRIX ====================

$WoWVersions = @(
    @{ Name = "Vanilla"; Patch = "1.12.1"; Code = "vanilla"; Builds = @("5875", "6005"); Years = @(2004,2005,2006); ClientVersions = @("1.8","1.9","1.10","1.11","1.12") },
    @{ Name = "Burning Crusade"; Patch = "2.4.3"; Code = "tbc"; Builds = @("8606"); Years = @(2007,2008); ClientVersions = @("2.0","2.1","2.2","2.3","2.4") },
    @{ Name = "Wrath of the Lich King"; Patch = "3.3.5a"; Code = "wotlk"; Builds = @("12340"); Years = @(2008,2009,2010); ClientVersions = @("3.0","3.1","3.2","3.3") },
    @{ Name = "Cataclysm"; Patch = "4.3.4"; Code = "cata"; Builds = @("15595"); Years = @(2010,2011); ClientVersions = @("4.0","4.1","4.2","4.3") },
    @{ Name = "Mists of Pandaria"; Patch = "5.4.8"; Code = "mop"; Builds = @("18414"); Years = @(2012,2013); ClientVersions = @("5.0","5.1","5.2","5.3","5.4") },
    @{ Name = "Warlords of Draenor"; Patch = "6.2.4"; Code = "wod"; Builds = @("21742"); Years = @(2014,2015); ClientVersions = @("6.0","6.1","6.2") },
    @{ Name = "Legion"; Patch = "7.3.5"; Code = "legion"; Builds = @("26972"); Years = @(2016,2017); ClientVersions = @("7.0","7.1","7.2","7.3") },
    @{ Name = "Battle for Azeroth"; Patch = "8.3.7"; Code = "bfa"; Builds = @("34220"); Years = @(2018,2019); ClientVersions = @("8.0","8.1","8.2","8.3") },
    @{ Name = "Shadowlands"; Patch = "9.2.7"; Code = "sl"; Builds = @("45779"); Years = @(2020,2021); ClientVersions = @("9.0","9.1","9.2") },
    @{ Name = "Dragonflight"; Patch = "10.2.7"; Code = "df"; Builds = @("54505"); Years = @(2022,2023); ClientVersions = @("10.0","10.1","10.2") }
)

$PrivateServers = @(
    @{ Name = "Northrend"; Type = "WOTLK"; URL = "northrend" },
    @{ Name = "Warmane"; Type = "Multi"; URL = "warmane" },
    @{ Name = "Kronos"; Type = "Vanilla"; URL = "kronos" },
    @{ Name = "Atlantiss"; Type = "Cata"; URL = "atlantiss" },
    @{ Name = "Tauri"; Type = "MOP"; URL = "tauri" }
)

# ==================== LOGGING SYSTEM ====================

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

# ==================== WEB ENGINE ====================

function Get-RandomUserAgent {
    return $UserAgents | Get-Random
}

function Invoke-WebRequestSafe {
    param(
        [string]$Uri,
        [int]$Retries = 2,
        [int]$TimeoutSeconds = 30,
        [string]$OutputPath = $null,
        [hashtable]$Headers = @{}
    )

    for ($i = 1; $i -le $Retries; $i++) {
        try {
            $params = @{
                Uri = $Uri
                TimeoutSec = $TimeoutSeconds
                ErrorAction = "Stop"
                UserAgent = Get-RandomUserAgent
                MaximumRedirection = 5
                Headers = $Headers
            }

            if ($OutputPath) { $params["OutFile"] = $OutputPath }

            return Invoke-WebRequest @params
        } catch {
            if ($i -lt $Retries) {
                $backoff = 2 * $i
                Start-Sleep -Seconds $backoff
            }
        }
    }
    return $null
}

# ==================== EXHAUSTIVE QUERY GENERATION ====================

function Generate-SearchQueries {
    Write-Log "Generating nuclear-level search queries for all targets..." "DISCOVERY"

    $queries = @()

    foreach ($version in $WoWVersions) {
        $name = $version.Name
        $patch = $version.Patch
        $code = $version.Code

        $queries += @(
            "Honorbuddy $name $patch profiles",
            "$code WoW bot profiles repository",
            "Honorbuddy $name meshes navigation grids",
            "$code quest profiles bot profiles",
            "Honorbuddy $patch daemon profiles",
            "$name $patch profile pack bot",
            "WoW $patch Honorbuddy combat routines",
            "$code dungeon profiles Honorbuddy",
            "Honorbuddy $name PvP profiles",
            "$patch dailies profiles Honorbuddy",
            "Honorbuddy $name leveling 1-max",
            "$code farming profiles bot"
        )

        foreach ($build in $version.Builds) {
            $queries += "Honorbuddy build $build profiles"
            $queries += "hbmeshes $build download"
        }
    }

    $queries += @(
        "hbmeshes all versions download",
        "Honorbuddy navigation meshes complete archive",
        "WoW navmesh all patches all zones",
        "hbmeshes github archive all",
        "meshcompiler Honorbuddy all versions",
        "mesh.zip Honorbuddy complete"
    )

    if ($IncludeAddons) {
        $queries += @(
            "Honorbuddy addons all versions",
            "Wow addons Honorbuddy compatible",
            "bot addons Lua scripts all versions",
            "gathering addons bot integration"
        )
    }

    if ($IncludePrivateServers) {
        foreach ($server in $PrivateServers) {
            $queries += @(
                "Honorbuddy $($server.Name) profiles $($server.Type)",
                "$($server.Name) bot profiles Honorbuddy",
                "Honorbuddy $($server.Type) server profiles"
            )
        }
    }

    $queries += @(
        "site:github.com `"honorbuddy`"",
        "site:github.com/brian8544 Honorbuddy",
        "site:github.com Honorbuddy profiles .hbs",
        "site:github.com Singular combat routine WoW",
        "site:ownedcore.com Honorbuddy profiles",
        "site:archive.org Honorbuddy installer",
        "filetype:hbs `"honorbuddy`"",
        "filetype:xml `"quest behavior`" `"honorbuddy`"",
        "filetype:zip Honorbuddy profiles",
        "filetype:exe Honorbuddy setup",
        "inurl:downloads.buddyauth.com archive",
        "bosslandgmbh Honorbuddy downloads",
        "code.google.com/p/hbmeshes files"
    )

    foreach ($version in $WoWVersions) {
        foreach ($year in $version.Years) {
            $queries += @(
                "Honorbuddy $($version.Name) $year profiles",
                "WoW bot profiles $year $($version.Patch)"
            )
        }
    }

    Write-Log "Compiled $(($queries | Measure-Object).Count) weaponized search patterns" "SUCCESS"
    return $queries | Sort-Object -Unique
}

# ==================== ASSET INTELLIGENCE & MAPPING ====================

function Extract-VersionFromContent {
    param([string]$Url, [string]$Content)

    $versionMatches = @()

    foreach ($version in $WoWVersions) {
        foreach ($clientVer in $version.ClientVersions) {
            if ($Url -imatch $clientVer -or $Content -imatch $version.Name) {
                $versionMatches += $version
            }
        }

        foreach ($build in $version.Builds) {
            if ($Url -imatch $build -or $Content -imatch $build) {
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
    }

    if ($Url -imatch '\.git$|github\.com/[^/]+/[^/]+(\.git)?$') {
        $classification.Type = "Repository"
    } elseif ($Url -imatch '\.(zip|7z|rar)$' -and $Url -imatch 'mesh|nav|grid') {
        $classification.Type = "MeshArchive"
    } elseif ($Url -imatch '\.(zip|7z)$' -and $Url -imatch 'profile|hbs') {
        $classification.Type = "ProfileArchive"
    } elseif ($Url -imatch '\.(zip|7z)$' -and $Url -imatch 'addon|lua') {
        $classification.Type = "AddonArchive"
    } elseif ($Url -imatch '\.(exe|zip|7z)$' -and $Url -imatch 'setup|install|honorbuddy') {
        $classification.Type = "Installer"
    } elseif ($Url -imatch '\.hbs$|\.lua$|\.xml$') {
        $classification.Type = "ScriptFile"
    } else {
        $classification.Type = "Archive"
    }

    $classification.Versions = Extract-VersionFromContent -Url $Url -Content $Content
    return $classification
}

# ==================== PHASE 0: DISCOVERY ====================

function Start-ExhaustiveDiscovery {
    Write-Log "================================================================" "INFO"
    Write-Log "  PHASE 0: OMNI-STRATEGY DISCOVERY MATRIX                       " "INFO"
    Write-Log "================================================================" "INFO"

    $allQueries = Generate-SearchQueries
    $allResults = @{}
    $githubHeaders = @{}

    if (-not [string]::IsNullOrWhiteSpace($GitHubToken)) {
        $githubHeaders["Authorization"] = "token $GitHubToken"
        Write-Log "GitHub Authentication active. Rate limits bypassed." "SUCCESS"
    } else {
        Write-Log "WARNING: No GitHub token provided. Severe API rate limiting expected." "WARNING"
    }

    $searchStrategies = @(
        @{ Name = "GitHub API"; Queries = $allQueries | Where-Object { $_ -notmatch "site:|filetype:" } },
        @{ Name = "Archive.org"; Queries = $allQueries | Where-Object { $_ -imatch "archive|historic|download" } },
        @{ Name = "Wayback CDX"; Queries = $allQueries | Where-Object { $_ -imatch "buddyauth|code.google" } }
    )

    $queryCount = 0

    foreach ($strategy in $searchStrategies) {
        Write-Log "Initiating Protocol: $($strategy.Name) - $($strategy.Queries.Count) trajectories" "DISCOVERY"

        foreach ($query in $strategy.Queries) {
            $queryCount++
            Write-Progress-Bar -Current $queryCount -Total $allQueries.Count -Activity "Scanning Grids"

            try {
                switch ($strategy.Name) {
                    "GitHub API" {
                        $url = "https://api.github.com/search/repositories?q=$([uri]::EscapeDataString($query))&per_page=100&sort=stars"
                        $response = Invoke-WebRequestSafe -Uri $url -TimeoutSeconds 20 -Headers $githubHeaders

                        if ($response) {
                            $json = $response.Content | ConvertFrom-Json
                            foreach ($item in $json.items) {
                                $allResults[$item.clone_url] = @{
                                    Title = $item.full_name
                                    Source = "GitHub"
                                    Updated = $item.updated_at
                                }
                            }
                        }
                    }
                    "Archive.org" {
                        $url = "https://archive.org/advancedsearch.php?q=$([uri]::EscapeDataString($query))&output=json&rows=100"
                        $response = Invoke-WebRequestSafe -Uri $url -TimeoutSeconds 20

                        if ($response) {
                            $json = $response.Content | ConvertFrom-Json
                            foreach ($item in $json.response.docs) {
                                $itemUrl = "https://archive.org/details/$($item.identifier)"
                                $allResults[$itemUrl] = @{
                                    Title = $item.title
                                    Source = "Archive.org"
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
                                    foreach ($row in $json[1..([Math]::Min(100, $json.Count-1))]) {
                                        $itemUrl = "https://web.archive.org/web/$($row[0])/$($row[1])"
                                        $allResults[$itemUrl] = @{
                                            Title = "$($row[1]) [$($row[0])]"
                                            Source = "Wayback Machine"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } catch { }

            # Anti-ban heuristic jitter
            Start-Sleep -Milliseconds (Get-Random -Minimum 100 -Maximum 350)
        }
    }

    Write-Host "`n" -NoNewline
    Write-Log "Discovery phase complete: $(($allResults.Count)) viable targets isolated." "SUCCESS"
    return $allResults
}

# ==================== PHASE 1: CRAWLING & MAPPING ====================

function Start-IntelligentCrawling {
    param($DiscoveredUrls)

    Write-Log "================================================================" "INFO"
    Write-Log "  PHASE 1: HEURISTIC CRAWLING & PRECISION MAPPING               " "INFO"
    Write-Log "================================================================" "INFO"

    $versionedAssets = @{}
    $crawledCount = 0
    $totalUrls = $DiscoveredUrls.Count

    foreach ($urlItem in $DiscoveredUrls.GetEnumerator()) {
        $crawledCount++
        Write-Progress-Bar -Current $crawledCount -Total $totalUrls -Activity "Parsing Content"

        $url = $urlItem.Key
        $metadata = $urlItem.Value

        try {
            $response = Invoke-WebRequestSafe -Uri $url -TimeoutSeconds $TimeoutSeconds -Retries $MaxRetries

            if ($response) {
                $classification = Classify-Asset -Url $url -Content $response.Content

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
        } catch { }
    }

    Write-Host "`n" -NoNewline
    Write-Log "Mapping complete: Assets structured across $($versionedAssets.Count) architectural tiers." "SUCCESS"
    return $versionedAssets
}

# ==================== PHASE 2: ACQUISITION (STRICT IO) ====================

function Start-DownloadPhase {
    param($VersionedAssets, $OutputDir)

    Write-Log "================================================================" "INFO"
    Write-Log "  PHASE 2: ASSET SECUREMENT & ACQUISITION                       " "INFO"
    Write-Log "================================================================" "INFO"

    if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null }

    $downloadCount = 0

    foreach ($versionKey in $VersionedAssets.Keys) {
        $versionData = $VersionedAssets[$versionKey]
        $version = $versionData.Version
        $versionDir = Join-Path $OutputDir "$($version.Code)_$($version.Patch)_$($version.Name -replace ' ', '_')"

        if (-not (Test-Path $versionDir)) { New-Item -ItemType Directory -Force -Path $versionDir | Out-Null }

        @("Repositories", "Profiles", "Meshes", "Addons", "Installers", "Tools") | ForEach-Object {
            $subdir = Join-Path $versionDir $_
            if (-not (Test-Path $subdir)) { New-Item -ItemType Directory -Force -Path $subdir | Out-Null }
        }

        foreach ($asset in $versionData.Assets) {
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

            if ($assetType -eq "Repository" -and $asset.URL -imatch '\.git') {
                # Strict Repo Sanitization
                $rawRepoName = Split-Path $asset.URL -Leaf -replace '\.git', ''
                $repoName = $rawRepoName -replace '[<>:"/\\|?*=&%]', '_'
                $repoPath = Join-Path $targetDir $repoName

                if (-not (Test-Path $repoPath)) {
                    Write-Log "[$($version.Name)] Cloning Repository: $repoName" "INFO"
                    & git clone -q $asset.URL $repoPath 2>&1 | Out-Null
                    if ($LASTEXITCODE -eq 0) { $downloadCount++ }
                }
            } else {
                # STRICT FILENAME SANITIZATION INJECTED
                $rawFilename = Split-Path $asset.URL -Leaf
                $filename = $rawFilename -replace '[<>:"/\\|?*=&%]', '_'

                if (-not $filename -or $filename.Length -lt 3) { $filename = "payload_$(Get-Random).bin" }
                $outputPath = Join-Path $targetDir $filename

                if (-not (Test-Path $outputPath)) {
                    Write-Log "[$($version.Name)] Acquiring: $filename" "INFO"
                    $result = Invoke-WebRequestSafe -Uri $asset.URL -OutputPath $outputPath -Retries $MaxRetries

                    if (Test-Path $outputPath) {
                        $fileSize = (Get-Item $outputPath).Length / 1MB
                        Write-Log "✓ Secured: $filename ($([math]::Round($fileSize, 2)) MB)" "SUCCESS"
                        $downloadCount++
                    }
                }
            }
        }
    }

    Write-Log "Acquisition protocol complete: $downloadCount objects secured in payload vault." "SUCCESS"
}

# ==================== PHASE 3: DATABASE GENERATION ====================

function Create-DualDatabase {
    param($VersionedAssets, $OutputDir)

    Write-Log "================================================================" "INFO"
    Write-Log "  PHASE 3: COMPILING DUAL-FORMAT DATABASES                      " "INFO"
    Write-Log "================================================================" "INFO"

    $txtPath = Join-Path $OutputDir "VERSION_MAPPING_DATABASE.txt"
    $jsonPath = Join-Path $OutputDir "VERSION_MAPPING_DATABASE.json"

    # 1. Generate TXT Database
    $db = @"
==============================================================================
        HONORBUDDY MASTER INDEX
        Asset-to-Client Compatibility Matrix
==============================================================================

INDEX COMPILED: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
SECURED VERSIONS: $($VersionedAssets.Count)
------------------------------------------------------------------------------

"@

    foreach ($versionKey in $VersionedAssets.Keys | Sort-Object) {
        $versionData = $VersionedAssets[$versionKey]
        $version = $versionData.Version

        $db += @"
TARGET PROTOCOL: $($version.Name) ($($version.Patch))
------------------------------------------------------------------------------
Active Years: $($version.Years -join ', ')
Engine Versions: $($version.ClientVersions -join ', ')
Secured Assets: $($versionData.Assets.Count)

ASSET INVENTORY:
"@
        $assetsByType = $versionData.Assets | Group-Object -Property Type
        foreach ($typeGroup in $assetsByType) {
            $db += "`n  $($typeGroup.Name): $($typeGroup.Count) registered`n"
            foreach ($asset in $typeGroup.Group) {
                $db += "    - $($asset.Title)`n"
                $db += "      Vector: $($asset.URL)`n"
                $db += "      Origin: $($asset.Source)`n"
            }
        }
        $db += "`n"
    }

    $db | Out-File -FilePath $txtPath -Encoding UTF8 -Force
    Write-Log "Human-readable matrix compiled: $txtPath" "SUCCESS"

    # 2. Generate JSON Database for programmatic extraction
    $VersionedAssets | ConvertTo-Json -Depth 5 | Out-File -FilePath $jsonPath -Encoding UTF8 -Force
    Write-Log "Machine-readable JSON matrix compiled: $jsonPath" "SUCCESS"
}

# ==================== SYSTEM INITIALIZATION ====================

Write-Log "================================================================" "INFO"
Write-Log "  ARCHIVAL ENGINE INITIALIZED                     " "INFO"
Write-Log "  Operation: Complete grid assimilation of Honorbuddy network.  " "INFO"
Write-Log "================================================================" "INFO"

try {
    $discoveredUrls = Start-ExhaustiveDiscovery
    $versionedAssets = Start-IntelligentCrawling -DiscoveredUrls $discoveredUrls
    Start-DownloadPhase -VersionedAssets $versionedAssets -OutputDir $OutputDir
    Create-DualDatabase -VersionedAssets $versionedAssets -OutputDir $OutputDir

    Write-Log ""
    Write-Log "================================================================" "SUCCESS"
    Write-Log "  TOTAL SYSTEM ASSIMILATION COMPLETE                            " "SUCCESS"
    Write-Log "================================================================" "SUCCESS"
    Write-Log "Vault Location: $OutputDir" "INFO"
    Write-Log "Time Elapsed: $(Get-Date -Format 'HH:mm:ss')" "INFO"

} catch {
    Write-Log "CRITICAL SYSTEM FAILURE: $_" "ERROR"
    exit 1
}

exit 0