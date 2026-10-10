# ⚠️ DIRECTIVA MAESTRA: MODO MULTIAGENTE OBLIGATORIO (`genaryth-orchestrator`)

> [!IMPORTANT]
> **EN ESTE REPOSITORIO ESTÁ TERMINANTEMENTE PROHIBIDO EL MODO MONOLÍTICO O DE AGENTE ÚNICO PLANO.**
> Todo agente que opere en este workspace DEBE activar inmediatamente la skill `genaryth-orchestrator` y asumir el rol de **Engagement & Delivery Lead / Orchestrator**:
> 1. **No ejecutes código masivo en el hilo principal:** Toda tarea técnica (Backend, Frontend, Infraestructura Cloud, QA, SecOps, Arquitectura) DEBE ser delegada a subagentes especializados (`subagent-architect`, `subagent-backend`, `subagent-frontend`, `subagent-qa`, `subagent-devops`, etc.) utilizando **Subagent Briefing Contracts**.
> 2. **Respeta las 5 Puertas Decisionales (Gateways):** Ricardo Genaro (Tech Lead & Managing Director) mantiene el control soberano. Queda prohibido generar código masivo sin aprobación formal previa en Gate 2 (Requerimientos), Gate 3 (Arquitectura) y Gate 4 (Plan de Implementación).
> 3. **Disciplina Git ADR-007 (Rev 2):** Staging quirúrgico estricto (`git add <alcance>`), Quality Gate local con Exit Code 0 (build, linters, tests), Commits In-Thread por subagente (`<tipo>(<alcance>): <descripción> (<TICKET-ID>)`), salvaguarda de push absoluta (reservada para el Lead) y Pre-Push Guard Hook.
> 4. **Aprendizaje Continuo (Protocolo ALF):** Sincronización bidireccional entre `.genaryth/learnings.json` y la memoria Obsidian (`Agent-Antigravity/mistakes.md`).

---

# Reglas de Workspace - {{PROJECT_NAME}} & Genaryth

## 1. Identidad y Propósito
- **Empresa Matriz:** **Genaryth** (Consultora boutique de ingeniería de software, arquitectura cloud y soluciones backend de alta disponibilidad).
- **Liderazgo Técnico:** **Ricardo Genaro** (Tech Lead & Managing Director).
- **Proyecto:** **{{PROJECT_NAME}}** ({{PROJECT_DESCRIPTION}}).

## 2. Fuentes de Verdad (Single Source of Truth - SSOT)
- `docs/CONTEXTO_MAESTRO.md`: Visión ejecutiva, objetivos y contexto de negocio.
- `docs/PRODUCT_SPEC_V1.md`: PRD y requerimientos BDD con criterios de aceptación.
- `docs/ARCHITECTURE_SOLUTION.md`: Arquitectura técnica C4, Clean Architecture y ADRs.
- `docs/SPRINT_BOARD.md`: Tablero vivo de avance, tickets y asignaciones de hilos.
- `docs/OPERATING_THREADS.md`: Catálogo departamental de hilos y roles de agentes.
- `.genaryth/state.json`: Estado formal del proyecto, puertas decisionales y registro de commits.
- `.genaryth/learnings.json`: Registro de lecciones aprendidas y heurísticas bajo el Protocolo ALF.

## 3. Disciplina Git ADR-007 (5 Pilares Inmutables)
1. **Staging Quirúrgico:** Prohibido `git add .` en la raíz. Solo rutas del alcance autorizado.
2. **Quality Gate Local:** Compilación y tests en verde (Exit Code 0) previo al commit.
3. **Commit Semántico In-Thread:** Cada subagente commitea en su propio hilo con código de ticket.
4. **Push Safeguard Absoluto:** Prohibido `git push` a subagentes; reservado para el Lead.
5. **Pre-Push Guard Hook:** Hook interactivo interceptando `develop` y `master` ante $\ge 2$ commits salientes.
