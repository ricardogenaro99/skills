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

