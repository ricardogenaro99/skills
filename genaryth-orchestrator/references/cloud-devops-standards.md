# Estándares de Arquitectura Cloud AWS y DevSecOps — Genaryth

**Propósito:** Definir los lineamientos inmutables de Infraestructura como Código (AWS CDK v2), nomenclatura determinística, cuotas serverless y pipelines de despliegue continuo.

---

## 🏷️ 1. Estándar Corporativo de Nomenclatura Cloud (Secuencial 001)

Alineado al estándar institucional de Genaryth (`ADR-006`):

1. **Fórmula Obligatoria de Nombrado:**
   $$\mathbf{[Regi\acute{o}n][Cuenta/Ambiente][TipoRecurso][Proyecto][SecuencialNum\acute{e}rico]}$$

2. **Glosario de Siglas Estándar:**
   - **Región:** `UE1` (us-east-1), `UE2` (us-east-2), `SA1` (sa-east-1).
   - **Ambiente/Cuenta:** `DEVL` (Desarrollo), `TEST` (Pruebas/Staging), `PROD` (Producción).
   - **Tipo de Recurso:** 
     - `MTOCLF` = CloudFormation Stack
     - `VPC` = Virtual Private Cloud
     - `SG` = Security Group
     - `APIC` = API Gateway REST/HTTP
     - `LMBFACT` = Lambda Function
     - `RDS` = Aurora / Relational Database
     - `PROXY` = RDS Proxy
     - `S3` = Simple Storage Service Bucket
     - `WAF` = Web Application Firewall
   - **Proyecto:** Identificador del proyecto (ej. `KINPET`, `GENARYTH`).
   - **Secuencial Numérico de 3 Dígitos:** Obligatorio sufijo secuencial `001`, `002`, `003` para permitir despliegues en paralelo y paridad absoluta de inventarios.

3. **Ejemplos Reales Validados:**
   - Stack CloudFormation: `UE1DEVLMTOCLFKINPET001`
   - Red VPC: `UE1DEVLVPCKINPET001`
   - API Gateway Core: `UE1DEVLAPICKINPET001`
   - Lambda Compute Core: `UE1DEVLLMBFACTKINPETCORE001`
   - Proxy de Base de Datos: `UE1DEVLPROXYKINPET001`

---

## ⚡ 2. Blindaje Serverless y Prevención de Límites de Cuota AWS

1. **Control de Cuota de Políticas de Recursos Lambda (<20 KB):**
   - **Problema Detectado:** Al declarar múltiples rutas independientes en API Gateway con CDK, AWS agrega automáticamente un permiso `lambda:InvokeFunction` por cada método, superando rápidamente el límite duro de CloudFormation de 20 KB de política de recurso.
   - **Regla Inmutable:** En constructs de integración API Gateway Lambda en CDK, configurar obligatoriamente:
     `scopePermissionToMethod: false` y `allowTestInvoke: false` (o asociar un único permiso `lambda:InvokeFunction` wildcard para todo el ARN del API Gateway) para mantener la política de la Lambda por debajo de 12 KB.
2. **Validación Declarativa en el Edge (RequestValidators):**
   - API Gateway debe validar la estructura del payload mediante JSON Schemas antes de despertar la Lambda.
   - Peticiones malformadas son rechazadas con `400 Bad Request` en el Edge, ahorrando costos de cómputo en Lambda y protegiendo la base de datos.
3. **Resiliencia de Conexiones a Base de Datos (AWS RDS Proxy):**
   - Toda función Lambda que acceda a PostgreSQL/Aurora Serverless DEBE conectarse obligatoriamente a través de **AWS RDS Proxy**.
   - Queda prohibido abrir conexiones directas desde Lambdas efímeras a clusters de base de datos relacionales para evitar el agotamiento del pool de conexiones (*Connection Starvation*).
4. **Sintaxis Estricta Alfanumérica en AWS WAFv2:**
   - En constructs de `CfnWebACL`, el atributo `description` tiene una validación por regex estricta en CloudFormation (`^[\w+=:#@/\-,\.][\w+=:#@/\-,\.\s]+[\w+=:#@/\-,\.]$`).
   - **Regla Inmutable:** Queda terminantemente PROHIBIDO utilizar paréntesis `()` o caracteres especiales en `description`. Usar exclusivamente cadenas en inglés alfanuméricas con guiones o espacios estándar (ej. `Genaryth WAF ACL for Desa Stage`).
5. **CORS Universal a Nivel de Gateway (`GatewayResponses`):**
   - Errores de validación en el Edge (`400 Bad Request`), autorización (`403 Forbidden`) o caídas del gateway (`500`) generados directamente por API Gateway enmascaran el error como un fallo de CORS en el navegador si no poseen los headers correspondientes.
   - **Regla Inmutable:** Configurar siempre `DEFAULT_4XX` y `DEFAULT_5XX` en `GatewayResponses` con los headers:
     - `'Access-Control-Allow-Origin': "'*'"`
     - `'Access-Control-Allow-Headers': "'Content-Type,Authorization,X-Api-Key'"`
     - `'Access-Control-Allow-Methods': "'GET,POST,PUT,DELETE,PATCH,OPTIONS'"`
   - Las peticiones preflight `OPTIONS` deben responder con status `204 No Content` y `allowOrigins: apigateway.Cors.ALL_ORIGINS`, delegando la validación de orígenes específicos a la capa de aplicación NestJS.
6. **Desacoplamiento Condicional de CloudFront en Ambientes No Productivos:**
   - La creación de distribuciones CloudFront en cuentas nuevas o de desarrollo puede fallar con `403 Forbidden` debido a cuotas de verificación no habilitadas en la cuenta AWS.
   - **Regla Inmutable:** CloudFront debe ser opcional mediante feature flag (`ENABLE_CLOUDFRONT=false` por defecto en `DESA`). Los servicios deben exponer endpoints directos de API Gateway funcionales mientras CloudFormation omite la creación de la distribución global.
7. **Arquitectura de Carga Binaria en 2 Fases (S3 Presigned URLs):**
   - **Anti-Patrón Prohibido:** Enviar binarios (imágenes, documentos) en Base64 a través de API Gateway y Lambda (provoca colapsos por límite de 100 KB en body-parser de Express y memory leaks en la memoria de la Lambda).
   - **Regla Canónica:** Usar carga desacoplada:
     1. Fase 1: El cliente solicita una URL prefirmada al backend (`POST /api/v1/media/upload-url`) especificando metadata (`contentType`, `size`).
     2. Fase 2: El cliente sube el archivo binario directamente a S3 vía `PUT` con la presigned URL.
8. **Inmutabilidad de Parámetros en Constructs CDK (Spread Operator Hazard):**
   - Al sobreescribir `deployOptions` en constructs L2 de API Gateway (`new apigateway.RestApi`), nunca usar `{ ...deployOptions, stageName: config.stage }` sin resguardar explícitamente el stage de fallback. Una sobreescritura accidental genera colisiones en CloudFormation al intentar re-crear el Stage por defecto (`prod` vs `dev`).
9. **Aceleración del Bucle Interno con `--hotswap`:**
   - Para iteraciones locales rápidas de funciones Lambda backend sin atravesar el ciclo completo de CloudFormation (~3 a 5 minutos), proveer siempre un script `pnpm infra:deploy:fast` configurado con `cdk deploy --hotswap`, reduciendo el ciclo a ~15 segundos en desarrollo.

---

## 🚀 3. Gobernanza de Pipelines CI/CD y Despliegue Manual Bajo Demanda

1. **Separación Estricta CI vs. CD:**
   - **CI (Continuous Integration):** Se ejecuta en cada `push` o `pull_request` a cualquier rama. Realiza lint, chequeo de tipos TypeScript, compilación del monorepo, tests unitarios en Jest, tests E2E y `cdk synth`. Tiempo objetivo: < 3 minutos.
   - **CD (Continuous Deployment):** **PROHIBIDO el despliegue automático de infraestructura en push.**
2. **Despacho Manual Bajo Demanda (`workflow_dispatch`):**
   - Los pipelines de despliegue a la nube en GitHub Actions deben configurarse con menú interactivo `workflow_dispatch` y un selector dropdown de ambiente (`DESA`, `TEST`, `PROD`).
   - El despliegue a AWS requiere la intervención humana consciente de Ricardo Genaro mediante el botón **"Run workflow"** o CLI autorizado, garantizando cero despliegues accidentales.
3. **Runner Local de Quality Gate (`pnpm ci:local`):**
   - Ante fallos de cuota o límites de minutos en GitHub Actions, cada repositorio debe contar con un script `pnpm ci:local` que ejecute la suite completa de validaciones localmente de forma secuencial y determinista (`typecheck`, `test`, `lint`, `build`, `harness:check`).

---

## 🛠️ 4. Checklist Obligatorio DevOps: Scoping y Segregación de Puertos (ADR-013)

Todo `subagent-devops` y `subagent-sre` que intervenga en la inicialización, scaffolding o mantenimiento de monorepos DEBE validar y certificar los siguientes dos controles de calidad antes de sellar su ticket:

### ✅ 4.1 Auditoría de Scoping Corporativo en `package.json`
- [ ] **Cero Nombres Planos:** Ningún archivo `package.json` dentro de `apps/*` o `packages/*` puede tener nombres genéricos sin scope (`web`, `api`, `hub`, `common`, etc.).
- [ ] **Namespace Institucional:** Cada módulo debe estar formalmente tipado bajo el namespace `@genaryth/<app-name>` o `@<org>/<app-name>` (ej. `@genaryth/web`, `@genaryth/api`, `@genaryth/studio-hub`, `@genaryth/contracts`).
- [ ] **Resolución Interna `workspace:*`:** Toda dependencia entre proyectos del monorepo debe referenciarse usando el prefijo con scope corporativo y la versión `workspace:*`.

### ✅ 4.2 Matriz de Puertos Locales en Scripts Canónicos
- [ ] **Web Principal (`apps/web`):** El script `"dev"` en `package.json` debe fijar el puerto 3000 de forma explícita (`"dev": "next dev -p 3000"`).
- [ ] **Backend Core (`apps/api`):** El servidor debe escuchar en `process.env.PORT || 3001` y el script de desarrollo `"dev": "nest start --watch"` no debe interferir con el 3000.
- [ ] **Studio Hub / Internal Cockpit (`apps/studio-hub`):** El script `"dev"` en `package.json` debe fijar el puerto 3002 de forma explícita (`"dev": "next dev -p 3002"`).
- [ ] **Ventures Secundarias o Microfrontends (`apps/*`):** Deben utilizar puertos 3003 en adelante de manera secuencial y determinista.
- [ ] **Verificación de Concurrencia:** Certificar que la ejecución simultánea (`pnpm dev` en la raíz vía Turborepo) no lance errores `EADDRINUSE`.

---

## 💻 5. Directiva de Infraestructura Local y Conciencia de Recursos de Máquina (Resource-Aware Policy — ADR-014)

Todo `subagent-devops`, `subagent-architect` y `subagent-sre` que diseñe entornos de desarrollo local, contenedores Docker, herramientas CLI o scripts de inicialización DEBE cumplir obligatoriamente con el perfil de hardware de la estación de trabajo de **Ricardo Genaro (Mac mini / Apple Silicon, 16 GB RAM, ~20–30 GB de almacenamiento disponible)**:

1. **Baneo de Suites Monolíticas y Emuladores Pesados:**
   - **TERMINANTEMENTE PROHIBIDO:** Recomendar, configurar o incorporar `LocalStack`, emuladores locales pesados de AWS, o suites de contenedores que excedan 1 GB de descarga o consuman más de 1.5 GB de RAM.
   - **Alternativa Canónica:** 
     - Sintaxis de CloudFormation validada mediante `cdk synth` (cero coste, en memoria).
     - Pruebas de integración de constructs mediante `@aws-cdk/assertions` (ejecución ultra-rápida con Jest/Vitest).
     - Validación real contra cuentas sandbox/dev efímeras de AWS con cuotas controladas.
2. **Política de Imágenes Docker Ultraligeras (Alpine-First):**
   - Todo servicio de desarrollo local complementario (bases de datos, colas) debe utilizar imágenes mínimas `alpine` (ej. `redis:7-alpine`, imágenes oficiales de PostgreSQL optimizadas).
   - Queda prohibido levantar bases de datos vectoriales gigantes o servidores LLM locales en Docker (tipo Ollama con modelos de 70B) que saturen la memoria RAM o el disco SSD.
3. **Control y Auditoría de Volúmenes y Contenedores:**
   - Todo `docker-compose.yml` provisto en repositorios de Genaryth debe incluir nombres de contenedores determinísticos (`local-<proyecto>-<servicio>`) para fácil inspección visual en `lazydocker` (`ld`).
   - Los scripts de limpieza (`pnpm docker:clean`) deben eliminar volúmenes huérfanos para resguardar la cuota de disco disponible del equipo host.

---

## 🐳 6. Topología de Infraestructura Local Unificada (Cluster Central PostgreSQL Multitenancy)

1. **Principio de Contenedor Único Compartido:**
   - **Anti-Patrón Prohibido:** Levantar múltiples contenedores Docker independientes de PostgreSQL en una misma máquina host (ej. un contenedor para Genaryth y otro para Kinpet en puertos distintos como 5432 y 5433). Esto satura la memoria RAM, duplica procesos en segundo plano y fragmenta el almacenamiento en múltiples volúmenes no coordinados.
   - **Regla Inmutable:** Todos los proyectos del ecosistema Genaryth comparten un **único cluster local central** en `localhost:5432`:
     - **Nombre del Contenedor:** `genaryth-postgres-dev`
     - **Imagen Canónica:** `postgres:16-alpine` (mínimo consumo < 50 MB de RAM base).
     - **Volumen Persistente Compartido:** `genaryth_pgdata`
     - **Credenciales Maestras Locales:** Usuario `genaryth`, Password `genaryth_dev_password`.
2. **Segregación Lógica Multi-Base de Datos:**
   - Cada proyecto o venture satélite opera sobre su propia base de datos lógica dentro del mismo motor:
     - Genaryth Platform: `genaryth_dev`
     - Kinpet Core: `kinpet_dev`
     - Sprintflow: `sprintflow_dev`
   - Los archivos `docker-compose.yml` de proyectos secundarios (como Kinpet) deben configurarse para adjuntarse al mismo contenedor y volumen compartido, garantizando que arrancar cualquiera de ellos reuse la infraestructura activa sin colisión.

---

## 🛡️ 7. Erradicación Mandatoria del Schema `public` en Bases de Datos Relacionales

1. **Aislamiento DDL Estricto por Schema Dedicado:**
   - **Anti-Patrón Prohibido:** Desplegar tablas en el schema por defecto `public` de PostgreSQL. Provoca colisiones de nombres, mezcla metadatos de migraciones y anula el principio de multi-arquetipo.
   - **Regla Inmutable:** Queda **terminantemente prohibido** el uso del schema `public`. Cada proyecto, microservicio o dominio DEBE operar en su propio schema dedicado explícito:
     - Genaryth Platform: Schema `genaryth`
     - Kinpet Core: Schema `kinpet`
2. **Configuración de URLs de Conexión:**
   - Toda connection string (Prisma, TypeORM, DBeaver) DEBE incluir explícitamente el parámetro de esquema:
     - `postgresql://genaryth:genaryth_dev_password@localhost:5432/genaryth_dev?schema=genaryth`
     - `postgresql://genaryth:genaryth_dev_password@localhost:5432/kinpet_dev?schema=kinpet`
3. **DDL de Inicialización Automática:**
   - Los scripts de inicialización o migraciones iniciales deben forzar la creación del esquema antes de cualquier sentencia DDL:
     ```sql
     CREATE SCHEMA IF NOT EXISTS genaryth;
     SET search_path TO genaryth;
     ```

---

## 🌐 8. Arquitectura Vercel Multi-Project y Política FinOps $0 (`npx turbo-ignore`)

1. **Desacoplamiento Absoluto de Proyectos en Monorepo:**
   - Al alojar múltiples aplicaciones en un monorepo (ej. `apps/web` para la landing pública y `apps/studio-hub` para el backoffice operativo), **NUNCA** deben desplegarse bajo un solo proyecto Vercel con rutas compartidas.
   - Se deben crear proyectos independientes en el dashboard de Vercel apuntando al mismo repositorio GitHub:
     - Proyecto 1: `genaryth-web` $\rightarrow$ Root Directory: `apps/web`
     - Proyecto 2: `genaryth-studio-hub` $\rightarrow$ Root Directory: `apps/studio-hub`
2. **Prevención de Despliegues Redundantes con `npx turbo-ignore`:**
   - Para evitar agotar los 6,000 minutos mensuales de build del plan Hobby y prevenir despliegues innecesarios:
   - En cada proyecto de Vercel (Settings $\rightarrow$ Git $\rightarrow$ Ignored Build Step), configurar el comando personalizado:
     ```bash
     npx turbo-ignore
     ```
   - Turborepo evaluará el grafo de cambios git. Si un commit solo afecta a `apps/studio-hub` o `docs/*`, Vercel cancelará de inmediato el build de `apps/web` con exit code 0, reduciendo el consumo de cómputo a $0.00.
3. **Variables de Entorno Aisladas:**
   - Cada proyecto mantiene sus propias variables de entorno en Vercel, resguardando la privacidad de secretos del backoffice frente al bundle de la web pública.

---

## 📦 9. Higiene de `package.json` y Prevención de Deadlocks No-Interactivos en CI

1. **Erradicación de Comandos Interactivos en Pipelines:**
   - **Problema Crítico:** Herramientas como `next lint` sin un archivo de configuración `.eslintrc` o `eslint.config.mjs` preexistente despiertan un prompt interactivo en la terminal pidiendo al usuario configurar ESLint. En runners CI no-interactivos (GitHub Actions, Vercel, scripts headless), esto provoca un **deadlock silencioso permanente** que congela el pipeline hasta alcanzar el timeout.
   - **Regla Inmutable:** En entornos sin linter interactivo formalizado, sustituir comandos ambiguos por verificación determinista de tipos:
     `"lint": "tsc --noEmit"`
2. **Poda de Dependencias Huérfanas (Ghost / Phantom Dependencies):**
   - Eliminar sistemáticamente librerías declaradas en `dependencies` o `devDependencies` que no se importen en ningún archivo fuente de la aplicación o paquete (ej. `clsx`, `tailwind-merge` si ya vienen provistas por `@<org>/ui`).
3. **Estandarización Semántica de Claves en `package.json`:**
   - Todo archivo `package.json` debe seguir el orden canónico de claves de industria:
     `name`, `version`, `private`, `description`, `author`, `license`, `engines`, `packageManager`, `main`, `types`, `files`, `scripts`, `dependencies`, `devDependencies`, `peerDependencies`.
   - Incluir siempre el bloque `engines` (`node: ">=20.0.0"`, `pnpm: ">=9.0.0"`) para asegurar paridad absoluta de versiones en tiempo de compilación.

---

## ⚡ 10. Topología Zero-Cost Serverless Direct Connect & FinOps Cloud ($0.00/mes)

1. **Desacople Total de VPC y Eliminación de NAT Gateways en Entornos No Productivos:**
   - **Problema de Coste Basal:** Provisionar Aurora Serverless v2 con ACUs mínimas continuas, NAT Gateways para subnets privadas y RDS Proxy genera un coste fijo inevitable de **\$380+ USD/mes** en AWS aun con tráfico cero.
   - **Regla Inmutable (Topología Serverless Direct Connect):** En entornos de desarrollo y pruebas (`DESA`, `TEST`), desacoplar completamente la función Lambda Core de la VPC (`vpc: undefined`).
   - La función Lambda se ejecuta en el tejido serverless multi-tenant nativo de AWS, conectándose directamente vía HTTPS e internet saliente a motores de base de datos PostgreSQL Serverless escalados a cero (como Neon o Supabase Cloud) a un coste basal de **$0.00/mes**.

2. **Gobernanza de Secretos: AWS SSM Parameter Store Standard vs. AWS Secrets Manager:**
   - **Fuga de Presupuesto FinOps:** `secretsmanager.Secret` factura \$0.40 USD/mes por secreto más costes por cada 10,000 llamadas API.
   - **Regla Canónica:** Para llaves de firma JWT, variables de configuración cifradas y secretos estáticos de aplicación, utilizar **exclusivamente AWS Systems Manager (SSM) Parameter Store Standard** (`ssm.StringParameter` o `SecureString` standard):
     - Coste por parámetro: **$0.00 USD/mes** (almacenamiento ilimitado hasta 10,000 parámetros estándar).
     - Coste por llamadas API: **$0.00 USD** dentro de la cuota de throughput estándar.
     - Permisos IAM mínimos: `jwtSecretParam.grantRead(this.apiLambda)`.

3. **Resolución de Colisiones en CloudFormation por Recursos Retenidos (`RemovalPolicy.RETAIN`):**
   - **Problema en Re-despliegues:** En stacks de producción (`PROD`), recursos críticos como Amazon S3 Buckets de assets multimedia (`KinpetAssetsBucket`) y tablas DynamoDB configuran `removalPolicy: RemovalPolicy.RETAIN` para prevenir pérdida accidental de datos. Si el stack CloudFormation se elimina o se despliega en una cuenta con recursos existentes, el despliegue falla con error `Resource already exists`.
   - **Reglas Inmutables de Resiliencia en CDK:**
     1. **Importación Dinámica o Fallback:** Si el bucket ya existe en la cuenta, el construct debe permitir reutilizar el recurso retenido existente (`s3.Bucket.fromBucketName(...)`) o parametrizar el nombre mediante override (`bucketNameOverride`).
     2. **Fallback Dinámico de Cuenta AWS en Configuración:** En `config.ts`, nunca fijar IDs de cuenta AWS de forma estricta sin fallback dinámico. Utilizar:
        `id: process.env.AWS_ACCOUNT_ID || '<DEFAULT_ACCOUNT_ID>'`
        permitiendo despliegues limpios y reproducibles entre distintas cuentas corporativas de AWS sin modificar el código fuente del construct.
     3. **Silenciamiento de Warnings Incompatibles:** Al utilizar `scopePermissionToMethod: false` en `apigateway.LambdaIntegration`, suprimir `allowTestInvoke: false` explícito para evitar advertencias de configuración redundante en CDK CLI.


