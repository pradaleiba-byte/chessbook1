#!/bin/sh
# Gradle wrapper script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$SCRIPT_DIR/gradle/wrapper/gradle-wrapper.jar" "$@" 2>/dev/null || \
  java -jar "$SCRIPT_DIR/gradle/wrapper/gradle-wrapper.jar" "$@" 2>/dev/null || \
  (which gradle && gradle "$@") || \
  echo "Error: no se encontró Gradle. Instala con: sdk install gradle"
