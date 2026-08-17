# Week 7: Security Hardening and Shift Left

**Sprint 4 Kickoff | Synchronous Lab**

> **Architecture Status Notice:** This week's lab assumes your team container allows Docker containers to run in privileged mode (`--privileged` flag). This architecture has not been approved by the professor. If privileged mode is unavailable in your environment, contact your instructor before proceeding.

## Overview

In this lab, you apply Kubernetes security controls to your deployed application: RBAC (Role-Based Access Control), NetworkPolicy to restrict pod-to-pod traffic, and SecurityContext to prevent privilege escalation inside containers. You will also add an automated image vulnerability scan to the CI pipeline, making security a gate on every build. After completing this lab, you will have a hardened application deployment with RBAC, NetworkPolicy, SecurityContext, and automated vulnerability scanning all committed to your repository.

## Learning Objectives

- Configure Kubernetes RBAC with a least-privilege ServiceAccount, Role, and RoleBinding
- Apply a NetworkPolicy that restricts pod-to-pod communication to declared paths only
- Configure SecurityContext settings to prevent privilege escalation inside containers
- Add automated image scanning to the GitHub Actions pipeline as a required check
- Understand the difference between authentication and authorization in Kubernetes

## Prerequisites

- Week 6 complete: GitHub Actions CI pipeline passing, branch protection configured
- k3d cluster running with application deployed

## Files and Directories

- `docs/` - Role-artifact templates (sprint retrospective, environment log, acceptance criteria, QA report)
- `manifests/` - Kubernetes manifests for security controls (to be created during lab)
- `scripts/` - Verification script for Week 7 deliverables
- `WEEK-7-LAB.md` - Full lab directions with step-by-step instructions and TODOs

## Getting Started

1. Read through `WEEK-7-LAB.md` from the top
2. Complete the Sprint Review for Sprint 3 (Part 0 of the lab)
3. Follow the role-specific task assignments
4. Fill in role-artifact templates as you progress through the lab
5. Run the validation checks and `check-week7.sh` before declaring deliverables complete

## Role Assignments

Week 7 is Sprint 4 Kickoff. Confirm your team's Sprint 4 role assignments:

- **Scrum Master:** Owns sprint board, leads Sprint Review, coordinates async week preparation
- **System Admin:** Leads environment checkpoint, documents infrastructure decisions, verifies security control application
- **QA:** Writes acceptance criteria before implementation, runs validation checks, approves deliverables
- **Developers:** Implement RBAC, NetworkPolicy, SecurityContext, and CI scanning

Refer to your team charter for role rotation details.
