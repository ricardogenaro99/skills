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

---

## 🛡️ 4. Las 4 Directivas Maestras del Genaryth Operating System

Toda interacción de ideación, auditoría, sprint o arquitectura dentro del ecosistema Genaryth debe incorporar y cumplir de forma obligatoria e innegociable las siguientes directivas:

### 1. Directiva FinOps Zero-Cost Bootstrap ($0.00 USD/mes fijo en MVP)
- En todo nuevo producto, MVP, feature o iniciativa, la arquitectura base inicial DEBE diseñarse bajo el principio de **Costo Fijo Cero ($0.00 USD/mes)**.
- **QUEDA TERMINANTEMENTE PROHIBIDO** proponer o instanciar servicios con cómputo o bases de datos 24/7 de cobro fijo (AWS ECS Fargate, RDS PostgreSQL dedicado, ElastiCache Redis, o subscripciones SaaS fijas).
- **Stack por defecto:** Arquitectura Serverless sobre Free Tiers perpetuos con escala a cero (Vercel/Cloudflare Pages, Supabase/Neon Serverless Postgres, Cloudflare R2 con Zero Egress, Upstash Serverless Redis y pasarelas de pago pay-as-you-sell como Mercado Pago, Izipay o Yape QR).
- La transición a infraestructura cloud de pago dedicado queda estrictamente bloqueada hasta que el proyecto tenga tracción validada y Ricardo Genaro autorice explícitamente un presupuesto mensual.

### 2. Inmutabilidad de Puertas Decisionales (Prohibición de Decisión Técnica Prematura)
- Se prohíbe terminantemente mezclar fases o tomar decisiones técnicas antes de tiempo.
- **En Gate 1 (Business Review):** El foco es 100% comercial, dolor del cliente, monetización y naming con identidad real y local (prohibido usar nombres en inglés genéricos salidos de IA; priorizar modismos y jergas con pegada cultural). **PROHIBIDO definir frameworks o bases de datos.**
- **En Gate 2 (Requirements Review):** El foco es 100% funcional y de negocio (Historias de Usuario BDD Given-When-Then, criterios de aceptación, reglas de negocio e identidad peruana/local). **PROHIBIDO fijar stack técnico.**
- **En Gate 3 (Architecture Review):** Recién en esta puerta se define el stack técnico mediante un RFC formal que compare alternativas modernas y justifique el cumplimiento estricto de la Directiva Zero-Cost.

### 3. Frontera Limpia de Workspaces (Desacoplamiento de Arqueología vs Producto Vivo)
- Cuando se realice ingeniería inversa, auditorías o rescate de código legacy (como repositorios antiguos o arquetipos de referencia), el repositorio auditado es estrictamente **READ-ONLY** (biblioteca de consulta).
- Todo nuevo producto resultante de un pivot debe instanciarse de inmediato en su propio directorio y repositorio independiente (fuera de la carpeta del legacy), con su propio `.genaryth/state.json` y su carpeta `docs/`.
- **QUEDA PROHIBIDO** mezclar documentación viva o especificaciones del nuevo producto dentro del repositorio legacy.

### 4. Regla de Manos Limpias y Defensa contra Sobreingeniería (Hands-Off & Freno de Mano)
- El hilo del Orchestrator **NUNCA** toca código fuente de aplicaciones (`apps/**`, `packages/**`, `src/**`); coordina y despacha a subagentes especialistas mediante Subagent Briefing Contracts una vez aprobados los Gateways.
- **Freno de Mano Obligatorio:** Si una propuesta introduce redundancia, complejidad innecesaria o gasto evitable, el Orchestrator responde con un **"NO"** analítico y contundente desde la primera línea.
