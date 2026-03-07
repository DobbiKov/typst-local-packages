# dobbikov (Typst package)

A local Typst package that sets up a LaTeX-like report style with custom headers,
figure/table styling, theorem environments, and gentle-clues callouts.

## Quick start

```typst
#import "@local/dobbikov:1.0.0": *

#show: dobbikov.with(
  title: [New Document],
  subtitle: none,
  author: "Yehor KOROTENKO",
  date: datetime.today(),
  language: "en",
)

#toc

= First Section
Some text.

#thm[Every even integer is the sum of two primes.] <goldbach>

Refer to @goldbach.
```

## Package entry point

`dobbikov` is the main show rule helper. It sets page layout, headings, fonts,
list indentation, hyperlink styles, and theorem rules, and optionally renders a
simple title page.

```typst
#show: dobbikov.with(
  title: [My Report],
  author: "Your Name",
  subtitle: [Optional subtitle],
  date: datetime.today(),
  maketitle: true,
  report-style: false,
  language: "en",
)
```

Parameters:
- `title`: document title (content). Use `none` to skip.
- `author`: author string. Use `none` to skip.
- `subtitle`: optional subtitle (content).
- `date`: `datetime` or string; use `none` to skip.
- `maketitle`: render a title page-like block at top.
- `report-style`: if `true`, heading level 1 is treated as chapters in refs.
- `language`: UI language for auto labels and theorem names. Allowed values: `"en"`, `"fr"`, `"ua"`.

## Table of contents

`#toc` renders a styled table of contents.

```typst
#toc
```

## Callout environments (gentle-clues)

These are wrappers around `gentle-clues` with preset accents:

```typst
#definition[Definition text.]
#problem[Problem statement.]
#exercise[Exercise text.]
#sample[Sample question.]
#solution[Solution text.]
#remark[Remark text.]
#recipe[Recipe text.]
#typesig[Type signature text.]
#digression[Digression text.]
```

## Theorem environments

Predefined theorem-like environments (numbered by heading):

```typst
#defn[Definition body.]
#thm[Theorem body.]
#lem[Lemma body.]
#prop[Proposition body.]
#notation[Notation body.]
#cor[Corollary body.]
#conj[Conjecture body.]
#ex[Example body.]
#algo[Algorithm body.]
#claim[Claim body.]
#rmk[Remark body.]
#prob[Problem body.]
#exer[Exercise body.]
#exerstar[Exercise (*) body.]
#ques[Question body.]
#fact[Fact body.]

#proof[Proof body.]
#soln[Solution body.]
```

Optional names:

```typst
#thm("Pythagoras")[...]
#defn(info: "Metric space")[...]
```

### Theorem styling helpers

If you need custom theorem styles, these helpers are exposed:

- `thm-border-style`
- `thm-borderless-style`
- `thm-leftbars-style`
- `thm-bordered`
- `thm-with-info`
- `border-base`, `borderless-base`, `leftbars-base`

These build on the bundled `theorems.typ` (from typst-theorems).

## Math helpers

```typst
#eqn[$E = mc^2$]
#pageref(<label>)
#pmod(x)
#bf(x)
#boxed(x)

$#pm$ $ #mp$ $ #int $ $ #oint $ $ #iint $ $ #oiint $ $ #iiint $ $ #oiiint $
#detmat(1, 2; 3, 4)
$#ee$
```

## Layout helpers

```typst
#part([Part Title])
#h1([Unnumbered heading 1])
#h2([Unnumbered heading 2])
#h3([Unnumbered heading 3])
#h4([Unnumbered heading 4])
#h5([Unnumbered heading 5])
#h6([Unnumbered heading 6])
```

## URL helper

```typst
#url("https://example.com")
```

## Fonts and dependencies

- Text/sans/mono default to "New Computer Modern".
- `gentle-clues` is imported from `@preview/gentle-clues:1.2.0`.
- Theorem machinery is based on `theorems.typ` (typst-theorems).

## Template

A minimal template exists at `template/main.typ` and is registered in
`typst.toml` for `typst init` usage.

## License

MIT.
