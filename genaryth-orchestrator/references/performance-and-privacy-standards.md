# Estándares de Rendimiento, SLAs Móviles y Privacidad (Genaryth Performance Standard)

**Propósito:** Garantizar que todos los productos de software, plataformas SaaS y aplicaciones desarrolladas por la consultora Genaryth operen con tiempos de respuesta de clase mundial en condiciones móviles adversas y respeten rigurosamente la privacidad de los usuarios.

---

## ⚡ 1. Genaryth Performance SLA (Vistas Públicas y Flujos Críticos)

Diseñado para garantizar respuesta instantánea en cualquier vista pública, portal de clientes, checkout o flujo operativo bajo cobertura móvil 3G/4G inestable:

1. **Largest Contentful Paint (LCP):**
   - **LCP < 1.5s** garantizado en conexiones móviles simuladas (Mobile 3G/4G).
   - Renderizado inicial puramente del lado del servidor (SSR / Server Components) sin dependencias de bundles JS pesados.
2. **Presupuesto de Rendimiento (Bundle Budget):**
   - Payload inicial transferido por red: **< 80 KB** (HTML + CSS comprimido). First Load JS < 50 KB.
   - Prohibido importar librerías completas o utilitarios pesados en componentes de vistas públicas rápidas.
3. **Islas Asíncronas (Progressive Disclosure):**
   - Funcionalidades pesadas o que requieren permisos del navegador (como geolocalización GPS, cámara, biométricos o mapas interactivos) NO deben bloquear el render principal.
   - Deben encapsularse en un Client Component aislado que se dispara asíncronamente con un timeout estricto (máximo 6 segundos).
   - **Fallback Elegante Obligatorio:** Si el usuario deniega permisos o la conexión falla, la interfaz principal jamás colapsa ni se congela; muestra la información base de inmediato.
4. **Touch Targets de Alta Fricción en Dispositivos Móviles:**
   - Botones críticos de acción (llamadas directas, mensajería, acciones de emergencia o confirmaciones de pago) deben tener un tamaño táctil mínimo de **56px $\times$ 56px** para permitir su uso con una sola mano bajo estrés o movimiento.

---

## 🚀 2. Ingesta de Alta Concurrencia y Telemetría Asíncrona

1. **SLA de Ingesta Asíncrona (<150 ms):**
   - Todo endpoint de captura de eventos masivos (escaneos QR, logs de telemetría, webhooks de terceros, señales IoT) debe retornar respuesta **`202 Accepted` en menos de 150ms**.
2. **Desacoplamiento Operativo:**
   - La ingesta rápida valida la sintaxis básica, persiste el evento crudo o lo encola (SQS/EventBridge/Kafka/Redis), y delega el procesamiento pesado (notificaciones push, emails, llamadas a n8n, geocodificación inversa) a workers en segundo plano.

---

## 🛡️ 3. Privacidad por Diseño (Data Privacy & PII Protection)

1. **Enmascaramiento Estricto de Datos Personales (PII):**
   - Ningún dato de contacto privado (número de teléfono, correo electrónico, documento de identidad, dirección exacta) debe enviarse en texto plano a vistas públicas.
   - El backend debe entregar datos ofuscados por defecto (ej. `+51 98* *** 321`).
   - Para iniciar contacto, se utilizan enlaces estructurados o proxies generados por el servidor sin exponer la base de datos de usuarios.
2. **Des-enmascaramiento Condicional Auditado:**
   - La revelación completa de datos personales o sensibles solo se permite si el recurso entra en un estado explícito de emergencia, consentimiento explícito auditado del titular o autorización RBAC de alto nivel.
3. **Protección Criptográfica de Contraseñas:**
   - Almacenamiento de credenciales protegido obligatoriamente mediante algoritmos modernos de hashing con resistencia a GPU: **Argon2id** (estándar OWASP) o **bcrypt** con factor de coste $\ge 12$.
