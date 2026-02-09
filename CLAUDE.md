# Claude Code Project Instructions

## This Project
Resayil Mobile App - WhatsApp-style Flutter messaging app with chats, groups, and status/stories.

## Skills to Read
Before making changes, read these skill files:
- ~/.claude/skills/resayil-app.md (app structure & dev workflow)
- ~/.claude/skills/firebase-testing.md (push notifications testing)

## Key Info
- **Repo**: `github.com/soudshoja/resayil-app` (private, branch: master)
- **Flutter SDK**: `~/flutter/bin/flutter` (v3.27.4)
- **PATH**: `export PATH="$HOME/flutter/bin:$PATH"`
- **API Base**: `https://wa.resayil.io/api/v1` (Bearer token auth)
- **Design**: WhatsApp Native dark theme (#111b21), accent green (#00a884)

## Key Rules
1. Always run `flutter analyze` after changes — must have 0 issues
2. Freezed models require code gen: `flutter pub run build_runner build --delete-conflicting-outputs`
3. Use Riverpod patterns (AsyncNotifier, FamilyAsyncNotifier) — no raw setState
4. GoRouter for navigation — StatefulShellRoute for tab shell
5. Capture `ScaffoldMessenger.of(context)` and `GoRouter.of(context)` BEFORE async gaps
6. `@JsonKey` triggers `invalid_annotation_target` — suppressed in analysis_options.yaml
7. `Color.value` deprecated — use `color.r`, `color.g`, `color.b` component accessors
8. `tail` command not available on this system — don't pipe to tail

## Tech Stack
- Flutter 3.27.4 / Dart 3.6.2
- State: Riverpod (AsyncNotifier, FamilyAsyncNotifier, StateProvider)
- HTTP: Dio + auth interceptor (Bearer token from secure storage)
- Models: Freezed + json_serializable (code gen via build_runner)
- Nav: GoRouter + StatefulShellRoute.indexedStack (4-tab bottom nav)
- DB: Drift (SQLite) — CachedChats, CachedMessages tables
- Storage: flutter_secure_storage for API key
- Images: cached_network_image, image_picker
- Fonts: Google Fonts (Inter)
- L10n: Arabic (RTL) + English via .arb files
- Push: Firebase Core + Firebase Messaging (FCM) + flutter_local_notifications

## Theme Colors
```
Background:     #111b21    Surface:        #1f2c34
Chat BG:        #0b141a    AppBar:         #1f2c34
Outgoing Bubble:#005c4b    Incoming Bubble:#1f2c34
Accent:         #00a884    Text Primary:   #e9edef
Text Secondary: #8696a0    Read Ticks:     #53bdeb
Badge:          #00a884    Error:          #ef5350
Border:         #2a3942
```

## Running Commands
```bash
export PATH="$HOME/flutter/bin:$PATH"
cd ~/resayil_app
flutter analyze          # Check for issues (must be 0)
flutter test             # Run tests
flutter pub run build_runner build --delete-conflicting-outputs  # Regenerate code
flutter run              # Run on connected device
```

## Phases Status
| Phase | Name | Status | Commit |
|-------|------|--------|--------|
| 1 | Foundation | Done | 8a9f71b |
| 2 | Chats | Done | 60a743c |
| 3 | Groups | Done | f8e0ec5 |
| 4 | Status/Stories | Done | b908bd2 |
| 5 | Push Notifications | Done | 6331900 |
| 6 | Polish | Pending | — |
| 7 | Release | Pending | — |

## Related Projects
- **Collect Resayil Gateway** (`~/collect-resayil-io`) — Laravel payment platform (separate project)
- Skills like n8n, SSH, browser-testing are shared across projects
