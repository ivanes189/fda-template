# Revisión completa independiente Astra — WP-008 D6-A

- Revisor: GPT-6 Astra, razonamiento Alto, contexto nuevo, solo lectura.
- Base: `dfc8a1fd8b6392e64313f0be72998ed9d96257b8`.
- Candidato revisado: `2bfec9cb9feffa83c0cdb9d4e2d786b8a2712646`.
- Alcance: contrato, código, pruebas, evidencias y seguridad T3.
- Veredicto: **NO APTO; cambios solicitados; no aplicar el paquete**.

## Hallazgos bloqueantes

### WP008-D6-H01 — ALTO — Aplicador no anclado al repositorio/paquete

`evidence/WP-008/parche/aplicar.sh:176` acepta directorios con cuatro archivos
regulares sin comprobar raíz Git, rama, base, ACTIVE, limpieza, modos ni
manifiesto. Calcula huellas desde candidatos presentes y solo rechaza enlaces en
el último componente. Reproducción: `.claude` enlazada a un directorio externo;
el aplicador sobrescribe fuera de la raíz y sale `0`.

Corrección mínima: validar contexto Git y paquete aprobado, valores fijados,
modos e identidad física; rechazar enlaces en todos los componentes y deriva
antes de sustituir.

### WP008-D6-H02 — ALTO — Copia fallida queda alterada fuera del rollback

`evidence/WP-008/parche/aplicar.sh:234` copia sobre el destino, usa temporales en
`$WORKDIR` y solo marca un archivo después de que `cp` termine en `0`.
Reproducción: copia de CI escribe y retorna `1`; settings se restaura, CI queda
alterado, pero imprime `ROLLBACK APLICADO` y sale `3`.

Corrección mínima: temporales hermanos exclusivos y sustitución atómica;
considerar afectados todos los destinos intentados y verificar conjuntamente
ambas preimágenes antes del mensaje global. Probar fallo parcial/restauración.

### WP008-D6-H03 — ALTO — Humo acepta inconclusos y fugas

`tests/runtime/smoke-env-raiz.sh:190` no exige intento Read ni denegación, ignora
códigos, errores JSON, ruta y asociación llamada/resultado; excluye stderr al
buscar el marcador. Reproducciones APTO/exit `0`: tratamiento vacío exit `42`,
JSON inválido, Read de `/inexistente` con ENOENT y marcador filtrado por stderr.

Corrección mínima: eventos completos válidos, exactamente un Read a la misma
ruta, resultado asociado y denegación inequívoca por permisos; rechazar códigos,
ambigüedad y fugas en todos los canales; añadir negativos.

### WP008-D6-H04 — ALTO — Preflight acepta siete reglas como ocho

`tests/runtime/check-config.sh:212` compara reglas serializadas por líneas. Una
cadena JSON con salto de línea se divide y falsea cardinalidad. Reproducción:
siete entradas, una con dos reglas separadas por `\n`, producen `0` y `9/0`.
Además, no valida `type` del hook.

Corrección mínima: comparación estructurada de strings indivisibles,
cardinalidad/igualdad/duplicados y estructura completa del hook; añadir negativos.

### WP008-D6-H05 — Tratamiento del humo no es la configuración final

`tests/runtime/smoke-env-raiz.sh:80` fabrica configuraciones mínimas, sin las
otras siete reglas, Bash, permisos ni hook. Derivar tratamiento del candidato
final verificado y control eliminando solo `Read(/**/.env*)`; acreditar delta.

### WP008-D6-H06 — Integridad incompleta y diagnóstico destruido

`tests/runtime/smoke-env-raiz.sh:48` inventaría solo regulares bajo `.claude`,
omite `.env`, otras rutas, directorios/enlaces y limpia siempre. Reproducción:
el stub crea `unrelated-created.txt`; el humo aprueba y dice estable.

Corrección mínima: inventario total de rutas/tipos/modos/contenido por fase,
huellas precalculadas; conservar diagnóstico y escalar ante divergencia.

### WP008-D6-H07 — Humo pierde evidencia y coste

`tests/runtime/smoke-env-raiz.sh:208` no registra versión, huellas ni coste por
invocación y elimina los streams F1. Debe extraer/validar evidencia saneada,
incluidos costes de invocaciones fallidas, antes de limpiar y permitir agregación.

### WP008-D6-H08 — Precondición humana imposible

`evidence/WP-008/parche/INSTRUCCIONES.md:23` exige `HEAD = origin/main` después
de commitear el candidato. Debe exigir HEAD candidato aprobado, ascendencia desde
la base exacta, rama dedicada y limpieza; la igualdad con main rige solo al inicio.

## Cobertura y reproducciones

- Alcance: 39/39 rutas permitidas; ninguna prohibida.
- Protegidos reales: intactos.
- Candidatos/parche: cambios exactos; huellas, OID, modos y postimágenes correctos.
- Suites oficiales: 22/22, 7/7 y 11/11, pero insuficientes por H01–H07.
- Documentación/enlaces: conformes salvo H08.
- Coste F1 inicial: saneado y aritméticamente coherente, 11,5487715 USD.
- Seguridad T3: **NO APTA** por H01–H04.

Astra repitió los ocho comandos prehumanos y validaciones adicionales. Los
escenarios se reprodujeron en fixtures desechables sin modificar el candidato.
No se inspeccionó R2. La falta de aplicación humana, humo real, checks remotos,
atestación y coste agregado corresponde a gates posteriores y no es un hallazgo.

## Contador

La revisión por sí sola no consume ciclo. La apertura humana preautorizada de la
pasada de corrección que trata H01–H08 establece **C1 = 1 / 2**.
