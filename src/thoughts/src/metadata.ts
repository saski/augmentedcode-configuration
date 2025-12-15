#!/usr/bin/env node
/**
 * thoughts-metadata - Generate git/project metadata for thoughts documents
 */

import { execSync } from 'child_process';

function execGit(cmd: string): string {
  try {
    return execSync(cmd, { encoding: 'utf-8', stdio: ['pipe', 'pipe', 'pipe'] }).trim();
  } catch {
    return '';
  }
}

function isGitRepo(): boolean {
  try {
    execSync('git rev-parse --is-inside-work-tree', { stdio: ['pipe', 'pipe', 'pipe'] });
    return true;
  } catch {
    return false;
  }
}

export interface ThoughtsMetadata {
  dateTimeTz: string;
  isoDateTime: string;
  dateShort: string;
  gitCommit: string;
  gitBranch: string;
  repoName: string;
  gitUser: string;
  gitEmail: string;
  filenameTimestamp: string;
}

export function getMetadata(): ThoughtsMetadata {
  const now = new Date();
  
  const dateTimeTz = now.toLocaleString('en-US', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    timeZoneName: 'short',
  });
  
  const isoDateTime = now.toISOString();
  const dateShort = now.toISOString().split('T')[0];
  const filenameTimestamp = `${dateShort}_${now.toTimeString().split(' ')[0].replace(/:/g, '-')}`;

  let gitCommit = 'no-commit';
  let gitBranch = 'no-branch';
  let repoName = 'no-repo';
  let gitUser = 'unknown';
  let gitEmail = 'unknown';

  if (isGitRepo()) {
    const repoRoot = execGit('git rev-parse --show-toplevel');
    repoName = repoRoot ? repoRoot.split('/').pop() || 'no-repo' : 'no-repo';
    gitBranch = execGit('git branch --show-current') || execGit('git rev-parse --abbrev-ref HEAD') || 'no-branch';
    gitCommit = execGit('git rev-parse HEAD') || 'no-commit';
    gitUser = execGit('git config user.name') || 'unknown';
    gitEmail = execGit('git config user.email') || 'unknown';
  }

  return {
    dateTimeTz,
    isoDateTime,
    dateShort,
    gitCommit,
    gitBranch,
    repoName,
    gitUser,
    gitEmail,
    filenameTimestamp,
  };
}

export function printMetadata(): void {
  const meta = getMetadata();
  
  console.log(`Current Date/Time (TZ): ${meta.dateTimeTz}`);
  console.log(`ISO DateTime: ${meta.isoDateTime}`);
  console.log(`Date Short: ${meta.dateShort}`);
  console.log(`Current Git Commit Hash: ${meta.gitCommit}`);
  console.log(`Current Branch Name: ${meta.gitBranch}`);
  console.log(`Repository Name: ${meta.repoName}`);
  console.log(`Git User: ${meta.gitUser}`);
  console.log(`Git Email: ${meta.gitEmail}`);
  console.log(`Timestamp For Filename: ${meta.filenameTimestamp}`);
}

// Run if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  printMetadata();
}

