# Stand der deutschen Fassung

## Ausgangslage (Upstream 5e1702e, 2026-10-04, ai395, Node 22.23.2)

- `npm run test:unit`: 608 Tests, 598 bestanden, **10 fehlgeschlagen bereits im Upstream-Stand** (gelten nicht als Regression):
  app_auto_update, content_auto_update, content_auto_update_backoff, custom_app_guard, drug_ingest_status,
  drug_interactions, drug_labels, ollama_controller_chat, ollama_done_reason, rag_retrieval_toggle (`tests/unit/*.spec.ts`).
- `npm run typecheck` (Server): fehlerfrei.
- `npx tsc --noEmit -p inertia` (Oberfläche): **35** `error TS` im Upstream-Stand (Ausgangswert; neue Fehler darüber sind Regressionen).
