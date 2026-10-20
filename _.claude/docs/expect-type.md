# Type tests with `expectTypeOf`

Type-test public type contracts, inference, and rejected inputs, alongside runtime tests; neither replaces the other. Only the typecheck (`tsc --noEmit`, e.g. `bun run lint:ts`) checks them: `bun test` runs them as no-ops, so make sure the tsconfig includes the test files. Examples use stage1's APIs.

## Structure
- One `types` test per `describe` is the exception to one behaviour per test: tsc reports every failing assertion separately. Type assertions inside a runtime test don't count toward its `expect.assertions(n)`.
- Check functions through `.parameters` and `.returns`, specializing with instantiation expressions (`fn<Concrete>`); use `expectTypeOf<Type>()` for aliases, indexed access, and utility types.
- Open with `not.toBeAny()` and `toBeFunction()`, and guard extracted returns with `not.toBeAny()` and `not.toBeNever()`. Equality already rejects both, but the guards name the cause, and `toExtend` would accept `any`. They can't see a nested `any` such as `Row<any>`.

## Matchers
- `toEqualTypeOf` pins the whole contract: keep related fields in one check, and preserve readonly, optional entries, intersections, deferred `T[K]`, and nested generics. Never simplify an expected type, or switch matchers, because it's hard to write.
- `toExtend` checks assignability: extra properties, narrower types, and narrowed method parameters (bivariance) all pass, so it never proves equality.
- `toMatchObjectType` strictly checks a chosen subset, but only of object-literal types; interfaces and class instances are compared whole. Pin their subset with `expectTypeOf<Pick<T, "a" | "b">>().toEqualTypeOf<…>()`, since `Pick` keeps `readonly` (including get-only accessors), which `T["a"]` loses.
- `toBeVoid()` also accepts `undefined`, so pair it with `not.toBeUndefined()`.
- Under `exactOptionalPropertyTypes`, optional parameters need `?:` and `| undefined`: `[options?: CompileOptions | undefined]`.
- An exported alias is code under test: equality with it proves the API uses it, not what it is. Pin its shape structurally too, or test it once on its own, and check public re-exports separately:

```ts
expectTypeOf(compileNoMacro).returns.toEqualTypeOf<CompileResult<Refs>>();
expectTypeOf(compileNoMacro).returns.toEqualTypeOf<{
  html: string;
  k: readonly string[];
  d: readonly number[] & InferRefs<Refs>;
  ref: Readonly<Record<string, `@${string}`>>;
  success: boolean;
}>();
```

- The same goes for an unexported type named through its consumer (`type View = Parameters<typeof collect>[1]`): add a structural check such as `.parameters.toExtend<[root: Node, view: Node]>()`, and test producer–consumer compatibility.

## Generics and inference
Extraction (`.parameters`, `.returns`, `ReturnType<typeof fn>`) erases type parameters to their constraints, or `unknown`; defaults apply only at call sites. Check the extracted contract, the default or inferred call result, and an explicit specialization, where each matters:

```ts
test("types", () => {
  expect.assertions(0);
  expectTypeOf(h).not.toBeAny();
  expectTypeOf(h).toBeFunction();
  expectTypeOf(h).parameters.toEqualTypeOf<[html: string]>();
  expectTypeOf(h).returns.not.toBeAny();
  expectTypeOf(h).returns.not.toBeNever();
  // Extraction uses the Node constraint; calls use the Element default.
  expectTypeOf(h).returns.toEqualTypeOf<ChildNode & Node>();
  expectTypeOf(h("<div></div>")).toEqualTypeOf<ChildNode & Element>();
  expectTypeOf(h<HTMLDivElement>).returns.toEqualTypeOf<ChildNode & HTMLDivElement>();
});
```

Specialization doesn't prove contextual inference. Assert unannotated callback parameters, and give properties distinct types so an accidental union shows:

```ts
const key = Symbol();
const state = store({ count: 0, label: "", [key]: true });
state.on("count", (value, prev) => {
  expectTypeOf(value).toEqualTypeOf<number>();
  expectTypeOf(prev).toEqualTypeOf<number>();
});
state.on(key, (value) => {
  expectTypeOf(value).toEqualTypeOf<boolean>();
});
// @ts-expect-error - unknown state key
state.on("missing", () => {});
// @ts-expect-error - count handlers receive numbers
state.on("count", (_value: string) => {});
```

Test inference across producer and consumer APIs inside a typed, never-invoked callback, so tsc checks real calls without fabricated data or execution:

```ts
interface FooBar {
  foo: HTMLDivElement;
  bar: Text;
}
expectTypeOf((meta: CompileResult<FooBar>) => {
  expectTypeOf(collect(document, meta.k, meta.d)).toEqualTypeOf<FooBar>();
  expectTypeOf(collect<{ foo: Node }>(document, meta.k, meta.d)).toEqualTypeOf<{ foo: Node }>();
  // @ts-expect-error - metadata does not contain baz
  collect<FooBar & { baz: Comment }>(document, meta.k, meta.d);
}).toBeFunction();
```

- Use interfaces as type arguments: they lack implicit index signatures, so they catch constraints that only object-literal types satisfy.
- Add focused regressions for key order and large mapped types; a small happy-path specialization won't catch them.

## Rejections and execution
- Reject invalid inputs with `@ts-expect-error - <reason>` on the narrowest line, so an unrelated error can't satisfy it; never `@ts-ignore`, which can't fail. An unused directive (TS2578) means the rejection stopped working.
- Check generic constraints by instantiation (`expectTypeOf(collect<{ foo: string }>)`), and parameter-value constraints with a call inside a never-invoked callback.
- Never suppress a failing positive assertion; characterize the limitation positively, then pin the concrete contract. Erasure turns `reconcileKeyed`'s `keyof T` into `never` and its extracted return into `any`, so its test asserts `.returns.toBeAny()` (labelled characterization) and pins item, node, and `void` return types on an instantiated signature.
- Matcher arguments execute; type arguments don't. `expectTypeOf(fn())` calls `fn`. `expectTypeOf(fn<Concrete>)` and `expectTypeOf(() => fn()).returns` don't; the latter also selects an overload or applies a generic default.
- Prove a suspicious assertion with a type mutation (widen a generic return to its constraint, break a key-specific callback type, drop a promised `readonly`), then run the typecheck.

## Tool limits
Checked on Bun 1.4.4 with TypeScript 6.0.3 and 7.0.2. On other versions, re-verify a limit before relying on it: read the vendored declarations (`bun-types/vendor/expect-type/`) and probe the runtime in Bun.

- Properties chain: `parameters`, `returns`, `items`, `branded`, `constructorParameters`, `thisParameter`, `instance`, `resolves`, `guards`, and `asserts`; so does `.map()`, whose callback never runs.
- These methods return `undefined` at runtime, so never chain them: `parameter`, `pick`, `omit`, `extract`, `exclude`, `toHaveProperty`, `toBeCallableWith`, `toBeConstructibleWith`. Use indexed access or utility types instead: `expectTypeOf<Result["ref"]>()`, `expectTypeOf<Pick<Result, "ref">>()`.
- `toBeCallableWith` checks the erased signature, so it can't infer a generic's type parameters from the arguments: call it on an instantiation, or test the real call in a never-invoked callback. Negated `toBeCallableWith` and `toBeConstructibleWith` are typed `never`; use `@ts-expect-error`.
- `.parameters`, `.returns`, and `.constructorParameters` union all overloads; `Parameters` and `ReturnType` take the last. A `never` return vanishes from the union, so check individual calls where it matters.
- Equality is representation-sensitive: `{ a: 1 } & { b: 2 }` doesn't equal `{ a: 1; b: 2 }`. Keep the intersection; use `.branded.toEqualTypeOf` only when structural equivalence is the contract, since it's slow and gives up on deeply nested types.

## Classes
- A generic class's prototype instantiates its parameters as `any`, so `expectTypeOf(C.prototype.method).returns.not.toBeAny()` passes on `Row<any>`. Use `expectTypeOf<C<Concrete>["method"]>()`, which also avoids unbound-method lint suppressions.
- Assert a private constructor with `expectTypeOf(C).not.toExtend<new (...args: never[]) => C>()`: it fails for a public constructor and never runs `new C()`.
