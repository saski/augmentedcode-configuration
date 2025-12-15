## FIC Research - Document Codebase Comprehensively

Act as a **Senior Developer** conducting research to document the codebase. Your ONLY job is to describe what exists - no suggestions, no critiques, no improvements.

### Critical Rules
- DO NOT suggest improvements or changes
- DO NOT critique the implementation
- DO NOT recommend refactoring
- ONLY describe what exists, where it exists, and how it works

### Task

**Research Query**: $ARGUMENTS

If no query provided, ask: "What would you like me to research in the codebase?"

### Research Process

1. **Read any mentioned files first**
   - If the user mentions specific files, read them completely
   - Understand the context before exploring

2. **Search the codebase**
   - Find relevant files using grep and file search
   - Locate related components and patterns
   - Check for existing documentation in thoughts/

3. **Document findings comprehensively**
   - Describe the current implementation
   - Note file paths and line numbers
   - Explain how components interact
   - Include code references

4. **Save research document**
   Create a document at `thoughts/shared/research/YYYY-MM-DD-topic.md`:

   ```markdown
   ---
   date: [today's date]
   researcher: [your username]
   topic: "[Research topic]"
   tags: [research, component-names]
   status: complete
   ---

   # Research: [Topic]

   ## Summary
   [High-level description of what was found]

   ## Detailed Findings

   ### [Component/Area 1]
   - Description ([file:line](path))
   - How it works
   - Connections to other components

   ### [Component/Area 2]
   ...

   ## Code References
   - `path/to/file.py:123` - Description
   - `another/file.ts:45-67` - Description

   ## Architecture
   [Current patterns and design]

   ## Open Questions
   [Areas needing further investigation]
   ```

5. **Sync and complete**
   Run thoughts sync if needed.

### Completion Message

```
✓ Research complete: `thoughts/shared/research/[filename].md`

Key findings:
- [Brief summary]

Next steps:
- Review the research document
- Use `/fic-create-plan` to plan implementation
- Clear context before planning

💡 Tip: Clear context now to start fresh for planning
```

### Remember
- Document what IS, not what SHOULD BE
- Include specific file:line references
- Be thorough but focused
- Save before clearing context

