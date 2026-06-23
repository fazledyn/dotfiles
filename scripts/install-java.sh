#!/usr/bin/env bash
#
# install-java.sh - Install several JDK versions via SDKMAN.
#
# All builds come from a single distribution: Azul Zulu (-zulu). Zulu is used
# because it offers the widest range of versions, including legacy (7) and
# non-LTS (13, 23) releases that Temurin and Corretto don't provide.
#
# The exact patch version for each major is resolved at runtime from
# `sdk list java`, so this keeps working as new patches are published.

set -euo pipefail

# Major versions to install, and the distribution to take them all from.
JAVA_VERSIONS=(7 8 11 13 17 21 23 25)
DISTRO="zulu"

# Load SDKMAN so the `sdk` shell function is available in this script.
export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
if [[ ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
  echo "SDKMAN not found at $SDKMAN_DIR. Run install-utils.sh first." >&2
  exit 1
fi
# shellcheck disable=SC1091
source "$SDKMAN_DIR/bin/sdkman-init.sh"

# Auto-answer SDKMAN's prompts (e.g. "set as default?") so the run doesn't hang.
sdkman_auto_answer=true

for major in "${JAVA_VERSIONS[@]}"; do
  # Pick the newest Zulu identifier for this major. `sdk list java` prints
  # newest first, so the first match is the latest available build.
  identifier="$(sdk list java \
    | grep -oE "[0-9][0-9a-z.]*-${DISTRO}" \
    | grep -E "^${major}([.-])" \
    | head -1 || true)"

  if [[ -z "$identifier" ]]; then
    echo "!! No ${DISTRO} build found for Java ${major}, skipping."
    continue
  fi

  echo ">> Installing Java ${major}: ${identifier}"
  # Don't let one failed version abort the rest.
  sdk install java "$identifier" || echo "!! Failed to install ${identifier}, continuing."
done

echo ">> Installed Java versions:"
sdk list java | grep -E "installed|local only" || true

echo ">> Done."
