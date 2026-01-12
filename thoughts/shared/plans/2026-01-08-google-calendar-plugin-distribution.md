# Google Calendar Full-Year View - Distribution & Chrome Web Store Preparation

## Overview

Transform the working unpacked Chrome extension into a production-ready, distributable plugin ready for Chrome Web Store submission. This plan covers build automation, store assets, privacy policy, versioning, and the complete submission process.

## Current State Analysis

**What exists now:**
- ✅ Fully functional extension (all 7 phases complete)
- ✅ All tests passing (15/15 tests, 4/4 suites)
- ✅ Icons created (16x16, 48x48, 128x128)
- ✅ OAuth configured with Client ID
- ✅ License: Unlicense (public domain)
- ✅ No build process (vanilla JS, no compilation needed)
- ✅ Extension loads successfully as unpacked

**Key constraints discovered:**
- No build/packaging automation
- No version management system
- No store listing assets (screenshots, descriptions)
- No privacy policy (required for Chrome Web Store)
- No release process
- `.gitignore` already excludes `dist/`, `build/`, `*.zip` (good for packaging)

**Files to reference:**
- `manifest.json:1:60` - Current manifest configuration
- `package.json:1:20` - Current package configuration
- `PROJECT_STATUS.md:1:437` - Complete project status
- `.gitignore:1:10` - Already excludes build artifacts

## Desired End State

**Specification:**
1. **Automated build process** that creates a `.zip` file ready for Chrome Web Store submission
2. **Version management** with semantic versioning and automated version bumping
3. **Store listing assets** including screenshots, detailed description, and promotional images
4. **Privacy policy** hosted and linked from manifest
5. **Release checklist** for consistent submissions
6. **Documentation** for the distribution process

**How to verify:**
- ✅ Run `npm run build` creates `dist/extension-v0.1.0.zip`
- ✅ Zip file contains all required files (no node_modules, no tests)
- ✅ Zip file validates in Chrome Web Store Developer Dashboard
- ✅ Privacy policy accessible via public URL
- ✅ Store listing assets created and documented
- ✅ Version number increments automatically or via script

## What We're NOT Doing

- **NOT** creating a build system for code compilation (vanilla JS doesn't need it)
- **NOT** setting up CI/CD pipelines (manual release process)
- **NOT** creating Firefox/Edge versions (Chrome Web Store only)
- **NOT** implementing auto-update mechanisms (handled by Chrome Web Store)
- **NOT** creating a website for the extension (store listing is sufficient)
- **NOT** setting up analytics (out of scope for initial release)

## Implementation Approach

**High-level strategy:**
1. Create build script that packages extension into Chrome Web Store-ready zip
2. Add version management scripts (bump version, update manifest)
3. Create store listing assets (screenshots, descriptions)
4. Create and host privacy policy
5. Document submission process
6. Add release checklist

**Key decisions:**
- Use Node.js scripts for build automation (no new dependencies needed)
- Store assets in `store-assets/` directory
- Privacy policy as simple HTML page (can be hosted on GitHub Pages or similar)
- Version bumping via npm script (updates both `package.json` and `manifest.json`)

## Phase 1: Build & Packaging Automation

### Overview
Create automated build process that packages the extension into a Chrome Web Store-ready zip file, excluding development files and including only production assets.

### Changes Required:

#### 1. Add Build Script
**File**: `package.json`
**Changes**: Add build and package scripts

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "build": "node scripts/build.js",
    "package": "npm run build && node scripts/package.js",
    "version:patch": "node scripts/version.js patch",
    "version:minor": "node scripts/version.js minor",
    "version:major": "node scripts/version.js major"
  }
}
```

#### 2. Create Build Script
**File**: `scripts/build.js` (new file)
**Changes**: Create build script that prepares extension for packaging

```javascript
const fs = require('fs');
const path = require('path');

const BUILD_DIR = path.join(__dirname, '..', 'dist');
const SRC_DIR = path.join(__dirname, '..');

// Files/directories to include
const INCLUDED_PATTERNS = [
  'manifest.json',
  'src/**/*',
  'assets/**/*',
  'LICENSE'
];

// Files/directories to exclude
const EXCLUDED_PATTERNS = [
  'node_modules',
  'tests',
  'thoughts',
  '*.test.js',
  '*.log',
  '.DS_Store',
  'dist',
  'build',
  '*.zip',
  '.env',
  '*.pem',
  'package.json',
  'package-lock.json',
  'jest.config.js',
  'jest.setup.js',
  '.git',
  '.gitignore',
  'README.md',
  'create-icons.sh',
  'fix-*.sh',
  'generate-icons.html'
];

// Implementation: Copy files matching INCLUDED_PATTERNS, exclude EXCLUDED_PATTERNS
// Create dist/ directory structure
// Validate manifest.json
```

#### 3. Create Package Script
**File**: `scripts/package.js` (new file)
**Changes**: Create zip file from dist/ directory

```javascript
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const DIST_DIR = path.join(__dirname, '..', 'dist');
const MANIFEST_PATH = path.join(DIST_DIR, 'manifest.json');

// Read version from manifest
// Create zip file: dist/extension-v{VERSION}.zip
// Verify zip file creation
```

#### 4. Create Version Management Script
**File**: `scripts/version.js` (new file)
**Changes**: Bump version in both package.json and manifest.json

```javascript
const fs = require('fs');
const path = require('path');

// Read current version from manifest.json
// Increment based on argument (patch/minor/major)
// Update both manifest.json and package.json
// Output new version number
```

### Success Criteria:
- [ ] `npm run build` creates `dist/` directory with all required files
- [ ] `npm run package` creates `dist/extension-v0.1.0.zip`
- [ ] Zip file contains only production files (no tests, no node_modules)
- [ ] Zip file size < 5MB (Chrome Web Store limit)
- [ ] Manifest.json is valid JSON
- [ ] All icon files included in zip

---

## Phase 2: Store Listing Assets

### Overview
Create all assets required for Chrome Web Store listing: screenshots, promotional images, detailed description, and category selection.

### Changes Required:

#### 1. Create Store Assets Directory
**File**: `store-assets/` (new directory)
**Changes**: Create directory structure for store assets

```
store-assets/
├── screenshots/
│   ├── 1280x800-1.png  # Main feature screenshot
│   ├── 1280x800-2.png  # Full-year view example
│   └── 1280x800-3.png  # Event details view
├── promotional/
│   ├── 440x280.png     # Small promotional tile
│   └── 920x680.png     # Large promotional tile (optional)
└── store-listing.md     # Store listing text content
```

#### 2. Create Store Listing Content
**File**: `store-assets/store-listing.md` (new file)
**Changes**: Document store listing text content

```markdown
# Chrome Web Store Listing

## Name
Google Calendar Full-Year View

## Short Description (132 characters max)
Adds a full-year view to Google Calendar with sequential day layout for better long-term planning

## Detailed Description (16,000 characters max)
[Detailed description of features, use cases, benefits]

## Category
Productivity

## Language
English (en)

## Tags
calendar, google-calendar, productivity, planning, year-view
```

#### 3. Screenshot Requirements
**File**: `store-assets/SCREENSHOT_GUIDE.md` (new file)
**Changes**: Document screenshot requirements and creation process

```markdown
# Screenshot Creation Guide

## Requirements
- Format: PNG
- Size: 1280x800 pixels (required)
- Minimum: 1 screenshot
- Maximum: 5 screenshots
- File size: < 1MB per image

## Screenshots to Create

1. **Main Feature** (1280x800-1.png)
   - Show full-year view activated in Google Calendar
   - Highlight the sequential day layout
   - Include sample events

2. **Event Details** (1280x800-2.png)
   - Show event hover/click interactions
   - Demonstrate event rendering

3. **Comparison View** (1280x800-3.png) [Optional]
   - Side-by-side: standard view vs full-year view
   - Highlight benefits

## Creation Steps
1. Load extension in Chrome
2. Navigate to Google Calendar
3. Activate full-year view
4. Take screenshots using browser DevTools or screenshot tool
5. Edit/crop to 1280x800
6. Save to store-assets/screenshots/
```

### Success Criteria:
- [ ] `store-assets/` directory created with proper structure
- [ ] At least 1 screenshot created (1280x800 PNG)
- [ ] Store listing content documented in `store-listing.md`
- [ ] Screenshot guide created with clear instructions
- [ ] All assets follow Chrome Web Store requirements

---

## Phase 3: Privacy Policy

### Overview
Create and host a privacy policy document required for Chrome Web Store submission. The policy must explain what data is collected, how it's used, and user rights.

### Changes Required:

#### 1. Create Privacy Policy Document
**File**: `store-assets/privacy-policy.html` (new file)
**Changes**: Create privacy policy HTML document

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Privacy Policy - Google Calendar Full-Year View</title>
</head>
<body>
  <h1>Privacy Policy</h1>
  <p>Last updated: [DATE]</p>
  
  <h2>Data Collection</h2>
  <p>This extension accesses your Google Calendar data to display events in the full-year view.</p>
  
  <h2>Data Usage</h2>
  <p>Calendar data is used solely for display purposes within the extension. No data is transmitted to external servers.</p>
  
  <h2>Data Storage</h2>
  <p>OAuth tokens are stored locally in Chrome's storage API. No calendar data is permanently stored.</p>
  
  <h2>Third-Party Services</h2>
  <p>This extension uses Google Calendar API. Your use of this extension is subject to Google's Privacy Policy.</p>
  
  <h2>Contact</h2>
  <p>For questions about this privacy policy, contact: [EMAIL or GitHub Issues URL]</p>
</body>
</html>
```

#### 2. Update Manifest with Privacy Policy Link
**File**: `manifest.json`
**Changes**: Add privacy policy URL (after hosting)

```json
{
  "manifest_version": 3,
  "name": "Google Calendar Full-Year View",
  "version": "0.1.0",
  "description": "Adds a full-year view to Google Calendar with sequential day layout",
  "homepage_url": "https://github.com/[USERNAME]/google-calendar-plugin",
  "privacy_policy": "https://[HOSTED-URL]/privacy-policy.html",
  // ... rest of manifest
}
```

#### 3. Create Privacy Policy Hosting Guide
**File**: `store-assets/PRIVACY_POLICY_HOSTING.md` (new file)
**Changes**: Document hosting options and setup

```markdown
# Privacy Policy Hosting Guide

## Hosting Options

### Option 1: GitHub Pages (Recommended - Free)
1. Create `docs/` directory in repository
2. Copy `privacy-policy.html` to `docs/privacy-policy.html`
3. Enable GitHub Pages in repository settings
4. URL: `https://[USERNAME].github.io/[REPO]/privacy-policy.html`

### Option 2: Netlify/Vercel (Free)
1. Create new site from repository
2. Deploy `store-assets/privacy-policy.html`
3. Get public URL

### Option 3: Personal Website
1. Upload HTML file to web server
2. Get public URL
3. Update manifest.json with URL

## Update Manifest
After hosting, update `manifest.json` with the privacy_policy URL.
```

### Success Criteria:
- [ ] Privacy policy HTML created with all required sections
- [ ] Privacy policy hosted at public URL
- [ ] `manifest.json` updated with `privacy_policy` field
- [ ] Privacy policy URL accessible and renders correctly
- [ ] Hosting guide documents setup process

---

## Phase 4: Version Management

### Overview
Implement semantic versioning with automated version bumping that updates both `package.json` and `manifest.json` simultaneously.

### Changes Required:

#### 1. Enhance Version Script
**File**: `scripts/version.js` (from Phase 1, enhance)
**Changes**: Complete version management implementation

```javascript
const fs = require('fs');
const path = require('path');

const MANIFEST_PATH = path.join(__dirname, '..', 'manifest.json');
const PACKAGE_PATH = path.join(__dirname, '..', 'package.json');

function bumpVersion(currentVersion, type) {
  const [major, minor, patch] = currentVersion.split('.').map(Number);
  
  switch(type) {
    case 'major': return `${major + 1}.0.0`;
    case 'minor': return `${major}.${minor + 1}.0`;
    case 'patch': return `${major}.${minor}.${patch + 1}`;
    default: throw new Error(`Invalid version type: ${type}`);
  }
}

// Read current version from manifest.json
// Bump version based on type
// Update both manifest.json and package.json
// Output new version
// Optionally create git tag
```

#### 2. Add Version Validation
**File**: `scripts/version.js` (enhance)
**Changes**: Validate version format

```javascript
function validateVersion(version) {
  const semverRegex = /^\d+\.\d+\.\d+$/;
  if (!semverRegex.test(version)) {
    throw new Error(`Invalid version format: ${version}. Use semantic versioning (e.g., 1.2.3)`);
  }
}
```

### Success Criteria:
- [ ] `npm run version:patch` increments patch version (0.1.0 → 0.1.1)
- [ ] `npm run version:minor` increments minor version (0.1.0 → 0.2.0)
- [ ] `npm run version:major` increments major version (0.1.0 → 1.0.0)
- [ ] Both `manifest.json` and `package.json` updated simultaneously
- [ ] Version format validated (semantic versioning)
- [ ] Script outputs new version number

---

## Phase 5: Release Process Documentation

### Overview
Create comprehensive documentation for the release process, including pre-submission checklist, submission steps, and post-release maintenance.

### Changes Required:

#### 1. Create Release Checklist
**File**: `RELEASE_CHECKLIST.md` (new file)
**Changes**: Document release process

```markdown
# Release Checklist

## Pre-Release

### Code Quality
- [ ] All tests passing: `npm test`
- [ ] No console errors in extension
- [ ] Manual testing completed
- [ ] Code reviewed

### Version Management
- [ ] Version bumped: `npm run version:patch|minor|major`
- [ ] Version updated in both manifest.json and package.json
- [ ] Changelog updated (if applicable)

### Build & Package
- [ ] Build successful: `npm run build`
- [ ] Package created: `npm run package`
- [ ] Zip file validated (opens correctly)
- [ ] Zip file size < 5MB

### Store Assets
- [ ] Screenshots created and optimized
- [ ] Store listing content finalized
- [ ] Privacy policy hosted and accessible
- [ ] Privacy policy URL added to manifest.json

### Documentation
- [ ] README.md updated (if needed)
- [ ] Release notes prepared

## Chrome Web Store Submission

### Developer Dashboard
1. [ ] Go to [Chrome Web Store Developer Dashboard](https://chrome.google.com/webstore/devconsole)
2. [ ] Click "New Item"
3. [ ] Upload zip file
4. [ ] Fill in store listing:
   - [ ] Name
   - [ ] Short description
   - [ ] Detailed description
   - [ ] Category
   - [ ] Language
   - [ ] Screenshots (at least 1)
   - [ ] Promotional images (optional)
5. [ ] Set visibility (Unlisted for testing, Public for release)
6. [ ] Submit for review

### Post-Submission
- [ ] Monitor review status
- [ ] Address any review feedback
- [ ] Publish when approved

## Post-Release

- [ ] Monitor user feedback
- [ ] Track error reports
- [ ] Plan next version improvements
```

#### 2. Create Submission Guide
**File**: `store-assets/SUBMISSION_GUIDE.md` (new file)
**Changes**: Step-by-step Chrome Web Store submission guide

```markdown
# Chrome Web Store Submission Guide

## Prerequisites

1. **Google Developer Account**
   - Cost: $5 one-time fee
   - Sign up: https://chrome.google.com/webstore/devconsole
   - Payment: Credit card required

2. **Extension Package**
   - Run: `npm run package`
   - File: `dist/extension-v{VERSION}.zip`
   - Size: Must be < 5MB

3. **Store Assets**
   - Screenshots: At least 1 (1280x800 PNG)
   - Description: Short (132 chars) and detailed (16K chars)
   - Privacy policy: Hosted and accessible

## Submission Steps

### Step 1: Create Developer Account
[Detailed steps...]

### Step 2: Upload Extension
[Detailed steps...]

### Step 3: Fill Store Listing
[Detailed steps with screenshots...]

### Step 4: Submit for Review
[Review process explanation...]

## Review Timeline
- Initial review: 1-3 business days
- Updates: 1-2 business days
- Rejections: Review feedback provided

## Common Issues
- Manifest errors: Check JSON validity
- Permission warnings: Justify all permissions
- Privacy policy: Must be accessible
- Screenshots: Must match functionality
```

### Success Criteria:
- [ ] `RELEASE_CHECKLIST.md` created with comprehensive checklist
- [ ] `SUBMISSION_GUIDE.md` created with step-by-step instructions
- [ ] All pre-release steps documented
- [ ] Chrome Web Store submission process documented
- [ ] Post-release maintenance steps included

---

## Phase 6: Update Documentation

### Overview
Update existing documentation to include distribution information and build process.

### Changes Required:

#### 1. Update README
**File**: `README.md`
**Changes**: Add distribution section

```markdown
## Distribution

### Building for Chrome Web Store

```bash
# Build extension
npm run build

# Create package for submission
npm run package

# Output: dist/extension-v{VERSION}.zip
```

### Version Management

```bash
# Bump patch version (0.1.0 → 0.1.1)
npm run version:patch

# Bump minor version (0.1.0 → 0.2.0)
npm run version:minor

# Bump major version (0.1.0 → 1.0.0)
npm run version:major
```

### Release Process

See `RELEASE_CHECKLIST.md` for complete release process.

### Chrome Web Store Submission

See `store-assets/SUBMISSION_GUIDE.md` for detailed submission instructions.
```

#### 2. Update PROJECT_STATUS
**File**: `thoughts/plans/PROJECT_STATUS.md`
**Changes**: Add distribution status section

```markdown
## Distribution Status

- [ ] Build process implemented
- [ ] Store assets created
- [ ] Privacy policy hosted
- [ ] Version management setup
- [ ] Release documentation complete
- [ ] Chrome Web Store submission ready
```

### Success Criteria:
- [ ] README.md updated with distribution section
- [ ] Build commands documented
- [ ] Version management commands documented
- [ ] Links to release checklist and submission guide added
- [ ] PROJECT_STATUS.md updated with distribution status

---

## Testing Strategy

### Unit Tests:
- Version bumping logic (test version.js script)
- Build script file filtering (test build.js)
- Package script zip creation (test package.js)

### Integration Tests:
- End-to-end build process: `npm run build && npm run package`
- Version bump updates both files correctly
- Zip file contains expected files
- Zip file excludes development files

### Manual Verification:
- Zip file opens correctly in Chrome
- Extension loads from zip file
- Store listing assets meet requirements
- Privacy policy renders correctly
- Submission process works end-to-end

## References
- Chrome Web Store Developer Documentation: https://developer.chrome.com/docs/webstore/
- Manifest V3 Documentation: https://developer.chrome.com/docs/extensions/mv3/
- Chrome Web Store Policies: https://developer.chrome.com/docs/webstore/policies/
- Current manifest: `manifest.json:1:60`
- Current package config: `package.json:1:20`
- Project status: `thoughts/plans/PROJECT_STATUS.md:1:437`

---

## Implementation Notes

### Build Script Considerations
- Use Node.js built-in modules (fs, path) - no new dependencies
- Handle file copying for nested directories
- Validate manifest.json after build
- Create dist/ directory if it doesn't exist
- Clean dist/ before building

### Version Management Considerations
- Always update both manifest.json and package.json
- Validate semantic versioning format
- Consider git tagging for releases (optional)
- Output version number for CI/CD integration

### Privacy Policy Considerations
- Must be publicly accessible
- Should be simple HTML (no external dependencies)
- Update "Last updated" date when making changes
- Include contact information or GitHub Issues link

### Store Listing Considerations
- Screenshots must show actual extension functionality
- Description should highlight key features
- Use clear, benefit-focused language
- Include relevant keywords for discoverability

---

## Success Metrics

**Phase 1 (Build & Packaging):**
- ✅ Build script creates clean dist/ directory
- ✅ Package script creates valid zip file
- ✅ Zip file ready for Chrome Web Store submission

**Phase 2 (Store Assets):**
- ✅ At least 1 screenshot created (1280x800)
- ✅ Store listing content documented
- ✅ All assets meet Chrome Web Store requirements

**Phase 3 (Privacy Policy):**
- ✅ Privacy policy created and hosted
- ✅ Privacy policy URL added to manifest
- ✅ Privacy policy accessible and renders

**Phase 4 (Version Management):**
- ✅ Version bumping works for all types
- ✅ Both manifest.json and package.json updated
- ✅ Version format validated

**Phase 5 (Release Documentation):**
- ✅ Release checklist created
- ✅ Submission guide created
- ✅ Process fully documented

**Phase 6 (Documentation Updates):**
- ✅ README updated with distribution info
- ✅ PROJECT_STATUS updated
- ✅ All documentation links working

**Overall Success:**
- ✅ Extension ready for Chrome Web Store submission
- ✅ All required assets and documentation in place
- ✅ Release process repeatable and documented

---

**Plan Status**: Ready for implementation  
**Estimated Time**: 4-6 hours total
- Phase 1: 1-2 hours (build scripts)
- Phase 2: 1 hour (assets and content)
- Phase 3: 30 minutes (privacy policy)
- Phase 4: 30 minutes (version script)
- Phase 5: 1 hour (documentation)
- Phase 6: 30 minutes (README updates)

**Next Steps:**
1. Review and approve this plan
2. Use `/fic-implement-plan` to execute phases sequentially
3. Test build process before creating store assets
4. Host privacy policy before final submission
