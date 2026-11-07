# Puertas de Aprobación Decisional (Gateways) - Genaryth Orchestrator

**Principio Rector:** La IA nunca avanza entre etapas sin la aprobación explícita de Ricardo Genaro (Tech Lead). Las actividades operativas se ejecutan únicamente dentro del alcance autorizado de una puerta abierta.

---

## 🚪 GATE 1: BUSINESS_REVIEW (Puerta de Oportunidad & Negocio)
* **Objetivo:** Asegurar que se comprende a fondo el problema del cliente, la viabilidad comercial y el alcance macro antes de definir especificaciones funcionales.
* **Entradas Requeridas:** Idea inicial, restricciones del cliente, objetivos estratégicos.
* **Subagentes Involucrados:** `orchestrator`, `subagent-process` (modelado de flujo As-Is/To-Be).
* **Entregable Obligatorio:** Propuesta de Negocio Estructurada (`docs/BUSINESS_OPPORTUNITY.md` o sección en `docs/CONTEXTO_MAESTRO.md`).
* **Criterios de Calidad:**
  - Problema y dolor real identificados con claridad.
  - Usuarios y partes interesadas mapeados.
  - Alternativas de solución evaluadas desde perspectiva de valor/costo.
  - Supuestos, riesgos y preguntas críticas pendientes.
* **Pregunta de Decisión al Tech Lead:** *¿Se aprueba el alcance de negocio y la propuesta estratégica para proceder con el levantamiento de requerimientos detallados?*
* **Condición de Bloqueo:** PROHIBIDO redactar Historias de Usuario o diseñar arquitectura técnica si Gate 1 no está en estado `APPROVED`.

> [!CAUTION]
> **REGLA DE INMUTABILIDAD DE FASES (NO TECHNICAL COMMITMENT IN GATE 1):**
> Queda **TERMINANTEMENTE PROHIBIDO** definir o escribir en `state.json` frameworks de frontend, runtimes de backend, ORMs o bases de datos en esta fase. El foco es 100% oportunidad comercial, viabilidad de mercado y dolor del cliente.

---

## 🚪 GATE 2: REQUIREMENTS_REVIEW (Puerta de Requerimientos & Criterios)
* **Objetivo:** Definir con rigor qué necesita la solución, eliminando ambigüedades antes del diseño técnico.
* **Entradas Requeridas:** Propuesta de Negocio aprobada en Gate 1.
* **Subagentes Involucrados:** `subagent-po` (BDD/Gherkin), `subagent-process`.
* **Entregable Obligatorio:** Especificación Funcional (`docs/PRODUCT_SPEC_V1.md` o PRD).
* **Criterios de Calidad:**
  - Historias de Usuario estructuradas con formato formal.
  - Criterios de Aceptación bajo sintaxis BDD (*Given-When-Then*).
  - Reglas de negocio explícitas y casos límite (edge cases, errores, excepciones).
  - Requerimientos no funcionales (SLAs de latencia, seguridad, rendimiento, navegadores).
  - Alcance explícitamente incluido y excluido (In-Scope vs. Out-of-Scope).
* **Pregunta de Decisión al Tech Lead:** *¿Se aprueban los requerimientos funcionales y criterios de aceptación para proceder con el diseño de arquitectura y contratos?*
* **Condición de Bloqueo:** PROHIBIDO modelar bases de datos ni endpoints si Gate 2 no está en estado `APPROVED`.

> [!CAUTION]
> **REGLA DE INMUTABILIDAD DE FASES (NO TECHNICAL COMMITMENT IN GATE 2):**
> Queda **TERMINANTEMENTE PROHIBIDO** comprometer decisiones técnicas, preseleccionar frameworks o registrar tecnologías en `state.json`. El foco de Gate 2 es 100% historias BDD y reglas de negocio funcionales. Toda definición técnica debe esperar obligatoriamente a Gate 3.

---

## 🚪 GATE 3: ARCHITECTURE_REVIEW (Puerta de Arquitectura, Contratos & Seguridad)
* **Objetivo:** Establecer la arquitectura sólida de la solución y sellar los contratos de integración antes de escribir código.
* **Entradas Requeridas:** Requerimientos aprobados en Gate 2.
* **Subagentes Involucrados:** `subagent-architect`, `subagent-secops`, `subagent-uiux` (Design System).
* **Entregable Obligatorio:**
  - Especificación de Arquitectura de la Solución (`docs/ARCHITECTURE_SOLUTION.md`).
  - **Evaluación y Selección Justificada del Tech Stack (RFC de Stack):** Backend (NestJS vs Express vs FastAPI vs Go), Frontend (Next.js vs Angular vs React vs Vue), Persistencia (PostgreSQL vs DynamoDB vs Firestore) y Cloud (AWS vs GCP vs Azure vs Firebase).
  - Catálogo y Contratos de API sellados (`docs/openapi.json` / `docs/API_CATALOG_V1.md`).
  - Modelos de Datos / DER relacional o esquemas NoSQL.
  - Registro de Decisiones de Arquitectura (ADRs) con alternativas evaluadas y pros/contras.
  - Threat Modeling preliminar y matriz de seguridad OWASP.

> [!IMPORTANT]
> **DIRECTIVA FINOPS ZERO-COST BOOTSTRAP (POLÍTICA DE COSTO CERO EN MVP):**
> Para todo nuevo producto o MVP del Venture Studio Genaryth, la arquitectura tecnológica propuesta por defecto en **Gate 3** debe cumplir estrictamente con la directiva **"$0.00 USD/mes de costo fijo"**.
> - **Prohibido:** Proponer stacks con cómputo o infraestructura 24/7 (como AWS ECS Fargate, RDS dedicado o ElastiCache) en fases iniciales.
> - **Mandatario:** Estructurar arquitecturas Serverless sobre Free Tiers perpetuos (Vercel/Cloudflare Pages, Supabase/Neon Serverless Postgres, Cloudflare R2 con Zero Egress, Upstash Serverless Redis y pasarelas de pago sin costo mensual fijo).
> - **Excepción:** Solo se migrará a infraestructura dedicada o aprovisionada si Ricardo Genaro (Tech Lead) aprueba explícitamente un presupuesto de escala en Gate 3.

> [!IMPORTANT]
> **POLÍTICA DE ARQUEOLOGÍA Y PIVOT DESACOPLADO (CLEAN ARCHEOLOGY BOUNDARY):**
> Cuando se realice una auditoría o ingeniería inversa sobre repositorios legacy:
> 1. El workspace del proyecto legacy opera estrictamente como biblioteca de lectura y extracción (**Read-Only**).
> 2. Si de la auditoría se decide crear un nuevo producto o pivot (como la evolución de Quena a Toca), el nuevo producto **DEBE instanciarse en un directorio y repositorio independiente**.
> 3. El nuevo producto debe contar con su propio `.genaryth/state.json` y su carpeta `docs/`, sin mezclar jamás la documentación o deuda del activo legacy con la del producto vivo.

* **Criterios de Calidad:**
  - Separación de responsabilidades clara (Clean Architecture / Hexagonal).
  - Códigos de error HTTP, autenticación y autorización (RBAC) especificados.
  - Estrategia de resiliencia y manejo de fallos definida.
* **Pregunta de Decisión al Tech Lead:** *¿Se aprueba la arquitectura, el modelo de datos y los contratos de API sellados para proceder con la planificación del sprint?*
* **Condición de Bloqueo:** PROHIBIDO escribir controladores, servicios, páginas o componentes si Gate 3 no está en estado `APPROVED`.

---

## 🚪 GATE 4: PLAN_REVIEW (Puerta de Planificación & Autorización de Implementación)
* **Objetivo:** Convertir los requerimientos y la arquitectura en un plan de implementación priorizado y ejecutable, autorizando el alcance exacto a construir.
* **Entradas Requeridas:** Contratos de arquitectura aprobados en Gate 3.
* **Subagentes Involucrados:** `orchestrator`, `subagent-backend`, `subagent-frontend`, `subagent-devops`.
* **Entregable Obligatorio:** Tablero de Implementación (`docs/SPRINT_BOARD.md`).
* **Criterios de Calidad:**
  - Desglose granular de tareas técnicas con identificadores únicos (`BE-XX`, `FE-XX`, `OPS-XX`, `QA-XX`).
  - Dependencias entre tareas identificadas y ruta crítica definida.
  - Tareas paralelas identificadas para ejecución de subagentes.
  - Asignación explícita de subagentes por tarea con modelo LLM asignado.
  - Alcance autorizado delimitado (ej. "Autorizado únicamente el Sprint 1: Autenticación y Perfil").
* **Pregunta de Decisión al Tech Lead:** *¿Se aprueba el plan de implementación, la priorización y el alcance autorizado para iniciar la construcción?*
* **Condición de Bloqueo:** PROHIBIDO ejecutar tareas de código que no estén dentro del `authorized_scope` aprobado en Gate 4.

---

## 🚪 GATE 5: ACCEPTANCE_REVIEW (Puerta de Validación, Calidad & Aceptación)
* **Objetivo:** Demostrar con evidencias verificables que el incremento implementado cumple todos los criterios de aceptación y estándares de calidad antes de autorizar cualquier despliegue.
* **Entradas Requeridas:** Código implementado dentro del alcance autorizado en Gate 4.
* **Subagentes Involucrados:** `subagent-qa`, `subagent-secops`, `subagent-sre`.
* **Entregable Obligatorio:** Reporte de Validación y Evidencias (`docs/QA_ACCEPTANCE_REPORT.md`).
* **Criterios de Calidad:**
  - Evidencias duras de pruebas unitarias (100% pasando).
  - Evidencias de pruebas E2E (Playwright) y pruebas de estrés de UI (`break-ui`).
  - Reporte de análisis estático (linter, tipado TypeScript estricto, cero errores).
  - Auditoría de accesibilidad (a11y WCAG AA) y performance (Core Web Vitals).
  - Cero secretos expuestos y dependencias vulnerables auditadas.
* **Pregunta de Decisión al Tech Lead:** *¿Se aceptan los entregables y evidencias para autorizar el cierre del incremento o el paso a despliegue en cloud?*
* **Condición de Bloqueo:** PROHIBIDO realizar despliegues (`cdk deploy`, merge a ramas productivas) si Gate 5 no está en estado `APPROVED`.

---

## ⚡ Orquestación Dual-Track (Dual-Track Governance)

> [!IMPORTANT]
> **LOS GATEWAYS GOBIERNAN ENTREGABLES, NO PARALIZAN EL SQUAD EN CASCADA LINEAL.**
> El Orchestrator evalúa las dependencias técnicas de forma desacoplada para mantener un flujo continuo de alto rendimiento:

```mermaid
flowchart TD
    subgraph TrackEstrategico["🧭 Track Estratégico (Diseño & Gobernanza)"]
        direction TB
        E1["Siguiente Hito: Requerimientos & Riesgos (Gate 2)"] --> E2["subagent-architect & subagent-secops"]
        E2 --> E3["RFC Formal, OpenAPI SSOT & Threat Model (Gate 3)"]
        E3 --> E4["Revisión & Aprobación Tech Lead (Ricardo Genaro)"]
    end

    subgraph TrackOperativo["⚡ Track Operativo (Construcción & Entrega)"]
        direction TB
        O1["Hito Actual: Contratos Previamente Aprobados (Gate 3/4)"] --> O2["subagent-frontend / subagent-qa / subagent-backend"]
        O2 --> O3["Staging Quirúrgico & Commit Local In-Thread (ADR-007)"]
        O3 --> O4["Quality Gate (Exit Code 0) & Reporte con SHA Hash"]
    end

    TrackEstrategico -.->|"Desbloquea nuevo alcance (Gate 4)"| TrackOperativo
    TrackOperativo -->|"Sincronización SSOT en state.json"| Sync["SSOT Consolidado"]
```

### Reglas Operativas del Dual-Track:
1. **Track Operativo (Momentum de Entrega):** Si un componente cuenta con contratos OpenAPI y modelos previamente aprobados (e.g. rediseño UI/UX de pantallas en `apps/web/`), el Orchestrator despacha a los especialistas operativos para avanzar sin fricción.
2. **Track Estratégico (Blindaje de Nuevos Dominios):** En paralelo, si el próximo incremento (e.g. arquitectura de webhooks y EDA en backend o nuevos stacks de CDK) involucra decisiones críticas, el Orchestrator asigna al Architect y SecOps la elaboración del RFC y Threat Modeling.
3. **Punto de Convergencia:** El Track Estratégico solo se convierte en código operativo cuando Ricardo Genaro otorga el `APPROVED` formal en el Gateway correspondiente.

