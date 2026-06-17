# Home Disk Usage Audit

## Summary

This note documents the current disk usage state under `/Users/saski` as measured on 2026-04-09.

- Filesystem usage for `/System/Volumes/Data`: `382Gi` used, `48Gi` available, `89%` capacity.
- The largest measured user-space buckets are split across:
  - `Library` application state, developer data, and caches
  - local repository worktrees under `eventbrite` and `saski`
  - personal media under `Music` and `Movies`
  - hidden package-manager and tool caches such as `.cache`, `.npm`, `.pyenv`, `.cursor`, and `.colima`

## Detailed Findings

### 1. Home-Level Directories

What it does:
User-owned content, app state, repositories, and media under `/Users/saski`.

Where it lives:
- `/Users/saski`

How it connects to other components:
- `Library` holds application state, caches, and developer artifacts.
- `eventbrite` and `saski` hold local source checkouts.
- `Music` and `Movies` hold personal media.
- hidden dot-directories hold package caches, local tool state, and VM data.

Measured sizes:
- `/Users/saski/Code/eventbrite`: `24G`
- `/Users/saski/Music`: `7.9G`
- `/Users/saski/Code`: `5.0G`
- `/Users/saski/Movies`: `1.1G`
- `/Users/saski/Pictures`: `477M`
- `/Users/saski/Downloads`: `175M`
- `/Users/saski/.cache`: `12G`
- `/Users/saski/.npm`: `3.5G`
- `/Users/saski/.pyenv`: `2.0G`
- `/Users/saski/.cursor`: `1.4G`
- `/Users/saski/.colima`: `999M`
- `/Users/saski/.codex`: `147M`

### 2. Library Application Data

What it does:
Persistent application data, browser profiles, embedded VM bundles, editor state, and synced app content.

Where it lives:
- `/Users/saski/Library/Application Support`

How it connects to other components:
- Browser profiles map to Google Chrome and Chrome Beta usage.
- Claude stores VM bundles inside its application support tree.
- Cursor stores user state, cached data, and workspace storage here.
- This subtree aligns with the storage categories that macOS often surfaces as Applications, Documents, and parts of System Data.

Measured sizes:
- `/Users/saski/Library/Application Support`: `50G`
- `/Users/saski/Library/Application Support/Google`: `22G`
- `/Users/saski/Library/Application Support/Claude`: `10G`
- `/Users/saski/Library/Application Support/Cursor`: `7.3G`
- `/Users/saski/Library/Application Support/Slack`: `1.5G`
- `/Users/saski/Library/Application Support/Code`: `1.0G`
- `/Users/saski/Library/Application Support/Figma`: `988M`

Google breakdown:
- `/Users/saski/Library/Application Support/Google/Chrome`: `16G`
- `/Users/saski/Library/Application Support/Google/Chrome Beta`: `5.7G`
- `/Users/saski/Library/Application Support/Google/DriveFS`: `605M`

Google Chrome breakdown:
- `/Users/saski/Library/Application Support/Google/Chrome/Profile 1`: `6.8G`
- `/Users/saski/Library/Application Support/Google/Chrome/OptGuideOnDeviceModel`: `4.0G`
- `/Users/saski/Library/Application Support/Google/Chrome/Default`: `3.9G`
- `/Users/saski/Library/Application Support/Google/Chrome/Snapshots`: `791M`

Google Chrome Beta breakdown:
- `/Users/saski/Library/Application Support/Google/Chrome Beta/OptGuideOnDeviceModel`: `4.0G`
- `/Users/saski/Library/Application Support/Google/Chrome Beta/Default`: `1.1G`

Claude breakdown:
- `/Users/saski/Library/Application Support/Claude/vm_bundles`: `9.5G`
- `/Users/saski/Library/Application Support/Claude/claude-code-vm`: `213M`
- `/Users/saski/Library/Application Support/Claude/Cache`: `195M`
- `/Users/saski/Library/Application Support/Claude/vm_bundles/claudevm.bundle/rootfs.img`: `10G`
- `/Users/saski/Library/Application Support/Claude/vm_bundles/claudevm.bundle/rootfs.img.zst`: `2.0G`
- `/Users/saski/Library/Application Support/Claude/vm_bundles/claudevm.bundle/sessiondata.img`: `30M`

Cursor breakdown:
- `/Users/saski/Library/Application Support/Cursor/User`: `5.5G`
- `/Users/saski/Library/Application Support/Cursor/CachedData`: `1.0G`
- `/Users/saski/Library/Application Support/Cursor/Partitions`: `409M`
- `/Users/saski/Library/Application Support/Cursor/Cache`: `226M`
- `/Users/saski/Library/Application Support/Cursor/User/workspaceStorage`: `4.2G`
- `/Users/saski/Library/Application Support/Cursor/User/globalStorage`: `1.3G`
- `/Users/saski/Library/Application Support/Cursor/User/workspaceStorage/43b7871efccd35dacf7d4f52a01637f7`: `4.2G`

### 3. Library Developer Data

What it does:
Xcode build output, package checkouts, symbol caches, and simulator device data.

Where it lives:
- `/Users/saski/Library/Developer`

How it connects to other components:
- `Xcode/DerivedData` is tied to local iOS/macOS builds.
- `CoreSimulator/Devices` is tied to installed and used simulator devices.
- The identified project names match local iOS projects such as `AttendeeApp` and `Rally`.

Measured sizes:
- `/Users/saski/Library/Developer`: `33G`
- `/Users/saski/Library/Developer/Xcode`: `21G`
- `/Users/saski/Library/Developer/CoreSimulator`: `11G`

Xcode breakdown:
- `/Users/saski/Library/Developer/Xcode/DerivedData`: `21G`
- `/Users/saski/Library/Developer/Xcode/UserData`: `70M`

Largest DerivedData entries:
- `/Users/saski/Library/Developer/Xcode/DerivedData/AttendeeApp-caubfciqqsfnkadacfhutnjyruiu`: `5.0G`
- `/Users/saski/Library/Developer/Xcode/DerivedData/AttendeeApp-bvozxeiidcuzxhcukavudpyweypb`: `4.3G`
- `/Users/saski/Library/Developer/Xcode/DerivedData/Rally-aswughesutciczavsjlrrhaufxkt`: `4.0G`
- `/Users/saski/Library/Developer/Xcode/DerivedData/AttendeeApp-giaqoumupxlviugixbroqaytcnlp`: `3.9G`
- `/Users/saski/Library/Developer/Xcode/DerivedData/AttendeeApp-etlfalnmfhakqegansyruhtbxovn`: `3.9G`
- `/Users/saski/Library/Developer/Xcode/DerivedData/ModuleCache.noindex`: `308M`

Largest subtrees inside DerivedData:
- `/Users/saski/Library/Developer/Xcode/DerivedData/AttendeeApp-caubfciqqsfnkadacfhutnjyruiu/SourcePackages`: `3.9G`
- `/Users/saski/Library/Developer/Xcode/DerivedData/AttendeeApp-bvozxeiidcuzxhcukavudpyweypb/SourcePackages`: `2.5G`
- `/Users/saski/Library/Developer/Xcode/DerivedData/AttendeeApp-bvozxeiidcuzxhcukavudpyweypb/Index.noindex`: `1.8G`
- `/Users/saski/Library/Developer/Xcode/DerivedData/AttendeeApp-caubfciqqsfnkadacfhutnjyruiu/Build`: `1.0G`

CoreSimulator breakdown:
- `/Users/saski/Library/Developer/CoreSimulator/Devices`: `11G`

Largest simulator device data directories:
- `/Users/saski/Library/Developer/CoreSimulator/Devices/51F75A4D-49A1-4575-8CDB-41C783F02241/data`: `3.6G`
- `/Users/saski/Library/Developer/CoreSimulator/Devices/4E035F0E-D222-4241-AEAA-563B49DE3BE5/data`: `3.1G`
- `/Users/saski/Library/Developer/CoreSimulator/Devices/3BF997DA-04EA-4B31-A3C6-BDEF6A96EBF8/data`: `2.3G`
- `/Users/saski/Library/Developer/CoreSimulator/Devices/4E2AAA24-E599-41BC-9291-B11226DA68B9/data`: `703M`
- `/Users/saski/Library/Developer/CoreSimulator/Devices/C96B24E1-27C3-4965-9BEB-6F013A29FE4B/data`: `489M`
- `/Users/saski/Library/Developer/CoreSimulator/Devices/80ED5B73-1FF9-4D78-A38C-E9ABCCCF6616/data`: `425M`

### 4. Library Caches and Tool Caches

What it does:
Temporary or reusable cache data for package managers, SDKs, browsers, tooling, and local inference models.

Where it lives:
- `/Users/saski/Library/Caches`
- `/Users/saski/.cache`
- `/Users/saski/.npm`
- `/Users/saski/.pyenv`
- `/Users/saski/.colima`
- `/Users/saski/.cursor`

How it connects to other components:
- `Library/Caches` is per-app cache storage.
- `.cache` holds tool-specific caches such as `uv` and Whisper model files.
- `.npm`, `.pyenv`, and `.colima` map to local development environments.
- `.cursor/extensions` maps to installed editor extensions.

Measured sizes:
- `/Users/saski/Library/Caches`: `27G`
- `/Users/saski/.cache`: `12G`
- `/Users/saski/.npm`: `3.5G`
- `/Users/saski/.pyenv/versions`: `2.0G`
- `/Users/saski/.colima/_lima`: `999M`
- `/Users/saski/.cursor/extensions`: `1.4G`

Largest `Library/Caches` entries:
- `/Users/saski/Library/Caches/Yarn`: `4.0G`
- `/Users/saski/Library/Caches/org.swift.swiftpm`: `3.5G`
- `/Users/saski/Library/Caches/Google`: `3.0G`
- `/Users/saski/Library/Caches/com.spotify.client`: `2.1G`
- `/Users/saski/Library/Caches/Homebrew`: `2.0G`
- `/Users/saski/Library/Caches/aws`: `1.7G`
- `/Users/saski/Library/Caches/Cypress`: `1.1G`
- `/Users/saski/Library/Caches/ms-playwright`: `1.1G`
- `/Users/saski/Library/Caches/Firefox`: `1.0G`
- `/Users/saski/Library/Caches/pypoetry`: `1.0G`
- `/Users/saski/Library/Caches/SiriTTS`: `943M`
- `/Users/saski/Library/Caches/pip`: `734M`
- `/Users/saski/Library/Caches/node-gyp`: `602M`

Largest `.cache` entries:
- `/Users/saski/.cache/uv`: `8.9G`
- `/Users/saski/.cache/whisper`: `2.9G`
- `/Users/saski/.cache/chrome-devtools-mcp`: `206M`

`.cache/uv` breakdown:
- `/Users/saski/.cache/uv/archive-v0`: `8.9G`
- `/Users/saski/.cache/uv/simple-v16`: `16M`
- `/Users/saski/.cache/uv/wheels-v5`: `1.4M`

`.cache/whisper` breakdown:
- `/Users/saski/.cache/whisper/large-v3.pt`: `2.9G`

`.npm` breakdown:
- `/Users/saski/.npm/_cacache`: `2.9G`
- `/Users/saski/.npm/_npx`: `527M`
- `/Users/saski/.npm/_logs`: `9.3M`

`.pyenv` breakdown:
- `/Users/saski/.pyenv/versions`: `2.0G`

`.cursor` breakdown:
- `/Users/saski/.cursor/extensions`: `1.4G`
- `/Users/saski/.cursor/projects`: `14M`
- `/Users/saski/.cursor/ai-tracking`: `8.1M`

### 5. Repository Worktrees

What it does:
Local working copies for source repositories and their generated artifacts.

Where it lives:
- `/Users/saski/Code/eventbrite`
- `/Users/saski/Code`

How it connects to other components:
- Repository size is split between version control history, dependency directories, and project-specific generated output.
- iOS repositories also connect to the large `Library/Developer` measurements above through Xcode and simulator use.

Measured sizes:
- `/Users/saski/Code/eventbrite`: `24G`
- `/Users/saski/Code`: `5.0G`

Largest `eventbrite` repositories:
- `/Users/saski/Code/eventbrite/eb-ui`: `9.3G`
- `/Users/saski/Code/eventbrite/EventService`: `3.7G`
- `/Users/saski/Code/eventbrite/iOS-attendee`: `2.4G`
- `/Users/saski/Code/eventbrite/core`: `2.3G`
- `/Users/saski/Code/eventbrite/consumer-header`: `1.6G`
- `/Users/saski/Code/eventbrite/listings-webapp`: `1.4G`
- `/Users/saski/Code/eventbrite/gitnexus`: `1.2G`
- `/Users/saski/Code/eventbrite/attendeeapp_android`: `1.2G`

`eventbrite/eb-ui` breakdown:
- `/Users/saski/Code/eventbrite/eb-ui/node_modules`: `5.6G`
- `/Users/saski/Code/eventbrite/eb-ui/.git`: `3.0G`
- `/Users/saski/Code/eventbrite/eb-ui/packages`: `416M`
- `/Users/saski/Code/eventbrite/eb-ui/bundles`: `106M`
- `/Users/saski/Code/eventbrite/eb-ui/coverage`: `96M`

`eventbrite/EventService` breakdown:
- `/Users/saski/Code/eventbrite/EventService/.git`: `2.6G`
- `/Users/saski/Code/eventbrite/EventService/terraform`: `1.0G`
- `/Users/saski/Code/eventbrite/EventService/services`: `37M`
- `/Users/saski/Code/eventbrite/EventService/vendor`: `18M`

`eventbrite/iOS-attendee` breakdown:
- `/Users/saski/Code/eventbrite/iOS-attendee/.git`: `2.2G`
- `/Users/saski/Code/eventbrite/iOS-attendee/ios`: `152M`
- `/Users/saski/Code/eventbrite/iOS-attendee/fastlane`: `55M`

`eventbrite/core` breakdown:
- `/Users/saski/Code/eventbrite/core/.git`: `1.6G`
- `/Users/saski/Code/eventbrite/core/django`: `365M`
- `/Users/saski/Code/eventbrite/core/.gitnexus`: `302M`
- `/Users/saski/Code/eventbrite/core/python`: `13M`

Largest `saski` repository:
- `/Users/saski/Code/iOS-attendee`: `2.7G`

`saski/iOS-attendee` breakdown:
- `/Users/saski/Code/iOS-attendee/.git`: `2.4G`
- `/Users/saski/Code/iOS-attendee/ios`: `291M`
- `/Users/saski/Code/iOS-attendee/fastlane`: `26M`

### 6. Media Libraries

What it does:
Personal audio and video files outside application-managed caches.

Where it lives:
- `/Users/saski/Music`
- `/Users/saski/Movies`

How it connects to other components:
- These directories map most directly to the Documents or Music Creation storage groupings in macOS.

Measured sizes:
- `/Users/saski/Music`: `7.9G`
- `/Users/saski/Movies`: `1.1G`

Largest `Music` entries:
- `/Users/saski/Music/Stereolab - Switched On Volumes 1-5 - flac`: `2.5G`
- `/Users/saski/Music/Music`: `2.2G`
- `/Users/saski/Music/Stereolab - Switched On Volumes 1-5 - mp3`: `898M`
- `/Users/saski/Music/Aphex Twin - Syro - wav`: `654M`
- `/Users/saski/Music/autechre live`: `455M`
- `/Users/saski/Music/Leyland Kirby - We drink to forget the coming storm`: `320M`
- `/Users/saski/Music/Aphex Twin - Collapse EP - wav`: `293M`

Largest `Movies` entries:
- `/Users/saski/Movies/UMBRALIA_TEST_05.mp4`: `685M`
- `/Users/saski/Movies/CapCut`: `268M`
- `/Users/saski/Movies/yeliz.mov`: `67M`

## Code References

- `/Users/saski`
- `/Users/saski/Library/Application Support`
- `/Users/saski/Library/Developer`
- `/Users/saski/Library/Caches`
- `/Users/saski/.cache`
- `/Users/saski/.npm`
- `/Users/saski/.pyenv`
- `/Users/saski/.cursor`
- `/Users/saski/.colima`
- `/Users/saski/Code/eventbrite`
- `/Users/saski/Code`
- `/Users/saski/Music`
- `/Users/saski/Movies`

## Architecture Notes

- The measured storage does not come from a single category. It is distributed across user content, application state, developer build artifacts, simulators, package caches, and repository histories.
- The `Library` subtree is the dominant non-repository area based on measured subtrees:
  - `/Users/saski/Library/Application Support`: `50G`
  - `/Users/saski/Library/Developer`: `33G`
  - `/Users/saski/Library/Caches`: `27G`
  - `/Users/saski/Library/Containers`: `2.1G`
  - `/Users/saski/Library/Group Containers`: `596M`
- The repository footprint is concentrated in a small number of large worktrees rather than many medium-sized projects.
- The developer footprint is split between repository data under home and derived artifacts under `Library/Developer`.

## Open Questions

- macOS Storage reports `Bin` at roughly `5.96 GB`, but direct shell inspection of `/Users/saski/.Trash` returned `Operation not permitted`, so the contents were not attributable in this audit.
- A full home-wide search for every file larger than `1G` did not complete within the session budget, so file-level evidence here is focused on the heaviest measured subtrees rather than a complete file inventory.
