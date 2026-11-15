# Catálogo Especializado de Subagentes & Matriz de Hilos — Genaryth Venture Studio

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                              SQUAD DE ESPECIALISTAS GENARYTH                           │
├─────────────────────────┬──────────────────────────┬───────────────────────────────────┤
│ 🧠 TIER HIGH            │ ⚡ TIER MEDIUM           │ 🔍 TIER LOW (54% FINOPS)          │
│ • subagent-architect    │ • subagent-backend       │ • subagent-frontend               │
│ • subagent-secops       │ • subagent-process       │ • subagent-mobile                 │
│                         │ • subagent-data-ai       │ • subagent-devops                 │
│                         │ • subagent-uiux          │ • subagent-sre                    │
│                         │                          │ • subagent-qa                     │
│                         │                          │ • subagent-automation             │
│                         │                          │ • subagent-po                     │
│                         │                          │ • subagent-docs                   │
└─────────────────────────┴──────────────────────────┴───────────────────────────────────┘
```

## Matriz Canónica de Hilos & Parámetro de Invocación FinOps

| Hilo | Nombre del Área | Prefijos | Scope de Directorio | Model Flag (`invoke_subagent`) | Subagentes Asignados |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **1** | **Product & Strategy** | `BIZ-XX`<br>`HU-XX`<br>`DOC-XX` | `docs/`<br>`*.md` | `Model: "flash"` | `subagent-po`<br>`subagent-process`<br>`subagent-docs` |
| **2** | **Backend & Architecture** | `BE-XX`<br>`SSOT-XX` | `apps/api/`<br>`packages/common/` | `Model: "inherit"` (Arquitectura)<br>`Model: "flash"` (Endpoints simples) | `subagent-backend`<br>`subagent-architect` |
| **3** | **DevOps, Cloud & CI/CD** | `OPS-XX`<br>`INF-XX` | `apps/api/infrastructure/`<br>`infra/`<br>`.github/` | `Model: "flash"` | `subagent-devops`<br>`subagent-sre` |
| **4** | **QA, Testing & Performance** | `QA-XX` | `apps/*/test/`<br>`apps/*/e2e/`<br>`tests/` | `Model: "flash"` | `subagent-qa` |
| **5** | **Frontend & UX** | `FED-XX`<br>`FE-XX`<br>`MOB-XX` | `apps/web/`<br>`apps/studio-hub/`<br>`apps/mobile/` | `Model: "flash"` | `subagent-frontend`<br>`subagent-uiux`<br>`subagent-mobile` |
| **6** | **Data, AI & Automations** | `DATA-XX`<br>`N8N-XX`<br>`EVT-XX` | `workflows/`<br>`packages/events/`<br>`apps/worker/` | `Model: "flash"` | `subagent-automation`<br>`subagent-data-ai` |

## 🏢 Directiva Inmutable de Scoping Corporativo y Segregación de Puertos (ADR-013)

1. **Scoping Corporativo Obligatorio (`@<org>/*`):**
   - 🚫 **PROHIBIDO:** Asignar nombres planos o genéricos en `package.json` dentro de `apps/*` o `packages/*` (ej. `"name": "web"`, `"name": "api"`, `"name": "hub"` o `"name": "common"`).
   - ✅ **OBLIGATORIO:** Toda aplicación y paquete DEBE inicializarse con el namespace de la organización: `@genaryth/<app-name>` o `@<org>/<app-name>` (ej. `@genaryth/web`, `@genaryth/api`, `@genaryth/studio-hub`, `@genaryth/contracts`, `@genaryth/ui`).
   - **Justificación:** Previene colisiones catastróficas en registros de paquetes públicos/privados, asegura trazabilidad unívoca de grafos en Turborepo y permite resolver dependencias internas vía `workspace:*` con tipado determinista.

2. **Matriz Canónica de Segregación de Puertos Locales (Anti-`EADDRINUSE`):**
   - Para erradicar colisiones al ejecutar `pnpm dev` en paralelo en monorepos, se establece la asignación fija de puertos en los scripts de `package.json` y variables de entorno:
     * **Puerto 3000:** Experiencia Pública B2B / Web Principal (`apps/web` -> `"dev": "next dev -p 3000"`).
     * **Puerto 3001:** API / Backend NestJS / Microservicios Core (`process.env.PORT || 3001` -> `"dev": "nest start --watch"`).
     * **Puerto 3002:** Studio Hub / Internal Operating System Cockpit (`apps/studio-hub` -> `"dev": "next dev -p 3002"`).
     * **Puertos 3003+:** Ventures secundarias, Microfrontends auxiliares o simuladores.
