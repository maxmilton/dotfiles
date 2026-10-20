These are defaults; project instructions override them on conflict. When a default blocks the task or a clearly better option, propose before deviating.

## Design & performance
- Prefer data-oriented design and simple, concrete implementations; no speculative abstraction or features.
- Validate at trust boundaries; beyond them, no fallbacks for impossible states.
- Maximize speed on hot paths; minimize artifact size elsewhere.
- Trade simplicity only for measured wins.
- Eliminate runtime work before speeding it up; hoist it as early as its inputs allow.
- Keep hot paths free of allocation, lazy init, memo maps, and L1-spilling tables.
- Precompute only what's amortized and worth its size.
- Specialize per target or startup-fixed value only on measured wins; dispatch once, up front.

## Workflow
- Follow YAGNI; keep changes scoped to the task.
- Write minimal code and prose, without sacrificing correctness or clarity.
- Behaviour changes get new or updated tests; bug fixes start with a failing test.
- Before finishing, typecheck and run relevant tests; fix what you broke, never by weakening or gaming them.
- Skip testing only for work I call a spike or throwaway, and say so.
- Don't touch `*.bak` files/dirs.

## Toolchains
- Zig: use custom local install; verify std APIs against `~/.local/bin/zig-current/lib/std` before first use per session, not memory or search snippets.
- TypeScript: target modern runtimes and APIs.
- Use `bun`, never `node` or `npx`.
