---
name: deslop-doc
description: Use when reviewing, tightening, shortening, rewriting, or drafting professional decision-carrying documents for a specific reader, especially when text is too long, unscannable, repetitive, vague, detail-heavy, inaccessible, or AI-sounding.
---

# Deslop-Doc: Reader-First Document Review

Review every document against one specific reader. Put the answer first, place
abstraction above detail, and remove only material that neither changes the
reader's action nor preserves the record's integrity.

## Step 0 — Acquire the reader model (blocking)

Do not start reviewing without it; without a reader, "too much detail" and
"too vague" are both unanswerable. Establish four fields:

- **Codebook** — which compressed phrases this reader can decompress unaided
  ("operational simplicity", "single-writer invariant"). Sets the abstraction
  ceiling.
- **Given set** — specific context already loaded: prior decisions, meetings
  attended, running arguments, team jargon. Treat it as a deletion candidate,
  not permission to erase context needed for auditability, handoff, or future
  readers.
- **Next action** — what the reader does after reading (approve, implement,
  escalate). Prioritize whatever changes that action.
- **Budget** — linear read or scan-and-descend? Hard length cap?

Extract these from the conversation if present; otherwise ask **one** short
question that confirms all four fields:

> I'll optimize this for [reader], who knows [terms and prior context], needs to
> [next action], and will [scan/read] within [budget] — correct?

If the user cannot answer, state conservative defaults: assume only the supplied
text is known, define nonstandard jargon, preserve durable decision context, and
optimize for scan-and-descend without a hard length cap. For mixed audiences,
pick the primary reader and serve the secondary with the fold (operation 5).

## The core rule

**Write at the highest abstraction level the reader can still decompress.**
Details belong beneath the line that summarizes them. Compression must preserve
facts, numbers, scope, uncertainty, modality, attribution, ownership,
constraints, approvals, and dependency relationships.

## Five operations, in this order

Order matters: positioning first exposes what the abstractions must be;
abstraction creates the layer that makes deletion safe.

1. **Position.** Put the one-breath answer — the decision, finding, or ask —
   in the first sentence under the title. If the writer can't state it in one
   breath, that's a thinking problem surfaced by the review, not a style
   problem; say so.
2. **Abstract.** Cluster the details, and for each cluster ask: can *this*
   reader decompress a one-line summary of it? If yes, write the line and
   demote the details beneath it (or cut them). If no, the details are
   load-bearing — keep them under a lead line.
3. **Deduplicate.** Enforce the given-new contract per sentence: each sentence
   must add something not already established by the document or the reader's
   given set. Before deleting known context, check whether it is needed for
   correctness, auditability, handoff, or readers who will use the document
   later.
4. **Surface gates.** Any open question that blocks the reader's next action
   (an unmade decision, a pending dependency, "needs sign-off from X") moves
   to the top layer. A buried gate is the worst failure available: the reader
   finishes the document not knowing they can't act on it.
5. **Mark the fold.** Where the document shifts audience — decision layer for
   approvers, mechanics for implementers — use a structural heading such as
   `Implementation details (optional)` so the primary reader knows where to
   stop.

## Verification — run all three

Run these checks exactly. Do not replace them with an imagined, simulated, or
delegated reader-memory test. A verification report must name Reconstruction,
Fidelity, and Restatement; omitting any one makes the review incomplete.

1. **Reconstruction test.** Extract the title, opening sentence, section leads,
   and bolded lines into an outline. From that outline alone, write the outcome
   in one sentence and list the detail sections it predicts. Compare the list
   with the full rewrite; move unpredicted load-bearing details under a suitable
   lead.
2. **Fidelity test.** Compare the source and rewrite for facts, numbers, scope,
   uncertainty, modality, attribution, ownership, constraints, approvals,
   gates, and dependencies. Restore any material change or omission.
3. **Restatement scan.** Flag sentences that add no decision-relevant or
   record-preserving information beyond established content. More than two
   usually indicates systematic bloat.

## AI-genre tells to hunt

| Pattern | Correction |
|---|---|
| Flat weighting | Emphasize the decision; demote caveats beneath it. |
| Constraints under a `Decision` heading | State one decision first; move constraints to consequences or non-goals. |
| Re-summary before each section | Delete it. |
| Every consideration included, none chosen | Make the call or surface the unresolved gate. |
| Symmetric, equally padded bullets | Let items be unequal; remove padding. |
| Throat-clearing opener | Start with the answer. |
| Concision removes a qualifier or approval | Restore it; fidelity outranks brevity. |

## Output format

Lead with the verdict in one sentence. Rank findings by impact on the reader's
next action, not document order. Point to the exact text and give a one-line fix
where possible. Rewrite only when asked or when the structure is beyond
patching. Apply the fidelity test to every rewrite.

## When drafting instead of reviewing

Establish the reader model first, then apply operations 1–5 to an outline before
adding detail. Run all three verification tests before delivery.
