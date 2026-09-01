# Store screenshots from the real app

The 6.5" App Store set (1242×2688) is captured from the web build and
composed into marketing frames. Both steps are scripted so the set can
be regenerated whenever the UI changes.

```sh
flutter build web --release --no-web-resources-cdn
python3 -m http.server 8099 --directory build/web &
# Captures (414×896 CSS px at DPR 3 = 1242×2688) into build/store/raw/:
node tool/store/drive.js "$(cat tool/store/shots.json)"
# Marketing frames into build/store/appstore_65/:
node tool/store/compose.js
```

`drive.js` takes a JSON list of steps (`tap` at CSS-pixel coordinates,
`goto` a route hash, `wait`, `scroll`, `seed` localStorage, `reload`,
`shot`). Flutter web renders to a canvas, so taps are by position;
`shots.json` holds the sequence for the eight frames listed in
`store/apple/screenshots_plan.md`. Environment: `PW` (path of the
playwright module), `CHROME` (browser executable), `BASE`, `OUT`, `RAW`.
