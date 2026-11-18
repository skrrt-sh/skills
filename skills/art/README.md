# art

Consistent image sets with [Higgsfield](https://higgsfield.ai): write the style once, build every
repeated object as a prop, then render and check the set. Needs the Higgsfield connector, or the
signed-in `higgsfield` CLI as a fallback, plus `jq`, `curl`, and ImageMagick.

This bucket is its own Claude Code plugin (`claude plugin install art@skrrt`), so its skills are
namespaced `/art:style`, `/art:prop`, and `/art:image`.

- **[style](./style/SKILL.md)**: Turn reference images into a written style file and prove it on unrelated subjects with no images attached.
- **[prop](./prop/SKILL.md)**: Freeze an object's identity, render a master and every angle, and keep them as references.
- **[image](./image/SKILL.md)**: Render the set from the style file and props, check every image on a sheet, and re-render misses.
