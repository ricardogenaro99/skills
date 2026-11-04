---
name: deploy-test-bpm-siniestro-credito-salud-api-proc-impl
description: Gestiona y ejecuta el despliegue local seguro del microservicio Camunda 7 Rimac BPM Siniestros Crédito Salud (bpm-siniestro-credito-salud-api-proc-impl) en AWS TEST. Usar cuando el usuario pida desplegar en TEST, verificar drift de Terraform, o consultar el estado del servicio ECS y Target Group desde la Mac o de forma remota desde el celular.
---

# Rimac BPM Siniestros Salud - Protocolo de Despliegue en TEST

Esta skill automatiza el despliegue local seguro y el monitoreo del microservicio `bpm-siniestro-credito-salud-api-proc-impl` en el entorno AWS TEST (`438323272304`).
Está 100% desacoplada del repositorio de trabajo de Rimac (no crea archivos ni commits en el repositorio de la empresa).

## Ubicación del Script y del CLI
El script bash de ejecución reside en:
* **Script dentro de la Skill:** `~/Documents/GitHub/ricardogenaro99/skills/deploy-test-bpm-siniestro-credito-salud-api-proc-impl/scripts/deploy.sh`
* **Acceso CLI en PATH:** `deploy-test-bpm-siniestro-credito-salud-api-proc-impl` (enlace simbólico en `~/.local/bin/`).

---

## 1. Consultar Estado del Servicio en TEST
Cuando el usuario pregunte por el estado del despliegue, la salud del contenedor o el target group:
```bash
deploy-test-bpm-siniestro-credito-salud-api-proc-impl --status
```
Retorna: estado del servicio ECS, definición de tarea activa, eventos recientes y estado de salud en el ALB (`healthy` / `draining`).

---

## 2. Flujo de Despliegue Seguro (Regla de Oro IaC)
Cuando el usuario pida desplegar en TEST (ej. *"despliega en test"*, *"haz el deploy local"*, *"sube los cambios a test"*):

### PASO 1: Validación obligatoria de Drift (Pre-flight Check)
Ejecuta primero:
```bash
deploy-test-bpm-siniestro-credito-salud-api-proc-impl --check
```

* **Si el exit code es 0 (Sin cambios en `.tf` ni `schemas/`):**
  Procede directamente a desplegar:
  ```bash
  deploy-test-bpm-siniestro-credito-salud-api-proc-impl
  ```
  Informa al usuario el progreso y estado final.

* **Si el exit code es 2 (Se detectaron cambios en archivos `.tf` o `schemas/`):**
  **ALTO OBLIGATORIO:** Queda terminantemente prohibido ejecutar el despliegue sin confirmación del usuario.
  Debes alertar al usuario en el chat (especialmente si está desde el celular):
  > ⚠️ **Atención:** Tu rama actual contiene cambios en archivos de infraestructura Terraform (`.tf` / `schemas/`).
  > Desplegar manualmente puede causar colisiones (`409 ConflictException`) en el `.tfstate` remoto de Rimac cuando corra el pipeline oficial de Azure DevOps.
  > ¿Confirmas que deseas forzar el despliegue del contenedor de todas formas?

### PASO 2: Despliegue Forzado (Solo tras confirmación explícita)
Si y solo si el usuario responde *"sí"*, *"procede"*, *"adelante"* o *"fuerza el despliegue"*:
```bash
deploy-test-bpm-siniestro-credito-salud-api-proc-impl --force
```
Monitorea la finalización con `deploy-test-bpm-siniestro-credito-salud-api-proc-impl --status` y repórtaselo al usuario.
