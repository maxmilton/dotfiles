# Type testing with `expectTypeOf`

Bun's vendored `expect-type`, measured on bun-types 1.3.14 — re-measure rather
than trust these if that version moves. Source of truth is
`node_modules/.bun/bun-types@*/node_modules/bun-types/vendor/expect-type/index.d.ts`.

Type assertions can only fail under `tsc` (`bun run lint:ts`). A green `bun test`
proves nothing about them, so lint is load-bearing.

**Guard against vacuity first.** `any` and `never` make every later assertion
pass. Lead with `expectTypeOf(x).not.toBeAny()`, and `toBeFunction()` before
`.parameters`/`.returns`; pin a return with `.returns.not.toBeAny()` and
`.not.toBeNever()` before asserting its shape.

**Extractor methods return `undefined` at runtime** — `omit`, `pick`, `extract`,
`exclude`, `map`, `parameter`, `toHaveProperty`, `toBeCallableWith`. Chaining
off one throws a `TypeError` while `tsc` still reports the line as passing.
Only the getters are safe to chain: `parameters`, `returns`,
`items`, `branded`, `constructorParameters` (unions constructor overloads,
same erasure caveat as `.parameters` below). Use the equivalent type operator
with the no-argument overload instead — `expectTypeOf<Omit<R, "ref">>()`,
`expectTypeOf<R["ref"]>()`.

**`.parameters` / `.returns` union every overload** (`OverloadParameters` /
`OverloadReturnTypes`), rather than taking the last signature the way
`Parameters<T>` does. An overload set `{ (): A; (x: X): B }` gives parameters
`[] | [X]` and returns `A | B` — so a `never` return contributed by one
overload vanishes into the union. To pin one overload, extract it as a type:

```ts
type NoArgReturn<T> = T extends { (): infer R; (...args: never[]): unknown } ? R : never;
```

**A generic class's `.prototype` instantiates its type parameters as `any`,
not as their constraints** — so `expectTypeOf(C.prototype.method)` assertions are near-vacuous, and
`.returns.not.toBeAny()` still passes when the return is `Row<any>`. Only
*method-level* generics erase to constraints. Assert on an instantiated member
type instead: `expectTypeOf<C<Concrete>["method"]>()`.

**`.parameters` / `.returns` / `ReturnType<typeof fn>` erase generics** —
every type parameter resolves to its constraint, or `unknown` when
unconstrained (and a default, `<T extends Node = Element>`, is ignored — only
checkable at a call site). An unconstrained `T` degrades further: `keyof T`
collapses to `never`, and the signature stops matching `ReturnType`, whose
false branch is `any`. Assertions on a generic function pass while saying
nothing about it.

Add instantiated assertions beside the erased ones, via instantiation
expressions — `expectTypeOf<ReturnType<typeof create<"div">>>()`,
`expectTypeOf<typeof clone<HTMLLIElement>>()`. These are zero-runtime. To
prove such an assertion can fail, mutate a generic's return to its own
constraint: the erased assertion stays green and only the instantiated one
reddens.

Other matcher limits:

- A *type-parameter* constraint reds in type position: `// @ts-expect-error` +
  `expectTypeOf<ReturnType<typeof create<"nope">>>()`. Zero-runtime, and an
  unused directive is `TS2578`, so it reds if the rejection stops working
  rather than passing silently. A *parameter-value* constraint that exists to
  reject (`initialState: T & { on?: never }`) instead needs a real
  `@ts-expect-error`ed call site, e.g. `store({ on: 1 })`:
  `.not.toBeCallableWith` types as `never`, `toBeCallableWith` cannot be
  negated at all, and its own doc says it will likely fail on generics. Either
  way, a directive reds when the rejection it covers breaks — but a directive
  placed on a *positive* assertion silently absorbs a different, unrelated
  failure instead. When the cause is tooling rather than the code, pin it
  positively (`expectTypeOf(fn).returns.toBeAny()`) so it reddens — prompting
  removal — once the tooling improves, rather than masking it with
  `@ts-expect-error`.
- `toExtend` compares methods bivariantly, so it still passes when a method
  parameter narrows. Use `Pick<C, …>` + `toEqualTypeOf` when parameter types
  are the contract.
- Neither `toEqualTypeOf` nor `toMatchObjectType` can equate a *deferred* mapped
  type with a written object literal. Pin `keyof T` separately and use
  `toExtend` for the values.
- `toEqualTypeOf` rejects an intersection against its equivalent flattened
  object (`{a:1}&{b:2}` vs `{a:1;b:2}`). `.branded.toEqualTypeOf` is the
  permissive check — upstream flags it as slow and prone to making tsc give
  up, so use it sparingly.
- A type that is not exported cannot be named on the right-hand side of an
  assertion. Pin it against a known supertype with `toExtend`, or invert the
  direction: `expectTypeOf<[number]>().toExtend<Parameters<typeof fn>>()`.
- `expectTypeOf(C.prototype.method)` and `expectTypeOf(C.staticMethod)` trip
  oxlint's `typescript/unbound-method`; wrap the block in
  `oxlint-disable`/`oxlint-enable`. `C.prototype[Symbol.dispose]` does not
  trip it.
- **`toMatchObjectType` does not narrow against a class** — given three of a
  class's members it demanded all nine (`TS2740`). Use
  `expectTypeOf<Pick<C, "a" | "b">>().toEqualTypeOf<…>()` — homomorphic, so it
  carries `readonly` through, which is how you pin a get-only accessor as
  read-only. `expectTypeOf<C["a"]>()` cannot say that.
- **`not.toBeConstructibleWith` types as `never`.** To pin a private
  constructor use `not.toExtend<new (...args: never[]) => C>()`: tsc will not
  assign a private constructor type to a public one, and the bottom function
  type keeps it about privacy rather than the constructor's parameters. Prefer
  it to a `@ts-expect-error`ed `new C()`, which is not zero-runtime.
- An expected optional parameter entry needs **both** `?:` and `| undefined`
  under `exactOptionalPropertyTypes`; dropping either fails as an unrelated
  `TS2554`.
