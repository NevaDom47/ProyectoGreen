---
name: agentes-personalizados
description: >-
  Guía completa y flujo de trabajo para crear, configurar y gestionar Agentes Personalizados (Custom Agents)
  en Antigravity. Utiliza esta skill cuando el usuario solicite crear un agente especializado, configurar
  subagentes o agentes principales, definir permisos de ejecución, o estructurar archivos en .agents/agents/.
---

# Agentes Personalizados (Custom Agents) en Antigravity

Los **Agentes Personalizados** permiten orquestar y dividir el trabajo de ingeniería de software creando agentes especializados basados en archivos. Cada agente cuenta con su propio rol, instrucciones de sistema, herramientas, habilidades y políticas de seguridad, evitando la saturación del contexto (context window bloat) y eliminando la necesidad de reexplicar directrices en cada sesión.

---

## 1. Dónde se guardan los archivos de Agente

Los agentes se definen como archivos individuales en formato Markdown (`.md`):

* **Nivel de Proyecto / Espacio de trabajo (Workspace)**:
  * Ruta: `.agents/agents/<nombre-del-agente>.md` (relativo a la raíz del repositorio).
  * **Uso recomendado**: Se versionan en Git y quedan inmediatamente disponibles para todos los miembros del equipo que clonen el proyecto, sin configuración manual.
* **Nivel Global (Usuario / Máquina)**:
  * Ruta: `~/.gemini/config/agents/<nombre-del-agente>.md` (en Windows: `%USERPROFILE%\.gemini\config\agents\`).
  * **Uso**: Disponibles en cualquier proyecto en la máquina local.

---

## 2. Formato del Archivo y Campos Soportados

Cada archivo de agente consta de dos partes:
1. **Encabezado YAML Frontmatter**: Define parámetros de configuración, modelo, permisos y herramientas.
2. **Cuerpo Markdown (`# Core Instructions`)**: Se compila directamente como el prompt de sistema del agente.

### Campos del Frontmatter

| Campo | Tipo | Requerido | Descripción |
| :--- | :--- | :--- | :--- |
| `name` | string | **Sí** | Identificador único del agente (en minúsculas, separado por guiones; ej. `dependency-modernizer`). |
| `description` | string | **Sí** | Descripción de las responsabilidades del agente y cuándo debe intervenir. |
| `model` | string | No | Modelo a utilizar (ej. `flash`, `pro`). |
| `tools` | list | No | Lista explícita de herramientas a las que tiene acceso (ej. `view_file`, `replace_file_content`, `run_command`, `manage_task`). |
| `skills` | list | No | Lista de habilidades (skills) curadas accesibles por el agente (ej. `skills/flutter-apply-architecture-best-practices`). |
| `mainAgent` | boolean | No | Si es `true`, puede ejecutarse directamente como agente principal en una sesión interactiva o CLI. |
| `subagent` | boolean | No | Si es `true`, puede ser invocado y delegado dinámicamente como subagente por un agente coordinador. |
| `permissionMode` | string | No | Nivel de permisos base (ej. `acceptEdits`, `bypassPermissions`). |
| `commandExecutionPolicy` | string | No | Política de ejecución de comandos. `auto` permite ejecutar pruebas y compilación en segundo plano sin pedir confirmación constante, mientras mantiene protegidas las acciones de alto riesgo (como borrado de archivos). |

---

## 3. Cómo se invocan los Agentes

Antigravity ofrece **simetría de ejecución**, permitiendo usar el mismo agente tanto de forma interactiva como delegada:

### Como Agente Principal (Main Agent)
* **Interfaz de Antigravity (GUI)**: Seleccionándolo directamente en el selector desplegable de agentes.
* **Línea de Comandos (CLI)**: Ejecutando:
  ```bash
  agy --agent <nombre-del-agente>
  ```
* Adopta directamente las instrucciones del cuerpo Markdown como su prompt base y asume las herramientas y permisos especificados.

### Como Subagente (Subagent)
* Un agente coordinador principal evalúa la tarea y, basándose en el campo `description`, delega trabajo a este agente como si fuera una herramienta especializada.
* Permite aislar ejecuciones largas o iterativas (ej. pruebas, refactorizaciones) sin contaminar el contexto del agente principal.

---

## 4. Plantillas y Ejemplos

### Ejemplo A: `dependency-modernizer.md`
```markdown
---
name: dependency-modernizer
description: Ayuda a actualizar dependencias y verificar que los tests pasen exitosamente.
model: flash
mainAgent: true
subagent: true
permissionMode: acceptEdits
commandExecutionPolicy: auto
tools:
  - view_file
  - replace_file_content
  - manage_task
  - run_command
skills:
  - skills/dart-resolve-package-conflicts
---

# Core Instructions
Eres un especialista en modernización de dependencias. Tu objetivo es revisar los
archivos de configuración (pubspec.yaml / package.json), actualizar las versiones
de librerías de forma segura, ejecutar las suites de pruebas y validar que el build sea exitoso.
```

### Ejemplo B: `flutter-tester.md` (Especializado para este proyecto)
```markdown
---
name: flutter-tester
description: Agente encargado de ejecutar, depurar y crear pruebas unitarias y de widgets en Flutter.
model: flash
mainAgent: true
subagent: true
commandExecutionPolicy: auto
tools:
  - view_file
  - replace_file_content
  - run_command
skills:
  - skills/flutter-add-widget-test
  - skills/dart-add-unit-test
  - skills/dart-fix-runtime-errors
---

# Core Instructions
Eres un agente enfocado en pruebas automáticas de Flutter.
Tu responsabilidad es ejecutar `flutter test`, analizar fallos, corregir pruebas rotas
o widgets asociados y asegurar que la cobertura se mantenga alta y sin advertencias de linter.
```

---

## 5. Procedimiento para Crear un Agente en el Proyecto

1. Crear el directorio `.agents/agents/` si aún no existe en la raíz del proyecto.
2. Crear un archivo `<nombre-en-kebab-case>.md`.
3. Incluir el bloque YAML de frontmatter con los campos necesarios (`name`, `description`, `tools`, `skills`, `mainAgent`, `subagent`, etc.).
4. Redactar las instrucciones nucleares bajo el encabezado `# Core Instructions`.
5. Probar el agente seleccionándolo en el selector de la UI o mediante `agy --agent <nombre-del-agente>`.
