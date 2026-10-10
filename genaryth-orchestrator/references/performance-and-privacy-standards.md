# Estándares de Rendimiento, SLAs Móviles y Privacidad (The Nala Standard)

**Propósito:** Garantizar que los productos de Genaryth operen con tiempos de respuesta de clase mundial en condiciones móviles adversas y respeten rigurosamente la privacidad de los usuarios.

---

## ⚡ 1. The Nala Performance SLA (Vistas Públicas Críticas)

Inspirado en la pantalla de rescate de Kinpet, donde una mascota extraviada exige respuesta instantánea en la vía pública bajo cobertura 3G/4G inestable:

1. **Largest Contentful Paint (LCP):**
   - **LCP < 1.5s** garantizado en conexiones móviles simuladas (Mobile 3G/4G).
   - Renderizado inicial puramente del lado del servidor (SSR) sin dependencias de bundles JS pesados.
2. **Presupuesto de Rendimiento (Bundle Budget):**
   - Payload inicial transferido por red: **< 80 KB** (HTML + CSS comprimido).
   - Prohibido importar librerías completas en componentes de vistas públicas rápidas.
3. **Islas Asíncronas (Progressive Disclosure):**
   - Funcionalidades pesadas o que requieren permisos del navegador (como geolocalización GPS, cámara o mapas interactivos) NO deben bloquear el render principal.
   - Deben encapsularse en un Client Component aislado que se dispara asíncronamente con un timeout estricto (máximo 6 segundos).
   - **Fallback Elegante Obligatorio:** Si el usuario deniega permisos o la conexión falla, la interfaz principal jamás colapsa ni se congela; muestra la información base de inmediato.
4. **Touch Targets de Alta Fricción en Vía Pública:**
   - Botones críticos de acción (llamar por teléfono, abrir WhatsApp, botones de emergencia) deben tener un tamaño táctil mínimo de **56px $\times$ 56px** para permitir su uso con una sola mano bajo estrés o movimiento.

---

## 🚀 2. Ingesta de Alta Concurrencia y Telemetría Asíncrona

1. **SLA de Ingesta Asíncrona (<150 ms):**
   - Todo endpoint de captura de eventos masivos (escaneos QR, logs de telemetría, webhooks de terceros) debe retornar respuesta **`202 Accepted` en menos de 150ms**.
2. **Desacoplamiento Operativo:**
   - La ingesta rápida valida la sintaxis básica, persiste el evento crudo o lo encola (SQS/EventBridge/Kafka/Redis), y delega el procesamiento pesado (notificaciones push, emails, llamadas a n8n, geocodificación inversa) a workers en segundo plano.

---

## 🛡️ 3. Privacidad por Diseño (Data Privacy & PII Protection)

1. **Enmascaramiento Estricto de Datos Personales (PII):**
   - Ningún dato de contacto privado (número de teléfono, correo electrónico, dirección exacta) debe enviarse en texto plano a vistas públicas.
   - El backend debe entregar datos ofuscados por defecto (ej. `+51 98* *** 321`).
   - Para iniciar contacto, se utilizan enlaces estructurados directos (deep links a WhatsApp) generados por el servidor sin exponer la base de datos de usuarios.
2. **Des-enmascaramiento Condicional Auditado:**
   - La revelación completa de datos de contacto solo se permite si el recurso entra en un estado explícito de emergencia (ej. Alerta Roja de Mascota Perdida activada por el dueño).
3. **Protección Criptográfica de Contraseñas:**
   - Almacenamiento de credenciales protegido obligatoriamente mediante algoritmos modernos de hashing con resistencia a GPU: **Argon2id** (estándar OWASP) o **bcrypt** con factor de coste $\ge 12$.
