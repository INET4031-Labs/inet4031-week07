# Sprint 4 Retrospective

**Written by:** Scrum Master at sprint close

**Purpose:** Reflect on what went well, what could improve, and what changes to make for Sprint 5.

---

## Sprint 4 Overview

**Sprint:** 4 (Weeks 7-8)
**Scrum Master:** [Enter your name]
**Sprint Close Date:** [YYYY-MM-DD]

This sprint covered two weeks: Week 7 (security controls and CI pipeline) and Week 8 (backup pipeline and recovery verification).

---

## What Went Well

[TODO: For each area below, describe what your team executed smoothly:]

### Communication and Coordination

- How effectively did the team communicate during the async week?
- Were blockers identified and resolved quickly?
- Did all roles understand their responsibilities?

### Technical Implementation

- Which parts of Week 7 and Week 8 went faster than expected?
- Were there any technical breakthroughs or clever solutions?
- Did the team complete the work on or ahead of schedule?

### Process and Sprints

- Did the sprint board stay current throughout the week?
- Were standup check-ins helpful or burdensome?
- Did the team follow the sprint structure from the lab directions?

---

## What Did Not Go Well

[TODO: For each area where the team faced challenges, describe the situation and root cause:]

### Communication and Coordination

- Were there miscommunications between roles?
- Did any team member feel unclear about what was expected?
- Were there decisions that needed to be made but were delayed?

### Technical Challenges

- Which parts of Week 7 or Week 8 took longer than expected?
- Were there failed attempts or rework cycles?
- Did the environment behave unexpectedly?

### Process Issues

- Did the sprint board fall behind?
- Were there tasks that were not assigned or claimed?
- Did the check-in schedule work for your team, or was it too frequent/infrequent?

---

## Specific Metrics from Sprint 4

[TODO: Use these questions to reflect on measurable outcomes:]

- How many GitHub issues were opened? How many closed?
- How many commits were made? What was the distribution across team members?
- How many pull request reviews happened? Were they timely?
- Did Week 8's recovery drill succeed on the first attempt? If not, how many iterations?
- What was the measured RTO in the recovery drill? Did it match expectations?

---

## One Process Change for Sprint 5

[TODO: Choose ONE thing the team will do differently in Sprint 5. Make it specific and actionable.]

Current approach (Sprint 4): [Describe what you did this sprint]

Proposed change (Sprint 5): [What will you do differently?]

Rationale: [Why do you expect this change to improve the sprint?]

How to measure success: [What will you look for to know if this change worked?]

---

## Role-Specific Reflections

### Scrum Master

- Did the sprint board stay current and reflect actual progress?
- Were roles clear and understood from the beginning?
- What would make the next sprint board more useful?

### System Admin

- Was the environment stable throughout the sprint?
- Did any infrastructure decisions prove wise or problematic in retrospect?
- What monitoring or documentation would have helped?

### QA

- Were acceptance criteria clear and useful during development?
- Did the check script catch all the issues it was meant to catch?
- What acceptance criteria were hard to verify? How would you improve them?

### Developer(s)

- What was the hardest part of implementing Week 7 and Week 8?
- Were there any design decisions you would reconsider?
- Did code review feedback help? Was there enough review, or too much?

---

## Questions for the Team to Discuss

[TODO: Answer these as a group in a sync meeting or async in the team channel:]

1. Week 8 required a recovery drill. Did you find that hands-on practice valuable, or was it stressful? Why?
2. The backup pipeline runs automatically on GitHub Actions. Did this feel like "real" infrastructure work, or did it feel less tangible than Week 7's security controls? Why?
3. Looking back at Week 7 and Week 8 together, which was harder: securing the application, or building the backup pipeline? What made it harder?
4. If a data loss happened in production tomorrow, how confident is the team in the recovery procedure? Would anything in the runbook need to change based on what you learned?

---

## Sprint Close Checklist

Before submitting the retrospective, verify:

- [ ] Scrum Master has closed all Sprint 4 issues on the board
- [ ] All Sprint 4 work is committed to the repository
- [ ] Environment log reflects the final state of the infrastructure
- [ ] QA report is complete with check script results
- [ ] Google Doc has been updated with all reflection question answers
- [ ] Team has discussed the "one process change" and agrees on it
