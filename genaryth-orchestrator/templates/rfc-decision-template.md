# Plantilla RFC de Decisión Arquitectónica / Gateway

Esta plantilla es de uso obligatorio para el Orquestador cuando se alcanza una Puerta Decisional (Gateways 1 al 5) o ante cualquier decisión de impacto clasificada como Nivel 3.

---

```markdown
### 📋 Propuesta de Decisión / Gateway: [GATE_X: NOMBRE_DEL_GATEWAY]

**Proyecto:** [Nombre del Proyecto]  
**Fecha:** [YYYY-MM-DD]  
**Autor:** [Rol proponente, ej. Solutions Architect / Engagement Lead]  
**Revisor Decisor:** Ricardo Genaro (Tech Lead)

---

#### 1. Contexto y Justificación
* **Problema u Oportunidad:** [Descripción concisa del desafío técnico o de negocio que estamos resolviendo].
* **Entregables Vinculados:** [[Ruta al entregable o PRD/ADR/OpenAPI]].
* **Objetivo de la Decisión:** [Qué se busca definir antes de avanzar a la siguiente etapa].

---

#### 2. Alternativas Evaluadas

| Criterio | Opción A (Recomendada) | Opción B (Alternativa) |
| :--- | :--- | :--- |
| **Nombre de la Opción** | [ej. PostgreSQL con Prisma ORM] | [ej. DynamoDB Single-Table Design] |
| **Arquitectura** | [Breve descripción técnica] | [Breve descripción técnica] |
| **Ventajas** | • [Ventaja 1]<br>• [Ventaja 2] | • [Ventaja 1]<br>• [Ventaja 2] |
| **Desventajas / Riesgos** | • [Desventaja 1] | • [Desventaja 1] |
| **Impacto en Costos / FinOps**| [Costo estimado o tier de consumo] | [Costo estimado o tier de consumo] |
| **Complejidad de Mantenimiento** | [Baja / Media / Alta] | [Baja / Media / Alta] |

---

#### 3. Riesgos, Dependencias e Impactos
* **Seguridad / Cumplimiento:** [¿Afecta datos sensibles, auth o secretos?]
* **Rendimiento / Latencia:** [¿Cumple con los SLAs requeridos?]
* **Deuda Técnica Previsible:** [¿Qué compromisos se asumen a futuro?]
* **Dependencias Bloqueantes:** [¿Requiere aprobación de infraestructura previa?]

---

#### 4. Recomendación Fundamentada del Squad
> **Recomendación:** Proponemos adoptar la **Opción [A/B]** debido a que [justificación sólida en base a simplicidad, compatibilidad con el stack de Genaryth y reducción de riesgos operativos].

---

#### 5. Decisión Requerida del Tech Lead
Para avanzar con el ciclo de vida, selecciona una de las siguientes opciones:

- [ ] **Aprobar Opción A (Recomendada):** Autoriza el paso al siguiente Gateway y la persistencia de la decisión.
- [ ] **Aprobar Opción B:** Instruye al squad a ajustar la arquitectura bajo la alternativa B.
- [ ] **Solicitar Ajustes / Análisis Adicional:** Especifica qué aspectos técnicos o de negocio requieren mayor profundización.
- [ ] **Rechazar:** Mantener el estado actual y reformular la propuesta.
```
