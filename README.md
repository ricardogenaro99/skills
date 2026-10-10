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
| **`genaryth-orchestrator`** | `/genaryth-orchestrator` | **Sistema de Dirección y Orquestación Multiagente.** Coordina a un squad de 13 subagentes especializados bajo la dirección del Tech Lead. Implementa 5 Puertas Decisionales obligatorias (Gateways), persistencia en `.genaryth/state.json`, autonomía de 4 niveles y política estricta de Git Governance. |
| **`obsidian-memory`** | `/obsidian-memory` | **Protocolo de Memoria Persistente Layer 3.** Conexión y sincronización bi-direccional de contexto a largo plazo con la bóveda de Obsidian en iCloud (`Agent-Shared/` y `Agent-Antigravity/`). |
| **`entrevistador-procesos`** | `/entrevistador-procesos` | **Mapeo y Diseño de Procesos de Negocio.** Entrevista estructurada para definir workflows, automatizaciones y sistemas antes de codificar. |
| **`optimizador-prompts`** | `/optimizador-prompts` | **Ingeniería de Prompts y Estructuración.** Transforma ideas desordenadas, notas rápidas y requerimientos informales en directivas de alta precisión para LLMs. |
| **`humanizador`** | `/humanizador` | **Naturalización de Texto.** Reescribe textos y entregables generados por IA para eliminar clichés corporativos, tono inflado y patrones artificiales. |
| **`resumen-proyecto`** | `/resumen-proyecto` | **Análisis Técnico y Funcional Exhaustivo.** Genera documentación profunda (README, SAD, APIs, alcance de negocio) para onboarding de proyectos y repositorios. |
| **`verificador-datos`** | `/verificador-datos` | **Fact-Checking y Rigor Analítico.** Audita afirmaciones técnicas, métricas y datos clave antes de ser publicados o presentados a stakeholders. |
| **`scaffolder`** | `/scaffolder` | **Automatización de Arquetipos.** Integración nativa con el CLI `@ricardogenaro99/scaffolder` para instanciación automatizada de microservicios NestJS + AWS CDK. |

---

## 🏛️ Destacado: Genaryth Orchestrator (`genaryth-orchestrator`)

El buque insignia de la colección. Implementa el **Genaryth Autonomous Squad Framework (GASF)** para la gestión del ciclo de vida completo del software:

1. **Human-in-the-Loop:** El Tech Lead (Ricardo Genaro) mantiene el control decisional absoluto. La IA asesora y ejecuta, pero no decide a espaldas del liderazgo técnico.
2. **Las 5 Puertas Decisionales:**
   * `GATE 1: BUSINESS_REVIEW` (Problema, propuesta de valor y flujos As-Is/To-Be)
   * `GATE 2: REQUIREMENTS_REVIEW` (Historias de Usuario y Criterios BDD *Given-When-Then*)
   * `GATE 3: ARCHITECTURE_REVIEW` (Clean Architecture, Schemas de BD y contratos OpenAPI 3.1)
   * `GATE 4: PLAN_REVIEW` (Desglose de tareas, estimaciones y alcance autorizado)
   * `GATE 5: ACCEPTANCE_REVIEW` (Pruebas unitarias, Playwright E2E y técnica `break-ui`)
3. **Squad de 13 Subagentes Especializados:**
   * **Thinking High:** Orchestrator Lead, Solutions Architect, AppSec & Compliance.
   * **Thinking Medium:** Business Process Analyst, Backend Engineer, AI & Data Engineer.
   * **Thinking Low (FinOps 54%):** Frontend Engineer, Cloud & DevOps, Automation (n8n MCP), Product Owner, SRE & Observability, QA Automation, Tech Writer.
4. **Git Anti-Chancado & Governance Policy:**
   * Staging quirúrgico obligatorio (prohibido `git add .` en la raíz).
   * Matriz de impacto en tres niveles (Low, Medium, High/Critical).

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
