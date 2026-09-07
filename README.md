# Week 7: Security Hardening and Shift Left

**Sprint 4 Kickoff**

## Overview

In this lab, you apply Kubernetes security controls to your deployed application: RBAC, NetworkPolicy to restrict pod-to-pod traffic, and SecurityContext to prevent privilege escalation inside containers. You will also add an automated image vulnerability scan to the CI pipeline, making security a gate on every build.

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
Week 6 `ci.yml` in place this week, following the wiki, neither file is replaced
wholesale. Since Week 4, `infrastructure/flask.tf` is the source of truth for the Flask
Deployment, so apply changes with `tofu apply`, not `kubectl apply`. Your Week 3
manifests (`postgres-deployment.yaml`, the two `*-secret.yaml` files) are untouched.

## Role Distribution

- **Scrum Master:** owns sprint board, leads Sprint Review, coordinates async week preparation
- **System Admin:** leads environment checkpoint, documents infrastructure decisions, verifies security control application
- **QA:** runs validation checks, verifies RBAC/NetworkPolicy/SecurityContext are enforced, approves deliverables
- **Developers:** implement RBAC, NetworkPolicy, SecurityContext, and CI scanning

## Deliverables

- `manifests/flask-serviceaccount.yaml`, `flask-role.yaml`, `flask-rolebinding.yaml` committed
- `manifests/default-deny.yaml` and the three explicit-allow NetworkPolicies committed
- `infrastructure/flask.tf` updated with `service_account_name` and `security_context`
- `.github/workflows/ci.yml` updated with Trivy scan job
- `tofu plan` shows no drift
- `./scripts/check-week7.sh` runs clean

## Full Instructions

The complete step-by-step lab, including exact manifest YAML and Trivy configuration, is in this repo's Wiki tab. This README is a reference, not a substitute.
