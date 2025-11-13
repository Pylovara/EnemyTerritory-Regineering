# Enemy Territory - Phase 2: Include Path Fixing

## Überblick

Nach Phase 1 (Reorganisation der Verzeichnisstruktur) brauchen wir Phase 2 um:

1. **Alle `#include` Pfade zu aktualisieren** - von der alten Struktur zur neuen
2. **Build-Dateien anzupassen** (SConstruct, Makefiles, .vcproj)
3. **Alles mit Dry-Run zu testen** - bevor echte Änderungen gemacht werden

## Alte Struktur → Neue Struktur

```
ALT (flach):                          NEU (organisiert):
├── renderer/          →              engine/renderer/
├── qcommon/           →              shared/qcommon/
├── game/              →              game/game/
├── client/            →              client/client/
├── cgame/             →              client/cgame/
├── ui/                →              client/ui/
├── win32/             →              windows/win32/
├── unix/              →              linux/unix/
└── ...
```

## Schritt-für-Schritt

### 1. Analyse durchführen

```bash
cd /workspaces/EnemyTerritory-BloodySkulls
bash phase2-analyze.sh
```

Das Script:
- Scannt alle `#include` Zeilen in allen `.c` und `.h` Dateien
- Erstellt eine Mapping-Datei (`phase2-mapping.txt`)
- Erstellt einen Analyse-Report (`phase2-analysis.txt`)

### 2. Dry-Run durchführen

```bash
bash phase2-fix.sh --dry-run
```

Das zeigt dir **genau welche Dateien geändert werden** ohne echte Änderungen zu machen.

Beispiel-Ausgabe:
```
[DRY-RUN] /workspaces/.../game/g_main.c
  Unterschiede:
  - #include "qcommon/q_shared.h"
  + #include "../shared/qcommon/q_shared.h"
```

### 3. Echte Änderungen durchführen

Wenn der Dry-Run gut aussieht:

```bash
bash phase2-fix.sh
```

Das Script:
- Erstellt automatisch ein Backup
- Ersetzt alle Include-Pfade
- Zeigt dir das Backup-Verzeichnis für Notfälle

## Was ersetzt wird?

### Include-Pfade (lokal mit "")

```c
// ALT:
#include "qcommon/q_shared.h"
#include "renderer/tr_types.h"
#include "game/g_local.h"

// NEU:
#include "../shared/qcommon/q_shared.h"
#include "../engine/renderer/tr_types.h"
#include "../game/game/g_local.h"
```

### Build-Dateien

- `SConstruct` - Pfade in Include-Pfaden
- `.vcproj` - Visual Studio Project Pfade (optional)
- `Makefiles` - Include-Verzeichnisse (optional)

## Backup & Recovery

Jedes Phase-2-Script erstellt ein Backup:

```bash
# Dateien aus Backup zurückcopieren:
cp -r /workspaces/EnemyTerritory-BloodySkulls/backup-phase2-YYYYMMDDHHMMSS/* \
      /workspaces/EnemyTerritory-BloodySkulls/workspace/original-et-source/src/
```

## Plattformen

Phase 2 arbeitet **plattformübergreifend**:
- ✓ Linux
- ✓ Windows
- ✓ Android (wenn vorhanden)

Die Pfade werden automatisch korrekt ersetzt.

## Problembehebung

### "Zu viele Änderungen"

Das ist OK! Das Script zeigt dir alle Änderungen im Dry-Run.

### "Include nicht gefunden nach Dry-Run"

1. Überprüfe `phase2-analysis.txt` auf alle gefundenen Includes
2. Passe `phase2-fix.sh` manuell an wenn spezielle Pfade da sind
3. Führe Dry-Run nochmal aus

### "Etwas ging schief"

```bash
# Backup zurückcopieren
cp -r backup-phase2-XXX/* workspace/original-et-source/src/

# Dry-Run nochmal ausführen
bash phase2-fix.sh --dry-run
```

## Nächste Schritte nach Phase 2

- [ ] Testen dass der Code kompiliert
- [ ] Dateien in die neue Ordnerstruktur kopieren
- [ ] Build-Dateien testen

---

**Sicherheit first:** Nutze IMMER `--dry-run` zuerst!
