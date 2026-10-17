#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  CHESSBOOK — Script de compilación automática
#  Funciona en: GitHub Codespaces / Ubuntu / macOS
#  Uso: bash setup.sh
# ═══════════════════════════════════════════════════════════════

set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${GREEN}"
echo "  ██████╗██╗  ██╗███████╗███████╗███████╗██████╗  ██████╗  ██████╗ ██╗  ██╗"
echo "  ██╔════╝██║  ██║██╔════╝██╔════╝██╔════╝██╔══██╗██╔═══██╗██╔═══██╗██║ ██╔╝"
echo "  ██║     ███████║█████╗  ███████╗███████╗██████╔╝██║   ██║██║   ██║█████╔╝ "
echo "  ██║     ██╔══██║██╔══╝  ╚════██║╚════██║██╔══██╗██║   ██║██║   ██║██╔═██╗ "
echo "  ╚██████╗██║  ██║███████╗███████║███████║██████╔╝╚██████╔╝╚██████╔╝██║  ██╗"
echo "   ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝"
echo -e "${NC}"
echo "  Compilador automático — by Juanchow"
echo ""

# ── 1. Verificar Java ────────────────────────────────────────────────────────
echo -e "${YELLOW}[1/4] Verificando Java...${NC}"
if ! command -v java &> /dev/null; then
    echo "Java no encontrado. Instalando Java 17..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -q && sudo apt-get install -y openjdk-17-jdk
    elif command -v brew &> /dev/null; then
        brew install openjdk@17
    else
        echo -e "${RED}Error: instala Java 17 manualmente desde adoptium.net${NC}"
        exit 1
    fi
fi
java -version
echo -e "${GREEN}✓ Java listo${NC}"

# ── 2. Verificar Android SDK ─────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}[2/4] Verificando Android SDK...${NC}"
if [ -z "$ANDROID_HOME" ] && [ -z "$ANDROID_SDK_ROOT" ]; then
    # Intentar rutas comunes
    for path in "$HOME/Android/Sdk" "$HOME/Library/Android/sdk" "/opt/android-sdk"; do
        if [ -d "$path" ]; then
            export ANDROID_HOME="$path"
            export ANDROID_SDK_ROOT="$path"
            break
        fi
    done
fi

if [ -z "$ANDROID_HOME" ]; then
    echo -e "${YELLOW}⚠ Android SDK no encontrado en rutas comunes.${NC}"
    echo ""
    echo "  Para compilar necesitas Android SDK. Opciones:"
    echo ""
    echo "  A) En GitHub Codespaces:"
    echo "     curl -s https://raw.githubusercontent.com/actions/runner-images/main/images/ubuntu/toolsets/toolset-2204.json | python3 -c \"import sys,json; d=json.load(sys.stdin); [print(x) for x in d.get('android', {}).keys()]\""
    echo ""
    echo "  B) Instalar SDK (requiere ~2GB):"
    echo "     wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
    echo "     unzip commandlinetools-linux-*.zip -d \$HOME/android-sdk"
    echo "     export ANDROID_HOME=\$HOME/android-sdk"
    echo "     \$ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=\$ANDROID_HOME 'platform-tools' 'platforms;android-34' 'build-tools;34.0.0'"
    echo ""
    echo "  C) Usa Android Studio en una PC (más fácil)."
    echo ""
    read -p "¿Tienes el SDK instalado en otra ruta? Escribe la ruta (o Enter para saltar): " SDK_PATH
    if [ -n "$SDK_PATH" ] && [ -d "$SDK_PATH" ]; then
        export ANDROID_HOME="$SDK_PATH"
        export ANDROID_SDK_ROOT="$SDK_PATH"
    else
        echo -e "${RED}Compilación cancelada: se necesita Android SDK.${NC}"
        echo ""
        echo "El código está 100% completo. Solo necesitas compilarlo con Android Studio."
        echo "Guarda este proyecto y ábrelo en Android Studio cuando tengas acceso a una PC."
        exit 1
    fi
fi
echo -e "${GREEN}✓ Android SDK: $ANDROID_HOME${NC}"

# ── 3. Dar permisos y compilar ───────────────────────────────────────────────
echo ""
echo -e "${YELLOW}[3/4] Compilando APK (puede tardar 3-8 minutos)...${NC}"
chmod +x gradlew
./gradlew assembleDebug --no-daemon

# ── 4. Resultado ─────────────────────────────────────────────────────────────
echo ""
APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(du -sh "$APK_PATH" | cut -f1)
    echo -e "${GREEN}"
    echo "  ╔══════════════════════════════════════╗"
    echo "  ║   ✅  BUILD EXITOSO                  ║"
    echo "  ║                                      ║"
    echo "  ║   APK listo: $APK_PATH"
    echo "  ║   Tamaño: $APK_SIZE"
    echo "  ║                                      ║"
    echo "  ║   Para instalar en tu tel:           ║"
    echo "  ║   adb install $APK_PATH              ║"
    echo "  ╚══════════════════════════════════════╝"
    echo -e "${NC}"
else
    echo -e "${RED}Error: no se generó el APK. Revisa los errores arriba.${NC}"
    exit 1
fi
