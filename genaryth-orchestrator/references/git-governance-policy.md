# Git Commit & Push Governance Policy (Genaryth Standard — ADR-007)

**Propósito:** Proteger la integridad del repositorio, garantizar la concurrencia segura entre múltiples hilos de agentes sin pisar código ajeno y eliminar la parálisis operativa mediante la resolución formal de la Paradoja Git Anti-Chancado (ADR-007).

---

## ⚖️ 1. Resolución de la Paradoja Git Anti-Chancado (ADR-007)

### El Problema Previo (La Paradoja)
Históricamente, prohibir commits locales en cambios clasificados como HIGH IMPACT (lógica de negocio, controladores, DTOs, infraestructura) generaba una **parálisis operativa**:
1. Los subagentes dejaban archivos modificados *unstaged* en el working tree esperando revisión humana.
2. Al ejecutarse múltiples hilos en paralelo (Backend, Frontend, QA, DevOps), el working tree sucio provocaba colisiones, mezcla accidental de cambios ajenos o bloqueo total de herramientas de compilación y staging.
3. El agente se detenía a mitad de la tarea sin cerrar el ciclo técnico verificable.

### La Solución Oficial (ADR-007: Compromiso Local Aislado)
ADR-007 resuelve la paradoja dividiendo la responsabilidad en dos fases complementarias:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                 FASE SUBAGENTE (IN-THREAD)                             │
│  [Aislamiento de Scope] ──> [Quality Gate (Exit Code 0)] ──> [Staging Quirúrgico]       │
│                                                                        │               │
│                                                                        ▼               │
│                                                        [Commit Semántico Local]        │
│                                                                        │               │
│                                                                        ▼               │
│                                                        [send_message con SHA Hash]     │
└──────────────────────────────────────────┬─────────────────────────────────────────────┘
                                           │
                                           ▼
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                              FASE ORCHESTRATOR & TECH LEAD                             │
│  [Validación Cross-Thread] ──> [Sincronización SSOT (state.json & SPRINT_BOARD.md)]    │
│                                                                        │               │
│                                                                        ▼               │
│                       [Salvaguarda de Push: Tech Lead (Ricardo Genaro) HitL]           │
│                                                                        │               │
│                                                                        ▼               │
│                                                        [git push / cdk deploy]         │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🛡️ 2. Reglas Inmutables de Git para Subagentes

### Regla 1: Staging Quirúrgico Obligatorio (Anti-Chancado)
* **TERMINANTEMENTE PROHIBIDO:** Ejecutar `git add .`, `git add -A` o `git add *` en la raíz del monorepo o proyecto.
* **EJECUCIÓN EXCLUSIVA:** Todo subagente debe ejecutar `git add` únicamente sobre las rutas explícitas de los archivos que modificó o generó dentro de su alcance autorizado:
  - Frontend: `git add apps/web/src/components/...`
  - Backend: `git add apps/api/src/modules/...`
  - Contratos SSOT: `git add packages/common/src/...`
  - Infraestructura: `git add apps/api/infrastructure/... .github/...`
  - QA: `git add apps/web/e2e/... apps/api/test/...`

### Regla 2: Quality Gate Mandatorio (Exit Code 0)
Antes de ejecutar `git commit`, el subagente **DEBE** correr la suite de verificación técnica del módulo y obtener Exit Code 0 limpio:
* No se commitea con errores de TypeScript (`tsc --noEmit`).
* No se commitea con linters rotos (`eslint`).
* No se commitea con tests fallidos (`jest`, `vitest`, `playwright`).

### Regla 3: Commit Semántico In-Thread
Una vez que el Quality Gate está en verde (Exit Code 0), el subagente **DEBE realizar el commit semántico local** utilizando Conventional Commits y el código de ticket trazable:
* `feat(web): implementar panel de control de rescates (FED-12)`
* `feat(api): endpoint transaccional de órdenes de compra (BE-08)`
* `feat(common): contratos sellados de webhooks v1 (SSOT-04)`
* `fix(infra): rutas declarativas y rate limiting en api gateway (OPS-07)`
* `test(qa): suite e2e de alerta roja en tiempo real (QA-08)`
* `docs(prd): especificación funcional de suscripciones b2b (BIZ-09)`

### Regla 4: Salvaguarda de Push (Push Safeguard)
* **PROHIBIDO A TODO SUBAGENTE EJECUTAR `git push`.**
* Ningún subagente tiene autorización para enviar ramas remotas, forzar push (`--force`), o alterar ramas de producción (`master`, `release`, `develop`).
* El `git push` y los despliegues a la nube (`cdk deploy`, Vercel deploy) quedan **estrictamente reservados para el Orchestrator** tras la validación cruzada y bajo autorización explícita del Tech Lead (**Ricardo Genaro**).

### Regla 5: Salvaguarda Pre-Push y Unificación Interactiva (Pre-Push Guard)
* Todo repositorio gobernado por Genaryth debe contar con el hook `.husky/pre-push` (instanciado desde `templates/hooks/pre-push`).
* Al ejecutar `git push` hacia ramas de integración o producción (`develop`, `master`, `main`):
  - Si se detectan **2 o más commits salientes acumulados**, el hook pausa la ejecución y abre un menú interactivo en terminal (`/dev/tty`):
    - `[1] Unificar (Squash)`: Condensa los commits salientes en uno solo semántico mediante `git reset --soft` al punto remoto base, solicitando el mensaje final consolidado para mantener un historial limpio en el remoto.
    - `[2] Pushear por separado`: Preserva los commits individuales si la granularidad de tickets lo amerita.
    - `[3] Abortar`: Cancela el push de inmediato sin alterar los archivos de trabajo.


---

## 📊 3. Matriz de Gobernanza y Alcance Git

| Nivel de Impacto | Tipos de Cambios Incluidos | Acciones Autorizadas al Subagente | Salvaguarda / Aprobación Requerida |
| :--- | :--- | :--- | :--- |
| **🟢 LOW IMPACT** | • Correcciones de documentación (`*.md`).<br>• Ajustes cosméticos y CSS menor aislado.<br>• Comentarios y typings menores. | • Staging quirúrgico.<br>• Commit semántico local. | Push gestionado por Orchestrator tras sync SSOT. |
| **🟡 MEDIUM IMPACT** | • Componentes UI interactivos nuevos.<br>• Suites de pruebas unitarias o E2E.<br>• Helpers, adaptadores y utilidades desacopladas. | • Staging quirúrgico tras Quality Gate (Exit Code 0).<br>• Commit semántico local in-thread con Ticket ID. | Push bloqueado para el subagente. Reportar SHA al Orchestrator. |
| **🔴 HIGH / CRITICAL IMPACT** | • Lógica de negocio central y transacciones ACID.<br>• Contratos de API (OpenAPI, DTOs compartidos).<br>• Esquemas de base de datos y migraciones SQL.<br>• Infraestructura Cloud (AWS CDK, IAM roles, WAF).<br>• Autenticación, tokens, criptografía (Argon2id, HMAC). | • Staging quirúrgico tras Quality Gate estricto.<br>• Commit semántico local in-thread con Ticket ID.<br>• **PROHIBIDO PUSH O DESPLIEGUE.** | Push y despliegues (`cdk deploy`) requieren confirmación explícita individual de Ricardo Genaro (Nivel 4 de Autonomía). |

---

## 📡 4. Protocolo de Cierre y Retorno vía `send_message`

Al completar su tarea y generar el commit local, el subagente DEBE emitir inmediatamente un mensaje estructurado al Orchestrator:

```markdown
### 🏁 Tarea Completada: [TICKET-ID] — [Título de la Tarea]
- **Hilo:** Hilo [1..6] ([Nombre del Área])
- **Commit Hash:** `[git rev-parse --short HEAD]`
- **Mensaje de Commit:** `[tipo(alcance): descripción (TICKET-ID)]`
- **Archivos Staged & Committed:**
  - `[ruta/archivo-1]`
  - `[ruta/archivo-2]`
- **Evidencia del Quality Gate:**
  - Build: ✅ Exit Code 0
  - Typecheck: ✅ Exit Code 0
  - Tests: ✅ [X]/[X] tests pasando limpiamente
- **Estado de Ticket:** LISTO PARA VALIDACIÓN CRUZADA / CI
```

