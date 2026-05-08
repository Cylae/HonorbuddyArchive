# 🤖 Honorbuddy Absolute Everything Archive System

Welcome to the **Apex Predator** of archival tools! This project is designed to comprehensively discover, map, and secure assets related to Honorbuddy across the internet. 🌐

## 🌟 Features

*   **Omni-Strategy Discovery:** 🕵️‍♂️ Uses multiple search strategies (GitHub API, Archive.org, Wayback Machine) to find relevant repositories, profiles, meshes, and tools.
*   **Intelligent Crawling:** 🧠 Explores discovered URLs up to a configurable depth to find deeply nested assets.
*   **Asset Securement:** 📥 Downloads or clones repositories and files into an organized structure based on WoW version and asset type.
*   **Dual-Format Database Generation:** 🗃️ Generates both a human-readable text file and a machine-readable JSON file mapping downloaded assets to their compatible game versions.
*   **Resilience & Anti-Ban:** 🛡️ Uses User-Agent rotation, retry logic with exponential backoff, and heuristic jitter to avoid rate limits.

## 🚀 Scripts

### `launcher.ps1` 🎮
The main entry point for starting the archival process. It provides an interactive UI to choose from different archival modes (`standard`, `aggressive`, `ultimate`) and options.

### `honorbuddy_absolute_everything.ps1` ⚙️
The core archival engine. It executes the exhaustive discovery, crawling, downloading, and database compilation phases.

### `honorbuddy_intelligent_discovery_agent.ps1` 🧭
An autonomous web research agent that dynamically discovers sources without predefined links. It calculates relevance scores for found URLs and intelligently crawls them.

## 🛠️ Usage

1.  Open a PowerShell prompt.
2.  Run the launcher script:
    ```powershell
    .\launcher.ps1
    ```
3.  Select the desired mode and options.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.
