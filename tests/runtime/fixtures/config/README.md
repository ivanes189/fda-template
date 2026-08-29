# Fixtures de configuración del preflight

Catorce variantes versionadas de `settings.json` que ejercitan las nueve
comprobaciones de `tests/runtime/check-config.sh`. **Ninguna es la configuración
real**: son entradas de prueba y no se instalan en ningún sitio.

| Fixture | Caso de `test-check-config.sh` | Qué debe pasar |
|---|---|---|
| `conforme.json` | 1, 9, 10 | Conforme completo · también sirve de base para los casos de guard |
| `json-malformado.json` | 2 | Falla la comprobación 1 |
| `sin-pretooluse.json` | 3 | Falla la comprobación 2 |
| `matcher-sin-bash.json` | 4 | Falla la comprobación 3 |
| `matcher-desordenado.json` | 5 | Falla la comprobación 3: es igualdad exacta, no de conjunto |
| `command-relativo.json` | 6 | Falla la comprobación 4 |
| `command-inerte.json` | 7 | Falla la comprobación 4 aunque contenga `CLAUDE_PROJECT_DIR` y `exit 2` |
| `command-espacio-de-mas.json` | 8 | **Conforme**: la normalización de espacios es parte del criterio |
| `regla-relativa.json` | 11 | Falla la comprobación 6 |
| `regla-write.json` | 12 | Falla la comprobación 7 |
| `falta-una-regla.json` | 13 | Siete reglas: fallan 8 y 9 |
| `sobra-una-regla.json` | 14 | Nueve reglas: fallan 8 y 9 |
| `duplicada-y-ausente.json` | 15 | **Ocho** reglas: falla solo la 9, con la 8 conforme |
| `sustituida.json` | 16 | **Ocho** reglas: falla solo la 9, con la 8 conforme |

Los casos **9, 10 y 17 a 22** necesitan además una **raíz de proyecto** con un
guard presente, ausente o sin bit de ejecución. Esas raíces **no se versionan**:
`test-check-config.sh` las crea con `mktemp -d`, fuera de la raíz física del
repositorio, conforme a la sección 9 del WP. **El hook real del repositorio no se
renombra, no se sustituye y no pierde permisos en ninguna prueba.**
