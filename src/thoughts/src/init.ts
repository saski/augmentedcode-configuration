#!/usr/bin/env node
/**
 * thoughts-init - Initialize thoughts/ directory structure
 */

import * as fs from 'fs';
import * as path from 'path';

const USERNAME = process.env.THOUGHTS_USER || 'saski';
const THOUGHTS_DIR = 'thoughts';

const colors = {
  green: (s: string) => `\x1b[32m${s}\x1b[0m`,
  yellow: (s: string) => `\x1b[33m${s}\x1b[0m`,
  red: (s: string) => `\x1b[31m${s}\x1b[0m`,
};

function info(msg: string): void {
  console.log(`${colors.green('[INFO]')} ${msg}`);
}

function warn(msg: string): void {
  console.log(`${colors.yellow('[WARN]')} ${msg}`);
}

export function initThoughts(): void {
  if (fs.existsSync(THOUGHTS_DIR)) {
    warn('thoughts/ directory already exists. Re-initializing (existing files preserved)...');
  }

  info('Creating thoughts/ directory structure...');

  const dirs = [
    `${THOUGHTS_DIR}/${USERNAME}/tickets`,
    `${THOUGHTS_DIR}/${USERNAME}/notes`,
    `${THOUGHTS_DIR}/shared/research`,
    `${THOUGHTS_DIR}/shared/plans`,
    `${THOUGHTS_DIR}/shared/prs`,
    `${THOUGHTS_DIR}/searchable`,
  ];

  dirs.forEach(dir => {
    fs.mkdirSync(dir, { recursive: true });
  });

  info('Directory structure created:');
  console.log(`  ${THOUGHTS_DIR}/`);
  console.log(`  ├── ${USERNAME}/`);
  console.log(`  │   ├── tickets/`);
  console.log(`  │   └── notes/`);
  console.log(`  ├── shared/`);
  console.log(`  │   ├── research/`);
  console.log(`  │   ├── plans/`);
  console.log(`  │   └── prs/`);
  console.log(`  └── searchable/ (will contain hardlinks)`);

  // Create .gitignore
  const gitignorePath = path.join(THOUGHTS_DIR, '.gitignore');
  if (!fs.existsSync(gitignorePath)) {
    info('Creating .gitignore...');
    fs.writeFileSync(gitignorePath, `# Ignore searchable/ directory (it contains hardlinks)
searchable/

# But track the structure
!searchable/.gitkeep
`);
  }

  // Create .gitkeep
  fs.writeFileSync(path.join(THOUGHTS_DIR, 'searchable', '.gitkeep'), '');

  // Create README
  const readmePath = path.join(THOUGHTS_DIR, 'README.md');
  if (!fs.existsSync(readmePath)) {
    info('Creating README.md...');
    fs.writeFileSync(readmePath, `# Thoughts Directory

This directory contains research documents, implementation plans, and notes for this project.

## Structure

- \`${USERNAME}/\` - Personal notes and tickets
  - \`tickets/\` - Ticket documentation and tracking
  - \`notes/\` - Personal notes and observations
- \`shared/\` - Team-shared documents
  - \`research/\` - Research documents from /fic-research
  - \`plans/\` - Implementation plans from /fic-create-plan
  - \`prs/\` - PR descriptions and documentation
- \`searchable/\` - Hardlinks for efficient grep searching (auto-generated)

## Usage

Use Cursor slash commands:
- \`/fic-research [topic]\` - Research and document codebase
- \`/fic-create-plan [description]\` - Create implementation plan
- \`/fic-implement-plan [plan-file]\` - Execute a plan
- \`/fic-validate-plan [plan-file]\` - Validate implementation

Run \`npx thoughts sync\` after adding/modifying files to update searchable/ hardlinks.
`);
  }

  info('✓ thoughts/ initialized successfully!');
  console.log('');
  info('Next steps:');
  console.log('  1. Run thoughts sync to create/update searchable/ hardlinks');
  console.log('  2. Use Cursor slash commands like /fic-research');
  console.log('  3. Commit thoughts/ directory to git (searchable/ is gitignored)');
}

// Run if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  initThoughts();
}

