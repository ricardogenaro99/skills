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

## 🔒 3. Concurrencia Segura y Trabajo Multihilo (Anti-Colisión)

1. **Monorepos Estructurados con Límites Claros:**
   - `apps/api/`: Territorio exclusivo de Backend.
   - `apps/web/`: Territorio exclusivo de Frontend.
   - `packages/common/`: Territorio compartido de contratos (gobernado por Architect).
   - `infra/` o `apps/api/infrastructure/`: Territorio exclusivo de DevOps.
2. **Staging Quirúrgico por Dominio:**
   - Para permitir que dos agentes o un desarrollador y un agente trabajen al mismo tiempo sin colisionar:
     - El agente de frontend solo hace `git add apps/web/...`.
     - El agente de backend solo hace `git add apps/api/...`.
     - Queda estrictamente prohibido el staging ciego de todo el árbol.
3. **Mantenimiento Continuo de la Memoria (Obsidian Layer 3):**
   - Cada hito importante, decisión de arquitectura (ADR) o lección aprendida se persiste inmediatamente en Obsidian (`Agent-Shared/decisions-log.md` y `Agent-Antigravity/daily/`).
   - Esto garantiza que cualquier nueva sesión de trabajo retome el contexto sin pérdida de conocimiento.
