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

---

## 🖥️ 4. Resiliencia de Renderizado & Web APIs (Frontend & Cross-Browser)

1. **Aislamiento de Canvas y APIs del DOM en SSR:**
   - Librerías que acceden directamente a `window`, `document` o WebGL (como Leaflet, Mapbox, Three.js) provocan colapsos de hidratación (`window is not defined`) si se evalúan en el servidor.
   - **Regla Inmutable:** Encapsular siempre en Client Islands importados dinámicamente:
     `const DynamicMap = dynamic(() => import('./MapComponent'), { ssr: false });` combinado con comprobación de estado de montaje (`const [mounted, setMounted] = useState(false)`).
2. **Optimización de LCP en Recursos Críticos:**
   - La imagen del Hero o el recurso principal visible en el primer viewport DEBE incluir `priority={true}` y atributos de dimensionamiento responsivo (`sizes`).
   - **Anti-Patrón:** Declarar `loading="lazy"` en la imagen del viewport inicial demorando el LCP más allá de los 2.5s.
3. **Escape de Contextos de Apilamiento (Stacking Contexts & Portals):**
   - Modales, menús desplegables y tooltips anidados dentro de contenedores con `backdrop-blur-*`, `transform` o `filter` quedan atrapados en el contexto de apilamiento local, ignorando valores de `z-index: 9999`.
   - **Regla Inmutable:** Montar siempre modales y overlays interactivos en la raíz del DOM mediante `createPortal(children, document.body)`.
4. **Peligro de Layout con Tailwind `space-y-*`:**
   - La utilidad `space-y-*` inyecta un selector CSS directo `> :not([hidden]) ~ :not([hidden])`, agregando márgenes superiores inesperados a capas absolutas (resplandores, spotlights, overlays decorativos).
   - **Regla Inmutable:** Prohibido usar `space-y-*` en contenedores con hijos `absolute`. Utilizar siempre `flex flex-col gap-*`.
5. **Normalización Defensiva de Formularios en Safari iOS / WebKit:**
   - Los elementos nativos `<select>` colapsan a alturas ilegibles (~28px) en iOS si no se fuerza su aspecto.
   - **Regla Inmutable:** Aplicar siempre `appearance-none`, `WebkitAppearance: 'none'`, altura fija explícita (`h-12`) y un icono SVG de flecha anclado de forma absoluta (`pointer-events-none`).
6. **Descargas Binarias Autenticadas:**
   - El atributo nativo HTML `<a href="..." download>` no soporta el envío de cabeceras de autorización (`Authorization: Bearer <JWT>`). Si la ruta está protegida, el navegador descarga silenciosamente una respuesta JSON 401/403 con extensión de archivo corrupta.
   - **Regla Inmutable:** Gestionar descargas protegidas mediante `fetch` autenticado con Bearer token, convirtiendo la respuesta a `Blob` y activando la descarga mediante `URL.createObjectURL(blob)`.
7. **Preprocesamiento Numérico en Validadores Zod:**
   - Los inputs HTML nativos de tipo número (`<input type="number">`) retornan strings vacíos `""` al borrarse o `NaN` en navegadores Safari, fallando la validación de `z.number()`.
   - **Regla Inmutable:** Usar siempre `z.preprocess((val) => (val === '' || Number.isNaN(Number(val)) ? undefined : Number(val)), z.number())`.
