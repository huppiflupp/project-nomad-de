import path from 'path'
import { readFile } from 'node:fs/promises'
import type { Lang } from '../../i18n/core.js'
import { getFileStatsIfExists, listDirectoryContentsRecursive } from './fs.js'

// Pure path/title logic for the docs service (kept free of Adonis-container imports so it is unit-testable).
export const DOC_ORDER: Record<string, number> = {
  'home': 1,
  'getting-started': 2,
  'use-cases': 3,
  'supply-depot-apps': 4,
  'drug-reference': 5,
  'community-add-ons': 6,
  'updates': 7,
  'faq': 8,
  'about': 9,
  'release-notes': 10,
}

const TITLE_OVERRIDES: Record<string, string> = {
  'faq': 'FAQ',
  'community-add-ons': 'Community Add-Ons',
}

export function prettify(filename: string) {
  const slug = filename.replace(/\.md$/, '')
  if (TITLE_OVERRIDES[slug]) {
    return TITLE_OVERRIDES[slug]
  }
  // Remove hyphens, underscores, and file extension
  const cleaned = slug.replace(/_/g, ' ').replace(/-/g, ' ')
  // Convert to Title Case
  const titleCased = cleaned.replace(/\b\w/g, (char) => char.toUpperCase())
  return titleCased.charAt(0).toUpperCase() + titleCased.slice(1)
}

export class DocsLocator {
  private docsPath: string
  private docsDePath: string

  constructor(baseDir: string = process.cwd()) {
    this.docsPath = path.join(baseDir, 'docs')
    this.docsDePath = path.join(baseDir, 'docs-de')
  }

  async listDocs(lang: Lang = 'en') {
    const contents = await listDirectoryContentsRecursive(this.docsPath)
    const files: Array<{ title: string; slug: string }> = []
    for (const item of contents) {
      if (item.type === 'file' && item.name.endsWith('.md')) {
        const slug = item.name.replace(/\.md$/, '')
        files.push({
          title: (lang === 'de' && (await this.germanTitle(slug))) || prettify(item.name),
          slug,
        })
      }
    }
    return files.sort((a, b) => (DOC_ORDER[a.slug] ?? 999) - (DOC_ORDER[b.slug] ?? 999))
  }

  private async germanTitle(slug: string): Promise<string | null> {
    try {
      const md = await readFile(path.join(this.docsDePath, `${slug}.md`), 'utf8')
      return /^#\s+(.+)$/m.exec(md)?.[1].trim() ?? null
    } catch {
      return null
    }
  }

  async resolveDocPath(slug: string, lang: Lang): Promise<string> {
    if (!slug) throw new Error('Filename is required')
    const filename = slug.endsWith('.md') ? slug : `${slug}.md`
    const roots = lang === 'de' ? [this.docsDePath, this.docsPath] : [this.docsPath]
    for (const root of roots) {
      const base = path.resolve(root)
      const full = path.resolve(path.join(root, filename))
      // Prevent path traversal — resolved path must stay within the docs directory
      if (!full.startsWith(base + path.sep)) throw new Error('Invalid document slug')
      if (await getFileStatsIfExists(full)) return full
    }
    throw new Error(`File not found: ${filename}`)
  }
}
