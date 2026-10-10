---
name: obsidian-memory
description: >
  Protocolo e integración de memoria extendida con la bóveda de Obsidian en iCloud.
  Úsalo cuando el usuario mencione "obsidian", "memoria extendida", "sincronízate", "guarda en obsidian",
  "anota en la bitácora", "actualiza el contexto", "revisa mis proyectos", "consulta la memoria",
  o cuando se necesite persistir o recuperar contexto a largo plazo de Ricardo Genaro y del ecosistema multi-agente
  (ShelBot / OpenClaw, RimacBot, Antigravity).
---

# Obsidian Extended Memory Protocol (Layer 3)

Este skill define la interacción entre Antigravity y la bóveda de Obsidian sincronizada en iCloud.

## 1. Localización de la Bóveda
* **Ruta Base:** `/Users/ricardogenaro1999/Library/Mobile Documents/iCloud~md~obsidian/Documents`

## 2. Estructura de Directorios

### `Agent-Shared/` (Conocimiento Común)
- `user-profile.md`: Identidad, preferencias de trabajo, estilo y configuraciones de Ricardo Genaro.
- `project-state.md`: Tabla de proyectos activos, archivados y prioridades técnicas.
- `decisions-log.md`: Architecture Decision Records (ADRs).
- `taxonomy-standards.md`: Reglas taxonómicas y principios inmutables de la bóveda.

### `Agent-Antigravity/` (Memoria Privada de Antigravity)
- `working-context.md`: Contexto activo, tarea actual, avances y estado inmediato.
- `mistakes.md`: Registro de errores cometidos, lecciones aprendidas y anti-patrones.
- `daily/YYYY-MM-DD.md`: Bitácoras diarias de sesiones, hitos y cambios relevantes.

### Agentes Hermanos
- `Agent-Shelbot/`: Orquestador principal (OpenClaw).
- `Agent-Rimacbot/`: Dominio corporativo de seguros.
- `Personal/`: Bóveda personal de Ricardo (`Finanzas`, `Knowledge-Base`, `Professional`, `Streaming`, etc.).

---

## 3. Reglas Inmutables de Escritura
1. **YAML Frontmatter Obligatorio:** Toda nota nueva debe incluir encabezado YAML (`date` o `updated`, `agent`, `tags`).
2. **Nombres en inglés, contenido en español:** Carpetas y nombres de archivo en minúsculas y kebab-case o snake_case en inglés (sin tildes ni caracteres especiales). Texto de notas en español.
3. **Seguridad iCloud:** En notas de bitácora (`daily/`), usar siempre método de anexar (`append`) para no provocar colisiones de sincronización entre macOS e iOS.
4. **Wikilinks:** Conectar conceptos usando la sintaxis `[[Nombre de Nota]]`.

---

## 4. Flujo de Trabajo

### Al Iniciar Sesión / Tarea
1. Leer `Agent-Shared/user-profile.md` y `Agent-Shared/project-state.md` si la tarea involucra decisiones sobre proyectos o preferencias.
2. Si se retoma trabajo previo, revisar `Agent-Antigravity/working-context.md` y la última entrada de `Agent-Antigravity/daily/`.

### Durante el Desarrollo
1. Si ocurre un error importante o una corrección directa del usuario: registrar inmediatamente en `Agent-Antigravity/mistakes.md`.
2. Si hay un hito relevante: reflejar el cambio en `Agent-Antigravity/working-context.md`.

### Al Finalizar o al invocar "Sincronízate"
1. Registrar la bitácora del día en `Agent-Antigravity/daily/YYYY-MM-DD.md`.
2. Actualizar `Agent-Antigravity/working-context.md` con el estado final.
3. Si el estado de un proyecto cambió, actualizar `Agent-Shared/project-state.md`.
