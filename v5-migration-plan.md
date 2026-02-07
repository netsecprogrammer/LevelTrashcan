# LevelTrashcan v5 Migration Plan

## Target: Geode v5.0.0-alpha.1 / GD 2.2081

## Dependency Status

| Dependency | Required? | v5 Index Available? | Action |
|------------|-----------|---------------------|--------|
| geode.node-ids | required | YES (1.22.0-beta.1) | Update version |
| hjfod.gmd-api | required | NO | We are porting it |
| hjfod.gdshare | suggested | NO | Remove (optional dep, not critical) |

## Migration Effort: MODERATE
mod.json updates + Popup de-templating + Event V1→V2 migration

## Changes Required

### 1. mod.json Updates
- `geode`: `"4.0.0-beta.1"` → `"5.0.0-alpha.1"`
- `gd.*`: `"2.2074"` → `"2.2081"` (all platforms)
- `geode.node-ids` version: `"1.12.0"` → `"1.22.0-beta.1"`
- `hjfod.gmd-api` version: `"1.2.1"` → `"1.4.4"` (our ported version)
- Remove `hjfod.gdshare` dependency (not available for v5, only "suggested")

### 2. Popup De-templating (1 class)
**TrashcanPopup.hpp:9**
- `class TrashcanPopup : public Popup<>` → `class TrashcanPopup : public Popup`
- `setup()` → `init()` with `Popup::init(w, h)` call

**TrashcanPopup.cpp:218-224**
- `initAnchored(350, 270)` → `init()` (call Popup::init inside)

### 3. Event V1 → V2 Migration

**UpdateTrashEvent** (Trashed.hpp:11):
```cpp
// OLD: struct UpdateTrashEvent : public Event {};
// NEW: struct UpdateTrashEvent final : public geode::SimpleEvent<UpdateTrashEvent> {
//          using SimpleEvent::SimpleEvent;
//      };
```

**Event posting** (Trashed.cpp — 4 locations: lines 142, 153, 168, 177):
```cpp
// OLD: UpdateTrashEvent().post();
// NEW: UpdateTrashEvent().send();
```

**Listeners** (TrashcanPopup.hpp:12, main.cpp:52):
```cpp
// OLD: EventListener<EventFilter<UpdateTrashEvent>> m_listener;
// NEW: geode::ListenerHandle m_listener;
```

**Listener binding** (TrashcanPopup.cpp:47-49):
```cpp
// OLD: m_listener.bind([this](auto*) { ... return ListenerResult::Propagate; });
// NEW: m_listener = UpdateTrashEvent().listen([this]() { ... });
```

**Listener binding** (main.cpp:64-68):
```cpp
// OLD: m_fields->listener.bind([=, this](auto*) { ... return ListenerResult::Propagate; });
// NEW: m_fields->listener = UpdateTrashEvent().listen([=, this]() { ... });
```

### 4. $modify Hooks (Verify — likely OK)
All hook targets exist in GD 2.2081:
- `GameLevelManager` — deleteLevel(), deleteLevelList()
- `LevelBrowserLayer` — init(), onDeleteSelected()
- `EditLevelLayer` — confirmDelete()
- `MenuLayer` — init()

### 5. No Changes Needed
- No ccArrayToVector, getMetadataRef, ranges:: usage
- No WebRequest/Task usage
- No matjson::Serialize usage
- No std::function in public APIs
- No checkJson usage

## Files (5 source + 2 config)
| File | Lines | Changes |
|------|-------|---------|
| mod.json | 39 | Version bumps, dep updates |
| src/Trashed.hpp | 45 | Event V2 definition |
| src/Trashed.cpp | 215 | .post() → .send() (4 locations) |
| src/TrashcanPopup.hpp | 25 | Popup de-template, ListenerHandle |
| src/TrashcanPopup.cpp | 230 | Popup init, listener binding |
| src/main.cpp | 163 | ListenerHandle, listener binding |
