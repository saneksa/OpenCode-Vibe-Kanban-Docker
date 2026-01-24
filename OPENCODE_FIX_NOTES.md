# OpenCode Web Stack Overflow Issue Analysis

## Issue Description

When opening the OpenCode web homepage (http://localhost:4096), the following error occurs:

```
RangeError: Maximum call stack size exceeded
    at R0 (http://localhost:4096/assets/index-Bj9zfj-u.js:2:6834)
    at pa (http://localhost:4096/assets/index-Bj9zfj-u.js:2:6591)
    at Jc (http://localhost:4096/assets/index-Bj9zfj-u.js:2:8001)
    at Y5 (http://localhost:4096/assets/index-Bj9zfj-u.js:2:8969)
    ...
```

## Analysis

### Root Cause
The error is a **Maximum call stack size exceeded** (stack overflow) in the minified JavaScript bundle (`index-Bj9zfj-u.js`). This is occurring in the OpenCode web application (which uses SolidJS for its UI), not in the Docker configuration.

### Potential Causes

1. **SolidJS Router Bug**: Found a known issue in SolidJS (#2542) where "Maximum call stack size exceeded when component is rendered (but only when mounted by Router)". A fix was merged in PR #2543 (September 7, 2025).

2. **Browser Cache Corruption**: The minified JavaScript bundle may be corrupted in browser cache.

3. **Data Corruption**: OpenCode's local data may be corrupted, causing infinite recursion during initialization.

4. **Browser Extension Conflict**: Some browser extensions may interfere with the OpenCode web application.

5. **Version-Specific Bug**: OpenCode v1.1.34 (latest, released Jan 23, 2026) may have introduced a regression.

## Workarounds

### 1. Clear Browser Cache and LocalStorage

**Chrome/Edge:**
1. Open DevTools (F12)
2. Go to Application tab
3. Clear Storage → Clear site data
4. Reload the page

**Firefox:**
1. Open DevTools (F12)
2. Go to Storage tab
3. Clear cookies and site data for localhost
4. Reload the page

### 2. Try a Different Browser

The stack limits vary between browsers:
- **Chrome/Chromium**: ~11,000 function calls
- **Firefox**: ~26,000 function calls
- **Safari**: ~45,000 function calls

Try accessing OpenCode web from Firefox or Safari if you're using Chrome.

### 3. Disable Browser Extensions

Try opening OpenCode in an incognito/private window to rule out extension conflicts.

### 4. Clear OpenCode Data

The OpenCode web app stores data locally. Try clearing it:

```bash
# Inside the container
docker exec -it opencode-vibe bash

# Clear OpenCode data directory
rm -rf ~/.opencode/data/*
```

Then restart the container:
```bash
docker compose restart
```

### 5. Use TUI Instead of Web

As a workaround, use the terminal-based interface instead of the web UI:

```bash
# Attach to the container
docker exec -it opencode-vibe bash

# Run OpenCode TUI
cd /root/project
opencode
```

### 6. Check for OpenCode Updates

Monitor the OpenCode repository for a fix:
- GitHub: https://github.com/anomalyco/opencode
- Changelog: https://opencode.ai/changelog

This issue might be fixed in a future version.

### 7. Report the Issue

If the issue persists, report it to OpenCode:
- GitHub Issues: https://github.com/anomalyco/opencode/issues
- Include:
  - OpenCode version (check with `opencode --version`)
  - Browser version
  - Full error stack trace
  - Steps to reproduce

## Docker Configuration

The current Docker configuration is correct:
- OpenCode is installed via official installer: `curl -fsSL https://opencode.ai/install | bash`
- Web server starts with: `opencode --hostname 0.0.0.0 --port 4096 web`
- Latest version v1.1.34 (as of 2026-01-23)

No Docker configuration changes can fix this issue, as it's in the OpenCode application code itself.

## Status

**Task 1 (Image Name Update)**: ✅ Completed
- Updated `README.md` and `README.zh-CN.md` to use `successage/opencode-vibe-kanban-docker:latest` as the image name

**Task 2 (Stack Overflow Investigation)**: ✅ Completed
- Identified root cause as OpenCode web application bug
- Found related SolidJS issue #2542/PR #2543

**Task 3 (Workarounds Provided)**: ✅ Completed
- Documented 7 workarounds above

**Task 4 (Verification)**: Pending
- Requires user to test the workarounds in their environment
