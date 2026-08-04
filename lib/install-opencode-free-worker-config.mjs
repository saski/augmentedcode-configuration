#!/usr/bin/env node

import { existsSync, mkdirSync, readFileSync, renameSync, writeFileSync } from 'node:fs'
import { dirname } from 'node:path'

const [mode, templatePath, configPath] = process.argv.slice(2)

if (!['install', 'validate'].includes(mode) || !templatePath || !configPath) {
  console.error('Usage: install-opencode-free-worker-config.mjs <install|validate> <template> <config>')
  process.exit(2)
}

const readJson = (path, label) => {
  try {
    return JSON.parse(readFileSync(path, 'utf8'))
  } catch (error) {
    console.error(`OpenCode ${label} must be strict JSON; no changes were made: ${error.message}`)
    process.exit(1)
  }
}

const isObject = (value) => value !== null && typeof value === 'object' && !Array.isArray(value)
const stableJson = (value) => JSON.stringify(value, null, 2) + '\n'
const equal = (left, right) => stableJson(left) === stableJson(right)
const localOmniRouteUrls = new Set([
  'http://127.0.0.1:20128/v1',
  'http://localhost:20128/v1',
])
const failConflict = (path) => {
  console.error(`OpenCode managed field conflict at ${path}; no changes were made`)
  process.exit(1)
}

const template = readJson(templatePath, 'template')
const managedProvider = template.provider?.omniroute
const managedWorker = template.agent?.['free-worker']

if (!isObject(managedProvider) || !isObject(managedWorker)) {
  console.error('OpenCode template is missing the managed provider or free-worker agent')
  process.exit(1)
}

const validate = (config) => {
  const provider = config.provider?.omniroute
  const worker = config.agent?.['free-worker']
  if (!isObject(provider) || !isObject(worker)) {
    console.error('OpenCode managed provider or free-worker agent is missing')
    process.exit(1)
  }
  if (!equal(provider.npm, managedProvider.npm)) failConflict('provider.omniroute.npm')
  if (!isObject(provider.options) || !localOmniRouteUrls.has(provider.options.baseURL)) {
    failConflict('provider.omniroute.options.baseURL')
  }
  for (const model of Object.keys(managedProvider.models)) {
    if (!isObject(provider.models?.[model])) {
      failConflict(`provider.omniroute.models.${model}`)
    }
  }
  if (!equal(worker, managedWorker)) failConflict('agent.free-worker')
}

if (mode === 'validate') {
  validate(readJson(configPath, 'configuration'))
  console.log(`✓ OpenCode free-worker fields valid: ${configPath}`)
  process.exit(0)
}

const config = existsSync(configPath) ? readJson(configPath, 'configuration') : {}

if (!isObject(config)) failConflict('root')
if (config.provider !== undefined && !isObject(config.provider)) failConflict('provider')
if (config.agent !== undefined && !isObject(config.agent)) failConflict('agent')

const next = structuredClone(config)
next.provider ??= {}
next.agent ??= {}

if (next.provider.omniroute === undefined) {
  next.provider.omniroute = structuredClone(managedProvider)
} else {
  const provider = next.provider.omniroute
  if (!isObject(provider)) failConflict('provider.omniroute')
  if (provider.npm === undefined) provider.npm = managedProvider.npm
  else if (!equal(provider.npm, managedProvider.npm)) failConflict('provider.omniroute.npm')
  if (provider.options === undefined) provider.options = structuredClone(managedProvider.options)
  if (!isObject(provider.options) || !localOmniRouteUrls.has(provider.options.baseURL)) {
    failConflict('provider.omniroute.options.baseURL')
  }
  if (provider.models === undefined) provider.models = {}
  if (!isObject(provider.models)) failConflict('provider.omniroute.models')
  for (const [model, definition] of Object.entries(managedProvider.models)) {
    if (provider.models[model] === undefined) provider.models[model] = structuredClone(definition)
    else if (!isObject(provider.models[model])) failConflict(`provider.omniroute.models.${model}`)
  }
}

if (next.agent['free-worker'] === undefined) {
  next.agent['free-worker'] = structuredClone(managedWorker)
} else if (!equal(next.agent['free-worker'], managedWorker)) {
  failConflict('agent.free-worker')
}

validate(next)
const original = stableJson(config)
const output = stableJson(next)
if (original !== output) {
  mkdirSync(dirname(configPath), { recursive: true })
  const temporaryPath = `${configPath}.tmp-${process.pid}`
  writeFileSync(temporaryPath, output, { mode: 0o600 })
  renameSync(temporaryPath, configPath)
  console.log(`✓ OpenCode free-worker fields installed: ${configPath}`)
} else {
  console.log(`✓ OpenCode free-worker fields already installed: ${configPath}`)
}
