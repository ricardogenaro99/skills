# Subagent Briefing Contract (Plantilla Inmutable de Despacho Técnico)

```markdown
# 🏛️ CONTRATO DE MISIÓN TÉCNICA — GENARYTH VENTURE STUDIO
**Proyecto:** {{PROJECT_NAME}} (ID: `{{PROJECT_ID}}`)
**Ticket:** [{{TICKET_ID}}] — {{TICKET_TITLE}}
**Hilo:** Hilo {{THREAD_ID}}: {{THREAD_NAME}}
**Rol:** {{SUBAGENT_ROLE}} ({{SUBAGENT_TYPE}})

## 1. Misión & Criterios BDD
{{TASK_DESCRIPTION_AND_REQUIREMENTS}}

- **Dado que** {{GIVEN_CONTEXT}}
- **Cuando** {{WHEN_ACTION_OCCURS}}
- **Entonces** {{THEN_OBSERVABLE_RESULT}}

## 2. Aislamiento de Código Autorizado (Scope Boundary)
- **Directorio Raíz Autorizado:** `{{AUTHORIZED_SCOPE_PATH}}`
- **Archivos / Módulos Permitidos:**
{{AUTHORIZED_FILES_OR_PATTERNS}}
- 🚫 **LÍMITE ESTRICTO:** Prohibido crear, modificar o eliminar archivos fuera de las rutas autorizadas. Cambios en contratos (`packages/common/`) requieren reporte al Orchestrator.

## 3. Quality Gate Mandatorio (Exit Code 0)
Ejecutar antes de comitear y verificar salida limpia sin errores ni warnings:
```bash
{{QUALITY_GATE_COMMANDS}}
```

## 4. Heurísticas & Lecciones Previas (Filtradas por Área)
{{PREVIOUS_LEARNINGS_AND_HEURISTICS}}
*(Nota para el Orchestrator: Inyectar exclusivamente las 2-3 heurísticas con `area == "{{SUBAGENT_AREA}}"`. Prohibido inyectar el catálogo completo de aprendizajes).*

## 5. Protocolo Git ADR-007 (Staging Quirúrgico & Commit Local)
1. **Staging Explícito:** `git add {{EXPLICIT_STAGING_PATHS_EXAMPLE}}` (Prohibido `git add .` o `-A`).
2. **Commit Local:** `git commit -m "{{COMMIT_CONVENTION_TYPE}}({{COMMIT_SCOPE}}): {{COMMIT_SUMMARY}} ({{TICKET_ID}})"`
3. 🚫 **PROHIBIDO GIT PUSH:** Exclusivo del Orchestrator con autorización del Tech Lead.

## 6. Retorno vía send_message
Emitir mensaje al Orchestrator con el siguiente formato exacto:
```markdown
### 🏁 Tarea Finalizada: [{{TICKET_ID}}]
- Commit SHA: `[SHA_HASH]`
- Archivos Modificados: [lista de rutas]
- Quality Gate: ✅ Exit Code 0
- Resumen Técnico: [1 a 2 líneas concisas]

### 💡 LEARNING & FRICTION LOG (Opcional si hubo fricción no documentada)
- Fricción: [Descripción breve]
- Solución: [Solución limpia]
- Regla Recomendada: [Instrucción preventiva]
- Ámbito: [PROJECT_LOCAL | ENTERPRISE_GLOBAL]
```
```
