---
name: session-mesh
description: Run a long multi-session project as an orchestrator (OS) coordinating implementation (IS) and reviewer (RS) sessions. Use when work spans days, repos, or more sessions than one context can hold. Triggers on "orchestrator", "OS session", "IS session", "RS session", "session mesh", "dispatch a prompt", or picking up a workstream with an ORCHESTRATOR_RELAY / ANCHOR file. Defines the three roles, the digest rule, prompt persistence, running lists, and the gate before anything irreversible.
---

# Session mesh

A long project outlives any single context. This is how the pieces stay coherent when they can't all
be in one window.

Three roles. **OS** orchestrates, holds cross-domain context, writes every prompt. **IS** implements
one scoped thing. **RS** attacks a conclusion before it becomes irreversible.

The load-bearing asymmetry: **only the OS can write a good prompt**, because a prompt is correct only
if it carries what was learned in other sessions. Everything else can be delegated. So the OS budget
is spent on holding context and dispatching, and never on reading raw artifacts.

---

## Read only your role

**If you were told to operate as an IS or an RS, read §0 and stop. The rest is orchestrator material
and you do not need it.**

### §0 — The standing contract for IS and RS sessions

You were pointed at a prompt file. **Read it. It is self-contained and authoritative.** These
obligations apply on top of it and are not restated in every prompt:

1. **Honour the scope fence.** The prompt names what is out of scope. If your work appears to require
   something fenced off, **stop and report rather than widening.** Adjacent work is someone else's
   lane, and two sessions editing the same surface is the most expensive failure in this pattern.
2. **Stage only files you created or edited.** Never `git add -A`. Other lanes share the tree, and
   changes you did not make are not a problem to solve.
3. **Verify, do not assume.** Run the numbers rather than quoting them. Prove behaviour rather than
   reasoning about it where a proof is available. A claim backed by an execution is worth ten backed by
   reading.
4. **Report what is wrong in the brief.** Every prompt asks for this and it is not politeness. The
   author holds cross-session context and less of the code than you do, so they are confidently wrong
   in ways only you can see. **This has caught something in every session this pattern has run.** If
   you find nothing, say so explicitly.
5. **Persist your report** to `session-summaries/<same-number-and-slug>-summary.md` before the session
   closes, in your own words, including item 4. A finding that exists only in a closed terminal gets
   rediscovered the expensive way.

**RS only:** you write nothing. Read, reason, attack. Assume the conclusion you were given is wrong and
find where. The people who produced it were competent and had less context than you have now.

---

## Invoking a session

Point at the prompt file; do not paste it. Pasting truncates, drifts from the artifact, and cannot be
re-run.

```
Load the session-mesh skill and operate as an IS.
Prompt: <path>/prompts/012-model-fixes-independent.md
```

Two lines. The session reads its own prompt, so the artifact stays the single source and a re-run is
trivial. Set model and effort from the prompt's header block before starting.

**Continuation on the same thread**, when the session is still open and holds relevant context:

```
Prompt: <path>/prompts/012a-<slug>.md
```

Nothing else needed. It already has the contract.

**Choosing continue-versus-fresh.** Continue when the session's warm context is the asset: follow-ups to
its own findings, or work that builds directly on what it just proved. Go fresh when its premises have
changed underneath it, because a compacted session with a stale premise is how bad work gets built
confidently. **When in doubt, go fresh and let the prompt carry the context.** That is what prompts are
for.

---

## 1. The digest rule

**The OS does not read large artifacts. It reads deltas.**

Context is spent on ingestion, not thinking, and ingestion is the one thing that delegates cleanly.

> **Any artifact over ~150 lines goes to a subagent with an explicit known-facts list. The subagent
> returns only what is new, what contradicts, and what corrects.**

The brief to a digest subagent always contains:

1. **What I already know**, listed concretely. Commits, counts, findings, decisions. This is the whole
   trick: without it the subagent re-reports the thing you sent it to avoid reading.
2. **Report only**: new findings, contradictions between sources, corrections to my stated beliefs, and
   any number or identifier not in the known list.
3. **A word limit.** 400–500. A digest that needs more is two digests.
4. `Do not summarise what the document does. Cite file:line.`

**The one exception: read the decision artifact yourself.** If a document is the thing you will steer
on, its reasoning matters as much as its conclusions and a digest flattens that. Digest the other
eight; read the one.

Run digests in parallel. Fan out on independent dimensions, not on document order.

## 2. Prompts

**Every prompt is written by the OS and persisted before it is fired.**

```
<workstream>/prompts/NNN-slug.md              the original prompt for a thread
<workstream>/prompts/NNNa-slug.md             first follow-up on that thread
<workstream>/prompts/NNNb-slug.md             second, and so on
<workstream>/prompts/session-summaries/NNN-slug-summary.md
<workstream>/prompts/README.md                naming convention + live state table
```

**The number is the thread; the letter is the iteration.** Never renumber. A low number does not mean
an old prompt. If a thread turns out to be two threads, give the second a new number and
cross-reference.

**The letter tracks deliverables, not just prompts.** When one prompt yields several separately
delivered reports, each takes the next letter: a `NNNa` prompt that returns three reports produces
`NNNa`, `NNNb`, `NNNc` summaries. Keep them as discrete artifacts rather than appending, so each can be
cited and superseded on its own. A summary with no matching prompt file is fine and expected.

**Every prompt is fully self-contained.** A follow-up restates what it needs rather than saying "as
discussed in 003." Sessions get compacted; a prompt that only works if you read its predecessor stops
working the moment context is lost.

Header block above the prompt body, so the dispatcher does not have to guess:

```
Target: IS | RS | digest
Model:  <model> · Effort: <level>
Repos:  <what must be in scope>
Reads:  <artifacts it must load first>
```

Every prompt ends with two things:

- **A scope fence.** Name what is explicitly out of scope and say _stop and report rather than widen_.
  Sessions are helpful by default and will absorb adjacent work.

  **Then check the fence against the task before you send it.** A fence that forbids something the task
  requires is worse than no fence: a good session honours it and ships something incomplete, and a
  session that overrides it has learned your fences are advisory. Both outcomes are worse than having
  written it correctly.

  This has a reliable smell. **If the task adds a member to a closed set** — an enum with an exhaustive
  switch, a discriminated union, a registry with a `default:` that throws — **then the fence almost
  certainly has to carve out whatever consumes that set.** Same for any change that must be visible at a
  boundary you fenced off. When you know an exception exists, state it inline rather than trusting the
  session to spot the contradiction.

- **"Tell me what is wrong in this brief."** Not politeness. This is the highest-signal mechanism in
  the whole pattern, and it works because the OS is confidently wrong in ways only someone holding the
  code can see.

### Intent may be delegated. Mechanism must be verified.

**Before a prompt asserts a mechanism, the OS reads that specific thing.** Not the file, not the
subsystem — the signature, the reference direction, the exception type, the line number.

| Kind of claim                                      | Example                                                                      | OS obligation               |
| -------------------------------------------------- | ---------------------------------------------------------------------------- | --------------------------- |
| **Intent** — what should be true when this is done | "wire converge into the promotion path so a role change writes tuples"       | none. The IS works out how  |
| **Mechanism** — how the code is shaped             | "take it as `IFoo?`", "catch `BarException`", "the entry point is at `:265`" | **read it first.** One grep |

This is not a context-budget question. It is cheap, it is a handful of greps, and it is orthogonal to
how long the session runs. The failure it prevents is asserting a mechanism from a summary, from an
earlier session's report, or from memory of how the code used to look.

**Two symptoms that you are about to do it:** you are writing a type name you have not seen today, or
you are specifying an interaction between two files you have not opened. Both are cheap to check and
expensive to get wrong, because an IS following a confident wrong instruction produces a confident
wrong implementation.

**When you get one wrong, the IS's pushback is the deliverable.** Record it in the summary as a
correction rather than quietly adopting their version, so the next prompt on that thread inherits the
right shape. The standing "tell me what is wrong in this brief" line exists for exactly this and it
earns its place; a mechanism error caught costs one round trip, and the same error shipped costs a
debugging session with nothing pointing at the cause.

## 3. Session summaries

**Persist every session's own report before closing it.** Same number and slug, plus `-summary`.

Capture the session's own words, not a paraphrase, and always include what it said was wrong in the
brief. A finding that exists only in a closed terminal is a finding that gets rediscovered the
expensive way, usually by hitting the same wall.

**After each IS lands, the OS writes one paragraph into the running state** saying what changed for the
project, not what the session did. The summary is the record; the paragraph is what the next OS reads
first.

## 4. The two context files, and why they are two

This split is the thing that survives contact with a long project.

| File        | Holds                                                                                                                                 | Rewrite cadence                                                |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| `ANCHOR.md` | **Understanding.** The mental model, governing decisions, facts that get re-derived wrong, the correction ledger, standing guardrails | Rarely. Append when something is learned, not when state moves |
| `RELAY.md`  | **State.** What is live, which sessions are open, what is next, current environment values                                            | Whenever state moves materially. Archive the old one           |

**Every other document points at the anchor in its first line.** State goes stale in a day;
understanding does not. Mixing them produces a document nobody trusts, because the reader cannot tell
which half has expired.

**Archive relays, never edit them in place.** `relays/RELAY_<date>.md`. A superseded relay says so at
the top, in full, so nobody splices two generations of state.

**The correction ledger is the highest-value section of the anchor.** Every belief that was held, acted
on, and turned out wrong. Not findings — _beliefs_. Without it the same wrong assumption returns every
few sessions, and it returns with confidence because it is written down somewhere older.

## 5. Running lists

Long projects accumulate faster than they resolve. One list per group of related work, indexed, with
progressive disclosure so the index is readable and the depth is one click away.

```
<workstream>/to-address/README.md         index: what each list holds, who acts
<workstream>/to-address/<group>.md        one list per coherent group
```

Rules that keep them useful:

- **Add the moment something surfaces**, not at write-up time.
- **One row, one `file:line`.** A finding without a location is a rumour.
- **Status per row**: `open` · `claimed:<name>` · `done:<sha>`.
- **Never delete a done row.** Strike it. The record of what was fixed and when is the point.
- **Mark wrong items `withdrawn` with a reason** rather than removing them. Withdrawals stop a wrong
  finding coming back.
- **Severity-bearing findings live in a findings file; work items live here.** When a work item turns
  out to be exploitable, move it.

## 6. The RS gate

**Before anything irreversible, one session's only job is to break the reasoning.**

Irreversible means: a schema or model publish, a bulk data write, a production cutover, a deletion, or
a message that goes outside the team. Not every prompt. Four or five moments in a project.

The RS gets the conclusion, the evidence, the correction ledger, and this instruction:

> Assume this is wrong. Find where. The people who produced it were competent and had less context than
> you have now.

An RS earns its place because near-misses in this pattern are almost always **OS errors**, and they get
caught incidentally, by an IS that happened to be asked. The RS catches them on purpose.

Give it the repos the original work could not see. A reviewer with the half of the system the author
lacked finds things nobody else can.

## 7. Roles

**OS.** Holds cross-domain context. Writes every prompt. Runs read-only investigation, queries and
proofs directly. Maintains the anchor, the relay and the lists. **Does not write feature code.** If it
starts implementing, the context it exists to hold is being spent on something delegable.

**IS.** One scoped thing, one repo where possible. Implements, verifies, reports. Stages only files it
created or edited, because other lanes share the tree. Reports what was wrong in its brief. Persists
its summary.

**RS.** Reads, reasons, attacks. **Writes nothing.** Reports where the reasoning fails and what would
have to be true for it to hold.

**Digest subagent.** Reads one large thing, returns the delta. Parallel by default.

## 8. Dispatch checklist

1. Is this prompt-shaped, or am I about to implement? If implementing, stop and write the prompt.
2. Does the prompt carry what other sessions learned? That is the only reason the OS writes it.
3. Scope fence named, with _stop and report rather than widen_.
4. Model and effort in the header.
5. Ends with "tell me what is wrong in this brief."
6. Persisted before firing.
7. On return: digest if large, persist the summary, write one paragraph into the relay, update the
   lists.

## 9. Failure modes this exists to prevent

| Symptom                                  | Cause                                        | Fix                                         |
| ---------------------------------------- | -------------------------------------------- | ------------------------------------------- |
| A finding gets rediscovered weeks later  | Session closed without its summary persisted | §3                                          |
| A session builds on a false premise      | Brief asserted something unverified          | Scope fence + "what is wrong in this brief" |
| The OS runs out of context mid-project   | Reading artifacts instead of digesting them  | §1                                          |
| Two sessions produce conflicting work    | No scope fence, shared tree, `git add -A`    | §2, stage by path                           |
| A stale document drives a wrong decision | State and understanding in one file          | §4                                          |
| The same wrong belief returns            | No correction ledger                         | §4                                          |
| Something irreversible ships broken      | No adversarial pass                          | §6                                          |
| A prompt only makes sense to its author  | Not self-contained                           | §2                                          |
