#!/bin/bash
set -euo pipefail

THEME="${1:-material-theme-palenight}"

# Theme color mappings
case "$THEME" in
  material-theme-palenight)
    BG="#292D3E" KW="#C792EA" TY="#FFCB6B" FN="#82AAFF" ST="#C3E88D"
    SE="#89DDFF" NM="#F78C6C" CM="#676E95" OP="#89DDFF" VR="#babed8"
    PR="#f07178" AT="#F78C6C" PN="#89DDFF"
    ;;
  tokyo-night)
    BG="#1a1b26" KW="#bb9af7" TY="#2ac3de" FN="#7aa2f7" ST="#9ece6a"
    SE="#89ddff" NM="#ff9e64" CM="#51597d" OP="#89ddff" VR="#c0caf5"
    PR="#e0af68" AT="#ff9e64" PN="#9aa5ce"
    ;;
  kanagawa-wave)
    BG="#1F1F28" KW="#957FB8" TY="#E6C384" FN="#7E9CD8" ST="#98BB6C"
    SE="#7FB4CA" NM="#FFA066" CM="#727169" OP="#C0A36E" VR="#DCD7BA"
    PR="#E6C384" AT="#FFA066" PN="#9CABCA"
    ;;
  dracula)
    BG="#282a36" KW="#ff79c6" TY="#8be9fd" FN="#50fa7b" ST="#f1fa8c"
    SE="#ff79c6" NM="#bd93f9" CM="#6272a4" OP="#f8f8f2" VR="#f8f8f2"
    PR="#ffb86c" AT="#50fa7b" PN="#f8f8f2"
    ;;
  rose-pine-moon)
    BG="#232136" KW="#3e8fb0" TY="#9ccfd8" FN="#ea9a97" ST="#f6c177"
    SE="#3e8fb0" NM="#ea9a97" CM="#6e6a86" OP="#908caa" VR="#e0def4"
    PR="#c4a7e7" AT="#c4a7e7" PN="#908caa"
    ;;
  *)
    echo "Unknown theme: $THEME"
    echo "Available: material-theme-palenight, tokyo-night, kanagawa-wave, dracula, rose-pine-moon"
    exit 1
    ;;
esac

echo "Switching to: $THEME"

# Update astro.config.mjs
sed -i "s/themes: \['[^']*'\]/themes: ['$THEME']/" astro.config.mjs

# Update fe-highlight.css
sed -i "s/--fe-hl-keyword, #[^)]*)/--fe-hl-keyword, $KW)/" public/fe-highlight.css
sed -i "s/--fe-hl-type, #[^)]*)/--fe-hl-type, $TY)/" public/fe-highlight.css
sed -i "s/--fe-hl-type-interface, #[^)]*)/--fe-hl-type-interface, $TY)/" public/fe-highlight.css
sed -i "s/--fe-hl-type-variant, #[^)]*)/--fe-hl-type-variant, $TY)/" public/fe-highlight.css
sed -i "s/--fe-hl-function, #[^)]*)/--fe-hl-function, $FN)/" public/fe-highlight.css
sed -i "s/--fe-hl-string, #[^)]*)/--fe-hl-string, $ST)/" public/fe-highlight.css
sed -i "s/--fe-hl-string-escape, #[^)]*)/--fe-hl-string-escape, $SE)/" public/fe-highlight.css
sed -i "s/--fe-hl-number, #[^)]*)/--fe-hl-number, $NM)/" public/fe-highlight.css
sed -i "s/--fe-hl-comment, #[^)]*)/--fe-hl-comment, $CM)/" public/fe-highlight.css
sed -i "s/--fe-hl-operator, #[^)]*)/--fe-hl-operator, $OP)/" public/fe-highlight.css
sed -i "s/--fe-hl-variable, #[^)]*)/--fe-hl-variable, $VR)/g" public/fe-highlight.css
sed -i "s/--fe-hl-attribute, #[^)]*)/--fe-hl-attribute, $AT)/" public/fe-highlight.css
sed -i "s/--fe-hl-punctuation, #[^)]*)/--fe-hl-punctuation, $PN)/" public/fe-highlight.css
sed -i "s/--fe-code-bg, #[^)]*)/--fe-code-bg, $BG)/" public/fe-highlight.css

echo "Done. Restart dev server (rm -rf .astro && pnpm dev) to see changes."
