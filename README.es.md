# Office Copilot PPT Agent Suite

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [Français](README.fr.md) | [Español](README.es.md)

Un paquete de capacidades desplegable para entornos empresariales donde no se pueden instalar Skills de la comunidad, pero sí se pueden utilizar agentes de Microsoft 365 Copilot. Permite crear presentaciones formadas por objetos nativos y editables de PowerPoint.

> Este repositorio no es un Skill instalable de forma nativa en Microsoft 365 Copilot. Proporciona capacidades reutilizables mediante agentes de Copilot, conocimiento gobernado en SharePoint, un formato PPT-HTML restringido y un compilador VBA fijo. Las plataformas compatibles con `SKILL.md` pueden instalar los dos Skills incluidos en `skills/`.

## Contenido

| Componente | Finalidad |
|---|---|
| PPT Authoring Agent | Convierte el chat y el contexto de Word, PowerPoint, Excel, PDF, texto, HTML, Markdown e imágenes en PPT-HTML 16:9 |
| PPT Skill Curator | Revisa Skills externos de presentaciones y publica normas internas aprobadas mediante un proceso de versiones controlado |
| PPT QA Agent | Audita el Schema, la capacidad de edición de objetos nativos, la geometría, la fidelidad visual, la integridad del contenido y la accesibilidad |
| PPT-HTML VBA Compiler Skill | Valida PPT-HTML y compila el modelo integrado en objetos nativos de PowerPoint mediante un motor VBA fijo |
| Orchestrator Skill | Despliega y mantiene el conjunto completo de agentes de Office Copilot |
| Plantilla Shared Library | Proporciona `Incoming`, `Draft`, `Test`, `Registry`, `Published/Current` y áreas de versiones inmutables |

## Inicio rápido con Office Copilot

1. Copie `shared-library-template/PPT-Skill-Library` en una biblioteca de documentos de SharePoint aprobada.
2. Sustituya `{{SHARED_LIBRARY_ROOT_URL}}` por la URL de SharePoint que termine en `PPT-Skill-Library`.
3. Abra Microsoft 365 Copilot Agent Builder y pegue cada archivo de `office-copilot/*-agent-generator.txt`.
4. Añada las carpetas de conocimiento indicadas en cada Generator Prompt.
5. Cree un host de compilación `.pptm` o `.ppam` de confianza a partir de `skills/ppt-html-vba-compiler/vba/`.
6. Realice pruebas privadas antes de compartir los agentes.

Consulte la [guía de configuración de Office Copilot](office-copilot/README.es.md) para ver todos los pasos.

## Instalar los Skills

Copie uno o ambos directorios en la carpeta Skills de una plataforma compatible con `SKILL.md`:

```text
skills/office-copilot-ppt-orchestrator
skills/ppt-html-vba-compiler
```

Se pueden invocar por separado:

```text
Use $office-copilot-ppt-orchestrator to configure this tenant's PPT agent suite.
Use $ppt-html-vba-compiler to validate and compile deck.html.
```

El Compiler Skill forma parte lógica de la suite, pero se mantiene físicamente independiente para que el sistema de Skills pueda detectarlo de forma fiable.

## Estructura del repositorio

```text
office-copilot/           Prompts e Instructions para copiar en Agent Builder
shared-library-template/  Conocimiento de SharePoint y plantilla de versiones
ppt-html/                 Schema, contrato de mapeo y ejemplos
skills/                   Dos Skills instalables de forma independiente
docs/                     Documentación de arquitectura y gobierno
tools/                    Herramientas de configuración y validación del repositorio
```

## Estado actual

Este repositorio es una implementación inicial. Incluye el PPT-HTML Schema, el validador determinista, el plan de objetos, el código VBA, los Agent Prompts, el flujo de gobierno, el contrato de QA, las pruebas y una presentación de ejemplo. La compilación de escritorio requiere un host de macros aprobado por la organización y Microsoft PowerPoint para Windows. Los efectos complejos del navegador deben declarar una alternativa nativa, SVG, ráster o no compatible.

Antes de publicar una versión, ejecute:

```powershell
python tools/validate_repository.py
python -m unittest discover -s skills/ppt-html-vba-compiler/tests -v
```

## Seguridad y gobierno

Los agentes de producción solo consultan `Published/Current`. El contenido de GitHub y los archivos de `Incoming`, `Draft`, `Test` o versiones históricas no son instrucciones de producción. Las actualizaciones externas requieren procedencia, revisión de licencia, pruebas de compatibilidad, aprobación humana, una instantánea inmutable y un plan de reversión.

Las macros solo deben ejecutarse desde hosts de confianza o firmados conforme a las políticas de la organización. El compilador rechaza versiones principales desconocidas del Schema y tipos de objetos desconocidos en lugar de adivinarlos.

## Documentación

- [Configuración de Office Copilot](office-copilot/README.es.md)
- [Arquitectura y gobierno](docs/architecture.es.md)
- [Uso de Skills](skills/README.es.md)
- [Ejemplo PPT-HTML](ppt-html/examples/sample-deck/deck.html)

## Licencia

El contenido creado para este proyecto se distribuye bajo la licencia MIT. Las dependencias VBA incluidas conservan sus propios avisos MIT en `skills/ppt-html-vba-compiler/vba/vendor/`.
