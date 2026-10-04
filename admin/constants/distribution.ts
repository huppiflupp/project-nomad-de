// Where this distribution comes from. The German edition (huppiflupp/project-nomad-de)
// installs, updates and loads its catalogs from the fork, never from upstream.
const repo = 'huppiflupp/project-nomad-de'
const registry = 'ghcr.io/huppiflupp'

export const DISTRIBUTION = {
  repo,
  registry,
  imageRepo: `${registry}/project-nomad-de`,
  translateImage: `${registry}/project-nomad-de-translate`,
  rawBase: `https://raw.githubusercontent.com/${repo}/refs/heads/main`,
  releasesApi: `https://api.github.com/repos/${repo}/releases`,
  mapsRepo: 'Crosstalk-Solutions/project-nomad-maps',
  upstreamRepo: 'Crosstalk-Solutions/project-nomad',
} as const
