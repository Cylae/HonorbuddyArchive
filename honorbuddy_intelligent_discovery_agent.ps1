# ==============================================================================
# HONORBUDDY INTELLIGENT DISCOVERY AGENT
# Autonomous Web Research & Archive Generation
# Searches without predefined links - discovers sources dynamically
# ==============================================================================

param(
    [int]$MaxCrawlDepth = 3,
    [int]$MaxRetries = 3,
    [int]$TimeoutSeconds = 30,
    [string]$OutputDir = "C:\Honorbuddy_AI_Archive",
    [int]$MaxUrlsPerSearch = 50
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# ==================== GLOBAL STATE ====================

$script:DiscoveredUrls = @{}           # URL -> Last Visited
$script:UrlQueue = [System.Collections.Queue]::new()
$script:ProcessedDomains = @{}         # Domain -> Count
$script:RelevanceScores = @{}          # URL -> Score
$script:FileLog = $null
$script:StartTime = Get-Date

# ==================== LOGGING ====================

function Write-Log {
    param([string]$Message, [string]$Level = "INFO", [bool]$File = $true)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = @{ INFO = "Cyan"; SUCCESS = "Green"; WARNING = "Yellow"; ERROR = "Red"; DEBUG = "DarkCyan" }[$Level]

    $logMsg = "[$timestamp] [$Level] $Message"
    Write-Host $logMsg -ForegroundColor $color

    if ($File -and $script:FileLog) {
        Add-Content $script:FileLog $logMsg
    }
}

# ==================== WEB REQUEST UTILITIES ====================

function Invoke-WebRequestSafe {
    param(
        [string]$Uri,
        [int]$Retries = 2,
        [int]$TimeoutSeconds = 30,
        [string]$OutputPath = $null
    )

    for ($i = 1; $i -le $Retries; $i++) {
        try {
            $params = @{
                Uri = $Uri
                TimeoutSec = $TimeoutSeconds
                ErrorAction = "Stop"
                UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
                MaximumRedirection = 5
            }

            if ($OutputPath) {
                $params["OutFile"] = $OutputPath
            }

            return Invoke-WebRequest @params
        } catch {
            if ($i -lt $Retries) {
                Start-Sleep -Seconds (1 + $i)
            } else {
                return $null
            }
        }
    }
}

function Extract-LinksFromHtml {
    param([string]$Html)

    $links = @()
    $pattern = 'href=["'']([^"'']+)["'']'
    $matches = [regex]::Matches($Html, $pattern)

    foreach ($match in $matches) {
        $link = $match.Groups[1].Value
        if ($link -match '^https?://' -or $link -match '^/') {
            $links += $link
        }
    }

    return $links | Sort-Object -Unique
}

function Resolve-RelativeUrl {
    param([string]$BaseUrl, [string]$RelativeUrl)

    if ($RelativeUrl -match '^https?://') {
        return $RelativeUrl
    }

    $baseUri = [uri]$BaseUrl
    if ($RelativeUrl.StartsWith('/')) {
        return "$($baseUri.Scheme)://$($baseUri.Host)$RelativeUrl"
    } else {
        $path = [System.IO.Path]::Combine($baseUri.AbsolutePath, $RelativeUrl)
        return "$($baseUri.Scheme)://$($baseUri.Host)$path"
    }
}

# ==================== RELEVANCE SCORING ====================

function Calculate-Relevance {
    param([string]$Url, [string]$Content = $null)

    $score = 0

    # URL-based scoring
    $keywords = @(
        @{ Pattern = "honorbuddy"; Weight = 100 },
        @{ Pattern = "hb\d+"; Weight = 80 },
        @{ Pattern = "quest.*profile"; Weight = 60 },
        @{ Pattern = "combat.*routine"; Weight = 60 },
        @{ Pattern = "wow.*bot"; Weight = 70 },
        @{ Pattern = "wotlk|cataclysm|mop|wod|legion"; Weight = 50 },
        @{ Pattern = "singular|kicksprofile"; Weight = 70 },
        @{ Pattern = "hbrelog"; Weight = 75 },
        @{ Pattern = "navigation.*mesh|navmesh"; Weight = 65 },
        @{ Pattern = "github\.com/[^/]+/(honorbuddy|hbrelog|singular)"; Weight = 90 },
        @{ Pattern = "archive\.org"; Weight = 40 },
        @{ Pattern = "wayback.*machine"; Weight = 35 }
    )

    foreach ($keyword in $keywords) {
        if ($Url -imatch $keyword.Pattern) {
            $score += $keyword.Weight
        }
    }

    # Content-based scoring (if available)
    if ($Content) {
        if ($Content -imatch "download|archive|backup") { $score += 20 }
        if ($Content -imatch "honorbuddy") { $score += 50 }
        if ($Content -imatch "version|release|changelog") { $score += 30 }
    }

    return $score
}

# ==================== INTELLIGENT SEARCH STRATEGIES ====================

function Invoke-SearchStrategy {
    param([string]$Query, [string]$Strategy)

    $searchUrls = @{
        "google" = "https://www.google.com/search?q={0}&num={1}"
        "github" = "https://api.github.com/search/repositories?q={0}&per_page={1}&sort=stars"
        "archive" = "https://archive.org/advancedsearch.php?q={0}&fl=identifier,title&output=json&rows={1}"
        "site_github" = "https://api.github.com/search/code?q={0}+repo:{1}&per_page={2}"
        "wayback_cdx" = "https://web.archive.org/cdx/search/cdx?url={0}&output=json&fl=timestamp,original&filter=statuscode:200&collapse=urlkey"
    }

    $url = $searchUrls[$Strategy] -f [uri]::EscapeDataString($Query), $MaxUrlsPerSearch

    Write-Log "Searching [$Strategy]: $Query" "DEBUG"
    $response = Invoke-WebRequestSafe -Uri $url -TimeoutSeconds 30

    if (-not $response) { return @() }

    $results = @()

    try {
        switch ($Strategy) {
            "github" {
                $json = $response.Content | ConvertFrom-Json
                foreach ($item in $json.items) {
                    $results += @{
                        Url = $item.clone_url
                        Title = $item.full_name
                        Source = "GitHub"
                        Score = (Calculate-Relevance -Url $item.clone_url)
                    }
                }
            }

            "archive" {
                $json = $response.Content | ConvertFrom-Json
                foreach ($item in $json.response.docs) {
                    $results += @{
                        Url = "https://archive.org/details/$($item.identifier)"
                        Title = $item.title
                        Source = "Archive.org"
                        Score = (Calculate-Relevance -Url "archive.org/$($item.identifier)")
                    }
                }
            }

            "wayback_cdx" {
                $json = $response.Content | ConvertFrom-Json
                if ($json.Count -gt 1) {
                    foreach ($row in $json[1..($json.Count-1)]) {
                        $timestamp = $row[0]
                        $original = $row[1]
                        $waybackUrl = "https://web.archive.org/web/$timestamp/$original"

                        $results += @{
                            Url = $waybackUrl
                            Title = "$original [$timestamp]"
                            Source = "Wayback Machine"
                            Score = (Calculate-Relevance -Url $waybackUrl)
                        }
                    }
                }
            }

            default {
                # Parse HTML search results
                $pattern = '<a[^>]+href=[''"]([^''\"]+)[''"][^>]*>([^<]+)<'
                $matches = [regex]::Matches($response.Content, $pattern)

                foreach ($match in $matches) {
                    $href = $match.Groups[1].Value
                    $title = $match.Groups[2].Value

                    if ($href -match '^https?://') {
                        $results += @{
                            Url = $href
                            Title = $title
                            Source = $Strategy
                            Score = (Calculate-Relevance -Url $href -Content $title)
                        }
                    }
                }
            }
        }
    } catch {
        Write-Log "Error parsing $Strategy results: $_" "WARNING"
    }

    return $results
}

# ==================== DISCOVERY ENGINE ====================

function Start-DiscoveryPhase {
    Write-Log "=== PHASE 0: DISCOVERY ENGINE ===" "INFO"

    $discoveryQueries = @(
        # Core bot searches
        @{ Query = "Honorbuddy WoW bot archive repository"; Strategy = "github" },
        @{ Query = "Honorbuddy profiles dungeons leveling"; Strategy = "github" },
        @{ Query = "HBRelog manager releases"; Strategy = "github" },
        @{ Query = "Singular combat routine"; Strategy = "github" },

        # Archive searches
        @{ Query = "Honorbuddy installer download"; Strategy = "archive" },
        @{ Query = "World of Warcraft bot profiles"; Strategy = "archive" },
        @{ Query = "navigation mesh wow"; Strategy = "archive" },

        # Wayback Machine searches
        @{ Query = "downloads.buddyauth.com"; Strategy = "wayback_cdx" },
        @{ Query = "code.google.com/p/hbmeshes"; Strategy = "wayback_cdx" },

        # Expansion-specific
        @{ Query = "WotLK 3.3.5 Honorbuddy profiles"; Strategy = "github" },
        @{ Query = "Cataclysm 4.3.4 bot routine"; Strategy = "github" },
        @{ Query = "MoP 5.4.8 profiles bot"; Strategy = "github" },
        @{ Query = "Legion 7.x quest profiles"; Strategy = "github" },

        # Tool searches
        @{ Query = "HonorBuddy mesh files navigation grids"; Strategy = "archive" },
        @{ Query = "quest behaviors engine"; Strategy = "github" },

        # Historical search
        @{ Query = "Bossland GmbH Honorbuddy official"; Strategy = "archive" }
    )

    $allResults = @()

    foreach ($search in $discoveryQueries) {
        Start-Sleep -Milliseconds 800  # Rate limiting
        $results = Invoke-SearchStrategy -Query $search.Query -Strategy $search.Strategy

        if ($results) {
            $allResults += $results
            Write-Log "Found $($results.Count) results for: $($search.Query)" "INFO"
        }
    }

    # Deduplicate and sort by relevance
    $allResults = $allResults | Group-Object -Property Url | ForEach-Object {
        $_.Group[0]  # Keep first instance
    } | Sort-Object -Property Score -Descending

    Write-Log "Total unique results discovered: $($allResults.Count)" "SUCCESS"

    # Queue discovered URLs
    foreach ($result in $allResults) {
        if ($result.Score -gt 20) {  # Quality threshold
            $script:UrlQueue.Enqueue($result)
            $script:DiscoveredUrls[$result.Url] = $null
            $script:RelevanceScores[$result.Url] = $result.Score
        }
    }

    Write-Log "Queued $($script:UrlQueue.Count) URLs for processing" "SUCCESS"
}

# ==================== CRAWLING ENGINE ====================

function Start-CrawlPhase {
    Write-Log "=== PHASE 1: INTELLIGENT CRAWLING ===" "INFO"

    $crawlCount = 0
    $depth = 0

    while ($script:UrlQueue.Count -gt 0 -and $depth -lt $MaxCrawlDepth) {
        $batchSize = [Math]::Min($script:UrlQueue.Count, 10)

        for ($i = 0; $i -lt $batchSize; $i++) {
            $urlItem = $script:UrlQueue.Dequeue()
            $url = $urlItem.Url

            if ($script:DiscoveredUrls[$url] -ne $null) {
                continue  # Already processed
            }

            Write-Log "Crawling [$($urlItem.Source)]: $url (Score: $($urlItem.Score))" "INFO"

            $response = Invoke-WebRequestSafe -Uri $url -TimeoutSeconds 20
            if (-not $response) { continue }

            $script:DiscoveredUrls[$url] = Get-Date
            $crawlCount++

            # Extract links from crawled page
            $links = Extract-LinksFromHtml -Html $response.Content

            foreach ($link in $links) {
                # Resolve relative URLs
                if (-not $link.StartsWith('http')) {
                    $link = Resolve-RelativeUrl -BaseUrl $url -RelativeUrl $link
                }

                # Filter irrelevant domains
                if ($link -match '(facebook|twitter|youtube|reddit)') { continue }

                # Calculate relevance
                $relevance = Calculate-Relevance -Url $link -Content $response.Content

                if ($relevance -gt 15 -and -not $script:DiscoveredUrls.ContainsKey($link)) {
                    $script:UrlQueue.Enqueue(@{
                        Url = $link
                        Title = "Auto-discovered from $($urlItem.Title)"
                        Source = "Crawl-$depth"
                        Score = $relevance
                    })

                    $script:DiscoveredUrls[$link] = $null
                    $script:RelevanceScores[$link] = $relevance
                }
            }
        }

        $depth++
        Write-Log "Crawl depth $depth complete. Queue size: $($script:UrlQueue.Count), Discovered: $($script:DiscoveredUrls.Count)" "INFO"
        Start-Sleep -Milliseconds 500
    }

    Write-Log "Crawled $crawlCount pages" "SUCCESS"
}

# ==================== CLASSIFICATION & DOWNLOADING ====================

function Classify-AndDownload {
    Write-Log "=== PHASE 2: CLASSIFICATION & DOWNLOADING ===" "INFO"

    $dirs = @{
        Root = $OutputDir
        Repos = Join-Path $OutputDir "Repositories"
        Installers = Join-Path $OutputDir "Installers"
        Profiles = Join-Path $OutputDir "Profiles"
        Tools = Join-Path $OutputDir "Tools"
        Archives = Join-Path $OutputDir "Archives"
        Logs = Join-Path $OutputDir "Logs"
    }

    foreach ($dir in $dirs.Values) {
        if (-Not (Test-Path $dir)) {
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
        }
    }

    $downloadedCount = 0
    $skippedCount = 0

    # Sort URLs by relevance and category
    $sortedUrls = $script:RelevanceScores.GetEnumerator() | Sort-Object -Property Value -Descending

    foreach ($item in $sortedUrls) {
        $url = $item.Key
        $score = $item.Value

        # Skip low-relevance results
        if ($score -lt 25) {
            $skippedCount++
            continue
        }

        # Classify URL
        $category = "Archives"
        if ($url -imatch '\.git(?:/|$)') {
            $category = "Repos"
        } elseif ($url -imatch '\.(zip|exe|7z|rar)$|installer|download.*\.exe') {
            $category = "Installers"
        } elseif ($url -imatch 'profile|quest|behavior|routine') {
            $category = "Profiles"
        } elseif ($url -imatch 'hbrelog|tool|utility|manager') {
            $category = "Tools"
        }

        # Attempt download/clone
        Write-Log "Processing [$category]: $url" "INFO"

        if ($category -eq "Repos" -and $url -imatch '\.git') {
            # Clone git repo
            $repoName = Split-Path $url -Leaf | ForEach-Object { $_ -replace '\.git$', '' }
            $repoPath = Join-Path $dirs.Repos $repoName

            if (-Not (Test-Path $repoPath)) {
                & git clone -q $url $repoPath 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Log "Cloned: $repoName" "SUCCESS"
                    $downloadedCount++
                }
            }
        } else {
            # Download file
            $filename = Split-Path $url -Leaf
            if (-Not $filename -or -Not $filename.Contains('.')) {
                $filename = "download_$(Get-Random).bin"
            }

            $outputPath = Join-Path $dirs[$category] $filename

            if (-Not (Test-Path $outputPath)) {
                $result = Invoke-WebRequestSafe -Uri $url -OutputPath $outputPath -Retries 1

                if (Test-Path $outputPath) {
                    $fileSize = (Get-Item $outputPath).Length / 1MB
                    Write-Log "Downloaded: $filename ($([math]::Round($fileSize, 2)) MB)" "SUCCESS"
                    $downloadedCount++
                }
            }
        }
    }

    Write-Log "Downloaded/Cloned: $downloadedCount | Skipped: $skippedCount" "SUCCESS"
}

# ==================== INITIALIZATION ====================

Write-Log "╔════════════════════════════════════════════════════════════════╗" "INFO"
Write-Log "║  HONORBUDDY INTELLIGENT DISCOVERY AGENT                      ║" "INFO"
Write-Log "║  Autonomous Web Research Mode                                ║" "INFO"
Write-Log "╚════════════════════════════════════════════════════════════════╝" "INFO"

# Setup logging
if (-Not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
}

$script:FileLog = Join-Path $OutputDir "discovery_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# ==================== EXECUTION ====================

try {
    Start-DiscoveryPhase
    Start-CrawlPhase
    Classify-AndDownload

    # Generate report
    $elapsed = New-TimeSpan -Start $script:StartTime -End (Get-Date)

    $report = @"
╔════════════════════════════════════════════════════════════════╗
║          DISCOVERY AGENT - FINAL REPORT                       ║
╚════════════════════════════════════════════════════════════════╝

Execution Time:         $([int]$elapsed.TotalMinutes)m $($elapsed.Seconds)s
Total URLs Discovered:  $($script:DiscoveredUrls.Count)
Archive Location:       $OutputDir
Log File:               $script:FileLog

Top Domains Crawled:
"@

    $script:ProcessedDomains.GetEnumerator() | Sort-Object -Property Value -Descending |
        Select-Object -First 10 | ForEach-Object {
        $report += "`n  - $($_.Key): $($_.Value) URLs"
    }

    $report | Write-Host -ForegroundColor Cyan
    $report | Add-Content $script:FileLog

    Write-Log "Discovery complete! Archive ready in: $OutputDir" "SUCCESS"

} catch {
    Write-Log "CRITICAL ERROR: $_" "ERROR"
    exit 1
}

exit 0