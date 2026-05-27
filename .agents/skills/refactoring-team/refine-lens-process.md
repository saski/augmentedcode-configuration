# Refine Lens Process

Iteratively improve a refactoring lens and its reviewer guide using deep research and the refinement-loop skill.

## Input

- Which lens to refine (e.g., `references/lenses/14-coupling.md`)
- Its reviewer guide (e.g., `references/reviewer-guides/14-coupling.reviewer.md`)
- Any existing research on the lens topic (optional)

## Phase 1: Calibrate

Read before writing anything:
- The lens to refine
- Its reviewer guide
- 3-4 existing lenses that are considered strong (08-duplication, 09-file-boundaries, 11-semantic-clarity are good benchmarks)
- Their reviewer guides
- Any existing research documents on the topic

Note the patterns: line count (20-31 for lenses), bullet count in How to Spot (typically 4), tone (practical not academic), structure (question-driven, perspective-shifting Process sections, punchy Go Deeper).

## Phase 2: Research

Launch parallel research subagents, one per major aspect of the lens. For each aspect, the agent should search for:
- What do the best thinkers say about this? (Fowler, Beck, Metz, Martin, Feathers, Ousterhout, etc.)
- When is this a real problem vs. acceptable?
- What are the common mistakes when trying to fix it?
- What nuances do practitioners miss?
- What are the respected dissenting opinions?

### How to decompose into research agents

Look at the lens and identify its distinct concepts. For a coupling lens, that was:
- Reaching through objects (Law of Demeter)
- Shotgun surgery / divergent change
- Pass-through coupling
- Essential vs accidental coupling theory
- Framework coupling / leaky abstractions

Each becomes a research agent prompt. Ask for specific quotes, examples, attributions, and sources. Emphasize nuanced perspectives over textbook definitions.

### What to look for in research results

Not everything belongs in the lens. Filter for:
- False positives the worker might trigger (what looks like this smell but isn't?)
- Wrong fixes the worker might attempt (what's the common over-correction?)
- Trade-off nuances that prevent over-zealous application
- Perspective shifts that make the Process section more powerful
- Specific, vivid phrasing that captures an insight better than the current draft

Discard:
- Academic frameworks that don't change what the worker does
- Historical context that's interesting but not actionable
- Techniques beyond the scope of a refactoring pass (e.g., git history mining)

## Phase 3: Refine

Use the `refinement-loop` skill to iterate on both files. The research provides ammunition — specific insights that reveal gaps, sharpen framing, or prevent mistakes.

### Refinement priorities

In order of impact:
- Preventing false positives (what the worker might wrongly flag)
- Preventing wrong fixes (what the worker might do that makes things worse)
- Sharpening the Process section (perspective shifts > checklists)
- Enriching Trade-off with nuance that prevents over-correction
- Tightening Go Deeper to push into specific hiding places

### Quality bar

Match the established lenses on:
- Conciseness: 20-31 lines for lens, 28-36 for reviewer guide
- How to Spot: ~4 bullets describing visible symptoms, not smell catalog names
- Process: a perspective shift or technique, not an audit checklist
- Trade-off: when NOT to act (prevents over-correction)
- Go Deeper: questions that push into hiding places, not generic "what else?"
- Tone: practical and grounded, no academic jargon
- No Fowler smell names used as labels (describe what you see, not what it's called)

### Reviewer guide specifics

The reviewer guide should include:
- False-positive awareness (what the worker might wrongly flag — push back)
- Wrong-fix awareness (what the worker might do that hides the problem without solving it)
- A technique the reviewer can use independently (not just re-checking the worker's findings)

## Example: How coupling was refined

Started with 7 How to Spot bullets reading like a smell catalog. After research:

| Research finding | Source | What it changed |
|---|---|---|
| Dot-chains through data structures are navigation, not coupling | Robert Martin | Added false-positive guard to bullet 1 |
| Coupling that's never triggered costs nothing | Kent Beck | Added change-axis nuance to Trade-off |
| Delegation wrappers hide coupling, don't fix it | Sandi Metz | Added wrong-fix warning to Go Deeper |
| "Trace the ripple" aligns with effect sketches | Michael Feathers | Validated the Process approach |
| Connascence theory provides richer vocabulary | Meilir Page-Jones | Deliberately excluded (too academic for the lens) |

The "deliberately excluded" row matters as much as the others. Not every research insight belongs in a concise, actionable lens.
