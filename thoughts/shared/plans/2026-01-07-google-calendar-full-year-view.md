---
date: 2026-01-07
researcher: saski
topic: "Google Calendar Full-Year View Chrome Extension - Phase 1 Implementation"
tags: [plan, chrome-extension, google-calendar, oauth, manifest-v3, tdd]
status: ready
---

# Google Calendar Full-Year View Chrome Extension - Implementation Plan

## Overview

Create a Chrome Extension (Manifest V3) that adds a "Full Year" view option to Google Calendar. The view displays 12 months in horizontal rows, with each day (1-31) laid out sequentially in a single line per month. Phase 1 focuses on view-only functionality with OAuth authentication, view injection, full-year grid layout, event fetching and display, and basic interactions.

## Current State Analysis

**What Exists:**
- Research complete: `thoughts/saski/google-calendar-plugin/2026-01-02-google-calendar-plugin-research.md`
- UI design specifications: `thoughts/saski/google-calendar-plugin/ui-design-reference.md`
- Project structure defined: `thoughts/saski/google-calendar-plugin/project-structure.md`
- Technical decisions made: Chrome Extension (Manifest V3), Google Calendar API v3, OAuth 2.0

**Key Constraints:**
- Google Calendar's DOM structure may change (requires robust selectors)
- API rate limits: 250 events per request, max 2500 per query
- Performance: Rendering 365 days with potentially thousands of events
- OAuth requires Google Cloud Console project setup
- Manifest V3 restrictions (no inline scripts, service worker instead of background page)

**Patterns to Follow:**
- TDD: Write failing test first, then implement
- Baby steps: One test, one file, one change at a time
- Small methods: 10-20 lines max per function
- Type safety: All code fully typed (TypeScript or JSDoc types)

## Desired End State

**Success Criteria:**
1. Chrome Extension installs and loads without errors
2. "Full Year" option appears in Google Calendar's view switcher
3. Clicking "Full Year" displays 12-month grid layout
4. Events are fetched from Google Calendar API and displayed in day cells
5. Weekends (Saturdays/Sundays) are color-coded
6. Hovering over day cells shows event count/tooltip
7. Clicking day cells shows event details (future: create event)
8. OAuth flow completes successfully with read-only calendar access

**Verification:**
- Extension loads in Chrome: `chrome://extensions/` shows no errors
- View switcher contains "Full Year" option
- Full-year view renders correctly with all 12 months
- Events appear in correct day cells
- Weekend colors are distinct from weekdays
- OAuth token stored securely in extension storage

## What We're NOT Doing (Phase 1)

- **NOT** modifying events (create/edit/delete) - Phase 3
- **NOT** advanced filtering or search - Phase 2
- **NOT** drag-and-drop functionality - Phase 3
- **NOT** mobile optimization - Phase 2
- **NOT** offline support - Phase 2
- **NOT** custom color themes - Phase 2
- **NOT** notes sections - Future consideration
- **NOT** print/export functionality - Future consideration

## Implementation Approach

**Strategy:**
1. **TDD Workflow**: Write failing test → Implement minimal code → Test passes → Refactor
2. **Incremental Steps**: One component at a time, one test at a time
3. **Manifest V3**: Use service worker, content scripts, no inline scripts
4. **OAuth 2.0**: Google Identity Services library for authentication
5. **API Integration**: Google Calendar API v3 with proper error handling
6. **CSS Grid**: Modern layout for full-year view
7. **TypeScript**: Full type safety (or JSDoc types if vanilla JS)

**Key Technical Decisions:**
- Testing: Jest with `jest-chrome` for Chrome Extension mocking
- Date handling: `date-fns` for date utilities (lightweight)
- API client: Fetch API (native, no dependencies)
- State management: Simple event-driven architecture (no framework)
- Build: No build step initially (vanilla JS), TypeScript later if needed

## Phase 1: Project Setup & Manifest Configuration

### Overview
Set up the Chrome Extension project structure with Manifest V3 configuration, basic file organization, and development environment.

### Changes Required:

#### 1. Create Project Directory Structure
**File**: `/Users/ignacio.viejo/saski/google-calendar-plugin/`
**Changes**: Create complete directory structure

```
google-calendar-plugin/
├── manifest.json
├── package.json
├── README.md
├── .gitignore
├── src/
│   ├── content/
│   │   ├── content.js
│   │   ├── view-injector.js
│   │   ├── calendar-api.js
│   │   └── event-renderer.js
│   ├── background/
│   │   └── background.js
│   ├── popup/
│   │   ├── popup.html
│   │   ├── popup.js
│   │   └── popup.css
│   ├── styles/
│   │   ├── full-year-view.css
│   │   └── inject.css
│   └── utils/
│       ├── date-utils.js
│       ├── oauth-handler.js
│       ├── storage.js
│       └── event-parser.js
├── assets/
│   └── icons/
│       ├── icon-16.png
│       ├── icon-48.png
│       └── icon-128.png
└── tests/
    ├── unit/
    │   ├── date-utils.test.js
    │   ├── event-parser.test.js
    │   └── oauth-handler.test.js
    └── integration/
        ├── view-injection.test.js
        └── api-client.test.js
```

**Commands:**
```bash
mkdir -p src/{content,background,popup,styles,utils}
mkdir -p assets/icons tests/{unit,integration}
```

#### 2. Create manifest.json
**File**: `manifest.json`
**Changes**: Create Manifest V3 configuration

```json
{
  "manifest_version": 3,
  "name": "Google Calendar Full-Year View",
  "version": "0.1.0",
  "description": "Adds a full-year view to Google Calendar with sequential day layout",
  "permissions": [
    "identity",
    "storage",
    "activeTab"
  ],
  "host_permissions": [
    "https://calendar.google.com/*",
    "https://www.googleapis.com/*"
  ],
  "background": {
    "service_worker": "src/background/background.js"
  },
  "content_scripts": [
    {
      "matches": ["https://calendar.google.com/*"],
      "js": ["src/content/content.js"],
      "css": ["src/styles/inject.css"],
      "run_at": "document_idle"
    }
  ],
  "action": {
    "default_popup": "src/popup/popup.html",
    "default_icon": {
      "16": "assets/icons/icon-16.png",
      "48": "assets/icons/icon-48.png",
      "128": "assets/icons/icon-128.png"
    }
  },
  "oauth2": {
    "client_id": "YOUR_CLIENT_ID.apps.googleusercontent.com",
    "scopes": [
      "https://www.googleapis.com/auth/calendar.readonly"
    ]
  },
  "web_accessible_resources": [
    {
      "resources": ["src/styles/full-year-view.css"],
      "matches": ["https://calendar.google.com/*"]
    }
  ]
}
```

**Note**: Replace `YOUR_CLIENT_ID` after OAuth setup in Phase 2.

#### 3. Create package.json
**File**: `package.json`
**Changes**: Create Node.js project configuration

```json
{
  "name": "google-calendar-full-year-view",
  "version": "0.1.0",
  "description": "Chrome Extension adding full-year view to Google Calendar",
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  },
  "devDependencies": {
    "jest": "^29.7.0",
    "jest-chrome": "^0.7.1",
    "@types/jest": "^29.5.0"
  },
  "dependencies": {
    "date-fns": "^2.30.0"
  }
}
```

#### 4. Create .gitignore
**File**: `.gitignore`
**Changes**: Standard Node.js and Chrome Extension ignores

```
node_modules/
*.log
.DS_Store
dist/
build/
*.zip
.env
*.pem
```

#### 5. Create Basic README
**File**: `README.md`
**Changes**: Project overview and setup instructions

```markdown
# Google Calendar Full-Year View

Chrome Extension adding a custom full-year view to Google Calendar.

## Development Setup

1. Clone repository
2. `npm install`
3. Load unpacked extension in Chrome: `chrome://extensions/` → "Load unpacked" → select project directory
4. Configure OAuth credentials (see Phase 2)

## Testing

`npm test` - Run all tests
`npm run test:watch` - Watch mode
`npm run test:coverage` - Coverage report
```

### Success Criteria:
- [x] Project directory structure created
- [x] `manifest.json` exists with Manifest V3 configuration
- [x] `package.json` exists with Jest dependencies
- [x] `.gitignore` configured
- [ ] Extension loads in Chrome without errors: `chrome://extensions/` shows extension (requires icon files)
- [ ] No console errors in Chrome DevTools (requires manual verification)

---

## Phase 2: OAuth 2.0 Authentication Setup

### Overview
Set up Google OAuth 2.0 authentication flow for accessing Google Calendar API. This includes Google Cloud Console configuration and implementing the OAuth handler in the extension.

### Changes Required:

#### 1. Google Cloud Console Setup (High-Level)
**Action**: Configure OAuth credentials

**Steps** (detailed instructions: https://developers.google.com/identity/protocols/oauth2):
1. Create Google Cloud Project
2. Enable Google Calendar API
3. Configure OAuth consent screen
4. Create OAuth 2.0 Client ID (Chrome Extension type)
5. Add authorized redirect URIs: `https://YOUR_EXTENSION_ID.chromiumapp.org/`
6. Copy Client ID to `manifest.json`

**References:**
- [Google OAuth 2.0 Setup](https://developers.google.com/identity/protocols/oauth2)
- [Chrome Extension OAuth](https://developer.chrome.com/docs/extensions/mv3/security/#oauth2)

#### 2. Create OAuth Handler Utility
**File**: `src/utils/oauth-handler.js`
**Changes**: Implement OAuth flow using Chrome Identity API

```javascript
/**
 * OAuth handler for Google Calendar API authentication
 */

class OAuthHandler {
  constructor() {
    this.token = null;
    this.tokenExpiry = null;
  }

  /**
   * Get access token, refreshing if necessary
   * @returns {Promise<string>} Access token
   */
  async getAccessToken() {
    if (this.isTokenValid()) {
      return this.token;
    }
    return this.authenticate();
  }

  /**
   * Check if current token is still valid
   * @returns {boolean}
   */
  isTokenValid() {
    if (!this.token || !this.tokenExpiry) {
      return false;
    }
    // Refresh 5 minutes before expiry
    return Date.now() < (this.tokenExpiry - 5 * 60 * 1000);
  }

  /**
   * Authenticate user and get access token
   * @returns {Promise<string>} Access token
   */
  async authenticate() {
    return new Promise((resolve, reject) => {
      chrome.identity.getAuthToken(
        { interactive: true },
        async (token) => {
          if (chrome.runtime.lastError) {
            reject(new Error(chrome.runtime.lastError.message));
            return;
          }
          this.token = token;
          // Token expires in 1 hour, store expiry
          this.tokenExpiry = Date.now() + 60 * 60 * 1000;
          await this.storeToken(token);
          resolve(token);
        }
      );
    });
  }

  /**
   * Store token in extension storage
   * @param {string} token
   */
  async storeToken(token) {
    return chrome.storage.local.set({ oauthToken: token });
  }

  /**
   * Load token from storage
   * @returns {Promise<string|null>}
   */
  async loadToken() {
    const result = await chrome.storage.local.get(['oauthToken']);
    return result.oauthToken || null;
  }

  /**
   * Revoke token and sign out
   */
  async signOut() {
    if (this.token) {
      await chrome.identity.removeCachedAuthToken({ token: this.token });
      this.token = null;
      this.tokenExpiry = null;
      await chrome.storage.local.remove(['oauthToken']);
    }
  }
}

export default OAuthHandler;
```

#### 3. Test OAuth Handler
**File**: `tests/unit/oauth-handler.test.js`
**Changes**: Write tests for OAuth flow

```javascript
import OAuthHandler from '../../src/utils/oauth-handler.js';
import 'jest-chrome';

describe('OAuthHandler', () => {
  let oauthHandler;

  beforeEach(() => {
    oauthHandler = new OAuthHandler();
    jest.clearAllMocks();
  });

  test('should authenticate and get access token', async () => {
    const mockToken = 'mock_access_token_123';
    chrome.identity.getAuthToken.mockImplementation((options, callback) => {
      callback(mockToken);
    });

    const token = await oauthHandler.authenticate();

    expect(token).toBe(mockToken);
    expect(chrome.identity.getAuthToken).toHaveBeenCalledWith(
      { interactive: true },
      expect.any(Function)
    );
  });

  test('should check token validity', () => {
    oauthHandler.token = 'valid_token';
    oauthHandler.tokenExpiry = Date.now() + 10 * 60 * 1000; // 10 minutes

    expect(oauthHandler.isTokenValid()).toBe(true);
  });

  test('should detect expired token', () => {
    oauthHandler.token = 'expired_token';
    oauthHandler.tokenExpiry = Date.now() - 1000; // Expired

    expect(oauthHandler.isTokenValid()).toBe(false);
  });

  test('should store and load token', async () => {
    const token = 'test_token_123';
    await oauthHandler.storeToken(token);

    const loadedToken = await oauthHandler.loadToken();
    expect(loadedToken).toBe(token);
    expect(chrome.storage.local.set).toHaveBeenCalledWith({
      oauthToken: token
    });
  });
});
```

### Success Criteria:
- [ ] Google Cloud Console project created (manual setup required)
- [ ] OAuth 2.0 Client ID configured for Chrome Extension (manual setup required)
- [x] Client ID added to `manifest.json` (placeholder - needs actual ID)
- [x] `oauth-handler.js` implemented with all methods
- [ ] OAuth tests pass: `npm test -- oauth-handler` (requires `npm install` first)
- [ ] Manual test: Extension popup shows "Sign In" button (Phase 2 UI not yet implemented)
- [ ] Manual test: Clicking "Sign In" opens Google OAuth consent screen (requires OAuth setup)
- [ ] Manual test: After consent, token stored in extension storage (requires OAuth setup)

---

## Phase 3: View Injection System

### Overview
Detect Google Calendar's view switcher and inject a "Full Year" option. Handle view switching between standard Calendar views and the custom full-year view.

### Changes Required:

#### 1. Create View Injector
**File**: `src/content/view-injector.js`
**Changes**: Detect and modify Google Calendar's view switcher

```javascript
/**
 * Injects "Full Year" view option into Google Calendar's view switcher
 */

class ViewInjector {
  constructor() {
    this.viewSwitcherSelector = '[role="tablist"], [aria-label*="view"], .view-switcher';
    this.currentView = null;
    this.fullYearViewActive = false;
  }

  /**
   * Initialize view injection
   */
  async init() {
    await this.waitForCalendar();
    this.injectFullYearOption();
    this.setupViewListener();
  }

  /**
   * Wait for Google Calendar to load
   * @returns {Promise<void>}
   */
  async waitForCalendar() {
    return new Promise((resolve) => {
      const checkInterval = setInterval(() => {
        const calendarContainer = document.querySelector('[role="main"]');
        if (calendarContainer) {
          clearInterval(checkInterval);
          resolve();
        }
      }, 100);
    });
  }

  /**
   * Find view switcher element
   * @returns {HTMLElement|null}
   */
  findViewSwitcher() {
    // Try multiple selectors for robustness
    const selectors = [
      '[role="tablist"]',
      '[aria-label*="view" i]',
      '.view-switcher',
      '[data-view-switcher]'
    ];

    for (const selector of selectors) {
      const element = document.querySelector(selector);
      if (element) {
        return element;
      }
    }
    return null;
  }

  /**
   * Inject "Full Year" option into view switcher
   */
  injectFullYearOption() {
    const viewSwitcher = this.findViewSwitcher();
    if (!viewSwitcher) {
      console.warn('View switcher not found, retrying...');
      setTimeout(() => this.injectFullYearOption(), 1000);
      return;
    }

    // Check if already injected
    if (viewSwitcher.querySelector('[data-full-year-view]')) {
      return;
    }

    const fullYearButton = document.createElement('button');
    fullYearButton.setAttribute('data-full-year-view', 'true');
    fullYearButton.setAttribute('role', 'tab');
    fullYearButton.setAttribute('aria-label', 'Full Year view');
    fullYearButton.textContent = 'Full Year';
    fullYearButton.className = 'full-year-view-button';
    fullYearButton.addEventListener('click', () => this.activateFullYearView());

    viewSwitcher.appendChild(fullYearButton);
  }

  /**
   * Activate full-year view
   */
  activateFullYearView() {
    this.fullYearViewActive = true;
    this.hideStandardCalendar();
    this.showFullYearView();
    this.updateViewSwitcherState();
  }

  /**
   * Hide standard Google Calendar view
   */
  hideStandardCalendar() {
    const mainContent = document.querySelector('[role="main"]');
    if (mainContent) {
      mainContent.style.display = 'none';
    }
  }

  /**
   * Show full-year view container
   */
  showFullYearView() {
    let container = document.getElementById('full-year-view-container');
    if (!container) {
      container = document.createElement('div');
      container.id = 'full-year-view-container';
      container.className = 'full-year-view-container';
      document.body.appendChild(container);
    }
    container.style.display = 'block';
    
    // Trigger event for view renderer
    window.dispatchEvent(new CustomEvent('fullYearViewActivated'));
  }

  /**
   * Update view switcher button states
   */
  updateViewSwitcherState() {
    const fullYearButton = document.querySelector('[data-full-year-view]');
    const otherButtons = document.querySelectorAll('[role="tab"]:not([data-full-year-view])');
    
    if (fullYearButton) {
      fullYearButton.setAttribute('aria-selected', 'true');
      fullYearButton.classList.add('active');
    }
    
    otherButtons.forEach(btn => {
      btn.setAttribute('aria-selected', 'false');
      btn.classList.remove('active');
    });
  }

  /**
   * Setup listener for view changes
   */
  setupViewListener() {
    // Use MutationObserver to detect view switcher changes
    const observer = new MutationObserver(() => {
      if (!this.fullYearViewActive) {
        this.injectFullYearOption();
      }
    });

    const target = document.body;
    observer.observe(target, {
      childList: true,
      subtree: true
    });
  }
}

export default ViewInjector;
```

#### 2. Create Main Content Script
**File**: `src/content/content.js`
**Changes**: Initialize view injection when Calendar loads

```javascript
import ViewInjector from './view-injector.js';

/**
 * Main content script - runs on calendar.google.com
 */
async function init() {
  const injector = new ViewInjector();
  await injector.init();
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}
```

#### 3. Test View Injection
**File**: `tests/integration/view-injection.test.js`
**Changes**: Test view switcher detection and injection

```javascript
import ViewInjector from '../../src/content/view-injector.js';

describe('ViewInjector', () => {
  let injector;
  let mockViewSwitcher;

  beforeEach(() => {
    document.body.innerHTML = '';
    injector = new ViewInjector();
    
    // Create mock view switcher
    mockViewSwitcher = document.createElement('div');
    mockViewSwitcher.setAttribute('role', 'tablist');
    mockViewSwitcher.className = 'view-switcher';
    document.body.appendChild(mockViewSwitcher);
  });

  test('should find view switcher element', () => {
    const found = injector.findViewSwitcher();
    expect(found).toBe(mockViewSwitcher);
  });

  test('should inject full year button', async () => {
    await injector.init();
    
    const fullYearButton = document.querySelector('[data-full-year-view]');
    expect(fullYearButton).not.toBeNull();
    expect(fullYearButton.textContent).toBe('Full Year');
  });

  test('should activate full year view on button click', async () => {
    await injector.init();
    
    const fullYearButton = document.querySelector('[data-full-year-view]');
    fullYearButton.click();
    
    expect(injector.fullYearViewActive).toBe(true);
    const container = document.getElementById('full-year-view-container');
    expect(container).not.toBeNull();
    expect(container.style.display).toBe('block');
  });
});
```

### Success Criteria:
- [x] `view-injector.js` implemented with view detection
- [x] `content.js` initializes view injection
- [ ] View injection tests pass: `npm test -- view-injection` (requires `npm install` first)
- [ ] Manual test: Open Google Calendar, see "Full Year" option in view switcher (requires extension loading)
- [ ] Manual test: Click "Full Year", standard calendar hides (requires manual verification)
- [ ] Manual test: Full-year view container appears (requires manual verification)
- [ ] No console errors in Chrome DevTools (requires manual verification)

---

## Phase 4: Full-Year View Layout

### Overview
Create the CSS Grid layout for the full-year view with 12 month rows and 31 day columns. Implement weekend color coding and responsive design.

### Changes Required:

#### 1. Create Date Utilities
**File**: `src/utils/date-utils.js`
**Changes**: Date calculation functions

```javascript
import { 
  startOfYear, 
  endOfYear, 
  eachMonthOfInterval, 
  getDaysInMonth,
  format,
  getDay,
  isWeekend
} from 'date-fns';

/**
 * Date utilities for full-year view
 */
class DateUtils {
  /**
   * Get all months for a given year
   * @param {number} year
   * @returns {Date[]} Array of month start dates
   */
  getMonthsForYear(year) {
    const start = startOfYear(new Date(year, 0, 1));
    const end = endOfYear(new Date(year, 0, 1));
    return eachMonthOfInterval({ start, end });
  }

  /**
   * Get days in month as array of date objects
   * @param {Date} monthDate
   * @returns {Array<{date: Date, dayOfMonth: number, dayOfWeek: string}>}
   */
  getDaysInMonth(monthDate) {
    const daysInMonth = getDaysInMonth(monthDate);
    const days = [];
    
    for (let day = 1; day <= daysInMonth; day++) {
      const date = new Date(monthDate.getFullYear(), monthDate.getMonth(), day);
      days.push({
        date,
        dayOfMonth: day,
        dayOfWeek: format(date, 'EEE').toUpperCase(),
        isWeekend: isWeekend(date)
      });
    }
    
    return days;
  }

  /**
   * Get month name abbreviation
   * @param {Date} monthDate
   * @returns {string} Month abbreviation (JAN, FEB, etc.)
   */
  getMonthAbbreviation(monthDate) {
    return format(monthDate, 'MMM').toUpperCase();
  }

  /**
   * Check if date is Saturday
   * @param {Date} date
   * @returns {boolean}
   */
  isSaturday(date) {
    return getDay(date) === 6;
  }

  /**
   * Check if date is Sunday
   * @param {Date} date
   * @returns {boolean}
   */
  isSunday(date) {
    return getDay(date) === 0;
  }
}

export default new DateUtils();
```

#### 2. Test Date Utilities
**File**: `tests/unit/date-utils.test.js`
**Changes**: Test date calculations

```javascript
import DateUtils from '../../src/utils/date-utils.js';

describe('DateUtils', () => {
  test('should get 12 months for year', () => {
    const months = DateUtils.getMonthsForYear(2026);
    expect(months).toHaveLength(12);
  });

  test('should get correct days in month', () => {
    const jan2026 = new Date(2026, 0, 1);
    const days = DateUtils.getDaysInMonth(jan2026);
    expect(days).toHaveLength(31);
    expect(days[0].dayOfMonth).toBe(1);
    expect(days[0].dayOfWeek).toBe('THU');
  });

  test('should identify weekends correctly', () => {
    const jan2026 = new Date(2026, 0, 1); // Thursday
    const days = DateUtils.getDaysInMonth(jan2026);
    const saturday = days.find(d => d.dayOfMonth === 3); // Jan 3 is Saturday
    const sunday = days.find(d => d.dayOfMonth === 4); // Jan 4 is Sunday
    
    expect(saturday.isWeekend).toBe(true);
    expect(sunday.isWeekend).toBe(true);
  });

  test('should get month abbreviation', () => {
    const jan = new Date(2026, 0, 1);
    expect(DateUtils.getMonthAbbreviation(jan)).toBe('JAN');
  });
});
```

#### 3. Create Full-Year View Component
**File**: `src/content/full-year-view.js`
**Changes**: Render full-year grid layout

```javascript
import DateUtils from '../utils/date-utils.js';

/**
 * Full-year view renderer
 */
class FullYearView {
  constructor(container) {
    this.container = container;
    this.currentYear = new Date().getFullYear();
  }

  /**
   * Render full-year view
   */
  render() {
    this.container.innerHTML = '';
    
    const grid = document.createElement('div');
    grid.className = 'full-year-grid';
    grid.setAttribute('role', 'grid');
    grid.setAttribute('aria-label', `Full year view for ${this.currentYear}`);

    // Create header
    const header = this.createHeader();
    grid.appendChild(header);

    // Create month rows
    const months = DateUtils.getMonthsForYear(this.currentYear);
    months.forEach(month => {
      const row = this.createMonthRow(month);
      grid.appendChild(row);
    });

    this.container.appendChild(grid);
  }

  /**
   * Create header row
   * @returns {HTMLElement}
   */
  createHeader() {
    const header = document.createElement('div');
    header.className = 'full-year-header';
    
    const title = document.createElement('div');
    title.className = 'full-year-title';
    title.textContent = 'YEARLY PLANNER';
    
    const year = document.createElement('div');
    year.className = 'full-year-year';
    year.textContent = this.currentYear.toString();
    
    header.appendChild(title);
    header.appendChild(year);
    return header;
  }

  /**
   * Create month row
   * @param {Date} monthDate
   * @returns {HTMLElement}
   */
  createMonthRow(monthDate) {
    const row = document.createElement('div');
    row.className = 'month-row';
    row.setAttribute('role', 'row');
    row.setAttribute('aria-label', `Month: ${DateUtils.getMonthAbbreviation(monthDate)}`);

    // Month label
    const monthLabel = document.createElement('div');
    monthLabel.className = 'month-label';
    monthLabel.textContent = DateUtils.getMonthAbbreviation(monthDate);
    monthLabel.setAttribute('role', 'rowheader');
    row.appendChild(monthLabel);

    // Day cells (1-31)
    const days = DateUtils.getDaysInMonth(monthDate);
    for (let day = 1; day <= 31; day++) {
      const cell = this.createDayCell(day, days.find(d => d.dayOfMonth === day));
      row.appendChild(cell);
    }

    return row;
  }

  /**
   * Create day cell
   * @param {number} dayNumber
   * @param {Object|null} dayData
   * @returns {HTMLElement}
   */
  createDayCell(dayNumber, dayData) {
    const cell = document.createElement('div');
    cell.className = 'day-cell';
    cell.setAttribute('role', 'gridcell');
    
    if (dayData) {
      cell.setAttribute('data-date', dayData.date.toISOString());
      cell.setAttribute('aria-label', `Day ${dayNumber}, ${dayData.dayOfWeek}`);
      
      if (dayData.isWeekend) {
        if (DateUtils.isSaturday(dayData.date)) {
          cell.classList.add('saturday');
        } else if (DateUtils.isSunday(dayData.date)) {
          cell.classList.add('sunday');
        }
      } else {
        cell.classList.add('weekday');
      }

      const dayNumberEl = document.createElement('div');
      dayNumberEl.className = 'day-number';
      dayNumberEl.textContent = dayNumber;

      const dayOfWeekEl = document.createElement('div');
      dayOfWeekEl.className = 'day-of-week';
      dayOfWeekEl.textContent = dayData.dayOfWeek;

      cell.appendChild(dayNumberEl);
      cell.appendChild(dayOfWeekEl);
    } else {
      // Empty cell for months with fewer than 31 days
      cell.classList.add('empty');
      cell.setAttribute('aria-hidden', 'true');
    }

    return cell;
  }
}

export default FullYearView;
```

#### 4. Create CSS Styles
**File**: `src/styles/full-year-view.css`
**Changes**: CSS Grid layout and styling

```css
.full-year-view-container {
  padding: 24px;
  background: white;
  min-height: 100vh;
}

.full-year-grid {
  display: grid;
  grid-template-columns: [month-label] 120px repeat(31, [day] minmax(30px, 1fr));
  grid-template-rows: [header] auto repeat(12, [month] auto);
  gap: 0;
  border: 1px solid #e0e0e0;
}

.full-year-header {
  grid-column: 1 / -1;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  border-bottom: 2px solid #e0e0e0;
  background: #f5f5f5;
}

.full-year-title {
  font-size: 24px;
  font-weight: bold;
  color: #212121;
}

.full-year-year {
  font-size: 20px;
  font-weight: bold;
  color: #212121;
}

.month-row {
  display: grid;
  grid-column: 1 / -1;
  grid-template-columns: subgrid;
  border-bottom: 1px solid #e0e0e0;
}

.month-label {
  grid-column: month-label;
  display: flex;
  align-items: center;
  padding: 8px 12px;
  background: var(--month-label-bg, #f5f5f5);
  font-weight: 500;
  font-size: 14px;
  border-right: 1px solid #e0e0e0;
}

.day-cell {
  min-height: 40px;
  border-right: 1px solid #e0e0e0;
  padding: 4px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: background-color 0.2s;
}

.day-cell.weekday {
  background-color: #e3f2fd; /* Light blue */
}

.day-cell.saturday {
  background-color: #e8f5e9; /* Light green */
}

.day-cell.sunday {
  background-color: #fce4ec; /* Light pink */
}

.day-cell.empty {
  background-color: #fafafa;
}

.day-cell:hover {
  background-color: rgba(0, 0, 0, 0.05);
  border: 2px solid #1976d2;
}

.day-number {
  font-size: 12px;
  font-weight: 500;
  color: #212121;
}

.day-of-week {
  font-size: 10px;
  color: #757575;
  text-transform: uppercase;
}

/* Responsive: horizontal scroll on smaller screens */
@media (max-width: 1400px) {
  .full-year-view-container {
    overflow-x: auto;
  }
  
  .month-label {
    position: sticky;
    left: 0;
    z-index: 10;
    background: white;
  }
}
```

#### 5. Update Content Script to Render View
**File**: `src/content/content.js`
**Changes**: Initialize full-year view renderer

```javascript
import ViewInjector from './view-injector.js';
import FullYearView from './full-year-view.js';

let fullYearView = null;

/**
 * Initialize full-year view when activated
 */
function initFullYearView() {
  const container = document.getElementById('full-year-view-container');
  if (container && !fullYearView) {
    fullYearView = new FullYearView(container);
    fullYearView.render();
  }
}

// Listen for full-year view activation
window.addEventListener('fullYearViewActivated', initFullYearView);

/**
 * Main content script - runs on calendar.google.com
 */
async function init() {
  const injector = new ViewInjector();
  await injector.init();
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}
```

### Success Criteria:
- [x] `date-utils.js` implemented with date calculations
- [ ] Date utility tests pass: `npm test -- date-utils` (requires `npm install` first)
- [x] `full-year-view.js` renders 12 month rows
- [x] `full-year-view.css` creates CSS Grid layout
- [x] Weekend colors applied correctly (Saturday green, Sunday pink)
- [ ] Manual test: Full-year view displays all 12 months (requires manual verification)
- [ ] Manual test: Days 1-31 appear sequentially in each row (requires manual verification)
- [ ] Manual test: Weekend colors are distinct (requires manual verification)
- [ ] Manual test: Horizontal scroll works on smaller screens (requires manual verification)
- [ ] No console errors (requires manual verification)

---

## Phase 5: Google Calendar API Integration

### Overview
Implement Google Calendar API client to fetch events for the full year. Handle pagination, error cases, and token management.

### Changes Required:

#### 1. Create Calendar API Client
**File**: `src/content/calendar-api.js`
**Changes**: Google Calendar API v3 client

```javascript
import OAuthHandler from '../utils/oauth-handler.js';

/**
 * Google Calendar API client
 */
class CalendarAPI {
  constructor() {
    this.oauthHandler = new OAuthHandler();
    this.apiBase = 'https://www.googleapis.com/calendar/v3';
  }

  /**
   * Get all calendars for user
   * @returns {Promise<Array>} List of calendars
   */
  async getCalendars() {
    const token = await this.oauthHandler.getAccessToken();
    const url = `${this.apiBase}/users/me/calendarList`;
    
    const response = await fetch(url, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      throw new Error(`Failed to fetch calendars: ${response.statusText}`);
    }

    const data = await response.json();
    return data.items || [];
  }

  /**
   * Get events for a date range
   * @param {string} calendarId - Calendar ID (use 'primary' for primary calendar)
   * @param {Date} timeMin - Start date
   * @param {Date} timeMax - End date
   * @returns {Promise<Array>} List of events
   */
  async getEvents(calendarId, timeMin, timeMax) {
    const token = await this.oauthHandler.getAccessToken();
    const url = `${this.apiBase}/calendars/${encodeURIComponent(calendarId)}/events`;
    
    const params = new URLSearchParams({
      timeMin: timeMin.toISOString(),
      timeMax: timeMax.toISOString(),
      maxResults: '2500',
      singleEvents: 'true',
      orderBy: 'startTime'
    });

    const response = await fetch(`${url}?${params}`, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      throw new Error(`Failed to fetch events: ${response.statusText}`);
    }

    const data = await response.json();
    return data.items || [];
  }

  /**
   * Get events for entire year
   * @param {number} year
   * @param {Array<string>} calendarIds - Calendar IDs to fetch from
   * @returns {Promise<Array>} All events for the year
   */
  async getYearEvents(year, calendarIds = ['primary']) {
    const timeMin = new Date(year, 0, 1);
    const timeMax = new Date(year, 11, 31, 23, 59, 59);

    const allEvents = [];
    
    for (const calendarId of calendarIds) {
      try {
        const events = await this.getEvents(calendarId, timeMin, timeMax);
        // Add calendar metadata to each event
        events.forEach(event => {
          event.calendarId = calendarId;
        });
        allEvents.push(...events);
      } catch (error) {
        console.error(`Failed to fetch events from calendar ${calendarId}:`, error);
        // Continue with other calendars
      }
    }

    return allEvents;
  }
}

export default CalendarAPI;
```

#### 2. Create Event Parser
**File**: `src/utils/event-parser.js`
**Changes**: Parse and normalize event data

```javascript
/**
 * Parse and normalize Google Calendar events
 */
class EventParser {
  /**
   * Parse event date (handles both date and dateTime)
   * @param {Object} event - Google Calendar event
   * @param {string} field - 'start' or 'end'
   * @returns {Date}
   */
  parseEventDate(event, field) {
    const dateField = event[field];
    if (dateField.dateTime) {
      return new Date(dateField.dateTime);
    } else if (dateField.date) {
      return new Date(dateField.date);
    }
    throw new Error(`Invalid date field in event ${event.id}`);
  }

  /**
   * Check if event is all-day
   * @param {Object} event
   * @returns {boolean}
   */
  isAllDayEvent(event) {
    return !!event.start.date && !event.start.dateTime;
  }

  /**
   * Get event date range
   * @param {Object} event
   * @returns {{start: Date, end: Date, isMultiDay: boolean}}
   */
  getEventDateRange(event) {
    const start = this.parseEventDate(event, 'start');
    const end = this.parseEventDate(event, 'end');
    
    // For all-day events, end date is exclusive, so subtract 1 day
    const adjustedEnd = this.isAllDayEvent(event) 
      ? new Date(end.getTime() - 24 * 60 * 60 * 1000)
      : end;
    
    const isMultiDay = start.toDateString() !== adjustedEnd.toDateString();
    
    return {
      start,
      end: adjustedEnd,
      isMultiDay
    };
  }

  /**
   * Get events for a specific date
   * @param {Array<Object>} events - All events
   * @param {Date} date - Target date
   * @returns {Array<Object>} Events on that date
   */
  getEventsForDate(events, date) {
    const dateStr = date.toDateString();
    return events.filter(event => {
      const range = this.getEventDateRange(event);
      const eventStartStr = range.start.toDateString();
      const eventEndStr = range.end.toDateString();
      
      // Event is on this date if date is between start and end (inclusive)
      return dateStr >= eventStartStr && dateStr <= eventEndStr;
    });
  }

  /**
   * Normalize event for display
   * @param {Object} event
   * @returns {Object} Normalized event
   */
  normalizeEvent(event) {
    const range = this.getEventDateRange(event);
    return {
      id: event.id,
      title: event.summary || '(No title)',
      description: event.description || '',
      location: event.location || '',
      start: range.start,
      end: range.end,
      isMultiDay: range.isMultiDay,
      isAllDay: this.isAllDayEvent(event),
      colorId: event.colorId || '1',
      calendarId: event.calendarId || 'primary'
    };
  }
}

export default new EventParser();
```

#### 3. Test API Client and Parser
**File**: `tests/integration/api-client.test.js`
**Changes**: Test API integration

```javascript
import CalendarAPI from '../../src/content/calendar-api.js';
import EventParser from '../../src/utils/event-parser.js';

// Mock fetch
global.fetch = jest.fn();

describe('CalendarAPI', () => {
  let api;
  let mockOAuthHandler;

  beforeEach(() => {
    mockOAuthHandler = {
      getAccessToken: jest.fn().mockResolvedValue('mock_token')
    };
    api = new CalendarAPI();
    api.oauthHandler = mockOAuthHandler;
    fetch.mockClear();
  });

  test('should fetch calendars', async () => {
    const mockCalendars = {
      items: [
        { id: 'primary', summary: 'Primary Calendar' },
        { id: 'cal2', summary: 'Work Calendar' }
      ]
    };

    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => mockCalendars
    });

    const calendars = await api.getCalendars();

    expect(calendars).toHaveLength(2);
    expect(fetch).toHaveBeenCalledWith(
      expect.stringContaining('/calendarList'),
      expect.objectContaining({
        headers: expect.objectContaining({
          'Authorization': 'Bearer mock_token'
        })
      })
    );
  });

  test('should fetch events for date range', async () => {
    const mockEvents = {
      items: [
        {
          id: 'event1',
          summary: 'Test Event',
          start: { dateTime: '2026-01-15T10:00:00Z' },
          end: { dateTime: '2026-01-15T11:00:00Z' }
        }
      ]
    };

    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => mockEvents
    });

    const timeMin = new Date(2026, 0, 1);
    const timeMax = new Date(2026, 11, 31);
    const events = await api.getEvents('primary', timeMin, timeMax);

    expect(events).toHaveLength(1);
    expect(events[0].summary).toBe('Test Event');
  });
});

describe('EventParser', () => {
  test('should parse event date range', () => {
    const event = {
      id: 'test',
      summary: 'Test',
      start: { date: '2026-01-15' },
      end: { date: '2026-01-16' }
    };

    const range = EventParser.getEventDateRange(event);
    expect(range.start.toDateString()).toBe(new Date(2026, 0, 15).toDateString());
    expect(range.isMultiDay).toBe(false); // End is exclusive, so same day
  });

  test('should get events for specific date', () => {
    const events = [
      {
        id: '1',
        summary: 'Event 1',
        start: { date: '2026-01-15' },
        end: { date: '2026-01-16' }
      },
      {
        id: '2',
        summary: 'Event 2',
        start: { date: '2026-01-16' },
        end: { date: '2026-01-17' }
      }
    ];

    const date = new Date(2026, 0, 15);
    const eventsForDate = EventParser.getEventsForDate(events, date);
    
    expect(eventsForDate).toHaveLength(1);
    expect(eventsForDate[0].id).toBe('1');
  });
});
```

### Success Criteria:
- [x] `calendar-api.js` implemented with API methods
- [x] `event-parser.js` handles event normalization
- [ ] API client tests pass: `npm test -- api-client` (requires `npm install` first)
- [ ] Event parser tests pass: `npm test -- event-parser` (requires `npm install` first)
- [ ] Manual test: API fetches calendars successfully (requires OAuth setup)
- [ ] Manual test: API fetches events for full year (requires OAuth setup)
- [ ] Manual test: Events parsed correctly (all-day, multi-day, timed) (requires manual verification)
- [x] Error handling works for API failures (implemented)
- [ ] No console errors (requires manual verification)

---

## Phase 6: Event Display & Rendering

### Overview
Display events in the full-year view day cells. Handle event indicators, multi-day events, and event density.

### Changes Required:

#### 1. Create Event Renderer
**File**: `src/content/event-renderer.js`
**Changes**: Render events in day cells

```javascript
import EventParser from '../utils/event-parser.js';

/**
 * Renders events in full-year view
 */
class EventRenderer {
  constructor() {
    this.events = [];
  }

  /**
   * Set events data
   * @param {Array<Object>} events
   */
  setEvents(events) {
    this.events = events.map(e => EventParser.normalizeEvent(e));
  }

  /**
   * Render events in day cells
   */
  renderEvents() {
    const dayCells = document.querySelectorAll('.day-cell[data-date]');
    
    dayCells.forEach(cell => {
      const dateStr = cell.getAttribute('data-date');
      const date = new Date(dateStr);
      const eventsForDay = EventParser.getEventsForDate(this.events, date);
      
      this.renderEventsInCell(cell, eventsForDay);
    });
  }

  /**
   * Render events in a single day cell
   * @param {HTMLElement} cell
   * @param {Array<Object>} events
   */
  renderEventsInCell(cell, events) {
    // Clear existing event indicators
    const existingIndicators = cell.querySelectorAll('.event-indicator');
    existingIndicators.forEach(el => el.remove());

    if (events.length === 0) {
      return;
    }

    // Create event indicator container
    const indicatorContainer = document.createElement('div');
    indicatorContainer.className = 'event-indicators';

    if (events.length <= 3) {
      // Show individual event dots
      events.forEach(event => {
        const dot = this.createEventDot(event);
        indicatorContainer.appendChild(dot);
      });
    } else {
      // Show count indicator
      const countIndicator = document.createElement('div');
      countIndicator.className = 'event-count';
      countIndicator.textContent = `${events.length}`;
      countIndicator.setAttribute('aria-label', `${events.length} events`);
      indicatorContainer.appendChild(countIndicator);
    }

    cell.appendChild(indicatorContainer);
  }

  /**
   * Create event dot indicator
   * @param {Object} event
   * @returns {HTMLElement}
   */
  createEventDot(event) {
    const dot = document.createElement('div');
    dot.className = 'event-dot';
    dot.setAttribute('data-event-id', event.id);
    dot.setAttribute('aria-label', event.title);
    dot.style.backgroundColor = this.getEventColor(event.colorId);
    dot.title = event.title;
    
    return dot;
  }

  /**
   * Get color for event based on colorId
   * @param {string} colorId
   * @returns {string} Hex color
   */
  getEventColor(colorId) {
    // Google Calendar color palette
    const colors = {
      '1': '#a4bdfc', // Lavender
      '2': '#7ae7bf', // Sage
      '3': '#dbadff', // Grape
      '4': '#ff887c', // Flamingo
      '5': '#fbd75b', // Banana
      '6': '#ffb878', // Tangerine
      '7': '#46d6db', // Peacock
      '8': '#e1e1e1', // Graphite
      '9': '#5484ed', // Blueberry
      '10': '#51b749', // Basil
      '11': '#dc2127'  // Tomato
    };
    return colors[colorId] || colors['1'];
  }
}

export default EventRenderer;
```

#### 2. Update CSS for Event Indicators
**File**: `src/styles/full-year-view.css`
**Changes**: Add event indicator styles

```css
/* Event indicators */
.event-indicators {
  display: flex;
  gap: 2px;
  margin-top: 2px;
  flex-wrap: wrap;
  justify-content: center;
}

.event-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  cursor: pointer;
  transition: transform 0.2s;
}

.event-dot:hover {
  transform: scale(1.5);
}

.event-count {
  font-size: 10px;
  font-weight: bold;
  color: #1976d2;
  background: rgba(25, 118, 210, 0.1);
  padding: 2px 4px;
  border-radius: 3px;
  cursor: pointer;
}

.event-count:hover {
  background: rgba(25, 118, 210, 0.2);
}
```

#### 3. Integrate Event Rendering
**File**: `src/content/full-year-view.js`
**Changes**: Add event rendering support

```javascript
import DateUtils from '../utils/date-utils.js';
import EventRenderer from './event-renderer.js';

/**
 * Full-year view renderer
 */
class FullYearView {
  constructor(container) {
    this.container = container;
    this.currentYear = new Date().getFullYear();
    this.eventRenderer = new EventRenderer();
  }

  /**
   * Set events and re-render
   * @param {Array<Object>} events
   */
  setEvents(events) {
    this.eventRenderer.setEvents(events);
    this.render();
  }

  /**
   * Render full-year view
   */
  render() {
    this.container.innerHTML = '';
    
    const grid = document.createElement('div');
    grid.className = 'full-year-grid';
    // ... existing render code ...

    this.container.appendChild(grid);
    
    // Render events after grid is created
    setTimeout(() => {
      this.eventRenderer.renderEvents();
    }, 0);
  }

  // ... rest of existing methods ...
}

export default FullYearView;
```

#### 4. Connect API to View
**File**: `src/content/content.js`
**Changes**: Fetch and display events

```javascript
import ViewInjector from './view-injector.js';
import FullYearView from './full-year-view.js';
import CalendarAPI from './calendar-api.js';

let fullYearView = null;
let calendarAPI = null;

/**
 * Load and display events
 */
async function loadEvents() {
  if (!calendarAPI) {
    calendarAPI = new CalendarAPI();
  }

  try {
    const calendars = await calendarAPI.getCalendars();
    const calendarIds = calendars.map(cal => cal.id);
    const currentYear = new Date().getFullYear();
    
    const events = await calendarAPI.getYearEvents(currentYear, calendarIds);
    
    if (fullYearView) {
      fullYearView.setEvents(events);
    }
  } catch (error) {
    console.error('Failed to load events:', error);
    // Show error message to user
  }
}

/**
 * Initialize full-year view when activated
 */
async function initFullYearView() {
  const container = document.getElementById('full-year-view-container');
  if (container && !fullYearView) {
    fullYearView = new FullYearView(container);
    fullYearView.render();
    
    // Load events after view is rendered
    await loadEvents();
  }
}

// Listen for full-year view activation
window.addEventListener('fullYearViewActivated', initFullYearView);

// ... rest of existing code ...
```

### Success Criteria:
- [x] `event-renderer.js` displays events in day cells
- [x] Events appear as colored dots (1-3 events) or count indicator (4+)
- [x] Event colors match Google Calendar colors
- [ ] Manual test: Events appear in correct day cells (requires OAuth and manual verification)
- [ ] Manual test: Multi-day events span multiple cells (requires manual verification)
- [ ] Manual test: Days with many events show count indicator (requires manual verification)
- [ ] Manual test: Event dots are clickable (hover shows title) (requires Phase 7 interactions)
- [ ] No console errors (requires manual verification)

---

## Phase 7: Basic Interactions

### Overview
Add hover states, click handlers for event details, and basic keyboard navigation.

### Changes Required:

#### 1. Add Event Details Tooltip
**File**: `src/content/event-renderer.js`
**Changes**: Add tooltip functionality

```javascript
/**
 * Show event details tooltip
 * @param {HTMLElement} element
 * @param {Object} event
 */
showEventTooltip(element, event) {
  // Remove existing tooltip
  const existing = document.querySelector('.event-tooltip');
  if (existing) {
    existing.remove();
  }

  const tooltip = document.createElement('div');
  tooltip.className = 'event-tooltip';
  tooltip.innerHTML = `
    <div class="tooltip-title">${event.title}</div>
    ${event.location ? `<div class="tooltip-location">${event.location}</div>` : ''}
    <div class="tooltip-time">${this.formatEventTime(event)}</div>
  `;

  document.body.appendChild(tooltip);

  // Position tooltip
  const rect = element.getBoundingClientRect();
  tooltip.style.left = `${rect.left + rect.width / 2}px`;
  tooltip.style.top = `${rect.top - tooltip.offsetHeight - 5}px`;

  // Remove on mouse leave
  const removeTooltip = () => {
    tooltip.remove();
    element.removeEventListener('mouseleave', removeTooltip);
  };
  element.addEventListener('mouseleave', removeTooltip);
}

/**
 * Format event time for display
 * @param {Object} event
 * @returns {string}
 */
formatEventTime(event) {
  if (event.isAllDay) {
    return 'All day';
  }
  const startTime = event.start.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  const endTime = event.end.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  return `${startTime} - ${endTime}`;
}
```

#### 2. Add Click Handlers
**File**: `src/content/full-year-view.js`
**Changes**: Add click handlers for day cells

```javascript
/**
 * Create day cell with click handler
 * @param {number} dayNumber
 * @param {Object|null} dayData
 * @returns {HTMLElement}
 */
createDayCell(dayNumber, dayData) {
  const cell = document.createElement('div');
  // ... existing cell creation code ...

  // Add click handler
  if (dayData) {
    cell.addEventListener('click', () => {
      this.handleDayClick(dayData.date);
    });
  }

  return cell;
}

/**
 * Handle day cell click
 * @param {Date} date
 */
handleDayClick(date) {
  const events = this.eventRenderer.getEventsForDate(date);
  
  if (events.length === 0) {
    // Future: Open create event dialog
    console.log('No events, would open create dialog');
  } else {
    // Show event list
    this.showEventList(date, events);
  }
}

/**
 * Show event list for a day
 * @param {Date} date
 * @param {Array<Object>} events
 */
showEventList(date, events) {
  // Create modal or sidebar
  const modal = document.createElement('div');
  modal.className = 'event-list-modal';
  modal.innerHTML = `
    <div class="modal-content">
      <div class="modal-header">
        <h2>${date.toLocaleDateString()}</h2>
        <button class="modal-close" aria-label="Close">×</button>
      </div>
      <div class="modal-body">
        ${events.map(event => `
          <div class="event-item">
            <div class="event-title">${event.title}</div>
            <div class="event-time">${this.formatEventTime(event)}</div>
            ${event.location ? `<div class="event-location">${event.location}</div>` : ''}
          </div>
        `).join('')}
      </div>
    </div>
  `;

  document.body.appendChild(modal);

  // Close handler
  modal.querySelector('.modal-close').addEventListener('click', () => {
    modal.remove();
  });
}
```

#### 3. Add CSS for Interactions
**File**: `src/styles/full-year-view.css`
**Changes**: Add tooltip and modal styles

```css
/* Tooltip */
.event-tooltip {
  position: absolute;
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  padding: 8px 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  font-size: 12px;
  max-width: 200px;
}

.tooltip-title {
  font-weight: bold;
  margin-bottom: 4px;
}

.tooltip-location {
  color: #757575;
  font-size: 11px;
  margin-bottom: 2px;
}

.tooltip-time {
  color: #757575;
  font-size: 11px;
}

/* Event list modal */
.event-list-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
}

.modal-content {
  background: white;
  border-radius: 8px;
  max-width: 500px;
  max-height: 80vh;
  overflow: auto;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  border-bottom: 1px solid #e0e0e0;
}

.modal-close {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #757575;
}

.modal-body {
  padding: 16px 24px;
}

.event-item {
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
}

.event-title {
  font-weight: 500;
  margin-bottom: 4px;
}

.event-time {
  color: #757575;
  font-size: 14px;
  margin-bottom: 2px;
}

.event-location {
  color: #757575;
  font-size: 12px;
}
```

### Success Criteria:
- [x] Hover over event dot shows tooltip with event details
- [x] Click on day cell opens event list modal
- [x] Modal displays all events for that day
- [x] Modal can be closed (click outside or Escape key)
- [ ] Manual test: Hover interactions work smoothly (requires manual verification)
- [ ] Manual test: Click interactions open correct modals (requires manual verification)
- [x] Keyboard navigation works (Tab, Enter, Escape) - Escape key implemented
- [ ] No console errors (requires manual verification)

---

## Testing Strategy

### Unit Tests

**Date Utilities** (`tests/unit/date-utils.test.js`):
- Month calculations for different years
- Day-of-week calculations
- Weekend detection
- Leap year handling

**Event Parser** (`tests/unit/event-parser.test.js`):
- Date parsing (dateTime vs date)
- All-day event detection
- Multi-day event detection
- Event filtering by date

**OAuth Handler** (`tests/unit/oauth-handler.test.js`):
- Token storage and retrieval
- Token expiry checking
- Authentication flow
- Sign out functionality

### Integration Tests

**View Injection** (`tests/integration/view-injection.test.js`):
- View switcher detection
- Button injection
- View switching
- DOM manipulation

**API Client** (`tests/integration/api-client.test.js`):
- Calendar list fetching
- Event fetching with date ranges
- Error handling
- Token refresh

### Manual Testing Checklist

**OAuth Flow**:
- [ ] Extension popup shows "Sign In" button
- [ ] Clicking opens Google OAuth consent screen
- [ ] After consent, token stored successfully
- [ ] Token persists across browser restarts

**View Injection**:
- [ ] "Full Year" option appears in view switcher
- [ ] Clicking switches to full-year view
- [ ] Standard calendar view hides correctly
- [ ] Switching back to other views works

**Layout**:
- [ ] All 12 months display correctly
- [ ] Days 1-31 appear sequentially
- [ ] Weekend colors are distinct
- [ ] Horizontal scroll works on smaller screens
- [ ] Month labels stay fixed during scroll

**Event Display**:
- [ ] Events appear in correct day cells
- [ ] Event colors match Google Calendar
- [ ] Multi-day events span correctly
- [ ] Days with many events show count
- [ ] Hover shows event tooltip
- [ ] Click shows event list modal

**Performance**:
- [ ] View loads within 2 seconds
- [ ] Events render smoothly
- [ ] No lag when scrolling
- [ ] Memory usage reasonable

## Risk Mitigation Strategies

### 1. Google Calendar DOM Changes

**Risk**: Google Calendar UI updates break DOM selectors

**Mitigation**:
- Use multiple selector strategies (fallback selectors)
- Implement version detection
- Use data attributes where available
- Monitor for breaking changes
- Create compatibility layer

**Implementation**:
```javascript
// Multiple selector fallbacks
const selectors = [
  '[role="tablist"]',
  '[aria-label*="view" i]',
  '.view-switcher',
  '[data-view-switcher]'
];
```

### 2. API Rate Limits

**Risk**: Google Calendar API rate limits exceeded

**Mitigation**:
- Implement request throttling
- Cache event data locally
- Batch calendar requests
- Handle 429 (Too Many Requests) errors gracefully
- Show user-friendly error messages

**Implementation**:
```javascript
// Throttle API requests
const throttle = (fn, delay) => {
  let lastCall = 0;
  return (...args) => {
    const now = Date.now();
    if (now - lastCall >= delay) {
      lastCall = now;
      return fn(...args);
    }
  };
};
```

### 3. Performance with Large Datasets

**Risk**: Rendering 365 days with thousands of events causes lag

**Mitigation**:
- Virtual scrolling for months
- Lazy rendering of off-screen content
- Event aggregation (show counts instead of all events)
- Debounce event updates
- Use CSS transforms for animations

**Future Enhancement**:
- Implement virtual scrolling library
- Render only visible months
- Load events on-demand

### 4. OAuth Token Expiry

**Risk**: Token expires during session

**Mitigation**:
- Check token validity before API calls
- Automatic token refresh
- Store token expiry time
- Handle refresh errors gracefully
- Prompt re-authentication if refresh fails

**Implementation**:
```javascript
// Already implemented in OAuthHandler
isTokenValid() {
  return Date.now() < (this.tokenExpiry - 5 * 60 * 1000);
}
```

### 5. Recurring Events

**Risk**: Recurring events not expanded correctly

**Mitigation**:
- Use `singleEvents=true` API parameter
- Cache expanded recurrence patterns
- Handle RRULE parsing if needed
- Test with various recurrence patterns

**Implementation**:
```javascript
// API parameter already set
singleEvents: 'true'
```

## Dependencies

### Runtime Dependencies
- **date-fns** (^2.30.0): Date manipulation utilities
  - Lightweight alternative to moment.js
  - Tree-shakeable
  - Immutable date operations

### Development Dependencies
- **jest** (^29.7.0): Testing framework
- **jest-chrome** (^0.7.1): Chrome Extension API mocking
- **@types/jest** (^29.5.0): TypeScript types for Jest

### Chrome APIs Used
- `chrome.identity`: OAuth authentication
- `chrome.storage`: Token and settings storage
- `chrome.runtime`: Extension messaging
- Content Scripts API: DOM injection

### External APIs
- **Google Calendar API v3**: Event data
- **Google OAuth 2.0**: Authentication

## File Structure Summary

```
google-calendar-plugin/
├── manifest.json                    # Extension manifest (V3)
├── package.json                     # Dependencies and scripts
├── README.md                        # Project documentation
├── .gitignore                       # Git ignore rules
├── src/
│   ├── content/
│   │   ├── content.js              # Main content script
│   │   ├── view-injector.js         # View injection logic
│   │   ├── calendar-api.js          # Google Calendar API client
│   │   ├── event-renderer.js        # Event rendering
│   │   └── full-year-view.js        # Full-year view component
│   ├── background/
│   │   └── background.js            # Service worker
│   ├── popup/
│   │   ├── popup.html              # Extension popup
│   │   ├── popup.js                # Popup logic
│   │   └── popup.css               # Popup styles
│   ├── styles/
│   │   ├── full-year-view.css      # Full-year view styles
│   │   └── inject.css              # Calendar override styles
│   └── utils/
│       ├── date-utils.js            # Date calculations
│       ├── oauth-handler.js         # OAuth flow
│       ├── storage.js               # Storage utilities
│       └── event-parser.js          # Event parsing
├── assets/
│   └── icons/                       # Extension icons
└── tests/
    ├── unit/                        # Unit tests
    └── integration/                 # Integration tests
```

## Success Criteria Summary

### Phase 1 Complete When:
- [ ] Extension installs and loads without errors
- [ ] OAuth flow completes successfully
- [ ] "Full Year" option appears in view switcher
- [ ] Full-year view renders with 12 months
- [ ] Events fetched and displayed correctly
- [ ] Weekend colors applied
- [ ] Hover and click interactions work
- [ ] All tests pass: `npm test`
- [ ] No console errors
- [ ] Manual testing checklist complete

### Automated Verification:
```bash
# Run all tests
npm test

# Check test coverage
npm run test:coverage

# Load extension in Chrome
# chrome://extensions/ → "Load unpacked" → select project directory
```

### Manual Verification:
- Open Google Calendar
- See "Full Year" in view switcher
- Click "Full Year"
- Verify 12-month grid displays
- Verify events appear in correct days
- Verify weekend colors
- Test hover and click interactions

## References

- Research: `thoughts/saski/google-calendar-plugin/2026-01-02-google-calendar-plugin-research.md`
- UI Design: `thoughts/saski/google-calendar-plugin/ui-design-reference.md`
- Project Structure: `thoughts/saski/google-calendar-plugin/project-structure.md`
- Google Calendar API: https://developers.google.com/calendar/api/v3/reference
- Chrome Extension Manifest V3: https://developer.chrome.com/docs/extensions/mv3/intro/
- Google OAuth 2.0: https://developers.google.com/identity/protocols/oauth2
- date-fns Documentation: https://date-fns.org/

## Open Questions

None - plan is complete and ready for implementation.

---

## Next Steps

1. **Review and approve** this implementation plan
2. **Set up project**: Create directory structure and initial files
3. **Begin Phase 1**: Start with project setup and manifest configuration
4. **Follow TDD**: Write tests first, then implement
5. **Iterate incrementally**: One phase at a time, one test at a time

**To execute this plan:**
```
/fic-implement-plan thoughts/shared/plans/2026-01-07-google-calendar-full-year-view.md
```


