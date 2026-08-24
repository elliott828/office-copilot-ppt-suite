# Uso de los Skills

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [Français](README.fr.md) | [Español](README.es.md)

Copie cualquiera de los directorios completos en la ubicación Skills de un entorno compatible con `SKILL.md`:

- `office-copilot-ppt-orchestrator` configura los Agents de Copilot, la biblioteca, el gobierno, el contrato de autoría y el QA.
- `ppt-html-vba-compiler` valida PPT-HTML de forma independiente, crea un plan determinista e invoca un VBA host fijo aprobado cuando está disponible.

```text
Use $office-copilot-ppt-orchestrator to prepare this tenant's deployment bundle.
Use $ppt-html-vba-compiler to validate deck.html and compile it with the approved host.
```

El Orchestrator puede entregar HTML validado al Compiler, pero los directorios permanecen al mismo nivel porque no todos los entornos detectan Skills anidados. El Compiler no debe rediseñar diapositivas, adivinar tipos desconocidos, inyectar VBA nuevo por documento ni afirmar que compiló sin evidencia.

Los usuarios de Microsoft 365 Copilot no instalan estos Skills. Utilizan los archivos de `../office-copilot/`; los mismos contratos se internalizan mediante Agent Instructions y conocimiento de SharePoint.
