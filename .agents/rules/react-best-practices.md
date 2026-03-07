# React Best Practices

This document defines React and TypeScript guidance used by agents when working on `.tsx`, `.ts`, `.jsx`, and `.js` files.

## 1. Core React Principles

- Prefer function components and hooks.
- Keep components small and focused on one responsibility.
- Prefer composition over deep prop drilling or monolithic components.
- Keep render logic simple and deterministic.
- Avoid premature abstractions.

## 2. TypeScript Standards

- Use strict, explicit types for props, state, and function return values.
- Avoid `any`; use unions, generics, and narrow types instead.
- Model domain concepts with named interfaces or type aliases.
- Keep types close to usage unless shared across modules.

## 3. Component Design

- Split container logic and presentational UI when complexity grows.
- Extract repeated JSX into reusable components.
- Keep component files readable and cohesive.
- Use clear prop names that describe domain intent.
- Avoid passing large unstructured objects when explicit props are clearer.

## 4. State Management

- Keep state as local as possible.
- Derive values from props/state instead of duplicating state.
- Use `useMemo` and `useCallback` only when profiling or clear dependency control justifies them.
- Prefer reducers for complex transitions.
- Avoid side effects in render paths.

## 5. Effects and Data Flow

- Use `useEffect` only for side effects.
- Keep effect dependency arrays correct and complete.
- Make async effects cancel-safe to prevent stale updates.
- Handle loading, success, and error states explicitly.
- Validate and normalize API data at boundaries.

## 6. Performance

- Measure before optimizing.
- Avoid unnecessary rerenders via stable props and component boundaries.
- Use list virtualization for large collections.
- Lazy-load heavy routes/components.
- Optimize images and critical render path assets.

## 7. Accessibility and UX

- Use semantic HTML first.
- Ensure keyboard navigation and visible focus states.
- Provide labels and accessible names for interactive controls.
- Announce async state changes where appropriate.
- Maintain color contrast and readable typography.

## 8. Testing Guidance

- Test behavior over implementation details.
- Prefer user-centric tests for components and flows.
- Cover critical states: loading, empty, error, success, and edge conditions.
- Keep tests deterministic and isolated.
- Add regression tests for bug fixes.

## 9. Security and Reliability

- Never render unsanitized HTML from untrusted input.
- Validate external data and guard against null/undefined access.
- Avoid exposing secrets in client code.
- Fail clearly with actionable error states.
- Log meaningful context for diagnosability.

## 10. Review Checklist

Before finalizing React changes:

1. Types are explicit and safe.
2. Components are small and cohesive.
3. State and effects are minimal and correct.
4. Accessibility basics are covered.
5. Tests cover intended behavior and key edge cases.
6. Performance-sensitive changes are measured or justified.
