# Shared Artifacts Rule

Any document intended to be reused across repos MUST be written to the
shared submodule backed by:

https://github.com/kcheath/fortessa_shared.git

Required locations:
- Plans → shared/plans/<topic>.plan.md
- Specs → shared/specs/<topic>.spec.md
- Contracts (machine-readable) → shared/contracts/<topic>.yaml
- ADRs → shared/adr/<topic>.adr.md
- Prompts/Templates → shared/prompts/ or shared/templates/

Do NOT place shared artifacts in /docs or project-local folders.

If the shared folder does not exist, create it.

Every shared artifact MUST begin with:
- Title
- Date (YYYY-MM-DD)
- Source Repo (fortessa_frontend | fortessa_backend | mindhearth)
- Intended Consumers
- Status: Draft | Reviewed | Released
- Original source path (if migrated)
