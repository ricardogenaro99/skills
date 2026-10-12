# Agent Execution Harness — Especificación Técnica & Runtime Guardrails (GASF v2.0)

## 1. Visión General & Filosofía
El **Agent Execution Harness** de Genaryth Venture Studio es la capa de contención, aislamiento y gobierno en tiempo de ejecución (Runtime Sandboxing & Guardrails) que envuelve a los subagentes especializados durante todo el ciclo de desarrollo asistido por IA.

En sistemas multiagente de alta velocidad, permitir que los modelos de lenguaje ejecuten comandos de terminal o modifiquen archivos sin supervisión estricta conduce inevitablemente a colisiones de código (*git chancado*), fugas de secretos, sobrecostos de tokens (*context bloating*), caídas de pipelines de CI/CD y despliegues accidentales.

El Execution Harness resuelve esto mediante 4 pilares tecnológicos:
1. **Context Pruning Engine:** Aislamiento quirúrgico del contexto inyectado a cada subagente.
2. **Tool Sandbox Matrix:** Matriz de permisos y accesos por rol y frontera de directorio (*Scope Boundaries*).
3. **Policy Interceptor:** Interceptor estricto en tiempo de ejecución que frena comandos prohibidos.
4. **State Synchronizer:** Persistencia y trazabilidad automática hacia `.genaryth/state.json`.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        GENARYTH AGENT EXECUTION HARNESS                                 │
├────────────────────────────────────────────────────────────────────────────────────────┤
│  [Tech Lead / Ricardo Genaro] ──> [Engagement & Delivery Lead / Orchestrator]          │
│                                           │                                            │
│                                  Subagent Briefing                                     │
│                                      Contract                                          │
│                                           ▼                                            │
│  ┌──────────────────────────────────────────────────────────────────────────────────┐  │
│  │                              EXECUTION HARNESS                                   │  │
│  │                                                                                  │  │
│  │   ┌────────────────────────┐      ┌──────────────────────────────────────────┐   │  │
│  │   │ Context Pruning Engine │      │ Tool Sandbox Matrix                      │   │  │
│  │   │ (Zero-Bloat Injection) │      │ (Read-Only / Scoped Write / No-Terminal) │   │  │
│  │   └───────────┬────────────┘      └────────────────────┬─────────────────────┘   │  │
│  │               │                                        │                         │  │
│  │               ▼                                        ▼                         │  │
│  │   ┌──────────────────────────────────────────────────────────────────────────┐   │  │
│  │   │ Policy Interceptor (interceptor-rules.json)                              │   │  │
│  │   │ 🚫 git add .  🚫 git push  🚫 cdk deploy  🚫 prisma migrate reset        │   │  │
│  │   └───────────────────────────────────┬──────────────────────────────────────┘   │  │
│  │                                       │                                          │  │
│  │                                       ▼                                          │  │
│  │                         [Specialized Subagent Execution]                         │  │
│  │                      (subagent-backend, subagent-frontend, etc.)                 │  │
│  │                                       │                                          │  │
│  │                                       ▼                                          │  │
│  │   ┌──────────────────────────────────────────────────────────────────────────┐   │  │
│  │   │ State Synchronizer -> .genaryth/state.json & SPRINT_BOARD.md (Commit Log)│   │  │
│  │   └──────────────────────────────────────────────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Context Pruning Engine (Aislamiento Quirúrgico de Contexto)

### 2.1 El Problema del Bloat de Contexto
Inyectar el monorepo completo, logs extensos de pruebas o historiales de conversación a un subagente provoca:
* **Alucinaciones y pérdida de foco:** El modelo pierde atención sobre los archivos específicos que debe modificar.
* **Sobrecosto FinOps:** Desperdicio de tokens en lecturas redundantes de miles de líneas irrelevantes.
* **Riesgo de contaminación cruzada:** El subagente intenta modificar archivos fuera de su especialidad (ej. un frontend intentando tocar la base de datos).

### 2.2 Reglas de Poda e Inyección
El motor de poda aplica **Inyección Quirúrgica** basada en el rol del subagente:

1. **Inyección Mínima Viable (MVI):**
   * **Contratos Compartidos (`packages/common/`):** Tipos DTOs e interfaces SSOT (siempre de solo lectura para todos los subagentes excepto Arquitectura).
   * **Scope Específico:** Únicamente los árboles de directorios autorizados en el *Subagent Briefing Contract*.
   * **Ficha del Ticket Activo:** Descripción BDD del ticket, criterios de aceptación y dependencias inmediatas.
   * **Heurísticas Previas Filtradas:** Máximo 3 a 5 lecciones aprendidas relevantes desde `.genaryth/learnings.json` correspondientes al dominio del subagente.
2. **Filtros de Exclusión Inviolables:**
   * Archivos y carpetas ignorados por defecto: `node_modules/`, `.git/`, `.next/`, `dist/`, `build/`, `cdk.out/`, `.turbo/`, `coverage/`, logs (`*.log`), archivos de lock (`pnpm-lock.yaml`, `package-lock.json`).
   * Prohibición de dumps masivos de terminal: Los logs de ejecución de pruebas o compilación deben truncarse reportando solo los errores de compilación (`stderr`) y el resumen final.

---

## 3. Tool Sandbox Matrix (Matriz de Permisos por Rol)

El acceso a las herramientas del entorno está estrictamente segmentado según el principio de privilegio mínimo (*Least Privilege*):

| Rol / Subagente | Lectura (`view_file`, grep) | Escritura (`write_to_file`, `replace_file_content`) | Terminal (`run_command`) | Delegación (`invoke_subagent`) | Git Remote (`git push`) |
| :--- | :---: | :--- | :--- | :---: | :---: |
| **Orchestrator Lead** | Global | 🚫 **Manos Limpias:** Solo `docs/**`, `.genaryth/**`, `GEMINI.md` | Comandos de inspección, git push autorizado | ✅ Si (Obligatorio) | ✅ Si (Con HitL) |
| **subagent-architect** | Global | Solo `docs/**`, `packages/common/**`, contratos | Comandos de validación (`npx openapi-generator`, `tsc`) | ❌ No | 🚫 PROHIBIDO |
| **subagent-backend** | Global | `apps/api/**`, `packages/**` | Tests, compilación, Prisma generate local | ❌ No | 🚫 PROHIBIDO |
| **subagent-frontend** | Global | `apps/web/**`, `packages/**` | Tests, Next.js build local, Playwright component | ❌ No | 🚫 PROHIBIDO |
| **subagent-devops** | Global | `apps/*/infrastructure/**`, `.github/**`, scripts | CDK synth, CDK diff, Docker build | ❌ No | 🚫 PROHIBIDO |
| **subagent-qa** | Global | `apps/*/e2e/**`, `apps/*/tests/**`, `docs/qa/**` | Jest, Vitest, Playwright E2E | ❌ No | 🚫 PROHIBIDO |
| **subagent-secops** | Global | `docs/security/**`, políticas de seguridad | Auditorías de dependencias (`pnpm audit`, trivy) | ❌ No | 🚫 PROHIBIDO |

---

## 4. Policy Interceptor (Interceptor de Comandos en Runtime)

El **Policy Interceptor** valida de forma estática cualquier instrucción antes de su ejecución en el runtime o shell del sistema.

### 4.1 Comandos Prohibidos en Seco (Hard Block - Exit Code 126)
Cualquier intento de ejecutar las siguientes expresiones detiene la ejecución inmediatamente y retorna un error de violación de política:

```bash
# 🚫 Git Anti-Chancado Violations:
git add .
git add -A
git add --all
git add *
git commit -a
git commit -am *

# 🚫 Push Safeguard Violations (Subagentes):
git push
git push origin *
git push --force*

# 🚫 Destructive Database / Infrastructure Commands:
prisma migrate reset*
drop database*
cdk deploy* (Sin autorización expresa del HitL)
rm -rf /
rm -rf ~
```

### 4.2 Verificación de Staging Quirúrgico
Antes de emitir cualquier comando `git commit`, el interceptor valida que el índice de Git contenga **exclusivamente archivos dentro del `authorized_scope`** del subagente:
```bash
# Validación de Staging por Interceptor:
UNAUTHORIZED_STAGED=$(git diff --name-only --cached | grep -v "^${AUTHORIZED_SCOPE_PATH}")
if [ -n "$UNAUTHORIZED_STAGED" ]; then
  echo "❌ [POLICY VIOLATION]: Intento de staging fuera del alcance autorizado:"
  echo "$UNAUTHORIZED_STAGED"
  exit 1
fi
```

---

## 5. State Synchronizer (Automatización de `.genaryth/state.json`)

Al finalizar con éxito una tarea, el Harness coordina la actualización transaccional del estado del proyecto:

1. **Validación de Ticket:** Comprueba que el ticket reportado coincida con el `active_ticket` asignado.
2. **Commit SHA Verification:** Confirma que el hash retornado existe en el historial local (`git rev-parse --verify [SHA]`).
3. **Actualización de Tableros:**
   * Mueve el ticket a `completed_tickets` en `.genaryth/state.json`.
   * Registra la entrada en `commit_log` con timestamp ISO y autor.
   * Marca el checklist en `docs/SPRINT_BOARD.md` conservando notas previas.
4. **Liberación de Hilo:** El hilo operativo pasa a estado `IDLE`, listo para el siguiente despacho.
