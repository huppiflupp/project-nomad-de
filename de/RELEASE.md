# Release der deutschen Fassung

Versionsschema: `X.Y.Z` mit Patch = 100 × Upstream-Patch + n (1.35.1 beruht auf Upstream 1.35.0).

1. **Voraussetzungen (einmalig):** Secret `DEPLOYMENT_AUTHORIZED_USERS` gesetzt:
   `gh secret set DEPLOYMENT_AUTHORIZED_USERS -R huppiflupp/project-nomad-de -b huppiflupp`.
   `CREATOR_PACKS_APP_KEY` bleibt leer, Creator Packs sind dann ausgeblendet.
2. **Prüfungen grün:** `de-checks` auf dem Zweig, der nach `main` geht.
3. **Merge:** `git checkout main && git merge --no-ff <zweig> && git push origin main`.
4. **Release-Notizen:** `de/release-notes/v<version>.md` schreiben, committen, pushen.
5. **Release:** `bash de/tools/release.sh <version>` – startet die Build-Workflows (Hauptimage, Sidecar-Updater,
   Disk-Collector), fragt nach grünen Builds und legt das GitHub-Release an.
6. **Pakete öffentlich machen:** GHCR legt neue Pakete privat an. Unter `https://github.com/huppiflupp?tab=packages`
   für `project-nomad-de`, `project-nomad-de-sidecar-updater`, `project-nomad-de-disk-collector` jeweils
   *Package settings → Change visibility → Public*.
   Prüfen: `docker logout ghcr.io; docker pull ghcr.io/huppiflupp/project-nomad-de:<version>` ohne Anmeldung.
7. **Translate-Image** (eigene Versionierung `0.1.0`, Teilprojekt C): `build-translate-proxy.yml` mit den dort
   verlangten Eingaben starten.
