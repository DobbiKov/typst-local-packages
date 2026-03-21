#import "@preview/gentle-clues:1.2.0": *
#import "theorems.typ": *

#let latex_font = "New Computer Modern"
#let fonts = (
  text: (latex_font),
  sans: (latex_font),
  mono: (latex_font),
)
#let colors = (
  title: black,
  headers: black,
  partfill: rgb("#002299"),
  label: black,
  hyperlink: blue,
  strong: black,
  thm-ref: black
)
#let _dobbikov-lang = state("dobbikov-lang", "en")
#let _dobbikov-i18n = (
  en: (
    "table-of-contents": "Table of contents",
    section: "Section",
    chapter: "Chapter",
    figure: "Figure",
    theorem: "Theorem",
    definition: "Definition",
    lemma: "Lemma",
    proposition: "Proposition",
    notation: "Notation",
    corollary: "Corollary",
    conjecture: "Conjecture",
    example: "Example",
    algorithm: "Algorithm",
    claim: "Claim",
    remark: "Remark",
    problem: "Problem",
    exercise: "Exercise",
    "exercise-star": "Exercise (*)",
    question: "Question",
    fact: "Fact",
    proof: "Proof",
    solution: "Solution",
  ),
  fr: (
    "table-of-contents": "Table des matieres",
    section: "Section",
    chapter: "Chapitre",
    figure: "Figure",
    theorem: "Theoreme",
    definition: "Definition",
    lemma: "Lemme",
    proposition: "Proposition",
    notation: "Notation",
    corollary: "Corollaire",
    conjecture: "Conjecture",
    example: "Exemple",
    algorithm: "Algorithme",
    claim: "Assertion",
    remark: "Remarque",
    problem: "Probleme",
    exercise: "Exercice",
    "exercise-star": "Exercice (*)",
    question: "Question",
    fact: "Fait",
    proof: "Preuve",
    solution: "Solution",
  ),
  ua: (
    "table-of-contents": "Зміст",
    section: "Розділ",
    chapter: "Розділ",
    figure: "Рисунок",
    theorem: "Теорема",
    definition: "Означення",
    lemma: "Лема",
    proposition: "Пропозиція",
    notation: "Позначення",
    corollary: "Наслідок",
    conjecture: "Гіпотеза",
    example: "Приклад",
    algorithm: "Алгоритм",
    claim: "Твердження",
    remark: "Зауваження",
    problem: "Задача",
    exercise: "Вправа",
    "exercise-star": "Вправа (*)",
    question: "Питання",
    fact: "Факт",
    proof: "Доведення",
    solution: "Розв'язок",
  ),
)

#let _normalize-language(language) = {
  if language == "en" or language == "fr" or language == "ua" {
    language
  } else {
    panic("dobbikov: `language` must be one of \"ua\", \"fr\", \"en\".")
  }
}

#let _typst-language(language) = if language == "ua" { "uk" } else { language }
#let _tr(language, key) = _dobbikov-i18n.at(language).at(key)

#let toc = {
  show outline.entry.where(level: 1): it => {
    v(1.2em, weak:true)
    text(weight:"bold", font:fonts.sans, it)
  }
  text(fill:colors.title, size:1.4em, font:fonts.sans, [*#context _tr(_dobbikov-lang.get(), "table-of-contents")*])
  v(0.6em)
  outline(
    title: none,
    indent: 2em,
  )
}

#let eqn(s) = {
  set math.equation(numbering: "(1)")
  s
}
#let pageref(label) = context {
  let loc = locate(label)
  let nums = counter(page).at(loc)
  link(loc, "page " + numbering(loc.page-numbering(), ..nums))
}

// Define clue environments
#let definition(..args) = clue(
  accent-color: _get-accent-color-for("abstract"),
  icon: _get-icon-for("abstract"),
  title: "Definition",
  ..args
)
#let problem(..args) = clue(
  accent-color: _get-accent-color-for("experiment"),
  icon: _get-icon-for("experiment"),
  title: "Problem",
  ..args
)
#let exercise(..args) = clue(
  accent-color: _get-accent-color-for("experiment"),
  icon: _get-icon-for("experiment"),
  title: "Exercise",
  ..args
)
#let sample(..args) = clue(
  accent-color: _get-accent-color-for("success"),
  icon: _get-icon-for("experiment"),
  title: "Sample Question",
  ..args
)
#let solution(..args) = clue(
  accent-color: _get-accent-color-for("conclusion"),
  icon: _get-icon-for("conclusion"),
  title: "Solution",
  ..args
)
#let remark(..args) = clue(
  accent-color: _get-accent-color-for("info"),
  icon: _get-icon-for("info"),
  title: "Remark",
  ..args
)
#let recipe(..args) = clue(
  accent-color: _get-accent-color-for("task"),
  icon: _get-icon-for("task"),
  title: "Recipe",
  ..args
)
#let typesig(..args) = clue(
  accent-color: _get-accent-color-for("code"),
  icon: _get-icon-for("code"),
  title: "Type signature",
  ..args
)
#let digression(..args) = clue(
  accent-color: rgb("#bbbbbb"),
  icon: _get-icon-for("quote"),
  title: "Digression",
  ..args
)

// Theorem environments
#let thm-args = (padding: (x: 0.5em, y: 0.6em), outset: 0.9em, counter: "thm", base-level: 1)
/// Creates a reusable border+title styling preset for theorem environments.
///
/// Returns a *style factory* (a function like `thm-plain.with(...)`) that you can
/// call with a heading and normal theorem args.
/// Example:
/// ```
/// #let scarlet = thm-border-style(color.rgb(140, 0, 30))
/// #let theorem = scarlet("Theorem", ..thm-args)
/// #let prop = scarlet("Proposition", ..thm-args)
/// ```
/// - stroke-color (color): Border + title/name color.
/// - stroke-width (length): Border width.
/// - title-fmt (function): Formatting for the head+number.
/// - name-fmt (function): Formatting for the optional parenthesized name/info.
/// - body-fmt (function): Formatting for the body text.
/// - fill (color|none): Box fill.
#let thm-border-style(
  stroke-color,
  stroke-width: 0.8pt,
  title-fmt: auto,
  name-fmt: auto,
  body-fmt: auto,
  fill: none,
) = {
  let emph-delta = 160
  let title-fmt = if title-fmt == auto {
    x => text(fill: stroke-color)[#strong(smallcaps([#x]), delta: emph-delta)]
  } else {
    title-fmt
  }
  let name-fmt = if name-fmt == auto {
    x => text(fill: stroke-color)[#strong(smallcaps([~(#x)]), delta: emph-delta)]
  } else {
    name-fmt
  }
  let body-fmt = if body-fmt == auto {
    x => text(fill: black)[#emph(x)]
  } else {
    body-fmt
  }
  thm-plain2.with(
    fill: fill,
    stroke: stroke-color + stroke-width,
    title-fmt: title-fmt,
    name-fmt: name-fmt,
    body-fmt: body-fmt,
  )
}

/// Convenience helper that creates a ready-to-use theorem env in one call.
/// Example:
/// ```
/// #let theorem = thm-bordered("Theorem", color.rgb(140, 0, 30), ..thm-args)
/// ```
#let thm-bordered(head, stroke-color, ..args) = {
  thm-border-style(stroke-color)(head, ..args)
}

/// Creates a borderless variant that keeps the same title/name/body styling.
/// Example:
/// ```
/// #let calm = thm-borderless-style(color.rgb(110, 0, 40))
/// #let theorem = calm("Theorem", ..thm-args)
/// ```
/// - accent-color (color): Title/name color.
/// - title-fmt/name-fmt/body-fmt/fill: Same as in @@thm-border-style.
#let thm-borderless-style(
  accent-color,
  title-fmt: auto,
  name-fmt: auto,
  body-fmt: auto,
  fill: none,
) = {
  let title-fmt = if title-fmt == auto {
    x => text(fill: accent-color)[#strong(smallcaps([#x]))]
  } else {
    title-fmt
  }
  let name-fmt = if name-fmt == auto {
    x => text(fill: accent-color)[#strong(smallcaps([~(#x)]))]
  } else {
    name-fmt
  }
  let body-fmt = if body-fmt == auto {
    x => text(fill: black)[#emph(x)]
  } else {
    body-fmt
  }
  thm-plain2.with(
    fill: fill,
    stroke: accent-color + 0pt,
    title-fmt: title-fmt,
    name-fmt: name-fmt,
    body-fmt: body-fmt,
  )
}

/// Creates a left-double-bar style (two vertical bars on the left).
/// Example:
/// ```
/// #let leftbars = thm-leftbars-style(color.rgb(110, 0, 40))
/// #let theorem = leftbars("Theorem", ..thm-args)
/// #let prop = leftbars("Proposition", ..thm-args)
/// ```
/// - accent-color (color): Bar + title/name color.
/// - bar-width (length): Width of each bar.
/// - bar-gap (length): Gap between the two bars.
/// - inner-gap (length): Gap between bars and content.
/// - separator/title-fmt/name-fmt/body-fmt/fill: Same as in @@thm-border-style.
#let thm-leftbars-style(
  accent-color,
  bar-width: 0.8pt,
  bar-gap: 1.2pt,
  inner-gap: 0.6em,
  separator: [.#h(0.2em)],
  title-fmt: auto,
  name-fmt: auto,
  body-fmt: auto,
  fill: none,
) = {
  let title-fmt = if title-fmt == auto {
    x => text(fill: accent-color)[#strong(smallcaps(x))]
  } else {
    title-fmt
  }
  let name-fmt = if name-fmt == auto {
    x => text(fill: accent-color)[#strong(smallcaps([~(#x)]))]
  } else {
    name-fmt
  }
  let body-fmt = if body-fmt == auto {
    x => text(fill: black)[#emph(x)]
  } else {
    body-fmt
  }

  (head,
    counter: auto,
    ..args,
    numbering: "1.1",
    supplement: auto,
    padding: (y: 0.1em),
    separator: separator,
    base: "heading",
    base-level: none,
  ) => {
    if counter == auto {
      counter = head
    }
    if supplement == auto {
      supplement = head
    }
    let fmt(
      name,
      number,
      body,
      title: auto,
      padding: padding,
      separator: separator,
      ..args_individual
    ) = {
      if not name == none {
        name = [ #name-fmt(name)]
      } else {
        name = []
      }
      if title == auto {
        title = head
      }
      if not number == none {
        title += " " + number
      }
      title = title-fmt(title)
      body = body-fmt(body)
      let content = block(width: 100%, {
        set par(first-line-indent: 0pt)
        [#title#name#separator#body]
      })
      let bars = block(
        width: 100%,
        fill: fill,
        stroke: (left: accent-color + bar-width),
        inset: (left: bar-width + bar-gap),
        block(
          width: 100%,
          stroke: (left: accent-color + bar-width),
          inset: (left: bar-width + inner-gap),
          content
        )
      )
      pad(
        ..padding,
        block(
          width: 100%,
          ..args.named(),
          ..args_individual.named(),
          bars
        )
      )
    }
    return thm-env(
      counter,
      fmt,
      base: base,
      base-level: base-level,
    ).with(
      numbering: numbering,
      supplement: supplement,
      restate-keys: (head, )
    )
  }
}

#let thm-red-color = color.rgb(110, 0, 40)
#let thm-red = thm-plain(
  "Theorem",
  fill: none,
  stroke: thm-red-color + 1pt,
  title-fmt: x => text(fill: thm-red-color)[#strong(x)],
  name-fmt: x => text(fill: thm-red-color)[#strong([(#x)])],
  body-fmt: x => text(fill: black)[#emph(x)],
  ..thm-args
)
#let thm-red-style = thm-leftbars-style(thm-red-color)
#let def-red-style = thm-border-style(thm-red-color)
#let basic-red-style = thm-borderless-style(thm-red-color)
#let defn-base = thm-red-style(
  "Definition",
  separator: text(fill: thm-red-color)[#strong(smallcaps([~–~]))],
  ..thm-args
)
/// Creates a base environment using the "red" style and the default dash separator.
/// Intended to be wrapped with @@thm-with-info.
/// Example:
/// ```
/// #let prop = thm-with-info(any-base("Proposition"))
/// ```
#let border-base(
  head,
  separator: text(fill: thm-red-color)[#strong(smallcaps([~–~]))],
  ..args,
) = def-red-style(
  head,
  separator: separator,
  counter: "thm",
  base-level: 1,
  padding: (x: 0.8pt, y: 0.6em),
  inset: (x: 0.5em, y: 0.8em),
  outset: 0pt,
  ..args,
)
#let borderless-base(
  head,
  separator: text(fill: thm-red-color)[#strong(smallcaps([~–]))],
  ..args,
) = thm-borderless-style(thm-red-color)(
  head,
  separator: separator,
  body-fmt: x => [#text(fill: black)[#emph(x)]#h(1fr)#text(fill: thm-red-color)[$diamond.small$]],
  counter: "thm",
  base-level: 1,
  padding: (x: 0pt, y: 0.6em),
  outset: 0pt,
  ..args,
)
#let leftbars-base(
  head,
  separator: text(fill: thm-red-color)[#strong(smallcaps([~–~]))],
  ..args,
) = thm-leftbars-style(thm-red-color)(
  head,
  separator: separator,
  counter: "thm",
  base-level: 1,
  padding: (x: 0.2em, y: 0.6em),
  inset: (x: 0em, y: 0.8em),
  outset: 0pt,
  ..args,
)
/// Wraps a theorem environment to add an optional `info` parameter.
/// `info` overrides the positional name and is passed as the environment name.
/// Example:
/// ```
/// #let defn = thm-with-info(defn-base)
/// #let theorem = thm-with-info(thm)
/// #let remark = thm-with-info(rmk)
/// ```
#let thm-with-info(env) = {
  (..args, body, info: auto) => {
    let name = none
    if args.pos().len() > 0 {
      name = args.pos().first()
    }
    if info != auto {
      name = info
    }
    if name == none {
      env(..args.named(), body)
    } else {
      env(name, ..args.named(), body)
    }
  }
}

#let _localized-head(key) = context _tr(_dobbikov-lang.get(), key)

#let defn = thm-with-info(border-base(_localized-head("definition")))
#let thm = thm-with-info(leftbars-base(_localized-head("theorem")))
#let lem = thm-with-info(borderless-base(_localized-head("lemma")))
#let prop = thm-with-info(border-base(_localized-head("proposition")))
#let notation = thm-with-info(borderless-base(_localized-head("notation")))
#let cor = thm-with-info(borderless-base(_localized-head("corollary")))
#let conj = thm-with-info(borderless-base(_localized-head("conjecture")))
#let ex = thm-with-info(borderless-base(_localized-head("example")))
#let algo = thm-def(_localized-head("algorithm"), fill: rgb("#ddffdd"), ..thm-args)
#let claim = thm-def(_localized-head("claim"), fill: rgb("#ddffdd"), ..thm-args)
#let rmk = thm-with-info(borderless-base(_localized-head("remark")))
#let prob = thm-with-info(borderless-base(_localized-head("problem")))
#let exer = thm-with-info(borderless-base(_localized-head("exercise")))
#let exerstar = thm-with-info(borderless-base(_localized-head("exercise-star")))
#let ques = thm-with-info(borderless-base(_localized-head("question")))
#let fact = thm-with-info(borderless-base(_localized-head("fact")))

#let todo = thm-plain("TODO", fill: rgb("#ddaa77"), padding: (x: 0.2em, y: 0.2em), outset: 0.4em).with(numbering: none)
#let proof = thm-proof(_localized-head("proof"))
#let soln = thm-proof(_localized-head("solution"))

// i have no idea how this works but it seems to work ¯\_(ツ)_/¯
#let recall-thm(target-label) = {
  context {
    let el = query(target-label).first()
    let loc = el.location()
    let thms = query(selector(<meta:thm-env-counter>).after(loc))
    let thmloc = thms.first().location()
    let thm = thm-stored.at(thmloc).last()
    (thm.fmt)(
      thm.name, link(target-label, str(thm.number)), thm.body, ..thm.args.named(),
    )
  }
}

#let pmod(x) = $space (mod #x)$
#let bf(x) = $bold(upright(#x))$
#let boxed(x) = rect(stroke: rgb("#003300") + 1.5pt,
  fill: rgb("#eeffee"),
  inset: 5pt, text(fill: rgb("#000000"), x))

// Some shorthands
#let pm = sym.plus.minus
#let mp = sym.minus.plus
#let int = sym.integral
#let oint = sym.integral.cont
#let iint = sym.integral.double
#let oiint = sym.integral.surf
#let iiint = sym.integral.triple
#let oiiint = sym.integral.vol
#let detmat(..args) = math.mat(delim: "|", ..args)
#let ee = $bold(upright(e))$

#let url(s) = {
  link(s, text(font:fonts.mono, s))
}

// Ersatz part command (similar to Koma-Script part in scrartcl)
#let part(s) = {
  heading(numbering: none, text(size: 1.4em, fill: colors.partfill, s))
}

// Unnumbered heading commands
#let h1(..args) = heading(level: 1, outlined: false, numbering: none, ..args)
#let h2(..args) = heading(level: 2, outlined: false, numbering: none, ..args)
#let h3(..args) = heading(level: 3, outlined: false, numbering: none, ..args)
#let h4(..args) = heading(level: 4, outlined: false, numbering: none, ..args)
#let h5(..args) = heading(level: 5, outlined: false, numbering: none, ..args)
#let h6(..args) = heading(level: 6, outlined: false, numbering: none, ..args)

#let standard_font_size = 11pt

// Main entry point to use in a global show rule
#let dobbikov(
  title: [tit],
  author: "Yehor",
  subtitle: none,
  date: none,
  maketitle: true,
  report-style: false,
  language: "en",
  body
) = {
  let language = _normalize-language(language)
  _dobbikov-lang.update(_ => language)
  set text(
    font: fonts.text,
    size: standard_font_size,
    lang: _typst-language(language),
    fallback: false,
  )
  // Set document parameters
  if (title != none) {
    set document(title: title)
  }
  if (author != none) {
    set document(title: title, author: author)
  }

  // Figures formatting
  show figure.caption: cap => context {
    set text(0.95em)
    block(inset: (x: 5em), [
      #set align(left)
      #text(weight: "bold")[#cap.supplement #cap.counter.display(cap.numbering)]#cap.separator#cap.body
    ])
  }

  // Table formatting
  show figure.where(kind: table): fig => {
    // Auto emphasize the table headers
    show table.cell.where(y: 0): set text(weight: "bold")
    let tableframe(stroke) = (x, y) => (
      left: 0pt,
      right: 0pt,
      top: if y <= 1 { stroke } else { 0pt },
      bottom: stroke,
    )
    set table(
      stroke: tableframe(rgb("#21222c")),
      fill: (_, y) => if (y==0) { rgb("#ffeeff") } else if calc.even(y) { rgb("#eaf2f5") },
    )
    fig
  }

  // Report parameters
  show ref: it => {
    let el = it.element
    if el != none and el.func() == heading and el.level == 1 and it.supplement == auto and not report-style {
      ref(it.target, supplement: _tr(language, "chapter"))
    } else {
      it
    }
  }

  // General settings
  set page(
    paper: "a4",
    margin: auto,
    header: context {
      set align(right)
      set text(size:0.8em)
      if (not maketitle or counter(page).get().first() > 1) {
        text(weight:"bold", title)
        if (author != none) {
          h(0.2em)
          sym.dash.em
          h(0.2em)
          text(style:"italic", author)
        }
      }
    },
    numbering: "1",
  )
  set par(
    justify: true,
    first-line-indent: 1em
  )

  // For bold elements, use sans font
  show strong: set text(size: 0.9em)

  // Theorem environments
  show: thm-rules.with(qed-symbol: $square$, thm-ref-color: colors.thm-ref)

  // Change quote display
  set quote(block: true)
  show quote: set pad(x:2em, y:0em)
  show quote: it => {
    set text(style:"italic")
    v(-1em)
    it
    v(-0.5em)
  }

  // Indent lists
  set enum(indent: 1em)
  set list(indent: 1em)

  // Section headers
  set heading(numbering: "1.1")
  show heading: it => {
    if (it.numbering != none) [
        #if(it.level != 1 or report-style == true){[
          #block(width: 100%, [
            #align(center)[
            #text(fill:colors.headers, size: standard_font_size,
              (if (not report-style and it.level == 1) { _tr(language, "chapter") + " " } else { "" })
              + counter(heading).display()
              + (if (not report-style and it.level == 1) { "." } else { "" })
            )
            #h(0.2em)
            #text(size: standard_font_size, it.body)
          #v(0.4em)
        ]
    ])
      ]}else{[
        #pagebreak()
        #v(1.8em)
        #block(width: 100%,
        [
          #box(width: 100%, stroke: (bottom: 2pt), inset: 10pt,
        align(center, text(size: 20pt, 
        [
          #it.body
        ]))
        )
        #emph(text(size: 27pt, weight: "medium")[§#counter(heading).display()])
        #v(1.5em)
      ])
      ]}

    
  ]else[
      #it.body
      #v(0.4em)
  ]
  }
  show heading: set text(size: 11pt)
  show heading.where(level: 1): set text(size: 14pt)
  show heading.where(level: 2): set text(size: 12pt)

  // Hyperlinks should be pretty
  show link: it => {
    set text(fill:
      if (type(it.dest) == label) { colors.label } else { colors.hyperlink }
    )
    it
  }
  show ref: it => {
    link(it.target, it)
  }

  // Gentle clues default font should be sans
  show: gentle-clues.with(
    title-font: "Noto Sans"
  )

  // Title page, if maketitle is true
  if maketitle {
    v(2.5em)
    set align(center)
    set block(spacing: 2em)
    block(text(fill:colors.title, size:2em, weight:"bold", title))
    if (subtitle != none) {
      block(text(size:1.5em, font:fonts.sans, weight:"bold", subtitle))
    }
    if (author != none) {
      block(smallcaps(text(size:1.7em, author)))
    }
    if (type(date) == datetime) {
      block(text(size:1.2em, date.display("[day] [month repr:long] [year]")))
    }
    else if (date != none) {
      block(text(size:1.2em, date))
    }
    v(1.5em)
  }
  body
}
