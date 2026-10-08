import * as assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import { test } from 'node:test'
import { compile, translateDynamic } from '../../i18n/core.js'

// Meldungen des Installationsprotokolls (this._broadcast in docker_service.ts) kommen als Server-Ereignis
// und müssen im Browser über das Wörterbuch laufen, auch mit Platzhaltern.
const dict = compile(JSON.parse(readFileSync(new URL('../../i18n/de.json', import.meta.url), 'utf8')))

const proben: Array<[string, string]> = [
  ['Downloading Wikipedia ZIM file from https://example.org/x.zim. This may take some time...',
   'Wikipedia-ZIM-Datei wird von https://example.org/x.zim heruntergeladen. Das kann einige Zeit dauern …'],
  ['Service nomad_kiwix_server installation completed successfully.',
   'Die Installation des Dienstes nomad_kiwix_server wurde erfolgreich abgeschlossen.'],
  ['Pulling Docker image ghcr.io/kiwix/kiwix-serve:3.8.1...', 'Docker-Image ghcr.io/kiwix/kiwix-serve:3.8.1 wird heruntergeladen …'],
  ['Pre-install actions for Kiwix Serve completed successfully.', 'Die Vorbereitung für Kiwix Serve wurde erfolgreich abgeschlossen.'],
  ['Error installing service nomad_ollama: boom', 'Fehler bei der Installation des Dienstes nomad_ollama: boom'],
  ['Successfully updated nomad_admin to 1.35.2', 'nomad_admin wurde erfolgreich auf 1.35.2 aktualisiert'],
  ['Generated kiwix library XML.', 'Kiwix-Bibliotheksdatei (XML) erzeugt.'],
]

for (const [en, de] of proben) {
  test(`Protokollmeldung übersetzt: ${en.slice(0, 40)}`, () => {
    assert.equal(translateDynamic(dict, en), de)
  })
}
