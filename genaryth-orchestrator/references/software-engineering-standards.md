# Estándares de Arquitectura y Buenas Prácticas de Software — Genaryth

**Propósito:** Definir los principios inmutables de ingeniería de software que rigen todo desarrollo en Genaryth (Backend, Frontend, Base de Datos y APIs).

---

## 🌐 0. Filosofía Multi-Stack: Principios Agnósticos & Selección por Requerimiento

En **Genaryth Venture Studio**, el stack tecnológico **NO es un dogma rígido**, sino una **decisión deliberada de arquitectura (Gate 3)** calibrada según las necesidades del producto, el presupuesto FinOps, el time-to-market y las restricciones del cliente:

| Capa Tecnológica | Arquetipo de Referencia Actual | Alternativas Oficiales por Requerimiento | Criterio de Selección (Gate 2 / Gate 3) |
| :--- | :--- | :--- | :--- |
| **Backend Core** | **NestJS** (Modular / Clean Arch) | • **Express / Fastify** (Node)<br>• **FastAPI / Django** (Python)<br>• **Go** (Gin / Chi)<br>• **Firebase Functions** | NestJS para microservicios enterprise complejos; Express/Fastify para microservicios ultra-ligeros; FastAPI para IA y datos; Firebase para MVPs y prototipado rápido. |
| **Frontend Web** | **Next.js** (App Router / SSR) | • **Angular** (Enterprise SPAs)<br>• **React SPA** (Vite)<br>• **Astro** (Content / Docs)<br>• **Vue / Nuxt** | Next.js para SaaS y comercio con SEO/LCP crítico; Angular para plataformas corporativas con gobernanza rígida; React SPA para backoffice interno desacoplado. |
| **Mobile Apps** | **React Native / Expo** | • **Flutter** (Dart)<br>• **Swift / Kotlin** (Nativo) | Expo para apps cross-platform con animaciones a 60 fps; Swift/Kotlin nativo ante requerimientos extremos de telemetría hardware o BLE. |
| **Persistencia** | **PostgreSQL** (Prisma / Aurora) | • **DynamoDB** (NoSQL)<br>• **Firestore / Firebase**<br>• **MongoDB**<br>• **Redis** (Caché / PubSub) | PostgreSQL para consistencia relacional y transacciones ACID; Firestore/DynamoDB para escalabilidad elástica y modelos sin esquema rígido. |
| **Cloud & Hosting**| **AWS CDK v2** (TypeScript) | • **GCP** (Cloud Run / BigQuery)<br>• **Firebase** (BaaS / Auth / Rules)<br>• **Azure** (Enterprise Cloud)<br>• **Vercel** (Edge Frontend) | AWS CDK para infraestructura auditable como código; GCP para pipelines de ML y datos; Firebase para apps serverless ágiles; Azure para ecosistemas corporativos Microsoft. |

### 💎 Principios Inmutables que Aplican a Cualquier Stack:
Sin importar si el proyecto se construye en NestJS, Express, Angular, FastAPI, Firebase o AWS/GCP:
1. **Clean Architecture & Inversión de Dependencias:** El dominio nunca depende de la base de datos ni de frameworks externos.
2. **Tipado Estricto:** Cero `any` en TypeScript, tipos estáticos en Go, type hints rigurosos en Python.
3. **Contract-First:** Contratos OpenAPI 3.1 o JSON Schemas sellados antes de programar endpoints o interfaces.
4. **Quality Gates con Exit Code 0:** Ningún código se commitea sin pasar la suite de verificación local (`pnpm test`, `ng test`, `pytest`, etc.).

---

## 🏛️ 1. Arquitectura Hexagonal y Clean Architecture (Backend)


En todo microservicio o backend (NestJS, Node, Python):

1. **Aislamiento Estricto por Capas (Inversión de Dependencias):**
   - **Capa de Dominio (`domain/`):** Entidades puras, Value Objects, interfaces de repositorios y reglas de negocio inmutables. CERO dependencias de frameworks, bases de datos o librerías externas.
   - **Capa de Aplicación (`application/`):** Casos de uso y servicios orquestadores (`AuthService`, `PetsService`, `OrdersService`). Manejan el flujo de la transacción y consumen puertos (interfaces).
   - **Capa de Infraestructura (`infrastructure/`):** Controladores HTTP (NestJS), adaptadores de persistencia (Prisma/TypeORM), clientes HTTP externos, integraciones cloud y adaptadores de mensajería.
2. **Puertos y Adaptadores:**
   - La lógica de negocio jamás depende de la base de datos directamente. Depende de interfaces (`IPetsRepository`).
   - El adaptador Prisma implementa la interfaz (`PrismaPetsRepository implements IPetsRepository`). Esto permite cambiar de base de datos o mockear tests sin tocar el dominio.
3. **Principios SOLID en la Práctica:**
   - **SRP (Single Responsibility):** Servicios pequeños y especializados. Controladores delgados (*Skinny Controllers*): solo validan DTOs, llaman al servicio y devuelven el código HTTP apropiado.
   - **DIP (Dependency Inversion):** Inyección de dependencias nativa en constructores con tipado estricto.

---

## 🔒 2. Integridad de Datos y Transaccionalidad ACID

1. **Transacciones Atómicas Obligatorias:**
   - Toda operación que involucre más de una tabla o efecto secundario dependiente DEBE encapsularse en una transacción (`prisma.$transaction`):
     - Ej. Crear un pedido (`Order`) + Descontar inventario (`ProductVariant`) + Registrar auditoría.
     - Ej. Reclamar collar ("Scan & Bind") + Asignar a mascota + Marcar collar como `ACTIVE`.
   - Si un paso falla, toda la transacción debe revertirse (Rollback automático).
2. **Aislamiento Multi-Tenant y Seguridad en Queries:**
   - Toda consulta autenticada sobre recursos de un usuario debe incluir explícitamente el tenant/propietario:
     `where: { id: petId, userId: currentUser.id }`.
   - Prohibido confiar ciegamente en IDs de la URL sin verificar que pertenezcan al usuario autenticado (prevención de vulnerabilidades BOLA/IDOR).
3. **Migraciones Versionadas, Idempotentes y Determinísticas:**
   - Prohibido modificar esquemas de base de datos directamente en el motor.
   - Todo cambio de esquema se realiza vía archivos de migración rastreados en Git (`prisma migrate dev`).
   - **Regla Inmutable DDL:** En bases de datos relacionales concurrentes (PostgreSQL / Aurora Serverless v2), las sentencias DDL manuales deben ser idempotentes: utilizar siempre `ADD COLUMN IF NOT EXISTS`, `CREATE INDEX IF NOT EXISTS` y `DROP TABLE IF EXISTS` para garantizar despliegues continuos sin tiempo de inactividad (*zero-downtime*).
   - **Sincronización del Cliente ORM:** Tras modificar `schema.prisma`, es obligatorio ejecutar inmediatamente `prisma generate` para regenerar los tipos estáticos antes de correr suites de tests o typecheck.
4. **Normalización Defensiva de Enums en PostgreSQL:**
   - PostgreSQL es estrictamente sensible a mayúsculas/minúsculas en tipos enumerados (`CREATE TYPE status_enum AS ENUM ('ACTIVE', 'PENDING')`). Enviar `"active"` desde un cliente HTTP arroja un error 500 no controlado.
   - **Regla Inmutable:** En la capa de aplicación/servicios, normalizar siempre todo valor de enum entrante con `.toUpperCase().trim()` antes de pasarlo a Prisma o a la capa de persistencia.
5. **Telemetría Honesta en Agregaciones y Métricas:**
   - Cuando una consulta agregada retorne cero filas o no existan datos históricos, el backend debe responder con valores reales: `null`, `0` o estado `Standby`.
   - **Anti-Patrón Prohibido:** Retornar promedios artificiales fijos (*hardcoded dummy values* como `142ms` o `100% Health`) para simular salud operativa. La telemetría debe reflejar la verdad auditable del sistema.
6. **Inyección Temprana de AWS Request ID & Salvaguarda Node.js 22+:**
   - En funciones Lambda, capturar e inyectar `context.awsRequestId` en la primera línea de ejecución del handler en el logger estructurado para garantizar correlación de logs en CloudWatch (`[RequestId: ${requestId}]`).
   - **Defensa ante strings literales en Node.js 22:** Validar `if (!requestId || requestId === 'undefined')` para prevenir registros basura con el texto literal `"undefined"`.
7. **Resolución de Módulos NodeNext ESM en Paquetes Compartidos:**
   - En monorepos configurados con TypeScript `"moduleResolution": "NodeNext"`, todas las importaciones relativas dentro de paquetes de contratos y utilidades (`packages/*`) deben declarar explícitamente la extensión `.js` (ej. `import { DTO } from "./dto.js";`), complementado con `resolve.extensionAlias` en Webpack/Next.js para resolución universal.

---

## 🎨 3. Estándar Maestro de Frontend y Design Engineering (Pipeline de 6 Fases)

A partir de la consagración del estándar institucional de diseño, todo desarrollo de interfaz, componente, vista o landing page en Genaryth DEBE regirse obligatoriamente bajo este pipeline secuencial. Queda **terminantemente prohibido generar interfaces genéricas de IA ("AI slop", plantillas planas de Bootstrap o componentes estándar sin intención)**. Todo código frontend debe ejecutarse encadenando las skills en este orden estricto:

### 🌟 Fase 1: Dirección de Arte & Propósito (`impeccable` + `design-taste-frontend`)
1. **Determinar el Modo de la Superficie:**
   - `Persuade` (Landing pages, Venture Studio showcase): Diseño atrevido, foco en autoridad, conversión y diferenciación.
   - `Operate` (Dashboards, herramientas internas, incubación): Escaneabilidad, densidad de información y cero distracciones.
2. **Anti-Slop Policy (de `taste-skill`):**
   - 🚫 **PROHIBIDO:** El layout cliché de IA consistente en titular centrado de 3 líneas con una fila de 3 tarjetas idénticas abajo.
   - ✅ **OBLIGATORIO:** Asimetría intencional, espacios generosos (*whitespace* estructurado) y escala tipográfica de alto impacto visual.

### 🔤 Fase 2: Sistema de Tokens & Tipografía (`ui-ux-pro-max` + `design-taste-frontend`)
1. **Tipografía Display de Autor:**
   - 🚫 **BANEADO:** Uso de `Inter` o fuentes genéricas para titulares principales.
   - ✅ **OBLIGATORIO:** Tipografías con carácter display y tracking negativo agresivo (`Geist`, `Satoshi`, `Cabinet Grotesk`, `Plus Jakarta Sans` con `tracking-[-0.03em]` a `tracking-[-0.04em]`).
   - Tipografía monoespaciada (`Geist Mono`, `JetBrains Mono`) reservada para SLAs, latencias (`<45ms`), métricas y telemetría de arquitectura.
2. **Baneo Absoluto de Emojis:**
   - 🚫 **PROHIBIDO:** Emojis en código, textos, botones, badges o estados.
   - ✅ **OBLIGATORIO:** Exclusivamente iconos SVG vectoriales curados (`@phosphor-icons/react`, Radix Icons o Lucide) con `strokeWidth` estandarizado a `1.5px`.
3. **Estabilidad de Viewport:**
   - 🚫 **BANEADO:** `h-screen`.
   - ✅ **OBLIGATORIO:** `min-h-[100dvh]` para evitar saltos o solapamientos con la barra de navegación en Safari iOS.

### 💎 Fase 3: Materiales & Física Táctil (`apple-design`)
1. **Materiales Translúcidos (Liquid Glass):**
   - Fondos oscuros profundos (`#08090A` / `#0D0F12`), evitando el negro plano puro `#000000`.
   - Capas con `backdrop-blur-md` y rellenos sutiles (`bg-white/[0.03]`).
2. **Kill Latency (Respuesta Inmediata):**
   - Todo botón y elemento interactivo debe responder en `pointer-down` (al presionar), no al soltar (`:active { transform: scale(0.98); }` con transición de 100ms).
   - Movimientos gobernados por física de resortes (*springs* interruptibles que conservan el momentum del usuario).

### ✨ Fase 4: Refinamiento Invisible (`emil-design-eng` - Emil Kowalski)
1. **Eliminación de `transition: all`:**
   - 🚫 **BANEADO:** `transition: all 300ms` (provoca jank y transiciones accidentales de layout).
   - ✅ **OBLIGATORIO:** Especificar siempre la propiedad exacta (`transition-transform`, `transition-opacity`, `transition-colors`).
2. **Principio de Masa:**
   - Ningún elemento aparece de la nada: modales, dropdowns y popovers entran con `scale(0.95) -> scale(1)` y `opacity: 0 -> 1`.
3. **Bordes Sub-Pixel:**
   - Evitar sombras oscuras pesadas. Delimitar tarjetas con bordes ultrafinos translúcidos (`border border-white/[0.08] hover:border-white/[0.18]`).
4. **Bento Grids con Efecto Spotlight:**
   - Las tarjetas interactivas de portafolio o servicios deben incluir un resplandor radial dinámico que sigue las coordenadas del cursor (`onMouseMove`).

### 🎬 Fase 5: Coreografía & Motion Cinemático (`gsap-scrolltrigger` + `gsap-react` / `animate`)
1. **Animación al Scroll:**
   - Emplear GSAP ScrollTrigger con el hook oficial `useGSAP()` para pinning de secciones, revelación de titulares con SplitText y scrubbing suave.
2. **Rendimiento a 60/120 fps:**
   - Animar exclusivamente mediante propiedades de GPU (`transform`, `opacity`) con `will-change: transform`.
   - Cero *layout thrashing* o lecturas repetidas a `getBoundingClientRect` dentro de bucles de animación.

### 🏗️ Fase 6: Arquitectura Clean Code (`vercel-react-best-practices`)
1. **Arquitectura Next.js App Router:**
   - Layouts y estructuras estáticas renderizadas como React Server Components (`RSC`).
   - Interactividad, GSAP, Framer Motion y manejadores de eventos encapsulados estrictamente en componentes hoja con `'use client'`.
2. **Verificación de Dependencias:**
   - Verificar siempre `package.json` antes de importar paquetes (`@phosphor-icons/react`, `gsap`, `framer-motion`, `clsx`, `tailwind-merge`).
3. **Formularios Tipados y Manejo de Estados Resilientes:**
   - Formularios vía **React Hook Form** + esquemas **Zod** compartidos con `@<org>/contracts`.
   - 4 estados canónicos en toda vista asíncrona: `Loading` (skeleton fino), `Success`, `Empty State` y `Error State` con botón de reintento.

---


## 📡 4. Contratos de API (Contract-First & OpenAPI SSOT)

1. **Contract-First en Monorepo:**
   - Todo tipo de datos, DTO de petición/respuesta y evento debe definirse primero en `packages/common` antes de ser implementado en backend o consumido en frontend.
2. **Especificación OpenAPI 3.1 Canónica:**
   - La API debe contar con documentación viva en `docs/openapi.json` / `openapi.yaml`.
   - Se debe mantener sincronizado mediante scripts automatizados (ej. Swagger CLI o decoradores `@nestjs/swagger`).
3. **Estandarización de Respuestas HTTP:**
   - Éxito síncrono: `200 OK` (lecturas/actualizaciones) o `201 Created` (creación de recursos).
   - Aceptación asíncrona: `202 Accepted` (ingestas de alta frecuencia, webhooks, telemetría GPS).
   - Errores de cliente: `400 Bad Request` (payload inválido), `401 Unauthorized` (sin token/expirado), `403 Forbidden` (sin permisos de rol), `404 Not Found` (recurso inexistente), `409 Conflict` (duplicado/estado incompatible).
   - Estructura uniforme de error JSON: `{ statusCode, message, error, timestamp, path }`.

---

## 📦 5. Scoping Corporativo y Segregación de Puertos Locales (ADR-013)

### 🏷️ 5.1 Directiva de Scoping Corporativo Obligatorio en Monorepos
Queda **estrictamente prohibido** asignar nombres planos o genéricos en los archivos `package.json` de aplicaciones (`apps/*`) o librerías internas (`packages/*`).

- 🚫 **Anti-patrón Prohibido:** `"name": "web"`, `"name": "api"`, `"name": "common"`, `"name": "hub"`.
- ✅ **Estándar Canónico:** `"name": "@<org>/<nombre-modulo>"` o `"name": "@genaryth/<nombre-modulo>"`.
  - Ejemplos:
    - `apps/web/package.json` $\rightarrow$ `"name": "@genaryth/web"` (o `@kinpet/web`, `@sprintflow/web`).
    - `apps/api/package.json` $\rightarrow$ `"name": "@genaryth/api"`.
    - `apps/studio-hub/package.json` $\rightarrow$ `"name": "@genaryth/studio-hub"`.
    - `packages/contracts/package.json` $\rightarrow$ `"name": "@genaryth/contracts"`.
    - `packages/ui/package.json` $\rightarrow$ `"name": "@genaryth/ui"`.
- **Beneficios Arquitectónicos:**
  1. **Aislamiento de Registro:** Elimina el riesgo de colisiones con paquetes públicos de npm.
  2. **Resolución Determinista en Workspace:** Facilita el consumo interno seguro mediante protocolos de monorepo (`"dependencies": { "@genaryth/contracts": "workspace:*" }`).
  3. **Filtros Quirúrgicos de Turbo/Pnpm:** Habilita comandos precisos sin ambigüedades (`pnpm --filter @genaryth/web build`).

### 🔌 5.2 Matriz Canónica de Segregación de Puertos Locales
Para erradicar conflictos de sockets concurrentes (`EADDRINUSE`) al arrancar el monorepo en desarrollo local (`pnpm dev`), se define una segregación estricta y predecible de puertos:

| Puerto | Rol / Servicio | Directorio Canónico | Comando / Configuración Canónica |
| :---: | :--- | :--- | :--- |
| **`3000`** | **Web Pública B2B / Portal Principal** | `apps/web/` | `"dev": "next dev -p 3000"` |
| **`3001`** | **API / Backend NestJS / Microservicios Core** | `apps/api/` | `process.env.PORT \|\| 3001` (`"dev": "nest start --watch"`) |
| **`3002`** | **Studio Hub / Internal Cockpit (IOS)** | `apps/studio-hub/` | `"dev": "next dev -p 3002"` |
| **`3003+`** | **Ventures Secundarias, Microfrontends o Simuladores** | `apps/simulators/`, etc. | Puertos secuenciales dedicados (`3003`, `3004`, etc.) |

**Reglas de Implementación:**
1. Los scripts `dev` en los `package.json` respectivos DEBEN declarar explícitamente el flag de puerto (`-p <PORT>`) o respetar el fallback de variable de entorno sin colisionar con el puerto 3000 predeterminado de Next.js.
2. Si un microfrontend o servicio backend intenta vincularse a un puerto ya reservado en la matriz, el Quality Gate local de DevOps rechazará la configuración.

---

## 🔑 6. Arquitectura de Claves Dual (Surrogate Key `id Int` + Natural Key `subId String`)

1. **Problema de Rendimiento con UUIDs como PK Primaria:**
   - Utilizar strings o UUIDs como clave primaria (`@id`) en bases de datos relacionales fragmenta los índices B-Tree de PostgreSQL, incrementa sustancialmente el tamaño de almacenamiento en disco, penaliza las operaciones de ordenamiento y desacelera drásticamente las consultas con `JOIN` sobre claves foráneas.
2. **Patrón Canónico de Clave Dual en Prisma:**
   - Todo modelo relacional de negocio en el ecosistema Genaryth debe implementar el patrón de clave dual:
     ```prisma
     model Issue {
       id          Int      @id @default(autoincrement())
       subId       String?  @unique @map("sub_id")
       key         String   @unique
       title       String
       projectId   Int      @map("project_id")
       project     StudioProject @relation(fields: [projectId], references: [id], onDelete: Cascade)
       // ...
     }
     ```
   - **Surrogate Key (`id Int`):** Entero autoincremental de 4 bytes utilizado exclusivamente para la integridad referencial física (`FOREIGN KEY`, relaciones entre tablas, índices B-Tree ultra-rápidos).
   - **Natural Business Key (`subId String?` o `key String`):** Cadena semántica única (ej. `mst_type_story`, `init-kinpet`, `EPIC-01`) utilizada para exposición en contratos de API, URLs públicas, parámetros REST y constantes inmutables en código.
3. **Resolución Transparente en Capa de Aplicación:**
   - Los contratos TypeScript y adaptadores de datos deben soportar de forma isomórfica ambos tipos mediante `z.union([z.number(), z.string()])`, resolviendo internamente el ID numérico correspondiente antes de consultar la persistencia.

---

## 📐 7. Inmutabilidad del Orden Físico en PostgreSQL (`ordinal_position` DDL)

1. **Comportamiento del Catálogo en PostgreSQL:**
   - En PostgreSQL (`information_schema.columns`), el orden físico de las columnas (`ordinal_position`) queda inmutablemente sellado en la sentencia `CREATE TABLE` inicial.
   - Ejecutar operaciones `ALTER TABLE ADD COLUMN` para insertar claves primarias (`id`) o identificadores de negocio (`subId`) añade físicamente las columnas al final de la tabla (ej. `ordinal_position = 16`), provocando que herramientas visuales de inspección de datos (DBeaver, TablePlus) oculten las columnas más críticas al final de la cuadrícula.
2. **Regla de Reconstrucción Limpia en Entornos de Desarrollo:**
   - Al refactorizar claves primarias o campos estructurales durante la fase de desarrollo, en lugar de acumular migraciones `ALTER TABLE` que deformen el orden visual, se debe ejecutar una reconstrucción limpia del schema:
     ```sql
     DROP SCHEMA genaryth CASCADE;
     CREATE SCHEMA genaryth;
     ```
   - Ejecutar a continuación `pnpm db:push` para forzar que el DDL inicial fije:
     - `ordinal_position = 1`: `id` (integer)
     - `ordinal_position = 2`: `subId` o `key` (text)
     - `ordinal_position >= 3`: atributos descriptivos de negocio.

---

## 🌱 8. Principio Clean Slate Seed vs. Fixtures Aisladas

1. **Segregación Estricta entre Datos Maestros y Datos de Prueba:**
   - **Anti-Patrón Prohibido:** Mezclar datos de prueba transaccionales (proyectos mock, épicas ficticias, tareas de demo) dentro del script canónico de semilla (`seed.ts`). Esto contamina la base de datos de desarrollo, arruina los Quality Gates de QA y exige limpiezas manuales constantes.
2. **Composición Canónica de Scripts de Base de Datos:**
   - **`pnpm db:seed` / `pnpm db:setup` (Clean Slate):** Siembra **exclusivamente** catálogos maestros y referencias inmutables del sistema (`MasterReference`). Tras su ejecución, las tablas transaccionales de negocio deben reportar exactamente **0 filas**.
   - **`pnpm db:seed:fixtures` (Entorno Mock Opcional):** Script aislado (`seed-fixtures.ts`) que puebla datos transaccionales de ejemplo para pruebas de UI y workshops de diseño.
   - **`pnpm db:clean` (Purga Transaccional):** Script para vaciar todas las tablas de negocio preservando intactos los catálogos de `MasterReference`.
3. **Verificación Automatizada Post-Seed:**
   - Toda suite de inicialización debe validar que `MasterReference` cuente con los registros canónicos completos y que ninguna tabla operativa contenga datos residuales no autorizados.


