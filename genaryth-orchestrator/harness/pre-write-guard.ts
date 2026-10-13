/**
 * Genaryth Autonomous Squad Framework (GASF v2.0)
 * Pre-Write & Runtime Guardrails Engine
 *
 * Intercepta y valida mutaciones de código en vuelo antes de que toquen el disco,
 * previniendo fugas de secretos, violaciones de Clean Architecture y anti-patrones.
 */

export interface GuardViolation {
  category: 'SECRET_LEAK' | 'ARCHITECTURAL_BOUNDARY' | 'TYPE_SAFETY' | 'COMMAND_SAFETY';
  severity: 'CRITICAL' | 'HIGH' | 'MEDIUM';
  message: string;
  matchedRule: string;
  location?: string;
}

export interface GuardScanResult {
  passed: boolean;
  violations: GuardViolation[];
}

export interface CommandSafetyResult {
  allowed: boolean;
  reason?: string;
  matchedPattern?: string;
}

// Patrones regex de alta fidelidad para detección de secretos estáticos
export const SECRET_PATTERNS: Array<{ name: string; pattern: RegExp; severity: 'CRITICAL' | 'HIGH' }> = [
  {
    name: 'AWS Access Key ID',
    pattern: /\bAKIA[0-9A-Z]{16}\b/,
    severity: 'CRITICAL'
  },
  {
    name: 'Generic API / Secret Key (OpenAI, Anthropic, Stripe)',
    pattern: /\b(?:sk-[a-zA-Z0-9_-]{20,}|sk_live_[a-zA-Z0-9]{24,})\b/,
    severity: 'CRITICAL'
  },
  {
    name: 'GitHub Personal Access Token',
    pattern: /\bghp_[a-zA-Z0-9]{20,}\b/,
    severity: 'CRITICAL'
  },
  {
    name: 'Hardcoded JSON Web Token (JWT)',
    pattern: /\beyJ[a-zA-Z0-9_-]{10,}\.eyJ[a-zA-Z0-9_-]{10,}\.[a-zA-Z0-9_-]{10,}\b/,
    severity: 'CRITICAL'
  },
  {
    name: 'Hardcoded Private Key Header',
    pattern: /-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----/,
    severity: 'CRITICAL'
  },
  {
    name: 'Database URI with Embedded Credentials',
    pattern: /(?:postgres|postgresql|mysql|mongodb|redis):\/\/[a-zA-Z0-9_.-]+:[^@\s]+@[a-zA-Z0-9_.-]+/,
    severity: 'CRITICAL'
  }
];

// Comandos de terminal estrictamente prohibidos en tiempo de ejecución
export const FORBIDDEN_COMMANDS: Array<{ pattern: RegExp; reason: string }> = [
  {
    pattern: /^git\s+add\s+(\.|\-A|\-\-all|\*)$/i,
    reason: 'Violación estricta de Git ADR-007. Prohibido staging masivo con comodines en la raíz (Riesgo Anti-Chancado). Exige staging quirúrgico archivo por archivo.'
  },
  {
    pattern: /^git\s+commit\s+\-a[m]?\b/i,
    reason: 'Prohibido git commit con flag -a. Se exige staging quirúrgico previo verificado.'
  },
  {
    pattern: /^git\s+push\b/i,
    reason: 'Violación estricta de Push Safeguard (ADR-007). Los subagentes tienen prohibido sincronizar con el repositorio remoto sin autorización expresa del Lead.'
  },
  {
    pattern: /^(npx\s+)?cdk\s+deploy\b/i,
    reason: 'Prohibido desplegar infraestructura directamente a AWS. Los despliegues se ejecutan exclusivamente vía CD manual con workflow_dispatch en GitHub Actions.'
  },
  {
    pattern: /^(npx\s+)?prisma\s+migrate\s+reset\b/i,
    reason: 'Comando destructivo bloqueado. Riesgo de eliminación de esquemas y tablas en bases de datos activas.'
  },
  {
    pattern: /^rm\s+\-[a-zA-Z]*r[a-zA-Z]*f\s+[\/\.\*]/i,
    reason: 'Comando destructivo bloqueado. Intento de eliminación recursiva no controlada de directorios raíz.'
  }
];

/**
 * Escanea el contenido de un archivo en busca de credenciales, tokens o secretos hardcodeados.
 */
export function scanContentForSecrets(content: string, filePath?: string): GuardViolation[] {
  const violations: GuardViolation[] = [];

  for (const { name, pattern, severity } of SECRET_PATTERNS) {
    if (pattern.test(content)) {
      violations.push({
        category: 'SECRET_LEAK',
        severity,
        message: `Detectado potencial secreto hardcodeado (${name}). Los secretos deben inyectarse exclusivamente vía AWS Secrets Manager o variables de entorno.`,
        matchedRule: name,
        location: filePath
      });
    }
  }

  return violations;
}

/**
 * Valida límites arquitectónicos y directivas de diseño limpio (Hexagonal Architecture / RSC).
 */
export function validateArchitecturalBoundaries(filePath: string, content: string): GuardViolation[] {
  const violations: GuardViolation[] = [];

  // Regla 1: Dominio Hexagonal Puro (Domain Isolation)
  // La capa de dominio o entidades jamás debe importar frameworks de infraestructura (NestJS, Prisma, Express, Fastify)
  if (filePath.includes('/domain/') || filePath.includes('/entities/')) {
    const forbiddenImports = ['@nestjs/', '@prisma/client', 'typeorm', 'express', 'fastify'];
    for (const imp of forbiddenImports) {
      if (content.includes(`from '${imp}`) || content.includes(`from "${imp}`)) {
        violations.push({
          category: 'ARCHITECTURAL_BOUNDARY',
          severity: 'HIGH',
          message: `Violación de Arquitectura Hexagonal: El módulo de dominio puro (${filePath}) no debe tener dependencias de infraestructura acopladas (${imp}).`,
          matchedRule: `HEXAGONAL_DOMAIN_PURITY:${imp}`,
          location: filePath
        });
      }
    }
  }

  // Regla 2: Purity en DTOs y Contratos de Datos
  // Prohibido el uso de tipos 'any' o esquemas laxos en DTOs compartidos
  if (filePath.endsWith('.dto.ts') || filePath.endsWith('.contract.ts') || filePath.includes('/types/')) {
    if (/(:\s*any\b|<any>|\bas\s+any\b)/.test(content)) {
      violations.push({
        category: 'TYPE_SAFETY',
        severity: 'MEDIUM',
        message: `Uso no autorizado del tipo comodín 'any' en contrato DTO (${filePath}). En Genaryth todo payload debe estar fuertemente tipado con interfaces, Zod o class-validator.`,
        matchedRule: 'NO_ANY_IN_DTOS',
        location: filePath
      });
    }
  }

  // Regla 3: Server Component Boundary en Next.js
  // Si un archivo de página o layout de Next.js App Router usa hooks de cliente sin la directiva 'use client'
  if ((filePath.includes('/app/') && (filePath.endsWith('page.tsx') || filePath.endsWith('layout.tsx'))) && !content.includes("'use client'")) {
    const clientHooks = ['useState', 'useEffect', 'useLayoutEffect', 'useReducer'];
    for (const hook of clientHooks) {
      if (new RegExp(`\\b${hook}\\s*\\(`).test(content)) {
        violations.push({
          category: 'ARCHITECTURAL_BOUNDARY',
          severity: 'HIGH',
          message: `El Server Component (${filePath}) invoca el hook interactivo '${hook}'. Para cumplir el Genaryth Performance SLA, extrae este comportamiento a un Client Island aislado con 'use client'.`,
          matchedRule: 'RSC_CLIENT_HOOK_LEAK',
          location: filePath
        });
      }
    }
  }

  return violations;
}

/**
 * Intercepta un comando de terminal antes de su ejecución para comprobar si cumple las políticas de seguridad.
 */
export function validateCommandSafety(command: string): CommandSafetyResult {
  const trimmed = command.trim();

  for (const { pattern, reason } of FORBIDDEN_COMMANDS) {
    if (pattern.test(trimmed)) {
      return {
        allowed: false,
        reason,
        matchedPattern: pattern.toString()
      };
    }
  }

  return { allowed: true };
}

/**
 * Escaneo integral de pre-escritura combinando secretos, límites de arquitectura y tipado.
 */
export function preWriteAudit(filePath: string, content: string): GuardScanResult {
  const secretViolations = scanContentForSecrets(content, filePath);
  const archViolations = validateArchitecturalBoundaries(filePath, content);
  const allViolations = [...secretViolations, ...archViolations];

  return {
    passed: allViolations.length === 0,
    violations: allViolations
  };
}
