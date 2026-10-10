# Estándares de Arquitectura y Buenas Prácticas de Software — Genaryth

**Propósito:** Definir los principios inmutables de ingeniería de software que rigen todo desarrollo en Genaryth (Backend, Frontend, Base de Datos y APIs).

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
3. **Migraciones Versionadas y Determinísticas:**
   - Prohibido modificar esquemas de base de datos directamente en el motor.
   - Todo cambio de esquema se realiza vía archivos de migración rastreados en Git (`prisma migrate dev`).

---

## 🎨 3. Arquitectura Frontend Moderna (Next.js App Router)

1. **Separación Estricta Server vs. Client Components:**
   - **Server Components por Defecto:** Todas las páginas (`page.tsx`), layouts y componentes de presentación estática o con fetch de datos son Server Components. Cero JavaScript bloqueante al cliente, máximo SEO y menor bundle size.
   - **Client Components Quirúrgicos (`'use client'`):** Únicamente en los componentes hoja interactivos que manejan eventos de usuario (`onClick`, formularios, modales, animaciones con Framer Motion).
2. **Formularios Tipados y Validación en Doble Capa:**
   - Manejo de formularios mediante **React Hook Form**.
   - Validación tipada unificada mediante esquemas **Zod** compartidos con el backend.
3. **Manejo de Estados de UI Resilientes:**
   - Toda vista con carga asíncrona DEBE contemplar los 4 estados canónicos:
     1. `Loading` (Skeleton loaders elegantes, no spinners invasivos).
     2. `Success` (Renderizado de datos con transiciones suaves).
     3. `Empty State` (Ilustración o mensaje claro invitando a la acción).
     4. `Error State` (Mensaje descriptivo y botón de reintento).

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
