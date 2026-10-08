import * as assert from 'node:assert/strict'
import { test } from 'node:test'
import { DISTRIBUTION } from '../../constants/distribution.js'

test('distribution points at the German fork', () => {
  assert.equal(DISTRIBUTION.repo, 'huppiflupp/project-nomad-de')
  assert.equal(DISTRIBUTION.imageRepo, 'ghcr.io/huppiflupp/project-nomad-de')
  assert.equal(DISTRIBUTION.releasesApi, 'https://api.github.com/repos/huppiflupp/project-nomad-de/releases')
  assert.equal(DISTRIBUTION.rawBase, 'https://raw.githubusercontent.com/huppiflupp/project-nomad-de/refs/heads/main')
  assert.equal(DISTRIBUTION.mapsRepo, 'Crosstalk-Solutions/project-nomad-maps')
})
