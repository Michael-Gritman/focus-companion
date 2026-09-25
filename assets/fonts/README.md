# Focus UI

`FocusUI.ttf` is a ~3.9 MB variable-font subset of Noto Sans SC, covering current Dart UI text, printable ASCII, and GB2312 common Chinese characters for user-entered Rule names. It is bundled so ordinary Chinese copy does not need a remote font service.

- Upstream: https://github.com/google/fonts/blob/main/ofl/notosanssc/NotoSansSC%5Bwght%5D.ttf
- Downloaded: 2026-09-08 (via jsDelivr mirror of `google/fonts@main`)
- Source SHA-256: `a3041811a78c361b1de50f953c805e0244951c21c5bd412f7232ef0d899af0da`
- License: SIL OFL 1.1, included in `OFL.txt`; original copyright metadata is retained.
- Derivative family name: Focus UI.

When adding Chinese UI copy, regenerate from the upstream source:

```powershell
python -m pip install --target .dart_tool/font-tools fonttools==4.64.0
curl.exe -fL 'https://cdn.jsdelivr.net/gh/google/fonts@main/ofl/notosanssc/NotoSansSC%5Bwght%5D.ttf' -o .dart_tool/NotoSansSC.ttf
python tool/subset_font.py .dart_tool/NotoSansSC.ttf
```

Rare characters outside this coverage use Flutter fallback fonts; on Web that may request a remote font. The subset script preserves the common-character coverage when UI text changes.
