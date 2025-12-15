#!/usr/bin/env node
/**
 * thoughts-sync - Synchronize hardlinks in thoughts/searchable/
 */

import * as fs from 'fs';
import * as path from 'path';

const THOUGHTS_DIR = 'thoughts';
const SEARCHABLE_DIR = path.join(THOUGHTS_DIR, 'searchable');

const colors = {
  green: (s: string) => `\x1b[32m${s}\x1b[0m`,
  yellow: (s: string) => `\x1b[33m${s}\x1b[0m`,
  red: (s: string) => `\x1b[31m${s}\x1b[0m`,
  blue: (s: string) => `\x1b[34m${s}\x1b[0m`,
};

function info(msg: string): void {
  console.log(`${colors.green('[INFO]')} ${msg}`);
}

function warn(msg: string): void {
  console.log(`${colors.yellow('[WARN]')} ${msg}`);
}

function error(msg: string): void {
  console.error(`${colors.red('[ERROR]')} ${msg}`);
  process.exit(1);
}

function debug(msg: string): void {
  if (process.env.THOUGHTS_DEBUG === '1') {
    console.log(`${colors.blue('[DEBUG]')} ${msg}`);
  }
}

function findMdFiles(dir: string, baseDir: string = dir): string[] {
  const files: string[] = [];
  
  if (!fs.existsSync(dir)) return files;
  
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    const relPath = path.relative(baseDir, fullPath);
    
    // Skip searchable directory
    if (relPath.startsWith('searchable')) continue;
    
    if (entry.isDirectory()) {
      files.push(...findMdFiles(fullPath, baseDir));
    } else if (entry.isFile() && entry.name.endsWith('.md')) {
      files.push(fullPath);
    }
  }
  
  return files;
}

function sameInode(file1: string, file2: string): boolean {
  try {
    const stat1 = fs.statSync(file1);
    const stat2 = fs.statSync(file2);
    return stat1.ino === stat2.ino && stat1.dev === stat2.dev;
  } catch {
    return false;
  }
}

export function syncThoughts(): void {
  if (!fs.existsSync(THOUGHTS_DIR)) {
    error("thoughts/ directory not found. Run 'thoughts init' first.");
  }

  fs.mkdirSync(SEARCHABLE_DIR, { recursive: true });

  let added = 0;
  let removed = 0;
  let skipped = 0;

  info('Synchronizing thoughts/searchable/ hardlinks...');

  const mdFiles = findMdFiles(THOUGHTS_DIR);

  for (const file of mdFiles) {
    const relPath = path.relative(THOUGHTS_DIR, file);
    const target = path.join(SEARCHABLE_DIR, relPath);
    const targetDir = path.dirname(target);

    fs.mkdirSync(targetDir, { recursive: true });

    if (fs.existsSync(target)) {
      if (sameInode(file, target)) {
        debug(`Skipping ${relPath} (already linked)`);
        skipped++;
        continue;
      } else {
        debug(`Removing old link: ${relPath}`);
        fs.unlinkSync(target);
        removed++;
      }
    }

    try {
      fs.linkSync(file, target);
      debug(`Hardlinked: ${relPath}`);
      added++;
    } catch {
      warn(`Could not create hardlink for ${relPath}, using symlink`);
      const relSource = path.relative(targetDir, file);
      fs.symlinkSync(relSource, target);
      added++;
    }
  }

  // Clean up orphaned links
  info('Cleaning up orphaned links...');
  let orphaned = 0;

  function cleanOrphans(dir: string): void {
    if (!fs.existsSync(dir)) return;
    
    const entries = fs.readdirSync(dir, { withFileTypes: true });
    
    for (const entry of entries) {
      const fullPath = path.join(dir, entry.name);
      
      if (entry.isDirectory()) {
        cleanOrphans(fullPath);
      } else if (entry.name.endsWith('.md')) {
        const relPath = path.relative(SEARCHABLE_DIR, fullPath);
        const sourceFile = path.join(THOUGHTS_DIR, relPath);
        
        if (!fs.existsSync(sourceFile)) {
          debug(`Removing orphaned link: ${relPath}`);
          fs.unlinkSync(fullPath);
          orphaned++;
        }
      }
    }
  }

  cleanOrphans(SEARCHABLE_DIR);

  // Remove empty directories
  function removeEmptyDirs(dir: string): void {
    if (!fs.existsSync(dir)) return;
    
    const entries = fs.readdirSync(dir);
    
    for (const entry of entries) {
      const fullPath = path.join(dir, entry);
      if (fs.statSync(fullPath).isDirectory()) {
        removeEmptyDirs(fullPath);
      }
    }
    
    const remaining = fs.readdirSync(dir);
    if (remaining.length === 0 && dir !== SEARCHABLE_DIR) {
      fs.rmdirSync(dir);
    }
  }

  removeEmptyDirs(SEARCHABLE_DIR);

  console.log('');
  info('✓ Sync complete!');
  console.log(`  Links added: ${added}`);
  console.log(`  Links removed: ${removed}`);
  console.log(`  Links skipped: ${skipped}`);
  console.log(`  Orphaned links cleaned: ${orphaned}`);

  const total = findMdFiles(SEARCHABLE_DIR, SEARCHABLE_DIR).length;
  console.log(`  Total .md files in searchable/: ${total}`);

  if (total === 0) {
    warn('No .md files found. Add some documents to thoughts/ first.');
  }
}

// Run if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  syncThoughts();
}

