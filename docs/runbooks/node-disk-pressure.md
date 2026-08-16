# Runbook: NodeDiskPressure

**Alert**: A Kubernetes node is reporting `DiskPressure` condition. Source:
`monitoring/alerts/platform-rules.yaml`.

## Impact
The kubelet will start evicting pods from the affected node (lowest
`priorityClass`/QoS first) to reclaim disk space, which can cause
unexpected pod rescheduling and, if it affects a node running the sole
replica of something without a PDB, a brief outage.

## Investigation
```sh
kubectl describe node <node>
kubectl get pods --all-namespaces --field-selector spec.nodeName=<node>
```
Common causes on EKS: container image layer buildup (rarely an issue with
managed AMIs that garbage-collect), a runaway log file inside a
container's writable layer (unlikely here since containers run with
`readOnlyRootFilesystem: true`), or genuinely undersized node disk for the
workload density.

## Mitigation
- Cordon and drain the affected node if eviction pressure is severe:
  `kubectl cordon <node> && kubectl drain <node> --ignore-daemonsets`.
- Cluster Autoscaler (`autoscaling/cluster-autoscaler/values.yaml`) should
  provision a replacement node automatically once the old one is drained,
  if the node group has capacity headroom.
- If this recurs across many nodes, increase the EBS root volume size in
  `terraform/modules/eks` (managed node group `disk_size` argument) rather
  than treating each occurrence as a one-off.

## Escalation
Escalate to infra owner if this affects multiple nodes simultaneously
(suggests a systemic sizing issue, not a single bad node).
