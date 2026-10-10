# Git Commit & Push Governance Policy (Genaryth Standard)

**Propósito:** Proteger la integridad del repositorio, evitar regresiones accidentales y garantizar que todo cambio tenga el nivel de escrutinio adecuado por parte del Tech Lead.

---

## 🛡️ Matriz de Clasificación de Impacto

Antes de ejecutar cualquier comando de Git (`git add`, `git commit`, `git push`), el subagente u orquestador DEBE evaluar y clasificar el nivel de impacto del conjunto de cambios:

| Nivel de Impacto | Tipos de Cambios Incluidos | Acciones Git Permitidas | Acciones Git Estrictamente Prohibidas |
| :--- | :--- | :--- | :--- |
| **🟢 LOW IMPACT** | • Correcciones de documentación (`*.md`).<br>• Corrección de tipografías o textos menores.<br>• Ajustes cosméticos y CSS menor aislado que no alteran layouts.<br>• Comentarios en código o actualización de diagramas. | • `git add` selectivo.<br>• `git commit` semántico local.<br>• `git push` a rama de trabajo activa autorizada. | • Modificar archivos fuera del alcance de la tarea.<br>• Forzar push (`--force`). |
| **🟡 MEDIUM IMPACT** | • Ajustes visuales de UI no disruptivos.<br>• Nuevos casos de prueba unitarios o E2E aislados.<br>• Utilidades puras desacopladas (helpers, formatters).<br>• Actualización menor de dependencias sin breaking changes. | • `git add` selectivo.<br>• `git commit` semántico local ÚNICAMENTE.<br>• Dejar listo el commit para revisión del Tech Lead. | • **PROHIBIDO `git push` a cualquier rama remota.**<br>El push requiere autorización explícita del Tech Lead. |
| **🔴 HIGH / CRITICAL IMPACT** | • Rediseños de arquitectura o Clean Architecture.<br>• Lógica central de negocio o algoritmos de dominio.<br>• Contratos de API (endpoints, request/response models).<br>• Esquemas de base de datos (Prisma, TypeORM, migraciones SQL).<br>• Autenticación, autorización, tokens o criptografía.<br>• Infraestructura como Código (AWS CDK stacks, IAM roles).<br>• Cambios en variables de entorno o archivos de configuración base. | • **DEJAR EN WORKING DIRECTORY:** Los archivos modificados deben permanecer unstaged / untracked.<br>• Reportar la lista exacta de archivos al Tech Lead. | • **PROHIBIDO `git commit`.**<br>• **PROHIBIDO `git push`.**<br>Ningún subagente puede comprometer cambios críticos sin revisión previa del Tech Lead. |

---

## 🚫 Regla de Oro: Git Anti-Chancado (Staging Quirúrgico)

En proyectos monorepo o multihilo de Genaryth, múltiples agentes y desarrolladores pueden trabajar en simultáneo:

1. **PROHIBICIÓN TOTAL:**
   - **TERMINANTEMENTE PROHIBIDO ejecutar `git add .`, `git add -A` o `git add *` en la raíz del monorepo.**
2. **STAGING QUIRÚRGICO OBLIGATORIO:**
   - Todo subagente debe ejecutar `git add` **únicamente sobre las rutas explícitas de los archivos que modificó** (ej. `git add apps/web/src/components/PetCard.tsx`).
   - Esto evita incluir por error archivos temporales, variables `.env`, archivos modificados por otros hilos en paralelo o código unstaged de alto impacto.

---

## 📋 Protocolo de Ejecución para Subagentes

1. **Pre-Commit Check:**
   - Verificar `git status` y `git diff --stat`.
   - Comprobar que solo los archivos propios de la tarea estén en staging.
   - Si existe al menos UN archivo modificado clasificado como HIGH IMPACT, todo el changeset se trata como HIGH IMPACT.
2. **Formato Semántico de Commit (Conventional Commits):**
   - `feat(modulo): descripción clara (TICKET-ID)`
   - `fix(modulo): descripción de la corrección (TICKET-ID)`
   - `docs(modulo): actualización documental (TICKET-ID)`
   - `test(modulo): nuevas pruebas automatizadas (TICKET-ID)`
   - `refactor(modulo): mejora estructural sin cambio funcional (TICKET-ID)`
3. **Escalamiento Obligatorio:**
   - Si un subagente finaliza una tarea de MEDIUM o HIGH IMPACT, debe informar al Orquestador:
     > *"Archivos preparados localmente. Nivel de impacto: [MEDIUM/HIGH]. Esperando tu revisión manual y autorización para commit/push según la Git Governance Policy."*
