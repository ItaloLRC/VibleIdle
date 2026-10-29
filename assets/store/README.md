# Store icons

Edit catalog.json (16x16 pixel silhouettes with per-icon game-palette color).
Run `python tools/generate_store_icons.py` from the project root.
This writes seven transparent SVGs here and src/client/StoreIconCatalog.luau.
StoreIcon.luau renders matching passive rectangles natively in Roblox; SVG upload
or external image hosting is unnecessary. tools/verify.py checks reconstruction,
generated-source equality and all seven SVGs. Keep changes in this project only.
