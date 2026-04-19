# Autoscaling layers

This repo uses several complementary autoscaling mechanisms rather than one global switch.

- **HPA**: CPU / memory based pod scaling for the app workloads. Those manifests already live in `kubernetes/base`.
- **KEDA**: event-driven worker scaling from Redis queue depth. Those manifests live in `autoscaling/keda`.
- **Cluster Autoscaler**: node-level capacity management for the Kubernetes cluster. The example Helm values live in `autoscaling/cluster-autoscaler`.
- **VPA**: recommendation-only right-sizing guidance. The example lives in `autoscaling/vpa`.

> Important: when KEDA owns worker scaling, do not also apply a separate CPU/memory HPA to that same `worker` Deployment unless you intentionally consolidate the metrics strategy. Two independent HPA controllers on one target will fight.

## Decision matrix

| Mechanism | Signal | Acts on | Use it when | Location |
| --- | --- | --- | --- | --- |
| HPA | CPU / memory | Pods | request-driven services such as `api` need steady reactive scaling | `kubernetes/base` |
| KEDA | Redis queue depth (`platform-jobs`) | Pods | `worker` throughput should track backlog, even when CPU is not yet saturated | `autoscaling/keda` |
| Cluster Autoscaler | Unschedulable pods / node pressure | Nodes | the cluster needs more or fewer worker nodes | `autoscaling/cluster-autoscaler` |
| VPA (Off) | Historical usage recommendations | Requests / limits guidance | you want safer right-sizing insight before changing live pod resources | `autoscaling/vpa` |

In practice, the common path here is: HPA for `api`, KEDA for `worker`, Cluster Autoscaler for the underlying EKS node groups, and VPA only as an advisory input.
