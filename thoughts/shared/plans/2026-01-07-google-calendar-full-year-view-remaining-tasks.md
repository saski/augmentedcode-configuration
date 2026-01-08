---
date: 2026-01-07
researcher: saski
topic: "Google Calendar Full-Year View - Remaining Tasks Before Validation"
tags: [tasks, chrome-extension, validation, setup]
status: in-progress
---

# Google Calendar Full-Year View - Remaining Tasks Before Validation

This document lists all remaining manual tasks, setup steps, and verification items that must be completed before running `/fic-validate-plan` on the main implementation plan.

## Overview

All 7 phases of code implementation are complete. The following tasks are required to make the extension fully functional and ready for validation.

## Critical Setup Tasks

### 1. Create Extension Icons ⚠️ REQUIRED

**Status**: ✅ Complete  
**Priority**: HIGH - Extension won't load without icons

**Tasks**:
- [x] Icon generator tool created (`generate-icons.html`)
- [x] Automated icon creation script created (`create-icons.sh`)
- [x] Create `assets/icons/icon-16.png` (16x16 pixels) ✅ Created 2026-01-07
- [x] Create `assets/icons/icon-48.png` (48x48 pixels) ✅ Created 2026-01-07
- [x] Create `assets/icons/icon-128.png` (128x128 pixels) ✅ Created 2026-01-07

**Completed**: Icons created using macOS sips command (2026-01-07). All three icon files verified in `assets/icons/` directory.

**Options**:
1. ✅ Use provided icon generator: Open `generate-icons.html` in browser
2. Use placeholder icons (simple colored squares with text)
3. Design custom icons matching Google Calendar style
4. Use online tool: https://www.favicon-generator.org/

**Icon Generator Tool**:
- Location: `google-calendar-plugin/generate-icons.html`
- Usage: Open in browser, click "Generate Icons", download each icon
- Saves to: `assets/icons/icon-{size}.png`

---

### 2. Google Cloud Console OAuth Setup ⚠️ REQUIRED

**Status**: ✅ Complete  
**Priority**: HIGH - API calls won't work without OAuth

**Tasks**:
- [x] Create Google Cloud Project ✅ (2026-01-07)
  - Go to: https://console.cloud.google.com/
  - Create new project or select existing
  - Note project ID

- [x] Enable Google Calendar API ✅ (2026-01-07)
  - Navigate to "APIs & Services" > "Library"
  - Search for "Google Calendar API"
  - Click "Enable"

- [x] Configure OAuth Consent Screen ✅ (2026-01-07)
  - Go to "APIs & Services" > "OAuth consent screen"
  - Choose "External" user type (unless using Google Workspace)
  - Fill required fields:
    - App name: "Google Calendar Full-Year View"
    - User support email: [your email]
    - Developer contact: [your email]
  - Add scopes:
    - `https://www.googleapis.com/auth/calendar.readonly`
  - Save and continue through test users (if needed)

- [x] Create OAuth 2.0 Client ID ✅ (2026-01-07)
  - Go to "APIs & Services" > "Credentials"
  - Click "Create Credentials" > "OAuth client ID"
  - Application type: "Chrome extension"
  - Name: "Google Calendar Full-Year View Extension"
  - Application ID: Get from Chrome extension page (after loading unpacked)
  - Click "Create"
  - Copy the Client ID

- [x] Update manifest.json ✅ (2026-01-07)
  - Open `manifest.json`
  - Replace `YOUR_CLIENT_ID.apps.googleusercontent.com` with actual Client ID
  - Save file
  - **Verified**: Client ID `477284037986-vh39enltkuuifgqq0k2duk57kc8hvtkc.apps.googleusercontent.com` configured

**References**:
- [Google OAuth 2.0 Setup Guide](https://developers.google.com/identity/protocols/oauth2)
- [Chrome Extension OAuth](https://developer.chrome.com/docs/extensions/mv3/security/#oauth2)

---

## Testing & Verification Tasks

### 3. Install Dependencies

**Status**: ✅ Complete  
**Priority**: MEDIUM - Required for running tests

**Tasks**:
- [x] Navigate to project directory (verified)
- [x] Troubleshooting tools created
  - `TROUBLESHOOT_NPM.md` - Complete troubleshooting guide
  - `fix-npm.sh` - Automated fix script
  - `fix-npm-macos.sh` - macOS-specific fix script
- [x] Install npm dependencies ✅ (2026-01-07)
  ```bash
  npm install
  ```
  **Status**: ✅ Fixed and verified 2026-01-07 - npm permissions resolved, all dependencies installed successfully

- [ ] Verify installation
  ```bash
  npm list
  ```

**Root Cause**: macOS extended attributes (`com.apple.provenance`) blocking file access

**Quick Fix**:
```bash
# Option 1: Remove macOS extended attributes (RECOMMENDED)
sudo xattr -cr ~/.nvm/versions/node/v18.20.8/
npm install

# Option 2: Run automated macOS fix script
./fix-npm-macos.sh

# Option 3: Manual fix (if Option 1 doesn't work)
sudo chown -R $(whoami) ~/.nvm/versions/node/v18.20.8/
chmod -R u+rw ~/.nvm/versions/node/v18.20.8/
npm install
```

**See**: `FIX_NPM_NOW.md` for detailed analysis and solutions

---

### 4. Run Automated Tests

**Status**: ✅ Complete - All Tests Passing  
**Priority**: HIGH - Verify code functionality

**Current Reality** (Verified 2026-01-07):
- ✅ **All tests passing** - 15/15 tests pass
- ✅ **All suites passing** - 4/4 test suites pass
- ✅ **No errors** - Clean test run
- ✅ **Chrome mocks working** - jest-chrome properly configured
- ✅ **npm permissions fixed** - Dependencies installed successfully

**Test Results** (Verified 2026-01-07):
```
Test Suites: 4 passed, 4 total
Tests:       15 passed, 15 total
Time:        0.879 s
```

**Tasks**:
- [x] Fix node_modules permissions ✅ (2026-01-07)
- [x] Dependencies installed ✅ (2026-01-07)
- [x] Jest configuration working ✅
- [x] Chrome mocks configured ✅
- [x] Run all unit tests ✅ (2026-01-07)
  ```bash
  npm test
  ```
  **Result**: All 4 suites, 15 tests passing ✅ (0.879s)

- [x] Verify test suites ✅ (2026-01-07)
  - ✅ `tests/unit/date-utils.test.js` - PASS
  - ✅ `tests/unit/oauth-handler.test.js` - PASS
  - ✅ `tests/integration/api-client.test.js` - PASS
  - ✅ `tests/integration/view-injection.test.js` - PASS

**Status**: ✅ **COMPLETE** - All tests passing, npm permissions fixed, ready for next steps

**See**: `TEST_STATUS_REAL.md` for verified test results

---

### 5. Load Extension in Chrome

**Status**: ⚠️ Ready to Load  
**Priority**: HIGH - Required for manual testing

**Tasks**:
- [ ] Open Chrome browser
- [ ] Navigate to `chrome://extensions/`
- [ ] Enable "Developer mode" (toggle in top right)
- [ ] Click "Load unpacked"
- [ ] Select project directory: `/Users/ignacio.viejo/saski/google-calendar-plugin`
- [ ] Verify extension appears in list
- [ ] Check for errors in extension details
- [ ] Note Extension ID (already configured in OAuth)

**Expected Result**:
- Extension appears with name "Google Calendar Full-Year View"
- No red error messages
- Version shows as "0.1.0"
- OAuth Client ID configured correctly

---

### 6. Manual Testing Checklist

**Status**: ⚠️ Pending  
**Priority**: HIGH - Verify functionality

#### OAuth Flow Testing
- [ ] Open Google Calendar: https://calendar.google.com
- [ ] Check browser console for content script loading
- [ ] Click extension icon in toolbar
- [ ] Verify popup appears
- [ ] (Future: Test "Sign In" button when popup UI is implemented)
- [ ] Verify OAuth consent screen appears when API is called
- [ ] Complete OAuth flow
- [ ] Verify token stored in extension storage
  - Open DevTools > Application > Storage > Extension Storage
  - Check for `oauthToken` key

#### View Injection Testing
- [ ] Open Google Calendar
- [ ] Look for "Full Year" option in view switcher
- [ ] Verify "Full Year" button appears
- [ ] Click "Full Year" button
- [ ] Verify standard calendar view hides
- [ ] Verify full-year view container appears
- [ ] Check browser console for errors

#### Layout Testing
- [ ] Verify 12 month rows display
- [ ] Verify days 1-31 appear sequentially in each row
- [ ] Verify month labels (JAN, FEB, etc.) appear correctly
- [ ] Verify weekend colors:
  - Saturdays are light green
  - Sundays are light pink
  - Weekdays are light blue
- [ ] Test horizontal scroll on smaller screen/window
- [ ] Verify month labels stay fixed during scroll

#### Event Display Testing
- [ ] Verify events appear in correct day cells
- [ ] Verify event colors match Google Calendar colors
- [ ] Test days with 1-3 events (should show individual dots)
- [ ] Test days with 4+ events (should show count indicator)
- [ ] Verify multi-day events appear on all relevant days
- [ ] Test hover over event dots (should show tooltip)
- [ ] Verify tooltip shows event title, location, time

#### Interaction Testing
- [ ] Click on day cell with events
- [ ] Verify event list modal appears
- [ ] Verify modal shows all events for that day
- [ ] Verify modal displays event details correctly
- [ ] Test closing modal:
  - Click X button
  - Click outside modal
  - Press Escape key
- [ ] Test clicking day cell with no events
- [ ] Verify console log for "would open create dialog"

#### Performance Testing
- [ ] Measure view load time (should be < 2 seconds)
- [ ] Test with calendar containing many events
- [ ] Verify smooth scrolling
- [ ] Check memory usage in DevTools
- [ ] Test with multiple calendars

---

### 7. Error Handling Verification

**Status**: ⚠️ Pending  
**Priority**: MEDIUM - Ensure robustness

**Tasks**:
- [ ] Test with no internet connection (should handle gracefully)
- [ ] Test with invalid OAuth token (should prompt re-auth)
- [ ] Test with API rate limit (should show error message)
- [ ] Test with empty calendar (should display empty grid)
- [ ] Test with very large number of events
- [ ] Verify console error messages are user-friendly
- [ ] Check for any unhandled promise rejections

---

### 8. Code Quality Checks

**Status**: ✅ Review Complete  
**Priority**: MEDIUM - Ensure code quality

**Tasks**:
- [x] Review all files for consistency
- [x] Check for console.log statements (found 6, 3 are debug statements to review)
- [x] Verify all functions are properly documented
- [x] Check for any TODO comments (none found)
- [x] Verify error messages are clear
- [x] Check for potential security issues
- [x] Verify no hardcoded credentials or sensitive data

**Findings**:
- **Appropriate console statements** (keep): `console.error` and `console.warn` for error handling
- **Debug console statements** (consider removing):
  - `popup.js` line 6: `console.log('Popup script loaded')`
  - `background.js` line 6: `console.log('Google Calendar Full-Year View extension loaded')`
  - `full-year-view.js` line 159: `console.log('No events, would open create dialog')`
- **No TODOs found** - Code is clean
- **No security issues** - No hardcoded credentials
- **See**: `SETUP_PROGRESS.md` for detailed review

---

### 9. Documentation Updates

**Status**: ✅ Complete  
**Priority**: LOW - Improve maintainability

**Tasks**:
- [x] Update README.md with actual setup results
- [x] Document any deviations from original plan
- [x] Add troubleshooting section to README
- [x] Document known issues or limitations
- [ ] Add screenshots (optional)
- [x] Update plan file with final status

**Completed**: README updated with troubleshooting section, setup instructions, and current status

---

## Validation Readiness Checklist

Before running `/fic-validate-plan`, ensure:

- [ ] All icons created and in place
- [ ] OAuth configured and Client ID added to manifest
- [ ] Dependencies installed (`npm install` completed)
- [ ] All automated tests passing (`npm test`)
- [ ] Extension loads in Chrome without errors
- [ ] Basic manual testing completed (view injection works)
- [ ] OAuth flow tested and working
- [ ] Events display correctly
- [ ] Interactions (hover, click) working
- [ ] No critical console errors
- [ ] Code quality acceptable

---

## Known Issues & Limitations

### Current Limitations (Phase 1 Scope)
- ❌ Event creation not implemented (Phase 3 feature)
- ❌ Event editing not implemented (Phase 3 feature)
- ❌ Advanced filtering not implemented (Phase 2 feature)
- ❌ Mobile optimization not implemented (Phase 2 feature)
- ❌ Offline support not implemented (Phase 2 feature)

### Potential Issues to Address
- [ ] ES6 module conversion may need refinement
- [ ] Date utility functions may need edge case testing
- [ ] CSS injection timing may need adjustment
- [ ] Error handling may need improvement
- [ ] Performance with large datasets needs testing

---

## Next Steps After Completion

Once all tasks are complete:

1. **Run validation**:
   ```
   /fic-validate-plan thoughts/shared/plans/2026-01-07-google-calendar-full-year-view.md
   ```

2. **Create git commits** (if using version control):
   - Commit code implementation
   - Commit configuration files
   - Commit documentation updates

3. **Consider Phase 2 features**:
   - Advanced filtering
   - Mobile optimization
   - Offline support

4. **Consider Phase 3 features**:
   - Event creation
   - Event editing
   - Event deletion

---

## Progress Tracking

**Overall Progress**: 🟡 In Progress

- ✅ Code Implementation: 100% Complete
- 🟡 Setup Tasks: 60% Complete
  - ✅ Icons: Tools created (HTML generator + script)
  - ✅ Documentation: Complete
  - ✅ OAuth: Guide created, needs manual setup
  - ⚠️ npm: Fixed configuration, dependencies incomplete
- ❌ Testing: 0% Complete (blocked - tests cannot run)
  - ❌ Dependencies incomplete: `@jest/test-sequencer` missing
  - ❌ Tests cannot execute: Jest fails to start
  - ⚠️ Previous runs: 2/4 suites passed when tests could run
- ⚠️ Validation: 0% Complete

**Estimated Time Remaining**:
- Setup (OAuth + Icons): 30-60 minutes
- Testing: 1-2 hours
- Bug fixes: Variable
- Validation: 15-30 minutes

---

## Notes

- All code is implemented and ready
- Module system converted to browser-compatible pattern
- No build step required
- Extension should work once icons and OAuth are configured
- Focus on manual testing and verification before validation

---

**Last Updated**: 2026-01-07  
**Next Review**: After setup tasks completion

---

## Implementation Progress Update

**Date**: 2026-01-07  
**Status**: Partial Implementation Complete

### Completed ✅
1. **Icon Generator Tool**: Created `generate-icons.html` for easy icon generation
2. **Code Quality Review**: Complete review of all source files
   - No TODOs found
   - Identified 3 debug console.log statements for cleanup
   - Verified no security issues
   - All error handling appropriate
3. **Documentation**: Created `SETUP_PROGRESS.md` with detailed findings

### Blocked ⚠️
1. **npm Install**: Permission error (EPERM) - requires manual intervention
2. **Tests**: Cannot run without dependencies installed

### Manual Tasks Remaining
1. **Icons**: Use provided `generate-icons.html` tool to create icons
2. **OAuth Setup**: Complete Google Cloud Console configuration (detailed instructions in plan)
3. **Dependencies**: Fix npm permissions and run `npm install`
4. **Testing**: Run tests after dependencies installed
5. **Manual Verification**: Load extension and test functionality

### Files Created
- `google-calendar-plugin/generate-icons.html` - Icon generator tool
- `google-calendar-plugin/create-icons.sh` - Automated icon creation script
- `google-calendar-plugin/SETUP_PROGRESS.md` - Detailed progress report
- `google-calendar-plugin/PROGRESS_SUMMARY.md` - Complete progress summary
- `google-calendar-plugin/OAUTH_SETUP_GUIDE.md` - Step-by-step OAuth setup guide
- `google-calendar-plugin/TROUBLESHOOT_NPM.md` - npm permission troubleshooting guide
- `google-calendar-plugin/FIX_NPM_NOW.md` - Quick npm fix instructions
- `google-calendar-plugin/FIX_DEPENDENCY_CONFLICT.md` - Dependency conflict solutions
- `google-calendar-plugin/FIX_TESTS.md` - Test environment fixes
- `google-calendar-plugin/fix-npm.sh` - Automated npm permission fix script
- `google-calendar-plugin/fix-npm-macos.sh` - macOS-specific npm fix
- `google-calendar-plugin/.npmrc` - npm configuration (legacy-peer-deps)

### Next Steps
1. Generate icons using provided tool
2. Complete OAuth setup in Google Cloud Console
3. Fix npm permissions and install dependencies
4. Run automated tests
5. Load extension in Chrome for manual testing

