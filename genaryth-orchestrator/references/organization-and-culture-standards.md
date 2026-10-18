# Estándares Organizacionales, Cultura y Modelo de Negocio — Genaryth

**Propósito:** Definir la constitución corporativa, cultura de ingeniería y modelo operativo de Genaryth como consultora de élite y venture studio de alto rendimiento.

---

## 🏛️ 1. Identidad Corporativa y Modelo de Negocio Dual

Genaryth opera bajo un modelo de sinergia dual:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        GENARYTH VENTURE STUDIO                         │
├───────────────────────────────────┬────────────────────────────────────┤
│       CONSULTORÍA B2B DE ÉLITE     │          VENTURE STUDIO            │
│   (Flujo de Caja & Autoridad)     │     (Equity & Escalamiento)        │
├───────────────────────────────────┼────────────────────────────────────┤
│ • Arquitectura Backend Serverless │ • Incubación de Startups Propias   │
│ • Sistemas de Misión Crítica      │ • Kinpet (Pet Identification SaaS) │
│ • Automatización Agéntica (GASF)  │ • Sprintflow (Agent Agile Board)   │
│ • Alta Disponibilidad & FinOps    │ • Arquetipos y Tooling Reutilizable│
└───────────────────────────────────┴────────────────────────────────────┘
```

1. **Flujo Virtuoso de Reinversión:**
   - La consultoría B2B financia y valida en campo arquitecturas de alta disponibilidad.
   - El Venture Studio empaqueta el conocimiento en productos SaaS escalables propios.
2. **Desacoplamiento Estricto de Dominios:**
   - Queda terminantemente prohibido mezclar la presencia pública (`apps/web`) con las herramientas y telemetría interna del Venture Studio (`apps/studio-hub`).
   - Todo módulo interno opera aislado bajo su propio scope y puerto dedicado (ADR-013).

---

## 🚀 2. El Embudo de Incubación en 5 Fases

Toda iniciativa, startup interna o producto incubado por Genaryth debe transitar obligatoriamente por 5 fases estandarizadas:

1. **Fase 1: Radar & Ideación:**
   - Identificación de fricciones reales en el mercado con análisis de viabilidad técnica y márgenes operativos.
2. **Fase 2: RFC & Puertas Decisionales (Gateways 1-3):**
   - Especificación formal en `PRODUCT_SPEC_V1.md` y arquitectura en `ARCHITECTURE_SOLUTION.md`. Aprobación soberana de Ricardo Genaro (Tech Lead).
3. **Fase 3: Prototipo Rápido (48 - 72h):**
   - Validación de la experiencia de usuario y contratos de integración con interfaces asimétricas y sin clichés de IA.
4. **Fase 4: MVP Funcional e Instrumentación:**
   - Backend con transacciones ACID, telemetría real conectada, SLAs de carga rápida (The Nala SLA < 1.2s) y suite de pruebas pasando al 100%.
5. **Fase 5: Lanzamiento & Operación Sostenible:**
   - Despliegue formal en AWS Serverless / Vercel Edge con observabilidad CloudWatch y balance financiero auditado.

---

## 👑 3. Soberanía del Tech Lead y Principio Human-in-the-Loop

1. **Liderazgo Técnico Soberano:**
   - **Ricardo Genaro** es el Managing Director y Tech Lead único del ecosistema. Ninguna IA toma decisiones arquitectónicas unilaterales que comprometan presupuesto o contratos.
2. **Regla de Manos Limpias (Hands-Off Code Rule):**
   - El Orchestrator coordina, desglosa, redacta contratos de despacho y audita; **NUNCA escribe código en el hilo principal**.
   - Toda tarea técnica se delega a subagentes especialistas (`subagent-backend`, `subagent-frontend`, `subagent-devops`, etc.).
3. **Cero Concesiones en Calidad:**
   - Exit Code 0 en suites locales como condición innegociable antes de cualquier commit.
   - Prohibido el código genérico de IA ("AI slop"); todo desarrollo responde al estándar de autor y craft refinado de la firma.
