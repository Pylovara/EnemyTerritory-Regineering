#!/bin/bash
# Enemy Territory Phase 2: Include Path Replacement
# Ersetzt alle Include-Pfade basierend auf der neuen Struktur
# Nutze --dry-run für Preview, sonst werden echte Änderungen vorgenommen

DRY_RUN=false
if [ "$1" = "--dry-run" ]; then
    DRY_RUN=true
    echo "MODE: DRY RUN (keine echten Änderungen)"
    echo ""
fi

WORKSPACE_ROOT="/workspaces/EnemyTerritory-BloodySkulls"
SRC_DIR="$WORKSPACE_ROOT/workspace/original-et-source/src"
BACKUP_DIR="$WORKSPACE_ROOT/backup-phase2-$(date +%Y%m%d%H%M%S)"

if [ ! -d "$SRC_DIR" ]; then
    echo "ERROR: $SRC_DIR existiert nicht!"
    exit 1
fi

echo "=========================================="
echo "Enemy Territory Phase 2: Path Replacement"
echo "=========================================="
echo ""

# Backup erstellen
if [ "$DRY_RUN" = false ]; then
    echo "[1/3] Erstelle Backup: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    cp -r "$SRC_DIR"/* "$BACKUP_DIR" 2>/dev/null || true
    echo "✓ Backup erstellt"
    echo ""
fi

echo "[2/3] Scanne und ersetze Includes..."
echo ""

# Define include path replacements
declare -A REPLACEMENTS
REPLACEMENTS=(
    # Engine paths
    ['#include "renderer/']='#include "../engine/renderer/'
    ['#include "snd_dma/']='#include "../engine/audio/'
    ['#include "sys/']='#include "../engine/system/'
    
    # Shared paths
    ['#include "qcommon/']='#include "../shared/qcommon/'
    
    # Game paths
    ['#include "game/']='#include "../game/game/'
    ['#include "botai/']='#include "../game/botai/'
    ['#include "botlib/']='#include "../game/botlib/'
    ['#include "server/']='#include "../game/server/'
    
    # Client paths
    ['#include "client/']='#include "../client/client/'
    ['#include "cgame/']='#include "../client/cgame/'
    ['#include "ui/']='#include "../client/ui/'
)

CHANGES_MADE=0
FILES_PROCESSED=0

# Finde alle C/H Dateien
while IFS= read -r file; do
    ((FILES_PROCESSED++))
    MODIFIED=false
    TEMP_FILE="$file.tmp"
    
    cp "$file" "$TEMP_FILE"
    
    # Ersetze jeden Include-Pfad
    for old_pattern in "${!REPLACEMENTS[@]}"; do
        new_pattern="${REPLACEMENTS[$old_pattern]}"
        
        if grep -q "$old_pattern" "$TEMP_FILE" 2>/dev/null; then
            sed -i "s|$old_pattern|$new_pattern|g" "$TEMP_FILE"
            MODIFIED=true
        fi
    done
    
    # Wenn Änderungen gemacht wurden
    if [ "$MODIFIED" = true ]; then
        ((CHANGES_MADE++))
        
        if [ "$DRY_RUN" = true ]; then
            echo "  [DRY-RUN] $file"
            echo "    Unterschiede:"
            diff -u "$file" "$TEMP_FILE" | head -10 || true
        else
            mv "$TEMP_FILE" "$file"
            echo "  ✓ $file"
        fi
    else
        rm -f "$TEMP_FILE"
    fi
    
    # Progress
    if [ $((FILES_PROCESSED % 50)) -eq 0 ]; then
        echo "  ... $FILES_PROCESSED Dateien bearbeitet"
    fi
    
done < <(find "$SRC_DIR" \( -name "*.c" -o -name "*.h" \) -type f)

echo ""
echo "✓ $FILES_PROCESSED Dateien gescannt, $CHANGES_MADE geändert"
echo ""

# Build-Dateien anpassen
echo "[3/3] Passe Build-Dateien an..."

if [ -f "$SRC_DIR/SConstruct" ]; then
    if [ "$DRY_RUN" = false ]; then
        # Backup
        cp "$SRC_DIR/SConstruct" "$SRC_DIR/SConstruct.bak"
        
        # Ersetze häufige Pfad-Muster in Build-Dateien
        sed -i "s|'renderer'|'../engine/renderer'|g" "$SRC_DIR/SConstruct"
        sed -i "s|'qcommon'|'../shared/qcommon'|g" "$SRC_DIR/SConstruct"
        sed -i "s|'game'|'../game/game'|g" "$SRC_DIR/SConstruct"
        sed -i "s|'client'|'../client/client'|g" "$SRC_DIR/SConstruct"
        
        echo "  ✓ SConstruct angepasst"
    else
        echo "  [DRY-RUN] SConstruct würde angepasst"
    fi
fi

echo ""
echo "=========================================="
if [ "$DRY_RUN" = true ]; then
    echo "✓ DRY-RUN ABGESCHLOSSEN!"
    echo ""
    echo "Wenn alles OK aussieht, führe aus:"
    echo "  bash $WORKSPACE_ROOT/phase2-fix.sh"
else
    echo "✓ PHASE 2 ABGESCHLOSSEN!"
    echo ""
    echo "Backup: $BACKUP_DIR"
    if [ $CHANGES_MADE -gt 0 ]; then
        echo "Falls Fehler: cp -r $BACKUP_DIR/* $SRC_DIR/"
    fi
fi
echo "=========================================="
echo ""
