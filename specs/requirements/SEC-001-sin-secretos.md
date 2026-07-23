# SEC-001 — Ningún secreto en el repositorio ni en los logs

**Id:** SEC-001 · **Categoría:** SEC (seguridad) · **Estado:** activo · **Fecha:** 2026-07-23

## Texto

El repositorio no contiene, en ningún commit ni en el árbol de trabajo, credenciales, claves de API, tokens, certificados privados ni cualquier otro material secreto.

Tampoco aparecen secretos en las salidas versionadas: logs de CI, archivos de `evidence/**`, mensajes de commit ni descripciones de PR.

Los secretos operativos viven **exclusivamente** en el almacén de secretos de GitHub Actions y se inyectan en tiempo de ejecución.

## Justificación

Un secreto commiteado no se elimina borrándolo: permanece en el historial de git y en cualquier clon o fork existente. La única remediación real es **rotar la credencial**, y eso solo funciona si el compromiso se detecta.

La superficie es más amplia de lo que parece: la FDA genera evidencias automáticamente, y un comando de verificación que imprima una variable de entorno deja el secreto en un archivo versionado sin que nadie lo escriba a propósito.

## Criterio de verificación

1. **Ningún archivo de secretos versionado:**

   ```bash
   git ls-files | grep -E '(^|/)\.env($|\.)|\.pem$|(^|/)secrets/'
   ```

   Debe devolver vacío. Se ejecuta en el job `secretos` de CI y es bloqueante.

2. **Escaneo de contenido:** `gitleaks` en verde sobre el historial completo (`fetch-depth: 0`), sin hallazgos.

3. **Controles nativos de GitHub activos:** secret scanning y push protection habilitados en el repositorio.

4. **Denegación de lectura:** `.claude/settings.json` deniega la lectura de rutas sensibles, de modo que un agente no puede exfiltrar por descuido lo que no puede leer:

   ```
   Read(./.env*)  ·  Read(./**/secrets/**)  ·  Read(./**/*.pem)  ·  Read(./**/id_rsa*)
   ```

5. **Higiene de evidencias:** ningún archivo bajo `evidence/**` contiene cadenas con forma de credencial (`sk-`, `gho_`, `ghp_`, `AKIA`, `-----BEGIN * PRIVATE KEY-----`).

6. **Prohibición operativa:** el valor de un secreto **nunca** se escribe en un archivo, ni siquiera temporalmente. Se configura con `gh secret set`, que lo lee de forma interactiva y lo transmite cifrado.

## Verificación actual

| Punto | Estado |
|---|---|
| Sin archivos de secretos versionados | Cumplido — comprobado en CI |
| `gitleaks` en CI | Configurado en el job `secretos` — **nunca ejecutado** (sin remoto todavía) |
| Secret scanning + push protection | **Pendiente** — requiere el repositorio en GitHub |
| Denies de lectura | Cumplido — 4 reglas activas |
| `.gitignore` cubre `.env*`, `**/secrets/**` | Cumplido |

## Nota sobre el alcance de este requisito

Este requisito cubre secretos **en reposo** en el repositorio y en sus salidas. La prevención de fuga por prompt injection —un agente inducido a leer y publicar un secreto— es un problema distinto, hoy fuera de alcance porque la Fase 1 es interactiva. Se aborda antes de activar `claude.yml`, según `FDA-diagnostico-y-plan-fase1.md` §1.3-B6.

## Trazabilidad

- Implementa: WP-005 (endurecimiento de CI/CD), Paso 0 (activación de scanning en GitHub)
- Origen: `FDA-diagnostico-y-plan-fase1.md` §3, `docs/02-guia-fabrica-desarrollo-agentica.md` §5
- Relacionado: [`REQ-FDA-002`](REQ-FDA-002-workflows-endurecidos.md)
