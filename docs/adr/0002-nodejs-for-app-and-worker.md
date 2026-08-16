# 2. Node.js for the api and worker services

## Status
Accepted

## Context
The reference architecture needed one synchronous request/response service
(`api`) and one asynchronous job-processing service (`worker`) sharing a
job-queue contract, to demonstrate the full path from an HTTP request
through to background processing and back.

## Decision
Both services are Node.js (Express for `api`, BullMQ for the queue/worker
contract on both sides). BullMQ's producer (in `api`) and consumer (in
`worker`) share the same npm ecosystem and the same mental model of a job,
which keeps the demonstration focused on the *platform* (CI/CD, Kubernetes,
autoscaling, observability) rather than on cross-language plumbing.

## Consequences
- Both services can share patterns (structured pino logging, prom-client
  metrics, graceful shutdown) almost verbatim - see `apps/api/src/` vs
  `apps/worker/src/`.
- A real polyglot production platform would likely mix languages per
  service; this repo optimizes for readability of the platform layer over
  demonstrating polyglot support.
