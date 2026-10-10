# Dinámica Operativa de Squad y Gestión de Equipos Agénticos — Genaryth (GASF)

**Propósito:** Definir los principios de colaboración, gestión ágil y sincronización concurrente entre el Tech Lead y los subagentes especializados.

---

## 👥 1. Filosofía de Squad: Especialización sin Silos

1. **Un Solo Tech Lead al Mando:**
   - Ricardo Genaro es el único decisor del rumbo estratégico y arquitectónico.
   - Los subagentes no compiten ni toman decisiones de dirección; asesoran, proponen alternativas fundamentadas y ejecutan las tareas autorizadas.
2. **Subagentes Especializados, no Generalistas:**
   - Cada subagente tiene un dominio delimitado (Frontend, Backend, DevOps, QA, etc.).
   - Cuando surge una tarea que involucra múltiples dominios (ej. nuevo flujo de checkout), el Orquestador coordina la secuencia de dependencias:
     1. `subagent-process`: Dibuja el flujo de negocio.
     2. `subagent-architect`: Define el contrato OpenAPI y el esquema de BD.
     3. `subagent-backend` & `subagent-frontend`: Construyen en paralelo contra el contrato.
     4. `subagent-qa`: Certifica con pruebas automatizadas.
3. **Resolución de Contradicciones:**
   - Si el Backend propone un esquema que rompe la interfaz del Frontend, o si DevOps detecta que una librería introduce costos excesivos, el Orquestador NO reconcilia a espaldas del Tech Lead. Presenta el dilema en la plantilla RFC con opciones claras para tu decisión.
4. **Patrón de Orquestación Dual-Track (Momentum & Gobernanza):**
   - El Squad opera en dos carriles desacoplados:
     * **Track Operativo:** Tareas con contratos y requerimientos sellados (e.g. componentes UI en Next.js, tests E2E) avanzan en paralelo a máxima velocidad.
     * **Track Estratégico:** Nuevas iniciativas o próximos hitos (e.g. arquitectura EDA, nuevas tablas SQL) se analizan previamente con `subagent-architect` y `subagent-secops` para generar el RFC y Threat Model (Gate 3) antes de escribir código operativo.


---

## 🏃 2. Gestión Ágil Pragmática (Sprint Board SSOT)

1. **Tablero Vivo en Markdown (`docs/SPRINT_BOARD.md`):**
   - El backlog y los sprints no viven en herramientas externas opacas (Jira/Trello); viven en disco dentro del repositorio en formato Markdown estructurado.
   - Toda tarea técnica cuenta con un ID trazable y un prefijo de área:
     - `HU-XX`: Historia de Usuario (Negocio/Producto)
     - `BE-XX`: Tarea de Backend
     - `FED-XX` o `FE-XX`: Tarea de Frontend / UI
     - `OPS-XX`: Tarea de Infraestructura o CI/CD
     - `QA-XX`: Tarea de Pruebas o Automatización
2. **Sprints Enfocados y Cortos (Timeboxing):**
   - Sprints acotados con un objetivo claro y entregables incrementales demostrables.
   - Al finalizar cada sprint, el squad debe entregar un incremento de software que compile, pase todos los tests y cuente con documentación actualizada.

---

## 🔒 3. Concurrencia Segura y los 6 Hilos Operativos Oficiales

Genaryth organiza el trabajo concurrente en **6 Hilos Operativos Estándar**, cada uno con su prefijo de ticket, alcance de directorio y suite de verificación:

| Hilo Operativo | Especialidad y Rol | Prefijos de Ticket | Alcance de Rutas Autorizadas | Quality Gate Típico | Convención Commit |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Hilo 1: Product & Business** | CPO & Strategist | `BIZ-XX`, `HU-XX`, `DOC-XX` | `docs/`, `*.md` | `markdownlint`, validación de links | `docs(prd): ... (BIZ-XX)` |
| **Hilo 2: Backend & Architecture** | Tech Lead Backend / Architect | `BE-XX`, `SSOT-XX` | `apps/api/`, `packages/common/` | `pnpm --filter api test`, `pnpm --filter api build` | `feat(api): ... (BE-XX)`<br>`feat(common): ... (SSOT-XX)` |
| **Hilo 3: DevOps, Cloud & CI/CD** | Cloud Architect | `OPS-XX`, `INF-XX` | `apps/api/infrastructure/`, `infra/`, `.github/` | `cdk synth`, `pnpm lint`, `docker compose config` | `fix(infra): ... (OPS-XX)`<br>`ci(actions): ... (OPS-XX)` |
| **Hilo 4: QA & Performance** | QA Automation Specialist | `QA-XX` | `apps/*/test/`, `apps/*/e2e/`, `tests/` | `pnpm test`, `npx playwright test` | `test(qa): ... (QA-XX)` |
| **Hilo 5: Frontend & UX** | Senior Frontend Engineer | `FED-XX`, `FE-XX` | `apps/web/` | `pnpm --filter web build`, `pnpm --filter web lint` | `feat(web): ... (FED-XX)`<br>`ui(shop): ... (FED-XX)` |
| **Hilo 6: Data, AI & Automations** | Data & Automation Lead | `DATA-XX`, `N8N-XX`, `EVT-XX` | `workflows/`, `packages/events/`, `apps/worker/` | Validación JSON Schema, `n8n validate` | `feat(n8n): ... (N8N-XX)`<br>`feat(data): ... (DATA-XX)` |

---

## 📜 4. Inyección Obligatoria del Subagent Briefing Contract

Cuando el Orchestrator delega una tarea a un subagente (`invoke_subagent`), **NUNCA envía una instrucción genérica o informal**.
Debe instanciar obligatoriamente el `Subagent Briefing Contract` (`templates/subagent-briefing-contract.md`) inyectando dinámicamente:
1. Dominio, rol y postura de consultoría de élite.
2. Aislamiento estricto de rutas de archivo (Scope Boundary).
3. Suite exacta de Quality Gate requerida (Exit Code 0).
4. Reglas de Git ADR-007 (Staging quirúrgico + Commit semántico local in-thread).
5. Protocolo de retorno estructurado vía `send_message` con SHA Hash.

---

## 🔄 5. Sincronización SSOT en Tiempo Real (Orchestrator)

El Orchestrator es el único responsable de la sincronización consolidada del proyecto:
1. **Recepción del Reporte:** Al recibir el mensaje de retorno del subagente con el Hash de commit y archivos modificados.
2. **Actualización de `docs/SPRINT_BOARD.md`:** Marca el ticket como `[x]` e incluye el SHA del commit (`Commit [hash]`).
3. **Actualización de `.genaryth/state.json`:** Registra la tarea en el hilo correspondiente, el commit hash, el estado del ticket y el timestamp en el change log.
4. **Sincronización de Memoria (Layer 3 - Obsidian):** Registra el hito en `Agent-Antigravity/working-context.md` y `daily/YYYY-MM-DD.md`.
5. **Salvaguarda de Push:** El Orchestrator evalúa cuándo consolidar y solicita autorización explícita a Ricardo Genaro para ejecutar `git push` o despliegues productivos.

