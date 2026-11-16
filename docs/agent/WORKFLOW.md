# NEO-OS GitHub Development & Learning Workflow

## Mandatory delivery sequence
1. **Inspect:** repository state, relevant AGENT.md documents, PRD, ADRs, open issues and existing branches.
2. **Issue:** create or select a GitHub issue with the problem, requirements, architecture/phase, task scope and measurable acceptance criteria. Assign labels/milestones when configured.
3. **Branch:** create a descriptive branch from up-to-date `master`: `feat/<issue>-<slug>`, `fix/<issue>-<slug>`, `docs/<issue>-<slug>`, or `test/<issue>-<slug>`.
4. **Plan:** identify touched files, concepts, security risks, validation steps and expected behavior.
5. **Implement:** commit focused changes to the feature branch, not directly to `master`.
6. **Test:** run appropriate tests/static checks and record exact commands and results. A screenshot is UI evidence, not proof of all behavior. Explicitly distinguish passed, failed, and not run.
7. **Pull request:** open a PR targeting `master`. Link the issue with `Closes #N` only if the PR fully resolves it. Fill the PR template; summarize diff, acceptance criteria, security, tests, rollback and teaching concepts.
8. **Review:** inspect diff and CI/check status, address findings, obtain independent review if required by repository policy. Never invent approval or test outcomes. If checks or reviewer cannot be verified, say so and leave PR pending when their completion is required.
9. **Merge:** once the acceptance gate is satisfied, use the repo's permitted merge policy and verify the merged head. Do not force merge or bypass required checks. Close/verify the linked issue; if still open, explain why.
10. **Handoff & teach:** report the issue, branch, PR, commit, outcome and remaining work. Provide a clear explanation of concepts, file-level changes, code/data flow, tests, trade-offs, reproduction instructions, and short exercises to assess the user's understanding.

## Implementation lesson structure
- **Objective and observed problem** — what user-visible/system behavior changed.
- **Concept lesson** — explain relevant programming, OS and workflow fundamentals with minimal but concrete examples.
- **Architecture/code walkthrough** — paths, responsibilities, data flow and important functions.
- **Verification** — commands, expected vs observed results, environmental limitations.
- **Risks and next work** — security, failure modes, rollback and pending tests.
- **Knowledge check** — 1–3 targeted questions or an exercise based on the code just changed.

## Completion policy
An implementation is complete only with merged code, validated acceptance criteria, updated project status and an evidence-based teaching handoff. A proposed PR is progress, not a completed milestone. Avoid changing existing state outside the issue's scope.
