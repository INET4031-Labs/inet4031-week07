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

## Pulling This Week's Starter Content Into Your Team Repo

This repo (`inet4031-week07`) is instructor-provided starter/reference content for
Week 7, not something you clone standalone. Pull the pieces you need into your
team's single repo:

```bash
git remote add week7 https://github.com/INET4031-Labs/inet4031-week07.git
git fetch week7
git checkout week7/main -- scripts docs
git remote remove week7
```

**`infrastructure/flask.tf` and `.github/workflows/ci.yml` are not shipped as
files in this repo.** You edit your own existing Week 4 `infrastructure/flask.tf` and
Week 6 `ci.yml` in place this week (adding `service_account_name`/`security_context` and
a Trivy scan job respectively), following the wiki step by step -- neither file is
replaced wholesale. Since Week 4, `infrastructure/flask.tf` (not `manifests/flask-deployment.yaml`)
is the source of truth for the Flask Deployment, so that is where the `serviceAccountName`/
`securityContext` additions belong; apply them with `tofu apply`, not `kubectl apply`.
Your Week 3 manifests (`postgres-deployment.yaml`, the two `*-secret.yaml` files) are untouched.

## Files and Directories

- `docs/` - Role-artifact templates (sprint retrospective, QA report)
- `manifests/` - Kubernetes manifests for security controls (extended during this lab)
- `scripts/` - Verification script for Week 7 deliverables

## Getting Started

1. Read through the full lab directions in the Wiki tab from the top
2. Complete the Sprint Review for Sprint 3 (Part 0 of the lab)
3. Follow the role-specific task assignments
4. Fill in role-artifact templates as you progress through the lab
5. Run the validation checks and `check-week7.sh` before declaring deliverables complete

## Role Assignments

Week 7 is Sprint 4 Kickoff. Confirm your team's Sprint 4 role assignments:

- **Scrum Master:** Owns sprint board, leads Sprint Review, coordinates async week preparation
- **System Admin:** Leads environment checkpoint, documents infrastructure decisions, verifies security control application
- **QA:** Runs validation checks, verifies RBAC/NetworkPolicy/SecurityContext are enforced, approves deliverables
- **Developers:** Implement RBAC, NetworkPolicy, SecurityContext, and CI scanning

Refer to your team charter for role rotation details.
