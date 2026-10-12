# Tríada de Gobernanza Universal Multi-Agente mediante Symlinks SSOT (ADR-010)

## 1. Contexto & Diagnóstico
En el ecosistema moderno de desarrollo de software asistido por IA, cada asistente, CLI o entorno de desarrollo (IDE) busca sus directivas de comportamiento y gobernanza en un archivo específico ubicado en la raíz del repositorio:

* **Google Antigravity / Gemini CLI:** Lee exclusivamente `GEMINI.md`.
* **Claude Code (Anthropic):** Lee exclusivamente `CLAUDE.md`.
* **Cursor IDE:** Lee prioritariamente `.cursorrules` (o `.cursor/rules`).
* **OpenCode / Aider / Linux Foundation Standard:** Lee `AGENTS.md`.

### El Riesgo del Drift de Gobernanza
Mantener cuatro archivos separados genera duplicación masiva, inconsistencias al actualizar reglas (drift de directivas) y degradación de la disciplina de ingeniería.
Por otro lado, obligar a los desarrolladores o agentes a recordar diferentes nombres de archivo según la herramienta viola el principio de **Single Source of Truth (SSOT)**.

---

## 2. Decisión de Arquitectura: La Tríada de Symlinks POSIX
Genaryth Venture Studio instituye la **Tríada de Gobernanza Universal Multi-Agente (ADR-010)**:
1. **Archivo Físico Maestro Canónico:** `GEMINI.md` en la raíz del repositorio contiene el 100% de la gobernanza viva, la directiva multiagente obligatoria (`genaryth-orchestrator`), los 5 Gateways, la disciplina Git ADR-007 Rev. 2 y los estándares de ingeniería.
2. **Tríada de Enlaces Simbólicos (Symlinks):** Se generan tres symlinks relativos POSIX apuntando a `GEMINI.md`:
   ```bash
   ln -s GEMINI.md CLAUDE.md
   ln -s GEMINI.md AGENTS.md
   ln -s GEMINI.md .cursorrules
   ```

---

## 3. Matriz de Compatibilidad Multi-Plataforma

| Entorno / Asistente | Fabricante / Estándar | Archivo Detectado | Mecanismo de Resolución | Estado Operativo |
| :--- | :--- | :--- | :--- | :---: |
| **Google Antigravity** | Google DeepMind | `GEMINI.md` | Archivo físico canónico | ✅ Nativo Canónico |
| **Gemini CLI** | Google Cloud / DeepMind | `GEMINI.md` | Archivo físico canónico | ✅ Nativo Canónico |
| **Claude Code** | Anthropic | `CLAUDE.md` | Symlink POSIX a `GEMINI.md` | ✅ Nativo Universal |
| **Cursor IDE** | Anysphere | `.cursorrules` | Symlink POSIX a `GEMINI.md` | ✅ Nativo Universal |
| **OpenCode / Aider** | Open Source / Linux Foundation | `AGENTS.md` | Symlink POSIX a `GEMINI.md` | ✅ Nativo Universal |

---

## 4. Checklist de Kickoff y Auditoría Preventiva

Todo Orchestrator o subagente de DevOps debe verificar la existencia y salud de los symlinks como parte de los Quality Gates de inicio:

### Script de Inicialización y Reparación Automática
```bash
#!/usr/bin/env bash
# Verifica y crea la Tríada de Symlinks SSOT si no existen o están rotos
set -euo pipefail

if [ ! -f "GEMINI.md" ]; then
  echo "❌ Error: GEMINI.md no existe en la raíz del repositorio."
  exit 1
fi

for link in "CLAUDE.md" "AGENTS.md" ".cursorrules"; do
  if [ ! -L "$link" ]; then
    echo "🔗 Creando symlink: $link -> GEMINI.md"
    ln -sf GEMINI.md "$link"
  else
    target=$(readlink "$link")
    if [ "$target" != "GEMINI.md" ]; then
      echo "⚠️  Corrigiendo symlink desalineado: $link -> GEMINI.md"
      ln -sf GEMINI.md "$link"
    else
      echo "✅ Symlink saludable: $link -> GEMINI.md"
    fi
  fi
done

echo "🎉 Tríada de Gobernanza Universal ADR-010 certificada con éxito."
```

---

## 5. Consideraciones de Git y Sistemas Operativos
1. **Preservación en Git:** Git versiona los enlaces simbólicos de forma nativa como punteros ligeros de 120000 mode (ej. `120000 78c9c4c... CLAUDE.md`), ocupando solo bytes en disco y sin duplicar contenido en el historial.
2. **Compatibilidad en Windows / WSL:** Asegurar `git config core.symlinks true` en entornos Windows para prevenir que Git clone los symlinks como archivos planos de texto.
