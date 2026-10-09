#!/usr/bin/env python3
"""tex2html.py – wandelt die Handbuch-Kapitel (eigener LaTeX-Dialekt aus handbuch.tex) in eine einzelne HTML-Datei.

Aufruf:  python3 tex2html.py handbuch  > html/handbuch.html          (alle Kapitel)
         python3 tex2html.py anleitung > html/installationsanleitung.html   (Kapitel 2–7: vom Stick bis zur Notfall-Karte)
Bilder aus bilder/web/*.jpg werden als Base64 eingebettet, die Datei ist allein lauffähig (USB-Stick, E-Mail).
Unterstützt nur die im Handbuch benutzten Befehle; unbekannte Befehle werden mit Warnung ausgegeben.
"""
import base64, html, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
KAPITEL = ['00-titel', '01-was-ist-nomad', '02-vorbereitung-windows', '03-ubuntu-installieren', '04-nomad-installieren',
           '05-daten-laden', '06-offline-test', '07-notfallkarte', '08-energie', '09-tabellen', '10-notfall-ki', 'anhang-grenzen']
WARN = set()


def strip_comments(s):
    return re.sub(r'(?<!\\)%.*', '', s)


def group(s, i):
    """s[i] == '{' → (Inhalt, Index hinter der schließenden Klammer)"""
    assert s[i] == '{', s[i:i + 40]
    d, j = 0, i
    while j < len(s):
        c = s[j]
        if c == '\\':
            j += 2
            continue
        if c == '{':
            d += 1
        elif c == '}':
            d -= 1
            if d == 0:
                return s[i + 1:j], j + 1
        j += 1
    raise ValueError('Klammer offen: ' + s[i:i + 60])


def opt(s, i):
    """optionales [..] ab i (Leerraum erlaubt) → (Inhalt|None, neuer Index)"""
    k = i
    while k < len(s) and s[k] in ' \n':
        k += 1
    if k < len(s) and s[k] == '[':
        e = s.index(']', k)
        return s[k + 1:e], e + 1
    return None, i


def args(s, i, n):
    out = []
    for _ in range(n):
        while i < len(s) and s[i] in ' \n':
            i += 1
        a, i = group(s, i)
        out.append(a)
    return out, i


def env_end(s, name, i):
    """Index von \\end{name} passend zum \\begin{name}, das davor beginnt (i = Anfang des Inhalts)"""
    d, j = 1, i
    b, e = '\\begin{%s}' % name, '\\end{%s}' % name
    while True:
        nb, ne = s.find(b, j), s.find(e, j)
        if ne < 0:
            raise ValueError('env offen: ' + name)
        if 0 <= nb < ne:
            d += 1
            j = nb + len(b)
        else:
            d -= 1
            if d == 0:
                return ne
            j = ne + len(e)


SYMB = {r'\times': '×', r'\div': '÷', r'\approx': '≈', r'\rightarrow': '→', r'\square': '☐', r'\textbackslash': '\\',
        r'\textperiodcentered': '·', r'\&': '&amp;', r'\_': '_', r'\%': '%', r'\$': '$', r'\#': '#', r'\,': '\u202f',
        r'\ ': ' ', r'\quad': '\u2003', r'\enskip': '\u2002'}


def SI(zahl, einheit):
    einheit = einheit.replace('\\euro', '€')
    return zahl.replace('.', '.') + '\u00a0' + einheit


def inline(s):
    """Fließtext mit Befehlen → HTML (ohne Absatz-/Umgebungslogik)"""
    out, i = [], 0
    while i < len(s):
        c = s[i]
        if c == '\\':
            m = re.match(r'\\([A-Za-z]+\*?)', s[i:])
            if not m:
                two = s[i:i + 2]
                out.append(SYMB.get(two, html.escape(two[1:])))
                i += 2
                continue
            name = m.group(1)
            i += len(m.group(0))
            full = '\\' + name
            if full in SYMB:
                out.append(SYMB[full])
                continue
            if name in ('textbf',):
                (a,), i = args(s, i, 1); out.append('<strong>%s</strong>' % inline(a))
            elif name in ('emph', 'textit'):
                (a,), i = args(s, i, 1); out.append('<em>%s</em>' % inline(a))
            elif name == 'texttt':
                (a,), i = args(s, i, 1); out.append('<code>%s</code>' % inline(a))
            elif name == 'taste':
                (a,), i = args(s, i, 1)
                out.append('<kbd>%s</kbd>' % (inline(a) or '&nbsp;&nbsp;&nbsp;&nbsp;'))
            elif name == 'menue':
                (a,), i = args(s, i, 1); out.append('<span class="menue">%s</span>' % inline(a))
            elif name == 'SI':
                (z, e), i = args(s, i, 2); out.append(SI(z, inline(e)))
            elif name == 'SIrange':
                (z1, z2, e), i = args(s, i, 3); out.append('%s\u2013%s' % (z1, SI(z2, inline(e))))
            elif name in ('feld', 'zeile'):
                _, i = opt(s, i); out.append('<span class="feld"></span>')
            elif name == 'abhaken':
                out.append('<span class="box">☐</span>')
            elif name == 'ref':
                (a,), i = args(s, i, 1); out.append('<a href="#%s">%s</a>' % (a, FIGNR.get(a, '?')))
            elif name == 'label':
                (a,), i = args(s, i, 1)
            elif name == 'color':
                (a,), i = args(s, i, 1)
            elif name in ('textsf',):
                (a,), i = args(s, i, 1); out.append(inline(a))
            elif name in ('small', 'normalsize', 'footnotesize', 'RaggedRight', 'centering', 'noindent', 'par', 'sffamily',
                          'bfseries', 'Large', 'raggedright', 'hfill', 'strut'):
                if name == 'par':
                    out.append('\n\n')
            elif name in ('vspace', 'hspace'):
                _, i = args(s, i, 1)
            elif name == 'url':
                (a,), i = args(s, i, 1); out.append('<code>%s</code>' % html.escape(a))
            else:
                WARN.add(full)
        elif c == '$':
            j = s.index('$', i + 1)
            out.append(inline(s[i + 1:j].replace('{,}', ',').replace('\\times', ' × ').replace('\\div', ' ÷ ')
                              .replace('\\approx', ' ≈ ').replace('\\rightarrow', ' → ').replace('\\SI', '\\SI')))
            i = j + 1
        elif c == '~':
            out.append('\u00a0'); i += 1
        elif c == '{' or c == '}':
            i += 1
        elif s.startswith('---', i):
            out.append('—'); i += 3
        elif s.startswith('--', i):
            out.append('–'); i += 2
        elif s.startswith('„', i) or True:
            if c in '<>&':
                out.append(html.escape(c))
            else:
                out.append(c)
            i += 1
    return ''.join(out)


def paragraphs(s):
    parts = [p.strip() for p in re.split(r'\n\s*\n', s) if p.strip()]
    return ''.join('<p>%s</p>\n' % inline(re.sub(r'\s*\n\s*', ' ', p)) for p in parts)


IMG_CACHE = {}
FIGNR = {}
FIGCOUNT = [0, 0]  # Kapitel, Abbildung
APPX = [False]


def bild(name, caption, label=None):
    path = os.path.join(HERE, 'bilder', 'web', name + '.jpg')
    if not os.path.exists(path):
        WARN.add('Bild fehlt: ' + name)
        return ''
    if name not in IMG_CACHE:
        IMG_CACHE[name] = base64.b64encode(open(path, 'rb').read()).decode()
    FIGCOUNT[1] += 1
    nr = '%d.%d' % (FIGCOUNT[0], FIGCOUNT[1])
    idattr = ''
    if label:
        FIGNR[label] = nr
        idattr = ' id="%s"' % label
    return ('<figure%s><img src="data:image/jpeg;base64,%s" alt="%s"><figcaption><strong>Abbildung %s:</strong> %s'
            '</figcaption></figure>\n' % (idattr, IMG_CACHE[name], html.escape(re.sub(r'\\[a-z]+|[{}]', '', caption)[:150]), nr, inline(caption)))


def tabelle(body):
    # \begin{tabular}{spec} / tabularx{w}{spec} wurde vom Aufrufer entfernt; body = Inhalt
    rows, cur = [], ''
    for line in re.split(r'(?<!\\)\\\\', body):
        rows.append(line)
    html_rows, header_done, seen_mid = [], False, False
    # Kopfzeile = Zeilen vor dem ersten \midrule (nach \toprule)
    out = ['<table>']
    cells_rows = []
    for r in rows:
        r = r.replace('\\toprule', '|TOP|').replace('\\midrule', '|MID|').replace('\\bottomrule', '|BOT|').replace('\\addlinespace', '')
        r = re.sub(r'\\renewcommand\{\\arraystretch\}\{[^}]*\}', '', r)
        cells_rows.append(r)
    mid_seen = any('|MID|' in r for r in cells_rows)
    in_head = mid_seen
    for r in cells_rows:
        marker_mid = '|MID|' in r
        clean = r.replace('|TOP|', '').replace('|BOT|', '')
        parts = clean.split('|MID|')
        for k, part in enumerate(parts):
            if k > 0:
                in_head = False
            if not part.strip():
                continue
            cells = re.split(r'(?<!\\)&', part)
            tds = []
            for cell in cells:
                cell = cell.strip()
                span = ''
                if cell.startswith('\\multicolumn'):
                    (n, _spec, txt), _ = args(cell, len('\\multicolumn'), 3)
                    span = ' colspan="%s"' % n
                    cell = txt
                tag = 'th' if in_head else 'td'
                tds.append('<%s%s>%s</%s>' % (tag, span, inline(cell), tag))
            out.append('<tr>%s</tr>' % ''.join(tds))
        if marker_mid:
            in_head = False
    out.append('</table>')
    return '\n'.join(out)


def liste(kind, body, optstr):
    items = re.split(r'\\item(?![a-zA-Z])', body)[1:]
    out = []
    for it in items:
        label = None
        it = it.lstrip()
        if it.startswith('['):
            e = it.index(']')
            label = it[1:e]
            it = it[e + 1:]
        content = block(it.strip())
        if kind == 'description':
            out.append('<dt>%s</dt><dd>%s</dd>' % (inline(label or ''), content))
        else:
            out.append('<li>%s</li>' % content)
    tag = {'itemize': 'ul', 'enumerate': 'ol', 'description': 'dl'}[kind]
    start = ''
    return '<%s>%s</%s>\n' % (tag, ''.join(out), tag)


def block(s):
    """Umgebungen, Kästen, Bilder usw. → HTML; Rest wird zu Absätzen."""
    s = strip_comments(s)
    s = re.sub(r"\\par(?![A-Za-z])", "\n\n", s)
    out, i, buf = [], 0, []

    def flush():
        t = ''.join(buf).strip()
        buf.clear()
        if t:
            out.append(paragraphs(t))

    while i < len(s):
        m = re.compile(r'\\(chapter\*?|section\*?|subsection\*?|bild|hinweis|achtung|merke|kasten|befehl|begin|renewcommand|'
                       r'thispagestyle|vspace\*?|small|normalsize|label|addcontentsline|tableofcontents|input)(?![A-Za-z])').search(s, i)
        if not m:
            buf.append(s[i:])
            break
        buf.append(s[i:m.start()])
        name, i = m.group(1), m.end()
        star = name.endswith('*')
        base = name.rstrip('*')
        if base == 'chapter':
            flush(); (a,), i = args(s, i, 1)
            FIGCOUNT[0] += 0 if star else 1; FIGCOUNT[1] = 0
            nr = ('A' if APPX[0] else str(FIGCOUNT[0]))
            out.append('<h1 id="k%d">%s%s</h1>\n' % (FIGCOUNT[0], '' if star else nr + '  ', inline(a)))
        elif base in ('section', 'subsection'):
            flush(); (a,), i = args(s, i, 1)
            lvl = 'h2' if base == 'section' else 'h3'
            out.append('<%s>%s</%s>\n' % (lvl, inline(a), lvl))
        elif base == 'bild':
            flush(); _, i = opt(s, i); (n, c), i = args(s, i, 2)
            lab = None
            mm = re.match(r'\s*\\label\{([^}]*)\}', s[i:])
            if mm:
                lab = mm.group(1); i += mm.end()
            out.append(bild(n, c, lab))
        elif base in ('hinweis', 'achtung', 'merke'):
            flush(); (a,), i = args(s, i, 1)
            titel = {'hinweis': 'Hinweis', 'achtung': 'Achtung', 'merke': 'Merken'}[base]
            out.append('<aside class="%s"><strong class="t">%s</strong>%s</aside>\n' % (base, titel, block(a)))
        elif base == 'kasten':
            flush(); (farbe, titel, a), i = args(s, i, 3)
            cls = {'warnrot': 'achtung', 'hinweisblau': 'hinweis', 'gruen': 'merke', 'nomadbraun': 'braun'}.get(farbe, 'hinweis')
            out.append('<aside class="%s"><strong class="t">%s</strong>%s</aside>\n' % (cls, inline(titel), block(a)))
        elif base == 'befehl':
            flush(); (a,), i = args(s, i, 1)
            txt = re.sub(r'\\allowbreak\s*', '', a)
            txt = txt.replace('\\textbackslash', '\\').replace('\\_', '_').replace('\\&', '&').replace('\\ ', ' ')
            out.append('<pre class="befehl">%s</pre>\n' % html.escape(re.sub(r'\s+', ' ', txt).strip()))
        elif base == 'begin':
            (env,), i = args(s, i, 1)
            if env in ('tabularx', 'tabular'):
                if env == 'tabularx':
                    _, i = args(s, i, 2)
                else:
                    _, i = args(s, i, 1)
                e = env_end(s, env, i)
                flush(); out.append('<div class="tab">%s</div>\n' % tabelle(s[i:e])); i = e + len('\\end{%s}' % env)
            elif env in ('itemize', 'enumerate', 'description'):
                o, i = opt(s, i)
                e = env_end(s, env, i)
                flush(); out.append(liste(env, s[i:e], o)); i = e + len('\\end{%s}' % env)
            elif env in ('center', 'tikzpicture', 'titlepage'):
                if env == 'tikzpicture':
                    e = env_end(s, env, i)
                    inner = s[i:e]
                    m2 = re.search(r'\\node\[[^\]]*\]\{', inner)
                    flush()
                    if m2:
                        txt, _ = group(inner, m2.end() - 1)
                        cls = 'karte' if 'NOTFALL-KARTE' in txt else 'steckbrief'
                        out.append('<aside class="%s">%s</aside>\n' % (cls, block(txt)))
                    i = e + len('\\end{tikzpicture}')
                else:
                    e = env_end(s, env, i)
                    flush(); out.append('<div class="%s">%s</div>\n' % (env, block(s[i:e]))); i = e + len('\\end{%s}' % env)
            else:
                WARN.add('env ' + env)
        elif base in ('renewcommand',):
            _, i = args(s, i, 2) if s[i] == '{' else (None, i)
        elif base in ('vspace', 'thispagestyle', 'addcontentsline'):
            _, i = args(s, i, {'addcontentsline': 3}.get(base, 1))
        elif base == 'label':
            _, i = args(s, i, 1)
        elif base == 'input':
            _, i = args(s, i, 1)
        elif base in ('small', 'normalsize', 'tableofcontents'):
            pass
    flush()
    return ''.join(out)


CSS = """
:root{--braun:#3b4021;--hell:#f4edd8;--rot:#9b1c1c;--blau:#1f4e79;--gruen:#2f6b2f}
*{box-sizing:border-box}html{font-size:20px}
body{font-family:'Liberation Sans','Noto Sans',Arial,sans-serif;line-height:1.55;color:#1d1d1d;background:#fff;margin:0}
main{max-width:46rem;margin:0 auto;padding:1.5rem 1.2rem 4rem}
h1{color:var(--braun);font-size:1.9rem;border-bottom:3px solid var(--braun);padding-bottom:.2rem;margin-top:3.5rem;line-height:1.2}
h2{color:var(--braun);font-size:1.4rem;margin-top:2.2rem}h3{color:var(--braun);font-size:1.15rem}
p{margin:.7rem 0}code{font-family:'Liberation Mono',monospace;background:#eee;padding:0 .25em;border-radius:3px;font-size:.9em}
kbd{border:1.5px solid #333;border-radius:4px;padding:0 .35em;background:#fafafa;font-size:.85em;font-family:inherit;white-space:nowrap}
.menue{font-weight:700}.box{font-size:1.1em}.feld{display:inline-block;min-width:7em;border-bottom:1.5px solid #333;height:1.1em;vertical-align:-.15em}
figure{margin:1.4rem 0;text-align:center}figure img{max-width:100%;height:auto;border:1px solid #bbb;border-radius:4px}
figcaption{font-size:.8rem;color:#444;margin-top:.3rem}
aside{border:2px solid;border-radius:6px;padding:.6rem .9rem;margin:1.1rem 0}aside p{margin:.4rem 0}
aside .t{display:block;font-weight:700;margin-bottom:.15rem}
aside.hinweis{border-color:var(--blau);background:#eef4fa}aside.hinweis .t{color:var(--blau)}
aside.achtung{border-color:var(--rot);background:#fbeeee}aside.achtung .t{color:var(--rot)}
aside.merke{border-color:var(--gruen);background:#eef6ee}aside.merke .t{color:var(--gruen)}
aside.braun{border-color:var(--braun);background:var(--hell)}aside.braun .t{color:var(--braun)}
aside.karte{border:3px solid var(--rot);background:#fff;font-size:.95rem}aside.steckbrief{border-color:var(--braun);background:var(--hell)}
pre.befehl{background:#f0f0f0;border:1.5px solid #666;padding:.55rem .8rem;border-radius:4px;white-space:pre-wrap;word-break:break-all;
font-family:'Liberation Mono',monospace;font-size:.88rem;margin:.8rem 0}
.tab{overflow-x:auto;margin:1rem 0}table{border-collapse:collapse;width:100%;font-size:.85rem}
th,td{border-bottom:1px solid #bbb;padding:.35rem .5rem;text-align:left;vertical-align:top}th{border-bottom:2px solid #333}
dt{font-weight:700;margin-top:.7rem}dd{margin:0 0 .3rem 1.2rem}ul,ol{padding-left:1.5rem}li{margin:.25rem 0}
nav{background:var(--hell);border:2px solid var(--braun);border-radius:6px;padding:.6rem 1.1rem;margin:1.5rem 0}nav a{color:var(--braun)}
nav ol{margin:.3rem 0}.titel{text-align:center;margin-top:2rem}
@media print{html{font-size:14pt}h1{page-break-before:always}figure,aside,pre{page-break-inside:avoid}nav{display:none}}
@media (max-width:600px){html{font-size:18px}}
"""


def main():
    modus = sys.argv[1] if len(sys.argv) > 1 else 'handbuch'
    kap = KAPITEL if modus == 'handbuch' else ['02-vorbereitung-windows', '03-ubuntu-installieren', '04-nomad-installieren',
                                               '05-daten-laden', '06-offline-test', '07-notfallkarte']
    titel = 'NOMAD-Handbuch' if modus == 'handbuch' else 'NOMAD – Installationsanleitung'
    if modus != 'handbuch':
        FIGCOUNT[0] = 1  # Kapitelnummern der Anleitung beginnen bei 2 (wie im Handbuch)
    # Vorlauf für \ref: erst alle Kapitel rendern, dann zweiter Durchlauf mit bekannten Abbildungsnummern
    for durchlauf in (1, 2):
        FIGCOUNT[0], FIGCOUNT[1] = (0, 0) if modus == 'handbuch' else (1, 0)
        teile = []
        for k in kap:
            src = open(os.path.join(HERE, 'kapitel', k + '.tex'), encoding='utf-8').read()
            APPX[0] = (k == 'anhang-grenzen')
            if k == '00-titel':
                # Titelseite: eigene Kopfzone, danach „So benutzen Sie dieses Heft“
                src = src.split('\\chapter*{')[1]
                src = '\\chapter*{' + src
            teile.append(block(src))
    inhalt = ''.join(teile)
    toc = ''.join('<li><a href="#k%d">%s</a></li>' % (i + 1, re.sub(r'<[^>]+>', '', h)) for i, h in enumerate(
        re.findall(r'<h1 id="k\d+">\d+\s+(.*?)</h1>', inhalt)))
    kopf = ('<div class="titel"><h1 style="border:0;font-size:2.6rem;margin:0">NOMAD</h1><p style="font-size:1.6rem;margin:0">%s</p>'
            '<p>Stand Oktober 2026 · Software-Version 1.35.2<br>Inoffizielle deutsche Fassung von Project NOMAD (Crosstalk Solutions), '
            'Apache-Lizenz 2.0</p></div>' % ('Handbuch' if modus == 'handbuch' else 'Installationsanleitung'))
    print('<!doctype html><html lang="de"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">'
          '<title>%s</title><style>%s</style></head><body><main>%s<nav><strong>Inhalt</strong><ol>%s</ol></nav>%s</main></body></html>'
          % (titel, CSS, kopf, toc, inhalt))
    for w in sorted(WARN):
        print('WARNUNG:', w, file=sys.stderr)


if __name__ == '__main__':
    main()
