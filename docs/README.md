# Documentation

This repository keeps **thin docs only**.

## Synapse consumer runtime
- Mindhearth applies `mindhearthSynapseProviderOverrides()` at the root `ProviderScope`.
- Host/BFF JSON handoff is applied through `MindhearthSynapseHostHandoffController`.
- Fortessa application API keys stay host/BFF-only; Flutter receives only end-user bearer and resolved package context.
- Adoption test: `test/core/synapse/mindhearth_synapse_integration_test.dart`.

## Canonical core documentation
Core, durable documentation lives in the `fortessa-docs` repository:

- Architecture
- Runbooks
- ADRs/RFCs
- Contracts and integration guides

## Ephemeral docs (delete anytime)
Temporary docs MUST go under:

- /scratch/cursor/
- /scratch/debug/
- /scratch/investigations/
- /scratch/handoffs/
