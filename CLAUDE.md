# CLAUDE.md — Game for Peter

A Godot 4 (GDScript) educational game for learning the alphabet and words, targeting **iOS** (iPhone/iPad).

---

## Project Overview

- **Engine:** Godot 4.7 (stable)
- **Language:** GDScript
- **Target platform:** iOS (iPhone/iPad)
- **Audience:** Young children learning letters and words
- **Repo:** https://github.com/vlalez/Game_for_Peter

> Note: Godot 4's C# support does not cover iOS — GDScript is required for iOS builds.

---

## Repository Structure

```
project.godot          # Godot project file (committed to git)
export_presets.cfg     # Export profiles for iOS (committed to git)
icon.svg               # App icon

scenes/
  start/
    StartScene.tscn    # Start screen scene
    StartScene.gd      # Start screen logic
  game/
    GameScene.tscn     # Main gameplay scene
    GameScene.gd       # Gameplay orchestration
    LetterTile.tscn    # Draggable letter tile prefab
    LetterTile.gd      # Drag-and-drop logic
    DropSlot.tscn      # Square drop target prefab
    DropSlot.gd        # Slot acceptance logic

scripts/
  autoloads/
    AudioManager.gd    # Singleton — all sound playback
    SceneLoader.gd     # Singleton — scene transitions

resources/
  words/               # WordData resources (.tres), one per word
  fonts/               # Custom fonts
  audio/               # Sound effects, music
  images/              # Word illustration sprites (cat.png, dog.png …)

addons/                # Third-party Godot plugins (if any)
```

---

## Coding Conventions (GDScript)

- **File names:** `snake_case.gd` and `snake_case.tscn`
- **Class names:** `PascalCase` (declared with `class_name`)
- **Variables and functions:** `snake_case`
- **Constants:** `ALL_CAPS`
- **Private members:** prefix with `_` (e.g. `_current_word`)
- **No magic strings or numbers** — use constants or `WordData` resources.
- **Signals over direct calls** — use `signal` for communication between nodes. Never let a child node call methods on a parent directly.
- **Type hints everywhere** — always annotate variables and function signatures:
  ```gdscript
  var score: int = 0
  func load_word(data: WordData) -> void:
  ```
- **One responsibility per script** — `LetterTile.gd` handles drag logic only; `GameScene.gd` orchestrates the round.

---

## Architecture Notes

- **Word data** lives in `Resource` files (`WordData.tres`) under `resources/words/`. Never hardcode word content in scripts.
- **WordData** custom resource:
  ```gdscript
  class_name WordData
  extends Resource

  @export var word: String          # e.g. "HOUSE"
  @export var image: Texture2D      # illustration sprite
  @export var pronunciation: AudioStream  # optional spoken word
  ```
- **Autoloads (singletons):** `AudioManager` and `SceneLoader` are registered as Autoloads in `Project > Project Settings > Autoload`. Access them globally without `get_node`.
- **Scene transitions:** always go through `SceneLoader.gd` — never call `get_tree().change_scene_to_file()` directly from gameplay scripts.
- **Audio:** always play sounds through `AudioManager` — never instantiate `AudioStreamPlayer` nodes ad hoc in gameplay scripts.
- **Localization:** use Godot's built-in localization (CSV or PO files under `locale/`). All player-visible strings must go through `tr()` — no hardcoded text in scripts or scenes.

---

## Scenes & Screen Flow

### StartScene
The first scene loaded on launch. Full-screen background with two buttons.

| Button         | Action                                        |
|----------------|-----------------------------------------------|
| **Start Game** | Calls `SceneLoader.go_to_game()` |
| **Quit**       | Calls `get_tree().quit()`                     |

Implementation notes:
- Script: `scenes/start/StartScene.gd`
- The **Quit** button is acceptable on iOS for a children's app, but note Apple may flag explicit quit buttons during review — wrap in `if OS.get_name() != "iOS"` if this becomes an issue.
- Layout must adapt to both portrait and landscape using anchors and `Control` node layout presets.

### GameScene
The main gameplay screen. The child sees an image, scrambled square letter tiles, and empty square drop slots.

#### Layout

**Portrait** (image top, tiles + slots below):
```
┌─────────────────────────────┐  ← top-right: [Quit Game] button
│                             │
│        [ Word Image ]       │  ← top ~50% of screen
│                             │
│      □  □  □  □  □  □       │  ← draggable square letter tiles (scrambled)
│                             │
│      □  □  □  □  □  □       │  ← square drop slots (one per letter)
│                             │
└─────────────────────────────┘
```

**Landscape** (image left, tiles + slots right):
```
┌──────────────┬──────────────────────┐  ← top-right: [Quit Game] button
│              │   □  □  □  □  □  □   │  ← letter tiles
│  [ Image ]   │                      │
│              │   □  □  □  □  □  □   │  ← drop slots
└──────────────┴──────────────────────┘
```

#### Gameplay mechanics
- The **image** illustrates the target word.
- **Letter tiles** are displayed in scrambled order. Each tile is a draggable square `Control` node.
- **Drop slots** are square outlines (same size as tiles), one per letter.
- Dragging a tile onto the correct slot snaps it in; wrong slot returns the tile to its origin.
- When all slots are filled correctly — play a success sound and load the next word.
- The **Quit Game** button sits on a `CanvasLayer` with a high layer index so it is never obscured by tiles.
- Show a brief confirmation dialog ("Are you sure?") before quitting to prevent accidental taps.

#### Word constraints
- **Word length:** 3 to 9 letters (e.g. "CAT" → "SUNFLOWER").
- Tiles and slots are generated **dynamically** at runtime based on word length — no fixed layouts.
- **Tile sizing:** use `HBoxContainer` with `size_flags_horizontal = SIZE_EXPAND_FILL` so tiles shrink gracefully for longer words. Minimum tile size ~60px; font size clamped between 24px (9 letters) and 48px (3 letters).
- SUNFLOWER (9 letters) is intentionally kept as the longest word — use it as the stress test for tile scaling.

#### Implementation scripts
- `scenes/game/GameScene.gd` — round orchestration, word loading, win detection
- `scenes/game/LetterTile.gd` — drag logic using `_gui_input()` or `_get_drag_data()` / `_can_drop_data()` / `_drop_data()`
- `scenes/game/DropSlot.gd` — slot acceptance and snapping logic

### Scene flow
```
StartScene  →  (Start Game button)  →  GameScene
GameScene   →  (Quit Game button)   →  quits the app
```

Register `StartScene.tscn` as the **Main Scene** in `Project > Project Settings > Application > Run`.

---

## Word List (v1 — 30 words)

All images must be free to use. Source from [Unsplash](https://unsplash.com) (free, no attribution required) or [Pixabay](https://pixabay.com) (free, CC0). Download each image, rename it to match the `imageFile` column, and place it under `resources/images/`.

Each word maps to one `WordData` resource at `resources/words/<word>.tres`.

| #  | Word      | Letters | Image search term  | imageFile      |
|----|-----------|---------|--------------------|----------------|
| 1  | CAT       | 3       | cat                | cat.png        |
| 2  | DOG       | 3       | dog                | dog.png        |
| 3  | SUN       | 3       | sun sky            | sun.png        |
| 4  | BEE       | 3       | bee flower         | bee.png        |
| 5  | EGG       | 3       | egg                | egg.png        |
| 6  | BIRD      | 4       | bird               | bird.png       |
| 7  | FISH      | 4       | fish               | fish.png       |
| 8  | FROG      | 4       | frog               | frog.png       |
| 9  | LION      | 4       | lion               | lion.png       |
| 10 | DUCK      | 4       | duck               | duck.png       |
| 11 | BEAR      | 4       | bear               | bear.png       |
| 12 | CAKE      | 4       | cake               | cake.png       |
| 13 | STAR      | 4       | star night sky     | star.png       |
| 14 | TREE      | 4       | tree               | tree.png       |
| 15 | ROSE      | 4       | rose flower        | rose.png       |
| 16 | APPLE     | 5       | apple fruit        | apple.png      |
| 17 | HORSE     | 5       | horse              | horse.png      |
| 18 | HOUSE     | 5       | house              | house.png      |
| 19 | TIGER     | 5       | tiger              | tiger.png      |
| 20 | CRANE     | 5       | crane bird         | crane.png      |
| 21 | LEMON     | 5       | lemon fruit        | lemon.png      |
| 22 | CAMEL     | 5       | camel desert       | camel.png      |
| 23 | DRAGON    | 6       | dragon             | dragon.png     |
| 24 | PILLOW    | 6       | pillow             | pillow.png     |
| 25 | SPIDER    | 6       | spider             | spider.png     |
| 26 | BANANA    | 6       | banana fruit       | banana.png     |
| 27 | CASTLE    | 6       | castle             | castle.png     |
| 28 | BRIDGE    | 6       | bridge             | bridge.png     |
| 29 | DOLPHIN   | 7       | dolphin            | dolphin.png    |
| 30 | SUNFLOWER | 9       | sunflower          | sunflower.png  |

> SUNFLOWER (9 letters) is intentionally kept as the longest word and serves as the stress test for tile scaling.

---

## Platform Notes — iOS

- **Minimum iOS version:** iOS 14+
- **Orientation:** Both portrait and landscape supported. Set in `Project > Project Settings > Display > Window` and in the iOS export preset under `Orientations`.
- **Export:** requires a Mac with Xcode and an Apple Developer account. Generate the Xcode project via `Project > Export > iOS`, then build and submit via Xcode or Xcode Cloud.
- **Input:** Godot handles touch input natively — no extra setup needed. Use `InputEventScreenTouch` and `InputEventScreenDrag` for custom touch logic if needed.
- **Do not commit** the generated Xcode project — add it to `.gitignore`. It is regenerated on each export.

---

## Download — No Installer Needed

Godot is a single executable (~80 MB), no installation or Hub required:

- **Primary:** [godotengine.org/download](https://godotengine.org/download)
- **Mirror (if primary is blocked):** [sourceforge.net/projects/godot-engine.mirror](https://sourceforge.net/projects/godot-engine.mirror)
- **GitHub releases:** [github.com/godotengine/godot/releases](https://github.com/godotengine/godot/releases)

Download `Godot_v4.7-stable_win64.exe` (Windows) or `Godot_v4.7-stable_macos.universal.zip` (Mac), unzip, and run. No license activation needed.

---

## Build & Export Commands

Godot supports headless export via command line (useful for CI):

```bash
# Export iOS (requires Mac + Xcode)
godot --headless --export-release "iOS" ./build/GameForPeter.ipa
```

Export presets are defined in `export_presets.cfg`. Register iOS export templates via `Editor > Manage Export Templates` before first export.

---

## Testing

- **In-editor:** press `F5` to run the project from the Main Scene, `F6` to run the currently open scene.
- **Unit tests:** use [GUT (Godot Unit Test)](https://github.com/bitwes/Gut) plugin for logic testing (word validators, shuffle functions, slot matching).
- **Device testing:** connect an iPhone/iPad via USB and use Xcode's device runner after exporting the Xcode project.
- All word-matching and tile-shuffle logic must have GUT tests before merging.

---

## Git Workflow

- **Branch naming:** `feature/<short-description>`, `fix/<short-description>`, `chore/<short-description>`
- **Commit style:** Conventional Commits — `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`
- **`.gitignore`:** exclude `.godot/`, `build/`, and generated Xcode projects.
- **Large assets (images, audio):** use [Git LFS](https://git-lfs.github.com/) for files > 1 MB.
- **PRs:** squash-merge into `main`. Each PR should be focused on one feature or fix.

---

## Key Constraints for Claude Code

- **Do not** hardcode word content, letter sequences, or image paths in scripts — always use `WordData` resources.
- **Do not** call `get_tree().change_scene_to_file()` directly — always go through `SceneLoader`.
- **Do not** play audio directly — always go through `AudioManager`.
- **Do not** use `find_child()` or `get_node()` with hardcoded long paths — use `@onready` variables or signals.
- **Always** use type hints on variables and function signatures.
- **Always** disconnect signals in `_exit_tree()` if connected manually to avoid memory leaks.
- **Always** handle the case where a `WordData` resource is `null` before accessing its properties.
- When adding a new word, create both the `.tres` resource and add the image to `resources/images/`.
- When adding a new Autoload, register it in `Project > Project Settings > Autoload` and document it here.
