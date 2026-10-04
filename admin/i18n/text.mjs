// admin/i18n/text.mjs
// Shared by the Babel plugin and the i18n CLI. Mirrors normalize() in core.ts.
export function normalize(s) {
  return String(s).replace(/\s+/g, ' ').trim()
}

/** True for strings a person reads; false for class names, slugs, identifiers, URLs, code. */
export function looksHuman(s) {
  if (s.length < 2 || !/[A-Za-z]{2}/.test(s)) return false
  if (/^(https?:|\/|\.\/|#|@|[a-z0-9_.-]+\/[a-z0-9_./-]*$)/i.test(s)) return false
  if (/^[a-z0-9_:.\-[\]/!%]+( [a-z0-9_:.\-[\]/!%()]+)*$/.test(s) && /[-:]/.test(s)) return false
  if (/^[a-z][a-zA-Z0-9_.]*$/.test(s)) return false
  if (/^[A-Z0-9_]+$/.test(s)) return false
  if (/^Icon[A-Z]\w+$/.test(s)) return false
  if (/^[a-z0-9-]+$/.test(s)) return false
  if (/^\w+\/[\w.+-]+$/.test(s)) return false
  if (/[{};]\s*$/.test(s) && /[=(]/.test(s)) return false
  if (/^v?\d+(\.\d+)*$/.test(s)) return false
  return /[A-Z]/.test(s[0]) || / /.test(s) || /[.!?:]$/.test(s)
}
