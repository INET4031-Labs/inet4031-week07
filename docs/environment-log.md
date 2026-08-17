# Environment Log

**System Admin:** [TODO: Fill in name]

Log infrastructure decisions, snapshots, disk usage, and resource state at key points during the sprint.

## Sprint 4 Environment Baseline (Start of Week 7)

**Snapshot Identifier:** [TODO: Record snapshot ID or timestamp]

**Timestamp:** [TODO: Date and time]

### Disk and Resource State

```
df -h output:
[TODO: Paste df -h output]

docker system df output:
[TODO: Paste docker system df output]

Note: k3d uses containerd, which maintains a separate image store.
```

### Cluster Status

```
k3d cluster list output:
[TODO: Paste output]

kubectl get nodes:
[TODO: Paste output]
```

### Infrastructure Decisions Made This Week

- [TODO: List any decisions about security controls, networking, or deployment strategy]

### Issues Encountered and Resolutions

[TODO: Document any environment-related problems and how they were resolved]

---

## Sprint 4 Environment End State (End of Week 8)

**Snapshot Identifier:** [TODO: Record snapshot ID or timestamp]

**Timestamp:** [TODO: Date and time]

### Disk and Resource State

```
df -h output:
[TODO: Paste df -h output]

docker system df output:
[TODO: Paste docker system df output]
```

### Final Cluster State

```
kubectl get pods -A:
[TODO: Paste output]
```

### Summary

[TODO: Summarize any resource growth or changes from start to end of sprint]
