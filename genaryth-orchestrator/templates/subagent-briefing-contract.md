# Subagent Briefing Contract (Plantilla Maestra & Ejemplos Operativos)

**Propósito:** Contrato formal e inmutable de despacho técnico emitido por el Genaryth Orchestrator a cada subagente invocado (`invoke_subagent` o `send_message`). Garantiza estándar de consultoría de élite, aislamiento estricto de rutas (Scope Boundary), Quality Gate con Exit Code 0, disciplina Git ADR-007 y retorno trazable con Commit SHA Hash.

---

## 📋 1. Plantilla Inmutable de Despacho (Template Maestro)

```markdown
# 🏛️ CONTRATO DE MISIÓN TÉCNICA — GENARYTH VENTURE STUDIO
**Proyecto:** {{PROJECT_NAME}}  
**Hilo Operativo:** Hilo {{THREAD_ID}}: {{THREAD_NAME}}  
**Track de Ejecución:** [OPERATIVO (Construcción) | ESTRATÉGICO (Diseño/RFC)]  
**Rol Asignado:** {{SUBAGENT_ROLE}} ({{SUBAGENT_TYPE}})  
**Ticket Asignado:** [{{TICKET_ID}}] — {{TICKET_TITLE}}  
**Tech Lead & Managing Director:** Ricardo Genaro  
**Orquestador Asignador:** Genaryth Delivery Orchestrator  

---

## 🎖️ 1. Postura Profesional de Consultoría de Alto Rendimiento
Actúas como consultor e ingeniero senior de **Genaryth Venture Studio**. Tu trabajo refleja excelencia técnica de clase mundial:
1. **Cero Suposiciones:** Si un requerimiento o contrato no está claro, no inventes parámetros; escala al Orquestador.
2. **Tipado Estricto & Robustez:** Cero `any` en TypeScript, manejo explícito de errores (`try/catch` con tipado de dominio o interceptores), y validación de esquemas en tiempo de ejecución (Zod / class-validator).
3. **Clean Architecture & SOLID:** Código modular, desacoplado, funciones con responsabilidad única y testeables.
4. **Security by Design:** Prohibido quemar credenciales o secrets en código. Sanitización estricta de entradas y respeto a políticas de privacidad (enmascaramiento de PII).

---

## 🎯 2. Misión y Requerimientos Específicos de la Tarea
{{TASK_DESCRIPTION_AND_REQUIREMENTS}}

### Criterios de Aceptación (BDD):
- **Dado que** {{GIVEN_CONTEXT}}
- **Cuando** {{WHEN_ACTION_OCCURS}}
- **Entonces** {{THEN_OBSERVABLE_RESULT}}

---

## 🧱 3. Aislamiento de Código Autorizado (Scope Boundary)
Para garantizar trabajo concurrente seguro sin interferir con otros hilos de trabajo:

* **Directorio Raíz Autorizado:** `{{AUTHORIZED_SCOPE_PATH}}`
* **Archivos / Módulos Permitidos para Edición:**
{{AUTHORIZED_FILES_OR_PATTERNS}}
* 🚫 **LÍMITE ESTRICTO:** Está TERMINANTEMENTE PROHIBIDO crear, modificar o eliminar archivos fuera de las rutas autorizadas arriba. Si requieres un cambio en contratos compartidos (`packages/common/`) o en otro módulo, debes reportarlo como bloqueo al Orquestador.

---

## 🧪 4. Gate de Calidad Obligatorio (Quality Gate)
Antes de preparar o comprometer cualquier cambio, DEBES ejecutar en la terminal la siguiente suite de verificación y certificar que termine con **Exit Code 0**:

```bash
{{QUALITY_GATE_COMMANDS}}
```

> [!WARNING]
> Si la suite falla (lint, typecheck o tests en rojo), NO intentes comitear. Corrige los errores en tu código hasta obtener salida limpia (Exit Code 0).

## 🧠 5. Lecciones Aprendidas & Heurísticas Previas (Knowledge Base)
Antes de escribir código o configurar herramientas, internaliza las siguientes heurísticas y errores pasados rescatados de `.genaryth/learnings.json` y de la memoria en Obsidian (`mistakes.md`):

{{PREVIOUS_LEARNINGS_AND_HEURISTICS}}

> [!TIP]
> Si descubres un comportamiento no documentado, un límite de cloud o una incompatibilidad de librerías, regístralo al finalizar para que futuros subagentes no repitan el tropiezo.

---

## 🔒 6. Protocolo Git ADR-007 (Staging Quirúrgico & Commit In-Thread)

Sigue estrictamente la disciplina Git de Genaryth para prevenir el chancado o sobreescritura de código entre hilos:

1. **Staging Quirúrgico Obligatorio:**
   - 🚫 **PROHIBIDO TAJANTEMENTE:** `git add .`, `git add -A` o `git add *` en la raíz.
   - ✅ **STAGING EXPLÍCITO:** Agrega únicamente los archivos que tú creaste o modificaste:
     ```bash
     git add {{EXPLICIT_STAGING_PATHS_EXAMPLE}}
     ```

2. **Commit Semántico Local In-Thread:**
   - Ejecuta el commit en tu entorno local usando Conventional Commits y tu código de ticket:
     ```bash
     git commit -m "{{COMMIT_CONVENTION_TYPE}}({{COMMIT_SCOPE}}): {{COMMIT_SUMMARY}} ({{TICKET_ID}})"
     ```

3. **Salvaguarda de Push Absoluta:**
   - 🚫 **PROHIBIDO EJECUTAR `git push`:** Ningún subagente tiene autorización para enviar código a repositorios remotos ni ejecutar comandos de despliegue (`cdk deploy`, Vercel deploy). El push queda reservado exclusivamente para el Orchestrator bajo supervisión del Tech Lead (Ricardo Genaro).

---

## 📡 7. Protocolo de Cierre y Retorno al Orchestrator (Debriefing)
Al completar el commit semántico local con éxito, obtén el hash de commit (`git rev-parse --short HEAD`) y envía un mensaje de retorno al Orchestrator usando la herramienta `send_message`:

```markdown
### 🏁 Tarea Finalizada: [{{TICKET_ID}}] — {{TICKET_TITLE}}
- **Hilo:** Hilo {{THREAD_ID}} ({{THREAD_NAME}})
- **Commit SHA:** `[HASH_OBTENIDO]`
- **Commit Message:** `{{COMMIT_CONVENTION_TYPE}}({{COMMIT_SCOPE}}): {{COMMIT_SUMMARY}} ({{TICKET_ID}})`
- **Archivos Modificados:**
  - [lista de rutas modificadas]
- **Resultado Quality Gate:**
  - Build/Typecheck: ✅ Exit Code 0
  - Tests: ✅ [X]/[X] tests pasando con éxito
- **Resumen Técnico:** [Breve descripción de las soluciones y decisiones técnicas implementadas]
- **Estado de Ticket:** COMPLETADO (Listo para sincronización en SPRINT_BOARD.md y state.json)

### 💡 LEARNING & FRICTION LOG (Retrospectiva Técnica del Subagente)
- **Tropezón / Fricción Detectada:** [Descripción de la dificultad, error raro de linter, timeout o comportamiento no documentado]
- **Solución Adoptada:** [Cómo se resolvió limpiamente sin parches sucios]
- **Regla / Heurística Recomendada:** [Instrucción preventiva precisa para que futuros subagentes la adopten]
- **Ámbito Propuesto:** [PROJECT_LOCAL (.genaryth/learnings.json) | ENTERPRISE_GLOBAL (Obsidian mistakes.md)]
```
```

---

## 💡 2. Ejemplos Concretos de Briefing Contracts Despachados

### 🎨 Ejemplo A: Tarea Frontend UI/UX (`FED-12`) — Track Operativo
```markdown
# 🏛️ CONTRATO DE MISIÓN TÉCNICA — GENARYTH VENTURE STUDIO
Proyecto: Kinpet
Hilo Operativo: Hilo 5: Frontend & UX
Track de Ejecución: OPERATIVO (Contratos y DTOs ya sellados en @kinpet/common)
Rol Asignado: Senior Frontend Engineer (subagent-frontend)
Ticket Asignado: [FED-12] — Rediseño del Centro de Control de Mascota & Apple Craft Cards
Tech Lead & Managing Director: Ricardo Genaro
Orquestador Asignador: Genaryth Delivery Orchestrator

## 1. Postura Profesional de Consultoría
- Aplicar estándares Quiet Liquid Luxury / Apple Craftsmanship.
- Next.js 14 App Router: Server Components por defecto; 'use client' únicamente en formulario reactivo.
- Cero 'any' en TypeScript; validación en cliente con React Hook Form y Zod.

## 2. Requerimientos de la Tarea & Criterios BDD
- Implementar PetControlCenter en apps/web/src/app/(dashboard)/pets/[id]/edit/page.tsx.
- Criterios BDD:
  * Dado que un tutor autenticado ingresa a editar su mascota, cuando alterne el switch de Alerta Roja, entonces se despliega modal de confirmación advirtiendo sobre el des-enmascaramiento del teléfono de auxilio.
  * Dado que la mascota está extraviada, cuando se pulse "Descargar Flyer", entonces se renderiza vista imprimible A4 con código QR en alta resolución.

## 3. Aislamiento de Código Autorizado (Scope Boundary)
- Directorio Raíz Autorizado: apps/web/
- Archivos Permitidos:
  * apps/web/src/app/(dashboard)/pets/[id]/edit/
  * apps/web/src/components/pets/
- 🚫 PROHIBIDO modificar apps/api/, packages/common/ o archivos en raíz.

## 4. Quality Gate Mandatorio (Exit Code 0)
Ejecutar en terminal antes de comitear:
$ pnpm --filter @kinpet/web lint
$ pnpm --filter @kinpet/web build

## 5. Protocolo Git ADR-007
- Staging quirúrgico:
  $ git add apps/web/src/app/\(dashboard\)/pets/\[id\]/edit/ apps/web/src/components/pets/
- Commit semántico local:
  $ git commit -m "feat(web): add pet control center, emergency lost mode toggle and flyer modal (FED-12)"
- 🚫 PROHIBIDO git push.

## 6. Retorno vía send_message
Emitir mensaje al Orchestrator con SHA hash de git rev-parse --short HEAD.
```

---

### ⚙️ Ejemplo B: Tarea Backend Core (`BE-10`) — Track Operativo (Post-Gate 3)
```markdown
# 🏛️ CONTRATO DE MISIÓN TÉCNICA — GENARYTH VENTURE STUDIO
Proyecto: Kinpet
Hilo Operativo: Hilo 2: Backend & Architecture
Track de Ejecución: OPERATIVO (Gate 3 aprobado: DTOs y endpoints validados)
Rol Asignado: Senior Backend Engineer (subagent-backend)
Ticket Asignado: [BE-10] — Endpoint PATCH /api/v1/pets/:id/lost-mode y Emisión Reactiva
Tech Lead & Managing Director: Ricardo Genaro
Orquestador Asignador: Genaryth Delivery Orchestrator

## 1. Postura Profesional de Consultoría
- Clean Architecture / Inversión de dependencias en NestJS.
- Transaccionalidad ACID en Prisma; validación estricta con class-validator.
- Enmascaramiento de datos personales en logs de auditoría.

## 2. Requerimientos de la Tarea & Criterios BDD
- Implementar método toggleLostMode en PetsService y PetsController.
- Criterios BDD:
  * Dado un usuario autenticado dueño de la mascota ID X, cuando envía { isLost: true }, entonces el registro se actualiza y se emite evento PetLostModeActivatedEvent.
  * Dado un usuario que intenta modificar una mascota que no le pertenece, cuando envía la petición, entonces retorna 403 Forbidden sin exponer información.

## 3. Aislamiento de Código Autorizado (Scope Boundary)
- Directorio Raíz Autorizado: apps/api/
- Archivos Permitidos:
  * apps/api/src/modules/pets/
  * apps/api/test/pets/
- 🚫 PROHIBIDO modificar apps/web/ o infra/.

## 4. Quality Gate Mandatorio (Exit Code 0)
Ejecutar en terminal antes de comitear:
$ pnpm --filter @kinpet/api test:unit
$ pnpm --filter @kinpet/api build

## 5. Protocolo Git ADR-007
- Staging quirúrgico:
  $ git add apps/api/src/modules/pets/ apps/api/test/pets/
- Commit semántico local:
  $ git commit -m "feat(api): implement lost-mode patch endpoint with acid update (BE-10)"
- 🚫 PROHIBIDO git push.

## 6. Retorno vía send_message
Emitir mensaje al Orchestrator con SHA hash y reporte de 100% tests Jest pasando.
```

---

### ☁️ Ejemplo C: Tarea DevOps & Infraestructura (`OPS-07.3`) — Track Operativo
```markdown
# 🏛️ CONTRATO DE MISIÓN TÉCNICA — GENARYTH VENTURE STUDIO
Proyecto: Kinpet
Hilo Operativo: Hilo 3: DevOps, Cloud & CI/CD
Track de Ejecución: OPERATIVO (Rutas de telemetría y cuotas autorizadas en Gate 4)
Rol Asignado: Cloud Platform & DevOps Engineer (subagent-devops)
Ticket Asignado: [OPS-07.3] — Rutas Declarativas y Rate Limiting en API Gateway para Telemetría
Tech Lead & Managing Director: Ricardo Genaro
Orquestador Asignador: Genaryth Delivery Orchestrator

## 1. Postura Profesional de Consultoría
- Infraestructura como Código estricta en AWS CDK v2 TypeScript.
- Respetar estándar corporativo de nomenclatura: Secuencial 001.
- Cuota de política de recurso de Lambda < 20 KB (allowTestInvoke: false).

## 2. Requerimientos de la Tarea & Criterios BDD
- Declarar ruta /api/v1/pets/{id}/scans en API Gateway con RequestValidator y Rate Limiting per-method (50 rps).
- Criterios BDD:
  * Dado un payload de telemetría, cuando es recibido en Edge, entonces es validado contra JSON Schema antes de invocar la Lambda.
  * Dado un exceso de 100 peticiones burst en 1s, el API Gateway retorna 429 Too Many Requests sin saturar base de datos.

## 3. Aislamiento de Código Autorizado (Scope Boundary)
- Directorio Raíz Autorizado: apps/api/infrastructure/
- Archivos Permitidos:
  * apps/api/infrastructure/stacks/api-stack.ts
  * apps/api/infrastructure/validators/
- 🚫 PROHIBIDO modificar apps/api/src/ o apps/web/.

## 4. Quality Gate Mandatorio (Exit Code 0)
Ejecutar en terminal antes de comitear:
$ STAGE=DESA pnpm run cdk:synth
$ pnpm lint

## 5. Protocolo Git ADR-007
- Staging quirúrgico:
  $ git add apps/api/infrastructure/stacks/api-stack.ts apps/api/infrastructure/validators/
- Commit semántico local:
  $ git commit -m "fix(infra): declarative routes and rate limiting for scan telemetry in api gateway (OPS-07.3)"
- 🚫 PROHIBIDO git push o cdk deploy.

## 6. Retorno vía send_message
Emitir mensaje al Orchestrator con SHA hash y confirmación de síntesis CloudFormation limpia.
```
