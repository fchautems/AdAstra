# PROJECT_STATE — AdAstra

Updated: 2026-09-11

## Verified state

- `plans/top-view-v11-base.svg` remains the validated wall-free top-view geometry baseline.
- `plans/top-view-v14-walls.svg` remains the accepted main-wall reference built on v11.
- `plans/ship-layout-v1.json` remains the last accepted parametric source for the validated top-view geometry and cabin-bay layout.
- Scale: 1 grid unit = 1 metre.
- Overall reference size: 58 m long, 32 m maximum width.
- Central corridor clear width: 2 m.
- Straight lateral corridor clear width: 2 m.
- Cylinder: x=10..43 m, 33 m long, 16 m diameter in side profile.
- Main wall thickness: 0.35 m. Cabin partition thickness: 0.18 m.
- Six cabin bays are defined: three per side. Upper side = 9 m command cabin + 7 m + 7 m standard cabins. Lower side = 7.5 m + 8 m + 7.5 m standard cabins.
- Every cabin requires a private bathroom, private kitchenette and large external window; detailed bathroom/kitchen geometry is still deferred.

## Current side-profile study

Current profile source:
- `plans/side-profile-v5-horizontal-band.json`

Current combined reference:
- `plans/top-and-side-v3.svg`

Current profile assumptions / decisions:
- cockpit remains triangular in side view;
- provisional cockpit height is 8 m;
- cockpit floor is aligned with the corridor floor;
- rotating cylinder is 16 m high, centered on the longitudinal axis;
- inhabited/circulation band is 2 m high and horizontal in side profile;
- this band runs flat from x=10 to the hangar at x=43; no diagonal/taper is drawn in side profile;
- hangar begins directly at the rear face of the cylinder at x=43;
- no visible corridor is drawn inside the hangar;
- hangar floor is aligned with the corridor floor;
- current provisional hangar height is 5 m;
- top-and-side v3 restores the cabin openings in top view and keeps both views on the same longitudinal scale.

Cockpit and hangar final heights are still provisional and must be refined visually.

## Latest door iterations

- Multiple JSON/SVG attempts were made to add rear doors, but the latest visual result was rejected because the rear-door geometry remained incorrect.
- The latest rejected pair is archived for traceability under:
  - `plans/iterations/ship-layout-v10-rear-side-doors-clean-rejected.json`
  - `plans/iterations/top-view-v26-rear-side-doors-clean-rejected.svg`
- These files are **not** the accepted plan and must not replace v11/v14 as geometry references.
- Cabin openings are useful and are shown again in the current combined top/side reference; the problematic rear-door details remain deferred.

## Plan editor

- Detailed specification is stored at `specs/plan-editor-v0.1.md`.
- Intended architecture: semantic geometry (`nodes + walls + corridors + doors`) with shared nodes, derived wall faces, door-to-wall attachment, snapping and deterministic SVG generation.
- The first editor prototype is not considered functional yet: click selection and door opening/editing do not work reliably.
- Do not rely on the editor for plan production until these basic interactions are fixed.

## Checks

- v11/v14 remain the accepted top-view geometry references.
- The profile study is now explicitly separated from the validated top-view baseline.
- `top-and-side-v3.svg` is a comparison/dimensioning reference, not yet a final orthographic drawing.
- Rear-door geometry remains unresolved and is intentionally not blocking the profile work.

## Blockers

- Rear-door geometry is still not validated.
- Plan editor interaction is currently broken/non-functional for reliable editing.
- Cockpit and hangar final vertical proportions are still provisional.

## Next action

- Continue validating the combined top/profile geometry using `plans/top-and-side-v3.svg`, then refine cockpit/hangar heights and profile details before returning to rear doors or the editor.

