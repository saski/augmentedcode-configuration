# Home Disk Space Reduction - Implementation Plan

## Overview

Reduce disk usage under `/Users/saski` in a conservative-first sequence that prioritizes redownloadable caches and regenerated developer artifacts before touching application state, repository working copies, or personal media.

This plan is based on the measured audit in `/Users/saski/Code/augmentedcode-configuration/thoughts/shared/research/2026-04-09-home-disk-usage.md`.

## Progress

- [x] Phase 1 completed on 2026-04-22. Verification: `/Users/saski/Library/Caches` `7.9G`, `/Users/saski/.cache` `3.6G`, `/Users/saski/.npm` `196M`, `/System/Volumes/Data` available space `94Gi`. Adaptation: `/Users/saski/Library/Caches/Google` was live during deletion and was reduced but not fully absent.
- [x] Phase 2 completed on 2026-04-22. Verification: `/Users/saski/Library/Developer/Xcode/DerivedData` removed, `/Users/saski/Library/Developer/CoreSimulator/Devices` `1.1G`, `/System/Volumes/Data` available space `97Gi`. Adaptation: `/Users/saski/.colima/_lima` was not touched because the phase thresholds were already met without resetting Colima.
- [x] Phase 3 skipped on 2026-04-22 because the gated cleanup was not needed after free space reached `97Gi`.
- [x] Phase 4 skipped on 2026-04-22 because the gated cleanup was not needed after free space reached `97Gi`.

## Current State

- `/System/Volumes/Data` currently reports `382Gi` used and `48Gi` available.
- The largest measured non-repository buckets are:
  - `/Users/saski/Library/Application Support`: `50G`
  - `/Users/saski/Library/Developer`: `33G`
  - `/Users/saski/Library/Caches`: `27G`
  - `/Users/saski/.cache`: `12G`
- The largest measured repository buckets are:
  - `/Users/saski/Code/eventbrite`: `24G`
  - `/Users/saski/Code`: `5.0G`
- The largest measured media buckets are:
  - `/Users/saski/Music`: `7.9G`
  - `/Users/saski/Movies`: `1.1G`

## Desired End State

- Available disk space under `/System/Volumes/Data` is materially increased from the current `48Gi`.
- Phases 1 and 2 reclaim the low-risk space first from caches and regenerated developer artifacts.
- Active source repositories remain intact by default.
- Application-owned state is only reduced in a dedicated gated phase after the related apps are closed.
- Personal media is only touched in the final optional phase.

## Out Of Scope

- Uninstalling applications from `/Applications`.
- Modifying macOS system-owned storage outside `/Users/saski`.
- Rewriting git history or deleting repository source code by default.
- Emptying protected Trash locations that require additional macOS permissions.
- Moving files to iCloud or changing iCloud storage settings.

## Approach

Two implementation approaches were considered:

- Conservative reclaim-first: clear caches, build outputs, simulator data, and explicit generated artifacts before touching application profiles, repository histories, or media.
- Aggressive footprint reduction: delete large app-owned state, cold repositories, and personal media in the same pass.

This plan selects the conservative reclaim-first approach and keeps aggressive cleanup in later gated phases.

Implementation guardrails:

- Capture a before snapshot at the start of implementation.
- Close Xcode, Simulator, Chrome, Chrome Beta, Cursor, Claude/Codex, and Colima before phases 2 and 3.
- Re-measure after every phase and stop once the free-space target has been reached.
- Treat phases 3 and 4 as gated even if phases 1 and 2 complete successfully.

## Phase 1: Clear Redownloadable Caches

### Goal

Reclaim space from caches that are expected to be rebuilt or redownloaded without affecting source repositories or personal files.

### Expected Modifications

```text
/Users/saski/Library/Caches/Yarn
/Users/saski/Library/Caches/org.swift.swiftpm
/Users/saski/Library/Caches/Google
/Users/saski/Library/Caches/com.spotify.client
/Users/saski/Library/Caches/Homebrew
/Users/saski/Library/Caches/aws
/Users/saski/Library/Caches/Cypress
/Users/saski/Library/Caches/ms-playwright
/Users/saski/Library/Caches/Firefox
/Users/saski/Library/Caches/pypoetry
/Users/saski/Library/Caches/SiriTTS
/Users/saski/Library/Caches/pip
/Users/saski/Library/Caches/node-gyp
/Users/saski/.cache/uv/archive-v0
/Users/saski/.cache/chrome-devtools-mcp
/Users/saski/.npm/_cacache
/Users/saski/.npm/_npx
```

### Automated Success Criteria

```bash
du -sh /Users/saski/Library/Caches
du -sh /Users/saski/.cache
du -sh /Users/saski/.npm
df -h /Users/saski
```

Phase 1 is successful when:

- `du -sh /Users/saski/Library/Caches` reports `10G` or less.
- `du -sh /Users/saski/.cache` reports `4G` or less.
- `du -sh /Users/saski/.npm` reports `1G` or less.
- `df -h /Users/saski` shows more available space than the current `48Gi` baseline.

## Phase 2: Remove Regenerated Developer Artifacts

### Goal

Reclaim space from Xcode build output, simulator device storage, and local VM/runtime artifacts that can be recreated from active projects.

### Expected Modifications

```text
/Users/saski/Library/Developer/Xcode/DerivedData
/Users/saski/Library/Developer/CoreSimulator/Devices/51F75A4D-49A1-4575-8CDB-41C783F02241/data
/Users/saski/Library/Developer/CoreSimulator/Devices/4E035F0E-D222-4241-AEAA-563B49DE3BE5/data
/Users/saski/Library/Developer/CoreSimulator/Devices/3BF997DA-04EA-4B31-A3C6-BDEF6A96EBF8/data
/Users/saski/Library/Developer/CoreSimulator/Devices/4E2AAA24-E599-41BC-9291-B11226DA68B9/data
/Users/saski/Library/Developer/CoreSimulator/Devices/C96B24E1-27C3-4965-9BEB-6F013A29FE4B/data
/Users/saski/Library/Developer/CoreSimulator/Devices/80ED5B73-1FF9-4D78-A38C-E9ABCCCF6616/data
/Users/saski/.colima/_lima
```

### Automated Success Criteria

```bash
du -sh /Users/saski/Library/Developer/Xcode/DerivedData 2>/dev/null || echo "DerivedData removed"
du -sh /Users/saski/Library/Developer/CoreSimulator/Devices
test ! -e /Users/saski/.colima/_lima && echo ".colima/_lima removed"
df -h /Users/saski
```

Phase 2 is successful when:

- `du -sh /Users/saski/Library/Developer/Xcode/DerivedData` reports `2G` or less, or the directory has been removed.
- `du -sh /Users/saski/Library/Developer/CoreSimulator/Devices` reports `2G` or less.
- `test ! -e /Users/saski/.colima/_lima` succeeds if Colima reset is part of the phase execution.
- `df -h /Users/saski` shows more available space than after Phase 1.

## Phase 3: Reduce Heavyweight App-Owned State

### Goal

Remove oversized browser, editor, and assistant data that is not required for source integrity but may be recreated by the applications.

### Expected Modifications

```text
/Users/saski/Library/Application Support/Google/Chrome/OptGuideOnDeviceModel
/Users/saski/Library/Application Support/Google/Chrome/Snapshots
/Users/saski/Library/Application Support/Google/Chrome Beta/OptGuideOnDeviceModel
/Users/saski/Library/Application Support/Google/Chrome Beta/Snapshots
/Users/saski/Library/Application Support/Cursor/CachedData
/Users/saski/Library/Application Support/Cursor/Cache
/Users/saski/Library/Application Support/Cursor/Partitions
/Users/saski/Library/Application Support/Cursor/User/workspaceStorage/43b7871efccd35dacf7d4f52a01637f7
/Users/saski/Library/Application Support/Claude/vm_bundles/claudevm.bundle/rootfs.img
/Users/saski/Library/Application Support/Claude/vm_bundles/claudevm.bundle/rootfs.img.zst
```

### Automated Success Criteria

```bash
test ! -e "/Users/saski/Library/Application Support/Google/Chrome/OptGuideOnDeviceModel" && echo "Chrome model removed"
test ! -e "/Users/saski/Library/Application Support/Google/Chrome Beta/OptGuideOnDeviceModel" && echo "Chrome Beta model removed"
test ! -e "/Users/saski/Library/Application Support/Cursor/User/workspaceStorage/43b7871efccd35dacf7d4f52a01637f7" && echo "Cursor workspace removed"
test ! -e "/Users/saski/Library/Application Support/Claude/vm_bundles/claudevm.bundle/rootfs.img" && echo "Claude rootfs removed"
du -sh "/Users/saski/Library/Application Support/Google"
du -sh "/Users/saski/Library/Application Support/Cursor"
du -sh "/Users/saski/Library/Application Support/Claude"
df -h /Users/saski
```

Phase 3 is successful when:

- The targeted Chrome and Chrome Beta model directories no longer exist.
- The targeted Cursor cache paths no longer exist.
- The targeted Claude VM bundle images no longer exist if the assistant VM reset is part of the phase execution.
- `du -sh "/Users/saski/Library/Application Support/Google"` reports `14G` or less.
- `du -sh "/Users/saski/Library/Application Support/Cursor"` reports `3G` or less.
- `du -sh "/Users/saski/Library/Application Support/Claude"` reports `1G` or less if the VM bundle reset is executed.
- `df -h /Users/saski` shows more available space than after Phase 2.

## Phase 4: Remove Repository-Generated Output And Optional Cold Data

### Goal

Free additional space without deleting source code by removing measured generated output first, then handling explicitly identified media only if more space is still required.

### Expected Modifications

```text
/Users/saski/Code/eventbrite/eb-ui/node_modules
/Users/saski/Code/eventbrite/eb-ui/coverage
/Users/saski/Code/eventbrite/eb-ui/bundles
/Users/saski/Music/Stereolab - Switched On Volumes 1-5 - flac
/Users/saski/Music/Music
/Users/saski/Music/Stereolab - Switched On Volumes 1-5 - mp3
/Users/saski/Movies/UMBRALIA_TEST_05.mp4
/Users/saski/Movies/CapCut
```

### Automated Success Criteria

```bash
test ! -e /Users/saski/Code/eventbrite/eb-ui/node_modules && echo "eb-ui node_modules removed"
test ! -e /Users/saski/Code/eventbrite/eb-ui/coverage && echo "eb-ui coverage removed"
test ! -e /Users/saski/Code/eventbrite/eb-ui/bundles && echo "eb-ui bundles removed"
du -sh /Users/saski/Code/eventbrite/eb-ui
du -sh /Users/saski/Music
du -sh /Users/saski/Movies
df -h /Users/saski
```

Phase 4 is successful when:

- The targeted generated paths under `/Users/saski/Code/eventbrite/eb-ui` no longer exist.
- `du -sh /Users/saski/Code/eventbrite/eb-ui` reports `4G` or less.
- `du -sh /Users/saski/Music` reports `4G` or less if the optional media portion is executed.
- `du -sh /Users/saski/Movies` reports `200M` or less if the optional media portion is executed.
- `df -h /Users/saski` shows more available space than after Phase 3.

## Execution Order

1. Phase 1
2. Phase 2
3. Re-measure available space
4. Phase 3 only if more space is still needed
5. Re-measure available space
6. Phase 4 only if more space is still needed

## Rollback Strategy

- Phase 1 and Phase 2 target redownloadable or regenerated data and do not require rollback.
- Phase 3 should only be executed after the related applications are closed, and the implementation should record exactly which paths were removed.
- Phase 4 media actions should use a reversible move to a staging location first if the files are not being deleted immediately.

## Final Verification

Run these commands after the last executed phase:

```bash
df -h /Users/saski
du -sh /Users/saski/Library/Application\ Support
du -sh /Users/saski/Library/Developer
du -sh /Users/saski/Library/Caches
du -sh /Users/saski/.cache
du -sh /Users/saski/Code/eventbrite
du -sh /Users/saski/Code
du -sh /Users/saski/Music
du -sh /Users/saski/Movies
```

The overall plan is successful when:

- Free space has increased materially above the starting `48Gi`.
- The largest reclaim-first targets from phases 1 and 2 are no longer dominating the home-folder footprint.
- Any later-phase removals are reflected in the measured path sizes above.
