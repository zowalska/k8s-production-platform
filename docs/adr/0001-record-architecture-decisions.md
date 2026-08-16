# 1. Record architecture decisions

## Status
Accepted

## Context
This platform makes several non-obvious technical choices (application
stack, GitOps deployment artifact, secrets management approach, policy
engine, autoscaling strategy). Future contributors - including future us -
need to know *why*, not just *what*, was chosen.

## Decision
We use lightweight Architecture Decision Records (ADRs), one Markdown file
per decision, numbered sequentially, following the format popularized by
Michael Nygard. New ADRs are added, never edited in place, once accepted;
superseding decisions get their own ADR referencing the one they replace.

## Consequences
Anyone touching a foundational choice in this repo should add an ADR here
rather than only explaining the change in a commit message or PR
description, which get harder to find over time.
