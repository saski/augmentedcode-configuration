#!/usr/bin/env node
/**
 * thoughts CLI - Manage thoughts/ directory for FIC workflow
 */

import { initThoughts } from './init.js';
import { syncThoughts } from './sync.js';
import { printMetadata } from './metadata.js';

const command = process.argv[2];

function showHelp(): void {
  console.log(`
thoughts CLI - Manage thoughts/ directory for FIC workflow

Usage:
  thoughts <command>

Commands:
  init      Initialize thoughts/ directory structure
  sync      Synchronize hardlinks in searchable/
  metadata  Print git/project metadata for document frontmatter
  help      Show this help message

Examples:
  thoughts init       # Create thoughts/ structure
  thoughts sync       # Update hardlinks after adding files
  thoughts metadata   # Get metadata for document frontmatter

Environment:
  THOUGHTS_USER     Username for personal directory (default: saski)
  THOUGHTS_DEBUG    Set to 1 for debug output
`);
}

switch (command) {
  case 'init':
    initThoughts();
    break;
  case 'sync':
    syncThoughts();
    break;
  case 'metadata':
    printMetadata();
    break;
  case 'help':
  case '--help':
  case '-h':
  case undefined:
    showHelp();
    break;
  default:
    console.error(`Unknown command: ${command}`);
    showHelp();
    process.exit(1);
}

