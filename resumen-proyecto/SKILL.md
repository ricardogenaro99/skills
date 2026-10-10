---
name: resumen-proyecto
description: Analiza un proyecto o repositorio de código A FONDO (con un método riguroso de entendimiento, planificación, detección de riesgos y revisión final, no un vistazo superficial) y genera documentación en Markdown con un resumen ejecutivo, el alcance funcional (qué hace, para quién, casos de uso) y el alcance técnico detallado (stack, arquitectura, integraciones, endpoints/APIs). Úsala siempre que el usuario pida documentar un proyecto, generar un "resumen ejecutivo", entender o explicar "qué hace" un proyecto/repositorio, pida un README o "overview" técnico-funcional, o quiera dejar constancia del alcance de un proyecto para stakeholders o para onboarding de otros desarrolladores. Dispara con frases como "documenta este proyecto", "hazme un resumen ejecutivo de este repo", "explícame el alcance funcional y técnico", "genera la documentación de este código", "analiza este proyecto a fondo", aunque el usuario no use exactamente esas palabras.
---

# Resumen de Proyecto

Skill para analizar un proyecto (repositorio de código, carpeta de archivos, o conjunto de documentos) **a fondo** y producir un documento Markdown con resumen ejecutivo + alcance funcional + alcance técnico detallado.

La diferencia clave de esta skill frente a "leer un poco el código y resumir" es que **todo el análisis** (inventario, funcional y técnico) sigue un método riguroso: entender el objetivo, planificar el análisis, detectar riesgos/vacíos de información, definir qué se considera un análisis completo, ejecutar, y revisar el propio resultado antes de entregarlo. Ese análisis se le muestra al usuario, no queda solo interno.

## Cuándo NO usarla

- Si el usuario solo pide leer o explicar un archivo puntual (no todo el proyecto), respóndele directo sin activar la skill.
- Si el usuario ya tiene un documento y solo pide corregirlo o darle formato, no es este caso (usa la skill docx/pdf según corresponda).

## Proceso

Antes de escribir el documento final, recorre estas fases para **cada uno de los tres bloques** del análisis (inventario/estructura, alcance funcional, alcance técnico). No te saltes fases aunque el proyecto parezca simple; puedes comprimirlas, pero deben quedar todas reflejadas en la salida.

### Fase 0 — Entender el objetivo del análisis

Antes de tocar el código, resume brevemente:
- Qué tipo de proyecto es (o se espera que sea) y qué se va a analizar exactamente (repo completo, carpeta, zip).
- Para quién es este documento (stakeholders no técnicos, onboarding de devs, ambos).
- Qué restricciones hay: acceso disponible (¿repo remoto sin árbol de carpetas? ¿archivos subidos completos?), nivel de detalle esperado.
- Qué información falta para poder analizarlo bien.

**Regla de acceso a GitHub (no negociable):** Si el usuario da un link de GitHub (u otro repo remoto) en vez de archivos subidos, intenta primero `web_fetch` sobre la página principal y archivos sueltos ya enlazados (README, package.json, etc.). GitHub bloquea el acceso automatizado a vistas de carpetas (`/tree/...`), así que no vas a poder inventariar `src/` u otras carpetas internas así. En ese caso, **pide siempre al usuario que suba los archivos o un `.zip`** del proyecto — no generes el alcance técnico detallado (componentes, rutas internas, endpoints) basándote solo en lo que un fetch de GitHub te deje ver, y no lo dejes pasar silenciosamente como "no verificado": pide el material primero. Esto es información crítica faltante, no un supuesto menor.

Si falta otra información crítica (sin ella no puedes analizar bien), pregunta antes de seguir. Si falta información menor, haz una suposición razonable y márcala como "Supuesto: ...".

### Fase 1 — Planificar el análisis

Antes de leer archivo por archivo al azar, define un plan corto:
- Qué archivos/carpetas vas a revisar primero y en qué orden (entrada principal, dependencias, rutas/controladores, modelos, tests, config).
- Qué necesitas confirmar para el alcance funcional (propósito de negocio, usuarios, flujos clave).
- Qué necesitas confirmar para el alcance técnico (stack, arquitectura, integraciones, endpoints).
- Qué harías si la evidencia es insuficiente en algún punto (marcarlo explícitamente, nunca inventarlo).

### Fase 2 — Riesgos y casos límite del análisis

Antes de ejecutar, identifica qué podría hacer que el análisis salga incompleto o incorrecto:
- Proyecto muy grande → puede que no puedas cubrir cada archivo; prioriza las capas que definen el comportamiento (rutas, servicios, modelos) sobre detalles menores.
- Documentación desactualizada (README que no coincide con el código real) → prioriza siempre lo que dice el código sobre lo que dice el README.
- Dependencias externas sin configuración visible (claves/env no incluidas) → repórtalo como limitación, no lo omitas.
- Repo remoto sin árbol de carpetas visible → aplica la regla de la Fase 0 (pedir zip/archivos).
- Tests ausentes o triviales → no asumas comportamiento que no esté verificado en código.

### Fase 3 — Inventario del proyecto (ejecución)

Con el plan de la Fase 1:
- Si es carpeta/repo local (subido o clonado): usa `view` sobre el directorio raíz para ver la estructura (2 niveles).
- Lee el archivo de entrada principal si existe (README, package.json, requirements.txt, pyproject.toml, pom.xml, etc.) para identificar nombre, dependencias y stack.
- Identifica el punto de entrada (main, index, app.py, server.js, etc.) y sigue los imports/rutas principales para entender el flujo real.
- Busca capas típicas: rutas/controladores (endpoints), modelos/esquemas (datos), servicios/integraciones externas (APIs, bases de datos, colas, terceros), configuración (.env.example, config/*).
- Si hay tests, revísalos: suelen revelar el comportamiento funcional esperado mejor que la documentación.

No asumas nada que no puedas verificar en el código/archivos. Si algo no está claro (p. ej. el propósito de negocio), pregúntale al usuario en vez de inventarlo.

### Fase 4 — Alcance funcional (con el mismo rigor)

Redacta en lenguaje no técnico, pero solo a partir de evidencia real del código/tests/README verificado:
- Qué problema resuelve el proyecto y para quién (usuarios, área de negocio).
- Funcionalidades principales (lista de lo que el sistema permite hacer).
- Flujos de usuario clave, si se pueden inferir del código o los tests.
- Fuera de alcance / limitaciones conocidas, si aplica.

Marca explícitamente cualquier punto donde estés infiriendo en vez de verificando (p. ej. "se infiere del nombre de las rutas, no confirmado por tests").

### Fase 5 — Alcance técnico detallado (con el mismo rigor)

Incluye siempre, cuando exista evidencia en el código:
- **Stack**: lenguajes, frameworks, versión (extraída de archivos de dependencias, no inventada).
- **Arquitectura**: cómo están organizadas las capas (monolito, microservicios, frontend/backend separados, etc.).
- **Integraciones**: APIs externas, servicios de terceros, bases de datos, colas de mensajes.
- **Endpoints/APIs**: lista de rutas expuestas con método HTTP y propósito breve (extraídas de los archivos de rutas/controladores reales).
- **Dependencias clave**: librerías relevantes y su función en el proyecto.
- **Configuración/despliegue**: variables de entorno relevantes (solo nombres, nunca valores/secrets), cómo se corre o despliega si es evidente.

Si algún punto no aplica o no hay evidencia suficiente, indícalo explícitamente ("No se encontraron integraciones externas") en vez de omitirlo silenciosamente.

### Fase 6 — Revisión final del propio análisis

Antes de generar el documento, revisa tu propio trabajo:
- ¿Cubriste inventario, funcional y técnico con evidencia real, no supuestos sueltos?
- ¿Quedó algún riesgo de la Fase 2 sin resolver o sin mencionar?
- ¿Hay algo marcado como "no verificado" que deberías haber verificado con las herramientas disponibles?
- ¿Falta contexto de negocio que solo el usuario puede dar (el "para qué" estratégico)?

### Fase 7 — Genera el documento Markdown

El documento final debe mostrar primero el análisis (transparencia) y luego el resultado. Usa esta estructura de salida (ajusta encabezados si el proyecto no tiene alguna sección):

```markdown
# [Nombre del proyecto] — Resumen Ejecutivo y Alcance

## Cómo se hizo este análisis
[Breve: qué se revisó, qué supuestos se hicieron, qué riesgos/limitaciones se detectaron durante el análisis — 4-8 líneas, no una narración extensa]

## Resumen Ejecutivo
[3-5 líneas: qué es, para qué sirve, estado actual]

## Alcance Funcional
[Ver Fase 4]

## Alcance Técnico
### Stack
### Arquitectura
### Integraciones
### Endpoints / APIs
### Dependencias clave
### Configuración y despliegue

## Estructura del Proyecto
[Árbol de carpetas resumido con una línea de propósito por carpeta clave]

## Notas y Limitaciones
[Supuestos marcados, puntos sin evidencia suficiente, riesgos detectados]
```

Guarda el archivo generado como un archivo `.md`.
* **Si estás trabajando dentro de un repositorio de código local (por ejemplo, con Git):** Guarda el archivo `.md` directamente en la raíz de dicho repositorio con un nombre descriptivo (por ejemplo, `resumen-ejecutivo-[nombre-proyecto].md` o `README-summary.md`). Esto permite que el reporte quede integrado en el codebase del proyecto.
* **Si estás en un entorno de desarrollo aislado (sandbox) o sin repositorio de código activo:** Guarda el archivo como `.md` en `/mnt/user-data/outputs/` con un nombre descriptivo y compártelo usando `present_files`.

### Fase 8 — Confirmación

Antes de darlo por definitivo, resume en 2-3 líneas al usuario lo que encontraste y pregúntale si falta algo de contexto de negocio que el código no pueda revelar (p. ej. el "para qué" estratégico).
