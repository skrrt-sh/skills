# Platform UX principles

Starting points with source and date. Re-check the live source when a decision rests on it.

## Process sources

- Stories: [GOV.UK user stories](https://www.gov.uk/service-manual/agile-delivery/writing-user-stories),
  [INVEST](https://xp123.com/invest-in-good-stories-and-smart-tasks/),
  [job stories](https://www.intercom.com/blog/using-job-stories-design-features-ui-ux/),
  [need statements](https://www.nngroup.com/articles/user-need-statements/),
  [story mapping](https://www.nngroup.com/articles/user-story-mapping/).
- Patterns: [competitive evaluations](https://www.nngroup.com/articles/competitive-usability-evaluations/),
  [pattern guidelines](https://www.nngroup.com/articles/design-pattern-guidelines/),
  [Jakob's Law](https://lawsofux.com/jakobs-law/),
  [10 heuristics](https://www.nngroup.com/articles/ten-usability-heuristics/) (2024),
  [cognitive load](https://www.nngroup.com/articles/4-principles-reduce-cognitive-load/),
  [GOV.UK principles](https://www.gov.uk/guidance/government-design-principles).
- Delight: [theory of delight](https://www.nngroup.com/articles/theory-user-delight/),
  [aesthetic-usability effect](https://www.nngroup.com/articles/aesthetic-usability-effect/).

## Mobile app

[Apple HIG](https://developer.apple.com/design/human-interface-guidelines),
[Material 3](https://m3.material.io).

- Bottom navigation for 3 to 5 destinations, icon plus label (M3 navigation bar, HIG tab bars).
- Tabs navigate; they never act.
- Targets at least 44 pt or 48 dp, 8 dp apart.
- System gestures and controls over custom ones.
- Text scales to 200%; contrast meets WCAG AA.
- Key actions at the top or bottom, within reach.
- Skip or minimize onboarding.
  [NN/g onboarding](https://www.nngroup.com/articles/mobile-app-onboarding/) (2020).
- Keep navigation visible.
  [NN/g hamburger menus](https://www.nngroup.com/articles/hamburger-menus/) (2016).
- Split complex tasks into steps, show every status, end with a receipt.

## Web app and SaaS

[NN/g complex applications](https://www.nngroup.com/articles/complex-application-design/)
(Nov 2020) unless noted.

- Learn by doing: safe trial and undo.
- Shortcuts in context for frequent users.
- Skip ahead and step back in multi-step work; resume after interruptions.
- Staged disclosure: basics first, advanced on demand.
- Peek at secondary information in place.
- Critical data stands out.
- System status, error prevention, plain-language errors (NN/g heuristics, 2024).
- Targets at least 24 CSS px (WCAG 2.2, 2.5.8).
- Tables support find, compare, view or edit, batch actions.
  [NN/g data tables](https://www.nngroup.com/articles/data-tables/) (2022).
- Keep desktop navigation visible.

## Landing page

[NN/g homepage principles](https://www.nngroup.com/articles/homepage-design-principles/)
(Mar 2024) unless noted.

- Logo top left with a tagline that says what you do.
- Unique value in the hero.
- Concrete examples of the product.
- Main tasks most prominent.
- Most important content in the first two screens: 57% of viewing time above the fold, 74% in
  the first two. [NN/g scrolling](https://www.nngroup.com/articles/scrolling-and-attention/)
  (2018).
- Simple standard layout, little motion, no pop-ups or splash.
- One primary call to action per section, saying what happens.

## Forms and checkout

- Single column; mark required and optional; state requirements upfront; errors on the field.
  NN/g forms (Jul 2025), [GOV.UK patterns](https://design-system.service.gov.uk/patterns/).
- Checkout: cut fields before steps; average 11.3 fields.
  [Baymard checkout](https://baymard.com/research/checkout-usability) (2024).
