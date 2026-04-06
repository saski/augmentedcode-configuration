#!/usr/bin/env node

const fs = require('fs');
const os = require('os');
const path = require('path');

function sanitizeSessionId(rawSessionId) {
  const sanitized = String(rawSessionId || 'default').replace(/[^a-zA-Z0-9_-]/g, '');
  return sanitized || 'default';
}

function readCount(counterFile) {
  try {
    const rawValue = fs.readFileSync(counterFile, 'utf8').trim();
    const parsed = Number.parseInt(rawValue, 10);
    if (Number.isFinite(parsed) && parsed > 0 && parsed <= 1_000_000) {
      return parsed;
    }
  } catch {}

  return 0;
}

function writeCount(counterFile, count) {
  fs.writeFileSync(counterFile, `${count}\n`);
}

function logSuggestion(message) {
  process.stdout.write(`[StrategicCompact] ${message}\n`);
}

function main() {
  const sessionId = sanitizeSessionId(process.env.CLAUDE_SESSION_ID);
  const counterFile = path.join(os.tmpdir(), `claude-tool-count-${sessionId}`);
  const configuredThreshold = Number.parseInt(process.env.COMPACT_THRESHOLD || '50', 10);
  const threshold =
    Number.isFinite(configuredThreshold) && configuredThreshold > 0 && configuredThreshold <= 10_000
      ? configuredThreshold
      : 50;
  const count = readCount(counterFile) + 1;

  writeCount(counterFile, count);

  if (count === threshold) {
    logSuggestion(`${threshold} tool calls reached; consider /compact if you are changing phases.`);
  }

  if (count > threshold && (count - threshold) % 25 === 0) {
    logSuggestion(`${count} tool calls reached; compact if the current context is stale.`);
  }
}

try {
  main();
} catch (error) {
  process.stderr.write(`[StrategicCompact] ${error.message}\n`);
  process.exit(0);
}
