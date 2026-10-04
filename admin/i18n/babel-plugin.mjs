// admin/i18n/babel-plugin.mjs
// Build-time i18n for the German distribution: rewrites user-visible English text in
// inertia/ files into __t("English text", ...args). English text is the dictionary key.
import { looksHuman, normalize } from './text.mjs'

export const TEXT_PROPS = new Set([
  'placeholder', 'title', 'aria-label', 'alt', 'label', 'description', 'helperText', 'tooltip',
  'subtitle', 'message', 'confirmText', 'cancelText', 'emptyMessage', 'heading', 'buttonText',
])
const SKIP_TAGS = new Set(['code', 'pre', 'kbd', 'samp', 'script', 'style', 'svg'])
const T = '__t'
const MARK = Symbol('nomadI18n')

export default function nomadI18n({ types: t }, opts = {}) {
  const runtime = opts.runtime ?? '~/i18n/runtime'
  const include = opts.include ?? /\/inertia\//
  const exclude = opts.exclude ?? /\/inertia\/i18n\//
  const collect = opts.collect

  const active = (state) => {
    const f = (state.filename ?? '').replace(/\\/g, '/')
    return include.test(f) && !exclude.test(f)
  }
  const human = (key) => /[A-Za-z]/.test(key) && looksHuman(normalize(key.replace(/\{\d+\}/g, ' ')))

  function mk(key, args, state) {
    state.nomadI18nUsed = true
    collect?.add(key)
    const node = t.callExpression(t.identifier(T), [t.stringLiteral(key), ...args])
    node[MARK] = true
    return node
  }

  function templateKey(tpl) {
    let key = ''
    tpl.quasis.forEach((q, i) => {
      key += q.value.cooked ?? q.value.raw
      if (i < tpl.expressions.length) key += `{${i}}`
    })
    return normalize(key)
  }

  // Returns a replacement node, or null (conditionals/logicals are patched in place).
  function wrapExpr(node, state) {
    if (!node || node[MARK]) return null
    if (t.isStringLiteral(node)) {
      const key = normalize(node.value)
      return human(key) ? mk(key, [], state) : null
    }
    if (t.isTemplateLiteral(node)) {
      const key = templateKey(node)
      if (!human(key)) return null
      return mk(key, node.expressions.map((e) => wrapExpr(e, state) ?? e), state)
    }
    if (t.isConditionalExpression(node)) {
      node.consequent = wrapExpr(node.consequent, state) ?? node.consequent
      node.alternate = wrapExpr(node.alternate, state) ?? node.alternate
      return null
    }
    if (t.isLogicalExpression(node)) {
      // &&, || and ??: only the right-hand side can be display text
      node.right = wrapExpr(node.right, state) ?? node.right
      return null
    }
    return null
  }

  function edge(raw, which) {
    const m = which === 'lead' ? /^\s*/.exec(raw)[0] : /\s*$/.exec(raw)[0]
    return m && !m.includes('\n') ? ' ' : ''
  }

  function handleChildren(path, state) {
    const kids = path.node.children
    const inline = kids.every((c) => t.isJSXText(c) || t.isJSXExpressionContainer(c))
    if (inline && kids.some((c) => t.isJSXExpressionContainer(c) && !t.isJSXEmptyExpression(c.expression))) {
      let key = ''
      let hasText = false
      const args = []
      for (const c of kids) {
        if (t.isJSXText(c)) {
          key += c.value
          if (c.value.trim()) hasText = true
        } else if (t.isJSXEmptyExpression(c.expression)) {
          continue
        } else if (t.isStringLiteral(c.expression)) {
          key += c.expression.value
          hasText = true
        } else {
          key += `{${args.length}}`
          args.push(c.expression)
        }
      }
      key = normalize(key)
      if (hasText && human(key)) {
        const wrapped = args.map((a) => wrapExpr(a, state) ?? a)
        path.node.children = [t.jsxExpressionContainer(mk(key, wrapped, state))]
        return
      }
    }
    const out = []
    for (const c of kids) {
      if (t.isJSXText(c)) {
        const key = normalize(c.value)
        if (key && human(key)) {
          const lead = edge(c.value, 'lead')
          const trail = edge(c.value, 'trail')
          if (lead) out.push(t.jsxExpressionContainer(t.stringLiteral(lead)))
          out.push(t.jsxExpressionContainer(mk(key, [], state)))
          if (trail) out.push(t.jsxExpressionContainer(t.stringLiteral(trail)))
          continue
        }
      } else if (t.isJSXExpressionContainer(c)) {
        const r = wrapExpr(c.expression, state)
        if (r) {
          out.push(t.jsxExpressionContainer(r))
          continue
        }
      }
      out.push(c)
    }
    path.node.children = out
  }

  return {
    name: 'nomad-i18n',
    visitor: {
      Program: {
        exit(path, state) {
          if (!state.nomadI18nUsed || path.scope.hasBinding(T)) return
          path.unshiftContainer(
            'body',
            t.importDeclaration([t.importSpecifier(t.identifier(T), t.identifier(T))], t.stringLiteral(runtime)),
          )
        },
      },
      JSXElement(path, state) {
        if (!active(state)) return
        const name = path.node.openingElement.name
        if (t.isJSXIdentifier(name) && SKIP_TAGS.has(name.name)) {
          path.skip()
          return
        }
        handleChildren(path, state)
      },
      JSXFragment(path, state) {
        if (active(state)) handleChildren(path, state)
      },
      JSXAttribute(path, state) {
        if (!active(state)) return
        const n = path.node.name
        const attr = t.isJSXNamespacedName(n) ? `${n.namespace.name}:${n.name.name}` : n.name
        if (!TEXT_PROPS.has(attr)) return
        const v = path.node.value
        if (t.isStringLiteral(v)) {
          const r = wrapExpr(v, state)
          if (r) path.node.value = t.jsxExpressionContainer(r)
        } else if (t.isJSXExpressionContainer(v)) {
          const r = wrapExpr(v.expression, state)
          if (r) v.expression = r
        }
      },
      ObjectProperty(path, state) {
        if (!active(state) || path.node.computed) return
        const k = path.node.key
        const name = t.isIdentifier(k) ? k.name : t.isStringLiteral(k) ? k.value : null
        if (!name || !TEXT_PROPS.has(name)) return
        const r = wrapExpr(path.node.value, state)
        if (r) path.node.value = r
      },
      CallExpression(path, state) {
        if (!collect || !active(state)) return
        const c = path.node.callee
        const a = path.node.arguments[0]
        if (t.isIdentifier(c) && (c.name === 't' || c.name === T) && t.isStringLiteral(a)) {
          collect.add(normalize(a.value))
        }
      },
    },
  }
}
