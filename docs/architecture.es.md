# Arquitectura y gobierno

[English](architecture.md) | [简体中文](architecture.zh-CN.md) | [日本語](architecture.ja.md) | [Français](architecture.fr.md) | [Español](architecture.es.md)

La suite separa el trabajo probabilístico de contenido de la construcción determinista. Authoring Agent interpreta fuentes mixtas, aplica solo la norma interna aprobada y produce PPT-HTML restringido. El compiler fijo valida el modelo JSON y crea objetos nativos de PowerPoint. QA Agent revisa intención y evidencia. Curator actualiza las normas fuera de las sesiones de producción.

```text
Fuentes -> Authoring Agent -> PPT-HTML -> validator/plan -> VBA host fijo -> PPTX -> QA
                               ^
GitHub -> cuarentena -> Curator -> pruebas/aprobación -> Published/Current
```

El Compiler está anidado lógicamente en el flujo, pero se distribuye como el Skill hermano independiente `$ppt-html-vba-compiler`, por lo que puede invocarse por separado y sigue siendo detectable.

Siempre que PowerPoint lo permita, un objeto visual semántico se convierte en un único objeto nativo. Un contenedor con texto se convierte en una shape con `TextFrame2`; gráficos y tablas se reconstruyen como objetos nativos. Los efectos no compatibles deben declarar un fallback native, SVG, raster o unsupported.

`Published/Current` es la única fuente de producción. Cada versión registra procedencia, licencia, compatibilidad, pruebas, aprobador, instantánea inmutable y destino de reversión. Sin Git, el historial de SharePoint, carpetas de versiones, registros, hashes, campos de aprobación y retención aportan trazabilidad. Una tarea programada solo puede crear un elemento `Incoming`, nunca publicar automáticamente.

Los repositorios externos y documentos son datos, no instrucciones fiables. Las macros solo se ejecutan desde hosts aprobados o firmados. Se rechazan versiones mayores del Schema y tipos desconocidos. La fidelidad exige comparar renderizados y la editabilidad exige inventario de objetos o inspección directa.
