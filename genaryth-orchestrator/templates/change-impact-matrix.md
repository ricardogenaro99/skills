# Plantilla de Matriz de Impacto ante Cambios (Change Impact Matrix)

Uso obligatorio cuando el Tech Lead o el cliente solicitan una modificación a un requerimiento, arquitectura o contrato previamente aprobado.

---

```markdown
### 🔄 Análisis de Impacto ante Cambio: [RFC-CAMBIO-XXX: NOMBRE]

**Fecha de Solicitud:** [YYYY-MM-DD]  
**Origen del Cambio:** [Tech Lead / Feedback de Cliente / Hallazgo Técnico]  
**Estado Actual del Proyecto:** [ej. IMPLEMENTATION]

---

#### 1. Descripción del Cambio Solicitado
* **Situación Aprobada Anteriormente:** [Qué se había acordado en Gateways previos].
* **Nueva Propuesta de Cambio:** [Qué se desea cambiar exactamente].
* **Razón del Cambio:** [Por qué es necesario este ajuste].

---

#### 2. Matriz de Impacto Cruzado

| Dimensión | Elementos Afectados | Nivel de Impacto | Acción Requerida |
| :--- | :--- | :---: | :--- |
| **Requerimientos (HUs)** | [ej. HU-02, Criterios BDD] | 🟡 Medio | Actualizar `docs/PRODUCT_SPEC_V1.md` |
| **Contratos de API** | [ej. PATCH /api/v1/pets/:id] | 🔴 Alto | Actualizar OpenAPI y `@kinpet/common` |
| **Modelos de Datos / BD** | [ej. Tabla pets, migración SQL] | 🔴 Alto | Generar nueva migración Prisma |
| **Código Backend** | [ej. PetsService, UpdatePetDto] | 🟡 Medio | Refactorizar lógica de dominio |
| **Código Frontend** | [ej. PetControlCenter.tsx] | 🟡 Medio | Ajustar formulario React Hook Form |
| **Infraestructura (CDK)** | [ej. Nuevo bucket S3, nuevas rutas] | 🟢 Bajo | Ajustar stack CDK en desarrollo |
| **Suites de Pruebas (QA)** | [ej. 4 tests Jest, 1 spec Playwright] | 🟡 Medio | Actualizar assertions y mocks |

---

#### 3. Estado de Puertas (Gateways) Afectadas

- [ ] **GATE 1 (Business):** Mantener `APPROVED`.
- [ ] **GATE 2 (Requirements):** Revertir temporalmente a `PENDING_REVISION` para reflejar el nuevo alcance.
- [ ] **GATE 3 (Architecture):** Revertir a `PENDING_REVISION` para actualizar contratos OpenAPI y modelos.
- [ ] **GATE 4 (Planning):** Ajustar estimaciones y dependencias en `docs/SPRINT_BOARD.md`.

---

#### 4. Riesgo de Deuda Técnica y Desviación de Cronograma
* **Esfuerzo Estimado de Refactor:** [X horas / X sprints].
* **Riesgo de Regresiones:** [Bajo / Medio / Alto].
* **Recomendación del Squad:** [¿Conviene aplicar el cambio ahora o posponerlo para la siguiente versión?].

---

#### 5. Decisión Requerida del Tech Lead
- [ ] **Aprobar Cambio y Reversión Controlada de Puertas:** Autoriza actualizar la documentación SSOT y reabrir Gate 2 y Gate 3 antes de modificar código.
- [ ] **Posponer Cambio (Registrar en Backlog Futuro):** Continuar con el incremento actual según lo aprobado y calendarizar el cambio para un release posterior.
- [ ] **Desestimar Cambio:** Mantener el diseño actual sin modificaciones.
```
