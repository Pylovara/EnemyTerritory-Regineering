#!/bin/bash
# Enemy Territory Phase 2: Include Path Analysis & Replacement
# Scannt alle #include Zeilen und erstellt ein Mapping für den Pfad-Fix

set -e

WORKSPACE_ROOT="/workspaces/EnemyTerritory-BloodySkulls"
SRC_DIR="$WORKSPACE_ROOT/workspace/original-et-source/src"
ANALYSIS_FILE="$WORKSPACE_ROOT/phase2-analysis.txt"
MAPPING_FILE="$WORKSPACE_ROOT/phase2-mapping.txt"

echo "=========================================="
echo "Enemy Territory Phase 2: Analysis"
echo "=========================================="
echo ""

# Schritt 1: Verzeichnisstruktur dokumentieren
echo "[1/3] Dokumentiere neue Struktur..."
cat > "$MAPPING_FILE" << 'EOF'
# Phase 2: Include Path Mapping
# Format: OLD_PATH -> NEW_PATH

# Engine
renderer/ -> ../engine/renderer/
snd_dma/ -> ../engine/audio/
sys/ -> ../engine/system/
net/ -> ../engine/network/

# Game
game/ -> ../game/game/
botai/ -> ../game/botai/
botlib/ -> ../game/botlib/
server/ -> ../game/server/

# Client
client/ -> ../client/client/
cgame/ -> ../client/cgame/
ui/ -> ../client/ui/

# Shared
qcommon/ -> ../shared/qcommon/
splines/ -> ../shared/splines/
curl-7.12.2/ -> ../shared/curl-7.12.2/
jpeg-6/ -> ../shared/jpeg-6/
ft2/ -> ../shared/ft2/
null/ -> ../shared/null/

# Platform
win32/ -> ../windows/win32/
unix/ -> ../linux/unix/
mac/ -> ../shared/mac/

# Tools
bspc/ -> ../tools/bspc/
extractfuncs/ -> ../tools/extractfuncs/

EOF

echo "✓ Mapping erstellt: $MAPPING_FILE"
echo ""

# Schritt 2: Alle Include-Zeilen finden
echo "[2/3] Scanne alle Include-Zeilen..."
cat > "$ANALYSIS_FILE" << 'EOF'
# Phase 2: Include Analysis Report
# Erstellt: $(date)

## Statistik

EOF

# Finde alle C/H Dateien mit Includes
find "$SRC_DIR" \( -name "*.c" -o -name "*.h" \) -type f > /tmp/source_files.txt
TOTAL_FILES=$(wc -l < /tmp/source_files.txt)
echo "Total source files: $TOTAL_FILES" >> "$ANALYSIS_FILE"
echo ""

# Finde alle lokalen Includes (mit "")
echo "## Local Includes (\"...\")" >> "$ANALYSIS_FILE"
grep -h '#include "' $(find "$SRC_DIR" -name "*.c" -o -name "*.h") 2>/dev/null | sort | uniq >> "$ANALYSIS_FILE" || echo "  (keine gefunden)" >> "$ANALYSIS_FILE"
echo "" >> "$ANALYSIS_FILE"

# Finde alle System Includes (mit <>)
echo "## System Includes (<...>)" >> "$ANALYSIS_FILE"
grep -h '#include <' $(find "$SRC_DIR" -name "*.c" -o -name "*.h") 2>/dev/null | sort | uniq >> "$ANALYSIS_FILE" || echo "  (keine gefunden)" >> "$ANALYSIS_FILE"
echo "" >> "$ANALYSIS_FILE"

# Analysiere Include-Verzeichnisse
echo "## Include Verzeichnis-Struktur" >> "$ANALYSIS_FILE"
echo "" >> "$ANALYSIS_FILE"
for dir in renderer qcommon game client cgame ui botlib server win32 unix; do
    if [ -d "$SRC_DIR/$dir" ]; then
        FILES=$(find "$SRC_DIR/$dir" -name "*.h" | wc -l)
        echo "  $dir/: $FILES header files" >> "$ANALYSIS_FILE"
    fi
done
echo "" >> "$ANALYSIS_FILE"

echo "✓ Analyse erstellt: $ANALYSIS_FILE"
cat "$ANALYSIS_FILE"
echo ""

# Schritt 3: Dry-Run vorbereiten
echo "[3/3] Vorbereitung für Dry-Run..."
echo ""
echo "Nächste Schritte:"
echo ""
echo "1. Überprüfe die Mapping-Datei:"
echo "   cat $MAPPING_FILE"
echo ""
echo "2. Überprüfe die Analyse:"
echo "   cat $ANALYSIS_FILE"
echo ""
echo "3. Starte den Pfad-Fix mit Dry-Run:"
echo "   bash $WORKSPACE_ROOT/phase2-fix.sh --dry-run"
echo ""
echo "4. Wenn alles OK: Starte ohne --dry-run:"
echo "   bash $WORKSPACE_ROOT/phase2-fix.sh"
echo ""

echo "=========================================="
echo "✓ Analyse abgeschlossen!"
echo "=========================================="
