# Implementación en Office Copilot

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [Français](README.fr.md) | [Español](README.es.md)

Este directorio es el kit para copiar en Microsoft 365 Copilot Agent Builder. Microsoft 365 Copilot no instala los Skills del repositorio: utiliza los tres Agent Prompts y el conocimiento aprobado en SharePoint.

## Requisitos

- Agent Builder y una biblioteca de SharePoint aprobada
- PowerPoint para Windows para la compilación de escritorio
- una política de macros aprobada y un host `.pptm`/`.ppam` de confianza o firmado
- responsables de autoría, curación, QA, seguridad y versiones

## Implementación

1. Copie `../shared-library-template/PPT-Skill-Library` en SharePoint sin cambiar su estructura.
2. Ejecute `python ../tools/configure_package.py --root-url "https://TENANT.sharepoint.com/sites/SITE/LIBRARY/PPT-Skill-Library" --output PATH` o sustituya `{{SHARED_LIBRARY_ROOT_URL}}`.
3. En Agent Builder, pegue cada `*-agent-generator.txt` en una conversación Agent nueva e independiente.
4. Authoring y QA solo consultan `Published/Current`. Curator puede consultar `Registry`, `Incoming`, `Draft`, `Test`, `Published/Current` y `Published/Releases`.
5. Si no puede usar los Generator Prompts, pegue el archivo correspondiente de `instructions/` directamente en Instructions.
6. Cree el host de compilación aprobado desde `../skills/ppt-html-vba-compiler/vba/`; consulte `references/compiler-host.md`.
7. Pruebe en privado con `../ppt-html/examples/sample-deck/deck.html`, revise el inventario de objetos y publique tras la aprobación humana.

Los Prompts normativos se mantienen en inglés para servir a un entorno multilingüe controlado; los Agents responden en el idioma del usuario. Puede traducir las etiquetas, pero no las rutas, los marcadores, las claves Schema, los comandos ni las versiones.

## Flujo de ejecución

Contexto del usuario → Authoring Agent → PPT-HTML restringido y manifest → VBA compiler fijo → objetos nativos de PowerPoint → QA Agent → aprobación humana.

Copilot prepara, revisa y explica los artefactos; no debe afirmar que ejecutó VBA. El contenido externo de GitHub permanece en cuarentena hasta verificar procedencia y licencia, probarlo, aprobarlo y publicar una versión interna inmutable.
