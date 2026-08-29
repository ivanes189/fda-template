#!/usr/bin/env bash
#
# Guard trivial del fixture de proyecto. NO es el guard real de la FDA: existe
# solo para que la comprobacion 5 del preflight —guard presente y ejecutable—
# tenga algo que encontrar dentro de la copia externa de trabajo.
#
# La plantilla versionada se guarda con modo 0644. El bit de ejecucion lo pone
# tests/runtime/test-protocolo.sh sobre la COPIA EXTERNA, nunca sobre la
# plantilla.
exit 0
