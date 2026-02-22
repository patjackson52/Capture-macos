# Release governance checklist (macOS)

Use this checklist before promoting any candidate to broad external distribution.

## 1) Approval gates

- [ ] Engineering owner approves release candidate commit/tag
- [ ] QA sign-off completed on supported macOS versions/hardware
- [ ] Product/release manager approval captured (ticket/change record)
- [ ] Security/privacy review completed for permission or data-path changes
- [ ] Branch protection + required checks passing on merge commit

## 2) Staged rollout plan

- [ ] Start with limited/direct audience (internal + trusted testers)
- [ ] Validate crash-free usage and primary workflows
- [ ] Expand distribution in controlled batches
- [ ] Monitor crash/error/performance regression metrics per stage
- [ ] Pause expansion on threshold breach

## 3) Rollback triggers

Trigger rollback or halt if any occur:

- [ ] Gatekeeper/notarization failures in clean-host verification
- [ ] P0/P1 defect in core workflow
- [ ] Security/privacy incident or credential compromise suspicion
- [ ] Install/launch failure rate above baseline
- [ ] Backend/API incompatibility causing broad impact

## 4) Rollback actions

- [ ] Stop further distribution immediately
- [ ] Remove affected binary/download links and replace with last known good
- [ ] Notify stakeholders and support channels
- [ ] Open corrective-action issue with owner + due date
- [ ] Record root cause + prevention updates in runbook
