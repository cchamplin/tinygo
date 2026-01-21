# Issue 4277 Analysis Prompt Design

**Goal:** Provide a clear, actionable prompt that guides an agent to research TinyGo issue #4277, including current implementation, prior art, and evidence needed to build a red/green TDD plan.

**Scope:**
- Target: `reflect.Type.AssignableTo()` interface handling in TinyGo.
- Inputs: Issue #4277, TinyGo source, upstream Go reflect behavior, related issues/PRs, and any external repros (e.g., fxamacker/cbor).
- Output: Research summary + a checklist of facts to support a comprehensive TDD plan.

**Prompt structure:**
1. **Context**: Link the issue, state observed panic, and describe expected behavior.
2. **Codebase survey**: Point to relevant files and functions in TinyGo and reflectlite.
3. **Prior art**: Instruct to search TinyGo history, issues, and upstream Go implementation.
4. **Repro guidance**: Note external repro (fxamacker/cbor) and local minimal repro.
5. **Iteration workflow**: Include rebuild steps and how to use the different TinyGo binaries.
6. **Deliverables**: Provide a concise research report + a set of test cases to drive a red/green plan.

**Prompt text (ready to send):**

```
You are investigating TinyGo issue #4277: https://github.com/tinygo-org/tinygo/issues/4277

Goal: Before designing a fix, produce a research summary of the current behavior, any relevant prior art, and constraints. Then outline the evidence needed to build a comprehensive red/green TDD plan to implement interface support in reflect.Type.AssignableTo.

What to research and report:
1) Issue context
   - Summarize the issue description, including the observed panic path and the requested behavior.
   - Note any external repros mentioned (fxamacker/cbor) and links to prior discussion.

2) Current implementation (TinyGo)
   - Inspect: src/reflect/type.go (rawType.AssignableTo), src/internal/reflectlite/type.go (RawType.AssignableTo), and any callsites in src/internal/reflectlite/value.go.
   - Identify exact conditions that return true vs. panic for interfaces.
   - Note any existing tests in src/reflect/value_test.go related to AssignableTo.

3) Upstream Go reference behavior
   - Compare TinyGo’s AssignableTo behavior to Go’s standard library reflect implementation and/or Go spec expectations.
   - Identify how Go handles assignability to interfaces (including non-empty interfaces).

4) Prior art in TinyGo
   - Search TinyGo issues/PRs/commits for similar interface/reflect assignability work.
   - Note any related limitations or TODOs.

5) Proposed test cases (for TDD plan)
   - Enumerate minimal and edge cases: empty interface, non-empty interface, named vs unnamed types, identical types, underlying type matches, pointer vs value receiver cases, etc.
   - Include at least one external repro (fxamacker/cbor or a minimal equivalent) if possible.

Iteration workflow (use this repo’s rebuild script and multiple TinyGo binaries):
- Rebuild dev environment:
  - ./scripts/rebuild-dev.sh
  - This builds build/tinygo, build/wasm-opt, and a native bundle in build/release-native/tinygo.
- Use different TinyGo binaries for iteration:
  - Source build: ./build/tinygo
  - Native bundle: build/release-native/tinygo/bin/tinygo
  - Installed release (armhf via qemu in this container): /home/vscode/.local/bin/tinygo
- When testing changes, prefer ./build/tinygo or the native bundle to avoid qemu overhead.

Deliverables:
- A short research summary (bulleted): issue context, current TinyGo behavior, upstream behavior, prior art.
- A list of concrete test cases that should be included in a red/green TDD plan.
- Any constraints or risks that should be considered before implementation.
```
