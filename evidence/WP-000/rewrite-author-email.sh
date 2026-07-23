#!/usr/bin/env bash
#
# rewrite-author-email.sh — Sustituye el correo personal por el noreply de GitHub
# en todo el historial, ANTES de hacer el repositorio público.
#
# POR QUÉ: al publicar un repositorio, el correo de autoría queda visible y
# permanente en los metadatos de cada commit. GitHub oculta tu correo en el
# perfil, pero no en git. Es material que los rastreadores de spam recogen.
#
# POR QUÉ AHORA: el repositorio se creó hace minutos y nadie más lo ha clonado,
# así que reescribir el historial es seguro. Una vez público y clonado por
# terceros, ya no hay vuelta atrás.
#
#   de:  ivanes189@gmail.com
#   a:   74557686+ivanes189@users.noreply.github.com
#
# La forma con ID numérico es la que GitHub usa para seguir atribuyéndote los
# commits en tu perfil y en el grafo de contribuciones.
#
# Lo ejecuta una PERSONA: requiere force-push, denegado a los agentes por
# .claude/settings.json — y con razón, porque reescribe historia publicada.
#
# RESPALDO: filter-branch deja el historial original en refs/original/.
# Para deshacer:
#   git reset --hard refs/original/refs/heads/main
#   git push --force origin main
#
# Uso:  bash evidence/WP-000/rewrite-author-email.sh

set -eu

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

VIEJO="ivanes189@gmail.com"
NUEVO="74557686+ivanes189@users.noreply.github.com"

echo "=============================================================="
echo " FDA — Anonimizar la autoría antes de publicar"
echo "   de:  $VIEJO"
echo "   a:   $NUEVO"
echo "=============================================================="
echo

echo "--- Paso 1: comprobaciones previas ---"
if [ -n "$(git status --porcelain)" ]; then
  echo "ERROR: hay cambios sin commitear. Commitea o descarta antes de reescribir."
  git status --short
  exit 1
fi
echo "  OK  árbol limpio"

RAMA="$(git rev-parse --abbrev-ref HEAD)"
[ "$RAMA" = "main" ] || { echo "ERROR: estás en '$RAMA', no en main."; exit 1; }
echo "  OK  en rama main"

N_ANTES="$(git rev-list --count HEAD)"
echo "  Commits en el historial: $N_ANTES"

if [ -d .git/refs/original ]; then
  echo "  AVISO: existe un refs/original de una reescritura previa."
  echo "         Bórralo con: git update-ref -d refs/original/refs/heads/main"
  exit 1
fi
echo

echo "--- Paso 2: configurar el correo para los commits futuros ---"
git config user.email "$NUEVO"
echo "  git config user.email = $(git config user.email)"
echo

echo "--- Paso 3: reescribir el historial ---"
echo "  (filter-branch avisará de que está deprecado; es esperado y correcto"
echo "   para este caso puntual de 33 commits)"
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch --env-filter "
  if [ \"\$GIT_AUTHOR_EMAIL\" = '$VIEJO' ]; then
    export GIT_AUTHOR_EMAIL='$NUEVO'
  fi
  if [ \"\$GIT_COMMITTER_EMAIL\" = '$VIEJO' ]; then
    export GIT_COMMITTER_EMAIL='$NUEVO'
  fi
" HEAD
echo

echo "--- Paso 4: verificar ---"
N_DESPUES="$(git rev-list --count HEAD)"
echo "  Commits antes: $N_ANTES · después: $N_DESPUES"
if [ "$N_ANTES" != "$N_DESPUES" ]; then
  echo "  ERROR: el número de commits ha cambiado. NO empujes."
  echo "  Restaura con: git reset --hard refs/original/refs/heads/main"
  exit 1
fi

echo "  Correos presentes en el historial:"
git log --format='%ae' | sort -u | sed 's/^/    autor:    /'
git log --format='%ce' | sort -u | sed 's/^/    commiter: /'

if git log --format='%ae %ce' | grep -q "$VIEJO"; then
  echo "  ERROR: el correo antiguo sigue presente. NO empujes."
  exit 1
fi
echo "  OK  el correo antiguo ha desaparecido del historial"
echo

echo "--- Paso 5: comprobar que el contenido NO ha cambiado ---"
ORIG="$(git rev-parse refs/original/refs/heads/main)"
if [ "$(git rev-parse 'HEAD^{tree}')" = "$(git rev-parse "${ORIG}"'^{tree}')" ]; then
  echo "  OK  el árbol de archivos es idéntico: solo cambió la metadata"
else
  echo "  ERROR: el contenido ha cambiado. NO empujes."
  exit 1
fi
echo

echo "--- Paso 6: force-push ---"
echo "  Se va a reescribir main en GitHub. Es seguro: nadie más ha clonado."
git push --force origin main
echo

echo "=============================================================="
echo " LISTO. Historial anonimizado y empujado."
echo " Respaldo local del historial original: refs/original/refs/heads/main"
echo "=============================================================="
