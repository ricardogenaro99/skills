# Genaryth Agent Skills Collection (`skills`)

Colección oficial de **Skills para Agentes de Inteligencia Artificial** de [Genaryth](https://github.com/ricardogenaro99), diseñada y optimizada para flujos de ingeniería de software, arquitectura cloud, metodologías ágiles y sistemas multiagente autónomos.

Compatible con **Antigravity**, **OpenClaw (ShelBot)**, **Claude Code**, **Gemini CLI** y el ecosistema de [skills.sh](https://skills.sh).

---

## 🚀 Instalación Rápida

Puedes instalar toda la suite de habilidades globalmente en tu máquina con el CLI oficial de `skills`:

```bash
# Instalar toda la colección de skills en todos tus agentes
npx -y skills add ricardogenaro99/skills -g -y

# O instalar una skill específica (ej. genaryth-orchestrator)
npx -y skills add ricardogenaro99/skills --skill genaryth-orchestrator -g -y
```

---

## 📦 Catálogo de Habilidades Incluidas

| Skill | Comando / Trigger | Descripción y Propósito |
| :--- | :--- | :--- |
| **`genaryth-orchestrator`** | `/genaryth-orchestrator` | **Sistema de Dirección y Orquestación Multiagente (GASF v2.0).** Coordina a un squad de 14 subagentes especializados bajo la dirección del Tech Lead. Implementa 5 Puertas Decisionales obligatorias (Gateways), persistencia en `.genaryth/state.json`, runtime execution harness con sandboxing y policy interceptors, framework de benchmarking tripartito, autonomía de 4 niveles y política estricta de Git Governance. |
| **`obsidian-memory`** | `/obsidian-memory` | **Protocolo de Memoria Persistente Layer 3.** Conexión y sincronización bi-direccional de contexto a largo plazo con la bóveda de Obsidian en iCloud (`Agent-Shared/` y `Agent-Antigravity/`). |
| **`entrevistador-procesos`** | `/entrevistador-procesos` | **Mapeo y Diseño de Procesos de Negocio.** Entrevista estructurada para definir workflows, automatizaciones y sistemas antes de codificar. |
| **`optimizador-prompts`** | `/optimizador-prompts` | **Ingeniería de Prompts y Estructuración.** Transforma ideas desordenadas, notas rápidas y requerimientos informales en directivas de alta precisión para LLMs. |
| **`humanizador`** | `/humanizador` | **Naturalización de Texto.** Reescribe textos y entregables generados por IA para eliminar clichés corporativos, tono inflado y patrones artificiales. |
| **`resumen-proyecto`** | `/resumen-proyecto` | **Análisis Técnico y Funcional Exhaustivo.** Genera documentación profunda (README, SAD, APIs, alcance de negocio) para onboarding de proyectos y repositorios. |
| **`verificador-datos`** | `/verificador-datos` | **Fact-Checking y Rigor Analítico.** Audita afirmaciones técnicas, métricas y datos clave antes de ser publicados o presentados a stakeholders. |
| **`scaffolder`** | `/scaffolder` | **Automatización de Arquetipos.** Integración nativa con el CLI `@ricardogenaro99/scaffolder` para instanciación automatizada de microservicios NestJS + AWS CDK. |

---

## 🏛️ Destacado: Genaryth Orchestrator (`genaryth-orchestrator`)

El buque insignia de la colección. Implementa el **Genaryth Autonomous Squad Framework (GASF v2.0)** para la gestión del ciclo de vida completo del software:

1. **Human-in-the-Loop:** El Tech Lead (Ricardo Genaro) mantiene el control decisional absoluto. La IA asesora y ejecuta, pero no decide a espaldas del liderazgo técnico.
2. **Las 5 Puertas Decisionales:**
   * `GATE 1: BUSINESS_REVIEW` (Problema, propuesta de valor y flujos As-Is/To-Be)
   * `GATE 2: REQUIREMENTS_REVIEW` (Historias de Usuario y Criterios BDD *Given-When-Then*)
   * `GATE 3: ARCHITECTURE_REVIEW` (Clean Architecture, Schemas de BD y contratos OpenAPI 3.1)
   * `GATE 4: PLAN_REVIEW` (Desglose de tareas, estimaciones y alcance autorizado)
   * `GATE 5: ACCEPTANCE_REVIEW` (Pruebas unitarias, Playwright E2E y técnica `break-ui`)
3. **Squad de 14 Subagentes Especializados:**
   * **Thinking High:** Orchestrator Lead, Solutions Architect, AppSec & Compliance.
   * **Thinking Medium:** Business Process Analyst, Backend Engineer, AI & Data Engineer, FinOps Specialist.
   * **Thinking Low (FinOps Optimization):** Frontend Engineer, Cloud & DevOps, Automation (n8n MCP), Product Owner, SRE & Observability, QA Automation, Tech Writer.
4. **Agent Execution Harness (Runtime Sandboxing & Guardrails):**
   * **Context Pruning Engine:** Descarte de ruido contextual e inyección quirúrgica de slices de código.
   * **Tool Sandbox Matrix:** Permisos declarativos por rol (lectura, mutación de archivos, ejecución terminal).
   * **Pre-Write Guardrails Engine (`pre-write-guard.ts`):** Escaneo en memoria contra fugas de secretos (AWS, Stripe, JWT, Private Keys) y violación de fronteras de arquitectura.
   * **Policy Interceptor (`interceptor-rules.json`):** Bloqueo en seco de operaciones prohibidas (`git add .`, push no autorizado, `cdk deploy`, `prisma migrate reset`, eliminaciones masivas).
   * **State Synchronizer:** Gestión de estado de proyecto y gobernanza en `.genaryth/state.json`.
5. **Evaluation & Benchmarking Harness (Quality & FinOps Graders):**
   * **Grader Tripartito:** Determinístico (AST / `tsc` / Jest), Seguridad (SAST / Git Policies) y LLM-as-a-Judge (Clean Code).
   * **Benchmark Suites Canónicas (`BENCH-*`):** Casos de prueba estandarizados en `evals/benchmark-suites/` para certificar a los subagentes antes de tocar código de producción.
   * **Multi-Agent Benchmark Runner CLI (`runner.ts` / `harness-cli.sh`):** Ejecutor autónomo en TypeScript que corre las suites en tiempo real, emite scorecards visuales y genera reportes de certificación.
   * **FinOps & Latency Tracking:** Monitorización de consumo de tokens y ratio costo/efectividad.
6. **Git Anti-Chancado & Governance Policy (ADR-007 & ADR-010):**
   * Staging quirúrgico obligatorio archivo por archivo.
   * Tríada de Gobernanza Universal Multi-Agente mediante Symlinks SSOT (`GEMINI.md` ➔ `CLAUDE.md`, `AGENTS.md`, `.cursorrules`).


---

## 🛠️ Desarrollo y Contribución Local

Si deseas clonar el repositorio para extender o crear nuevas skills:

```bash
git clone git@github.com:ricardogenaro99/skills.git
cd skills
```

Para vincular las skills localmente a tus agentes en desarrollo:
```bash
# Crear enlace simbólico hacia tu carpeta global de agentes
ln -s "$(pwd)/genaryth-orchestrator" ~/.agents/skills/genaryth-orchestrator
ln -s "$(pwd)/genaryth-orchestrator" ~/.openclaw/skills/genaryth-orchestrator
```

---

## 📄 Licencia

Desarrollado y mantenido por **Ricardo Genaro** para el ecosistema tecnológico de **Genaryth**.
Licencia MIT.
