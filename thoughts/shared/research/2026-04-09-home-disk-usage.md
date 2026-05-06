# Home Disk Usage Audit

## Summary

This note documents the current disk usage state under `/Users/ignacio.viejo` as measured on 2026-04-09.

- Filesystem usage for `/System/Volumes/Data`: `382Gi` used, `48Gi` available, `89%` capacity.
- The largest measured user-space buckets are split across:
  - `Library` application state, developer data, and caches
  - local repository worktrees under `eventbrite` and `saski`
  - personal media under `Music` and `Movies`
  - hidden package-manager and tool caches such as `.cache`, `.npm`, `.pyenv`, `.cursor`, and `.colima`

## Detailed Findings

### 1. Home-Level Directories

What it does:
User-owned content, app state, repositories, and media under `/Users/ignacio.viejo`.

Where it lives:
- `/Users/ignacio.viejo`

How it connects to other components:
- `Library` holds application state, caches, and developer artifacts.
- `eventbrite` and `saski` hold local source checkouts.
- `Music` and `Movies` hold personal media.
- hidden dot-directories hold package caches, local tool state, and VM data.

Measured sizes:
- `/Users/ignacio.viejo/eventbrite`: `24G`
- `/Users/ignacio.viejo/Music`: `7.9G`
- `/Users/ignacio.viejo/saski`: `5.0G`
- `/Users/ignacio.viejo/Movies`: `1.1G`
- `/Users/ignacio.viejo/Pictures`: `477M`
- `/Users/ignacio.viejo/Downloads`: `175M`
- `/Users/ignacio.viejo/.cache`: `12G`
- `/Users/ignacio.viejo/.npm`: `3.5G`
- `/Users/ignacio.viejo/.pyenv`: `2.0G`
- `/Users/ignacio.viejo/.cursor`: `1.4G`
- `/Users/ignacio.viejo/.colima`: `999M`
- `/Users/ignacio.viejo/.codex`: `147M`

### 2. Library Application Data

What it does:
Persistent application data, browser profiles, embedded VM bundles, editor state, and synced app content.

Where it lives:
- `/Users/ignacio.viejo/Library/Application Support`

How it connects to other components:
- Browser profiles map to Google Chrome and Chrome Beta usage.
- Claude stores VM bundles inside its application support tree.
- Cursor stores user state, cached data, and workspace storage here.
- This subtree aligns with the storage categories that macOS often surfaces as Applications, Documents, and parts of System Data.

Measured sizes:
- `/Users/ignacio.viejo/Library/Application Support`: `50G`
- `/Users/ignacio.viejo/Library/Application Support/Google`: `22G`
- `/Users/ignacio.viejo/Library/Application Support/Claude`: `10G`
- `/Users/ignacio.viejo/Library/Application Support/Cursor`: `7.3G`
- `/Users/ignacio.viejo/Library/Application Support/Slack`: `1.5G`
- `/Users/ignacio.viejo/Library/Application Support/Code`: `1.0G`
- `/Users/ignacio.viejo/Library/Application Support/Figma`: `988M`

Google breakdown:
- `/Users/ignacio.viejo/Library/Application Support/Google/Chrome`: `16G`
- `/Users/ignacio.viejo/Library/Application Support/Google/Chrome Beta`: `5.7G`
- `/Users/ignacio.viejo/Library/Application Support/Google/DriveFS`: `605M`

Google Chrome breakdown:
- `/Users/ignacio.viejo/Library/Application Support/Google/Chrome/Profile 1`: `6.8G`
- `/Users/ignacio.viejo/Library/Application Support/Google/Chrome/OptGuideOnDeviceModel`: `4.0G`
- `/Users/ignacio.viejo/Library/Application Support/Google/Chrome/Default`: `3.9G`
- `/Users/ignacio.viejo/Library/Application Support/Google/Chrome/Snapshots`: `791M`

Google Chrome Beta breakdown:
- `/Users/ignacio.viejo/Library/Application Support/Google/Chrome Beta/OptGuideOnDeviceModel`: `4.0G`
- `/Users/ignacio.viejo/Library/Application Support/Google/Chrome Beta/Default`: `1.1G`

Claude breakdown:
- `/Users/ignacio.viejo/Library/Application Support/Claude/vm_bundles`: `9.5G`
- `/Users/ignacio.viejo/Library/Application Support/Claude/claude-code-vm`: `213M`
- `/Users/ignacio.viejo/Library/Application Support/Claude/Cache`: `195M`
- `/Users/ignacio.viejo/Library/Application Support/Claude/vm_bundles/claudevm.bundle/rootfs.img`: `10G`
- `/Users/ignacio.viejo/Library/Application Support/Claude/vm_bundles/claudevm.bundle/rootfs.img.zst`: `2.0G`
- `/Users/ignacio.viejo/Library/Application Support/Claude/vm_bundles/claudevm.bundle/sessiondata.img`: `30M`

Cursor breakdown:
- `/Users/ignacio.viejo/Library/Application Support/Cursor/User`: `5.5G`
- `/Users/ignacio.viejo/Library/Application Support/Cursor/CachedData`: `1.0G`
- `/Users/ignacio.viejo/Library/Application Support/Cursor/Partitions`: `409M`
- `/Users/ignacio.viejo/Library/Application Support/Cursor/Cache`: `226M`
- `/Users/ignacio.viejo/Library/Application Support/Cursor/User/workspaceStorage`: `4.2G`
- `/Users/ignacio.viejo/Library/Application Support/Cursor/User/globalStorage`: `1.3G`
- `/Users/ignacio.viejo/Library/Application Support/Cursor/User/workspaceStorage/43b7871efccd35dacf7d4f52a01637f7`: `4.2G`

### 3. Library Developer Data

What it does:
Xcode build output, package checkouts, symbol caches, and simulator device data.

Where it lives:
- `/Users/ignacio.viejo/Library/Developer`

How it connects to other components:
- `Xcode/DerivedData` is tied to local iOS/macOS builds.
- `CoreSimulator/Devices` is tied to installed and used simulator devices.
- The identified project names match local iOS projects such as `AttendeeApp` and `Rally`.

Measured sizes:
- `/Users/ignacio.viejo/Library/Developer`: `33G`
- `/Users/ignacio.viejo/Library/Developer/Xcode`: `21G`
- `/Users/ignacio.viejo/Library/Developer/CoreSimulator`: `11G`

Xcode breakdown:
- `/Users/ignacio.viejo/Library/Developer/Xcode/DerivedData`: `21G`
- `/Users/ignacio.viejo/Library/Developer/Xcode/UserData`: `70M`

Largest DerivedData entries:
- `/Users/ignacio.viejo/Library/Developer/Xcode/DerivedData/AttendeeApp-caubfciqqsfnkadacfhutnjyruiu`: `5.0G`
- `/Users/ignacio.viejo/Library/Developer/Xcode/DerivedData/AttendeeApp-bvozxeiidcuzxhcukavudpyweypb`: `4.3G`
- `/Users/ignacio.viejo/Library/Developer/Xcode/DerivedData/Rally-aswughesutciczavsjlrrhaufxkt`: `4.0G`
- `/Users/ignacio.viejo/Library/Developer/Xcode/DerivedData/AttendeeApp-giaqoumupxlviugixbroqaytcnlp`: `3.9G`
- `/Users/ignacio.viejo/Library/Developer/Xcode/DerivedData/AttendeeApp-etlfalnmfhakqegansyruhtbxovn`: `3.9G`
- `/Users/ignacio.viejo/Library/Developer/Xcode/DerivedData/ModuleCache.noindex`: `308M`

Largest subtrees inside DerivedData:
- `/Users/ignacio.viejo/Library/Developer/Xcode/DerivedData/AttendeeApp-caubfciqqsfnkadacfhutnjyruiu/SourcePackages`: `3.9G`
- `/Users/ignacio.viejo/Library/Developer/Xcode/DerivedData/AttendeeApp-bvozxeiidcuzxhcukavudpyweypb/SourcePackages`: `2.5G`
- `/Users/ignacio.viejo/Library/Developer/Xcode/DerivedData/AttendeeApp-bvozxeiidcuzxhcukavudpyweypb/Index.noindex`: `1.8G`
- `/Users/ignacio.viejo/Library/Developer/Xcode/DerivedData/AttendeeApp-caubfciqqsfnkadacfhutnjyruiu/Build`: `1.0G`

CoreSimulator breakdown:
- `/Users/ignacio.viejo/Library/Developer/CoreSimulator/Devices`: `11G`

Largest simulator device data directories:
- `/Users/ignacio.viejo/Library/Developer/CoreSimulator/Devices/51F75A4D-49A1-4575-8CDB-41C783F02241/data`: `3.6G`
- `/Users/ignacio.viejo/Library/Developer/CoreSimulator/Devices/4E035F0E-D222-4241-AEAA-563B49DE3BE5/data`: `3.1G`
- `/Users/ignacio.viejo/Library/Developer/CoreSimulator/Devices/3BF997DA-04EA-4B31-A3C6-BDEF6A96EBF8/data`: `2.3G`
- `/Users/ignacio.viejo/Library/Developer/CoreSimulator/Devices/4E2AAA24-E599-41BC-9291-B11226DA68B9/data`: `703M`
- `/Users/ignacio.viejo/Library/Developer/CoreSimulator/Devices/C96B24E1-27C3-4965-9BEB-6F013A29FE4B/data`: `489M`
- `/Users/ignacio.viejo/Library/Developer/CoreSimulator/Devices/80ED5B73-1FF9-4D78-A38C-E9ABCCCF6616/data`: `425M`

### 4. Library Caches and Tool Caches

What it does:
Temporary or reusable cache data for package managers, SDKs, browsers, tooling, and local inference models.

Where it lives:
- `/Users/ignacio.viejo/Library/Caches`
- `/Users/ignacio.viejo/.cache`
- `/Users/ignacio.viejo/.npm`
- `/Users/ignacio.viejo/.pyenv`
- `/Users/ignacio.viejo/.colima`
- `/Users/ignacio.viejo/.cursor`

How it connects to other components:
- `Library/Caches` is per-app cache storage.
- `.cache` holds tool-specific caches such as `uv` and Whisper model files.
- `.npm`, `.pyenv`, and `.colima` map to local development environments.
- `.cursor/extensions` maps to installed editor extensions.

Measured sizes:
- `/Users/ignacio.viejo/Library/Caches`: `27G`
- `/Users/ignacio.viejo/.cache`: `12G`
- `/Users/ignacio.viejo/.npm`: `3.5G`
- `/Users/ignacio.viejo/.pyenv/versions`: `2.0G`
- `/Users/ignacio.viejo/.colima/_lima`: `999M`
- `/Users/ignacio.viejo/.cursor/extensions`: `1.4G`

Largest `Library/Caches` entries:
- `/Users/ignacio.viejo/Library/Caches/Yarn`: `4.0G`
- `/Users/ignacio.viejo/Library/Caches/org.swift.swiftpm`: `3.5G`
- `/Users/ignacio.viejo/Library/Caches/Google`: `3.0G`
- `/Users/ignacio.viejo/Library/Caches/com.spotify.client`: `2.1G`
- `/Users/ignacio.viejo/Library/Caches/Homebrew`: `2.0G`
- `/Users/ignacio.viejo/Library/Caches/aws`: `1.7G`
- `/Users/ignacio.viejo/Library/Caches/Cypress`: `1.1G`
- `/Users/ignacio.viejo/Library/Caches/ms-playwright`: `1.1G`
- `/Users/ignacio.viejo/Library/Caches/Firefox`: `1.0G`
- `/Users/ignacio.viejo/Library/Caches/pypoetry`: `1.0G`
- `/Users/ignacio.viejo/Library/Caches/SiriTTS`: `943M`
- `/Users/ignacio.viejo/Library/Caches/pip`: `734M`
- `/Users/ignacio.viejo/Library/Caches/node-gyp`: `602M`

Largest `.cache` entries:
- `/Users/ignacio.viejo/.cache/uv`: `8.9G`
- `/Users/ignacio.viejo/.cache/whisper`: `2.9G`
- `/Users/ignacio.viejo/.cache/chrome-devtools-mcp`: `206M`

`.cache/uv` breakdown:
- `/Users/ignacio.viejo/.cache/uv/archive-v0`: `8.9G`
- `/Users/ignacio.viejo/.cache/uv/simple-v16`: `16M`
- `/Users/ignacio.viejo/.cache/uv/wheels-v5`: `1.4M`

`.cache/whisper` breakdown:
- `/Users/ignacio.viejo/.cache/whisper/large-v3.pt`: `2.9G`

`.npm` breakdown:
- `/Users/ignacio.viejo/.npm/_cacache`: `2.9G`
- `/Users/ignacio.viejo/.npm/_npx`: `527M`
- `/Users/ignacio.viejo/.npm/_logs`: `9.3M`

`.pyenv` breakdown:
- `/Users/ignacio.viejo/.pyenv/versions`: `2.0G`

`.cursor` breakdown:
- `/Users/ignacio.viejo/.cursor/extensions`: `1.4G`
- `/Users/ignacio.viejo/.cursor/projects`: `14M`
- `/Users/ignacio.viejo/.cursor/ai-tracking`: `8.1M`

### 5. Repository Worktrees

What it does:
Local working copies for source repositories and their generated artifacts.

Where it lives:
- `/Users/ignacio.viejo/eventbrite`
- `/Users/ignacio.viejo/saski`

How it connects to other components:
- Repository size is split between version control history, dependency directories, and project-specific generated output.
- iOS repositories also connect to the large `Library/Developer` measurements above through Xcode and simulator use.

Measured sizes:
- `/Users/ignacio.viejo/eventbrite`: `24G`
- `/Users/ignacio.viejo/saski`: `5.0G`

Largest `eventbrite` repositories:
- `/Users/ignacio.viejo/eventbrite/eb-ui`: `9.3G`
- `/Users/ignacio.viejo/eventbrite/EventService`: `3.7G`
- `/Users/ignacio.viejo/eventbrite/iOS-attendee`: `2.4G`
- `/Users/ignacio.viejo/eventbrite/core`: `2.3G`
- `/Users/ignacio.viejo/eventbrite/consumer-header`: `1.6G`
- `/Users/ignacio.viejo/eventbrite/listings-webapp`: `1.4G`
- `/Users/ignacio.viejo/eventbrite/gitnexus`: `1.2G`
- `/Users/ignacio.viejo/eventbrite/attendeeapp_android`: `1.2G`

`eventbrite/eb-ui` breakdown:
- `/Users/ignacio.viejo/eventbrite/eb-ui/node_modules`: `5.6G`
- `/Users/ignacio.viejo/eventbrite/eb-ui/.git`: `3.0G`
- `/Users/ignacio.viejo/eventbrite/eb-ui/packages`: `416M`
- `/Users/ignacio.viejo/eventbrite/eb-ui/bundles`: `106M`
- `/Users/ignacio.viejo/eventbrite/eb-ui/coverage`: `96M`

`eventbrite/EventService` breakdown:
- `/Users/ignacio.viejo/eventbrite/EventService/.git`: `2.6G`
- `/Users/ignacio.viejo/eventbrite/EventService/terraform`: `1.0G`
- `/Users/ignacio.viejo/eventbrite/EventService/services`: `37M`
- `/Users/ignacio.viejo/eventbrite/EventService/vendor`: `18M`

`eventbrite/iOS-attendee` breakdown:
- `/Users/ignacio.viejo/eventbrite/iOS-attendee/.git`: `2.2G`
- `/Users/ignacio.viejo/eventbrite/iOS-attendee/ios`: `152M`
- `/Users/ignacio.viejo/eventbrite/iOS-attendee/fastlane`: `55M`

`eventbrite/core` breakdown:
- `/Users/ignacio.viejo/eventbrite/core/.git`: `1.6G`
- `/Users/ignacio.viejo/eventbrite/core/django`: `365M`
- `/Users/ignacio.viejo/eventbrite/core/.gitnexus`: `302M`
- `/Users/ignacio.viejo/eventbrite/core/python`: `13M`

Largest `saski` repository:
- `/Users/ignacio.viejo/saski/iOS-attendee`: `2.7G`

`saski/iOS-attendee` breakdown:
- `/Users/ignacio.viejo/saski/iOS-attendee/.git`: `2.4G`
- `/Users/ignacio.viejo/saski/iOS-attendee/ios`: `291M`
- `/Users/ignacio.viejo/saski/iOS-attendee/fastlane`: `26M`

### 6. Media Libraries

What it does:
Personal audio and video files outside application-managed caches.

Where it lives:
- `/Users/ignacio.viejo/Music`
- `/Users/ignacio.viejo/Movies`

How it connects to other components:
- These directories map most directly to the Documents or Music Creation storage groupings in macOS.

Measured sizes:
- `/Users/ignacio.viejo/Music`: `7.9G`
- `/Users/ignacio.viejo/Movies`: `1.1G`

Largest `Music` entries:
- `/Users/ignacio.viejo/Music/Stereolab - Switched On Volumes 1-5 - flac`: `2.5G`
- `/Users/ignacio.viejo/Music/Music`: `2.2G`
- `/Users/ignacio.viejo/Music/Stereolab - Switched On Volumes 1-5 - mp3`: `898M`
- `/Users/ignacio.viejo/Music/Aphex Twin - Syro - wav`: `654M`
- `/Users/ignacio.viejo/Music/autechre live`: `455M`
- `/Users/ignacio.viejo/Music/Leyland Kirby - We drink to forget the coming storm`: `320M`
- `/Users/ignacio.viejo/Music/Aphex Twin - Collapse EP - wav`: `293M`

Largest `Movies` entries:
- `/Users/ignacio.viejo/Movies/UMBRALIA_TEST_05.mp4`: `685M`
- `/Users/ignacio.viejo/Movies/CapCut`: `268M`
- `/Users/ignacio.viejo/Movies/yeliz.mov`: `67M`

## Code References

- `/Users/ignacio.viejo`
- `/Users/ignacio.viejo/Library/Application Support`
- `/Users/ignacio.viejo/Library/Developer`
- `/Users/ignacio.viejo/Library/Caches`
- `/Users/ignacio.viejo/.cache`
- `/Users/ignacio.viejo/.npm`
- `/Users/ignacio.viejo/.pyenv`
- `/Users/ignacio.viejo/.cursor`
- `/Users/ignacio.viejo/.colima`
- `/Users/ignacio.viejo/eventbrite`
- `/Users/ignacio.viejo/saski`
- `/Users/ignacio.viejo/Music`
- `/Users/ignacio.viejo/Movies`

## Architecture Notes

- The measured storage does not come from a single category. It is distributed across user content, application state, developer build artifacts, simulators, package caches, and repository histories.
- The `Library` subtree is the dominant non-repository area based on measured subtrees:
  - `/Users/ignacio.viejo/Library/Application Support`: `50G`
  - `/Users/ignacio.viejo/Library/Developer`: `33G`
  - `/Users/ignacio.viejo/Library/Caches`: `27G`
  - `/Users/ignacio.viejo/Library/Containers`: `2.1G`
  - `/Users/ignacio.viejo/Library/Group Containers`: `596M`
- The repository footprint is concentrated in a small number of large worktrees rather than many medium-sized projects.
- The developer footprint is split between repository data under home and derived artifacts under `Library/Developer`.

## Open Questions

- macOS Storage reports `Bin` at roughly `5.96 GB`, but direct shell inspection of `/Users/ignacio.viejo/.Trash` returned `Operation not permitted`, so the contents were not attributable in this audit.
- A full home-wide search for every file larger than `1G` did not complete within the session budget, so file-level evidence here is focused on the heaviest measured subtrees rather than a complete file inventory.
