# QA checklist

## Layout and visual
- [ ] Desktop 1440, laptop 1280, tablet 768, mobile 390: nothing overflows horizontally, nothing overlaps
- [ ] Spacing follows the scale; alignment on a consistent grid
- [ ] Type scale, weights and line-heights match DESIGN.md; no orphaned default fonts
- [ ] Colours only from DESIGN.md tokens (or, before the design-capture ticket, the seed palette in DESIGN.md/direction.html); dark mode (if specified) has no unreadable pairs
- [ ] Cards, surfaces, borders, shadows follow the elevation rules
- [ ] Icons consistent in set, size and stroke
- [ ] Images/logos crisp, correct aspect ratio

## Interaction
- [ ] Every button/link has hover, active and focus-visible states as specified
- [ ] Transitions use the specified durations/easing; nothing janky; respects reduced motion
- [ ] Primary action per screen is obvious
- [ ] Forms: labels, placeholder vs label, inline validation, error messages in plain language, disabled submit while pending, success feedback
- [ ] Destructive actions confirm; undo where sensible
- [ ] Keyboard: tab order logical, Escape closes dialogs, Enter submits

## States
- [ ] Empty state with guidance and a next action
- [ ] Loading: skeletons or spinners, no layout jump
- [ ] Error: request failure shows a helpful message, not a blank screen
- [ ] Long content: long names, 1000 rows, missing optional fields

## Correctness
- [ ] Each acceptance criterion in the ticket verified by doing it
- [ ] Data persists after refresh; appears for the right role and is hidden from the wrong role (RLS check with a second account if available)
- [ ] No console errors; no failed network requests; no 404 assets
- [ ] Page titles and meta sensible; favicon present

## Content
- [ ] Copy uses CONTEXT.md terms and the specified language
- [ ] Danish formats: `1.234,56 kr.`, dates `23. sep. 2026`, 24-hour time

## Accessibility
- [ ] Contrast AA for all text
- [ ] Inputs labelled; images have alt text; icon buttons have accessible names
- [ ] Colour is never the only signal
