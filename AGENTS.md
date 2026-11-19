# Directrices de Trabajo para Agentes — El Mercadito (`app_mercadito`)

Este proyecto cuenta con una arquitectura colegiada de desarrollo en Flutter/Dart con soporte proyectado hacia **PostgreSQL + PostgREST**. Todo agente que intervenga en cualquier solicitud dentro de este workspace debe cumplir obligatoriamente con las siguientes fuentes rectoras:

## 1. Documentos Rectores Obligatorios

1. **Memoria y Estatus del Proyecto**: [MEMORIA_PROYECTO.md](./MEMORIA_PROYECTO.md)
   - **Cuándo leer**: **Siempre** al iniciar cualquier solicitud de análisis, arquitectura, código o prueba, para entender el estatus actual, los módulos existentes y los contratos ya definidos.
   - **Cuándo actualizar**: **Siempre** al finalizar una solicitud aprobada por QA, actualizando el estatus del módulo y añadiendo una entrada en la *Bitácora de Evolución (Changelog)*.

2. **Arquitectura y Optimización de Base de Datos (PostgreSQL + PostgREST)**: [DesarrolloDB.md](./DesarrolloDB.md)
   - **Cuándo leer**: Siempre que el requerimiento implique persistencia, modelos de datos, repositorios, servicios de datos, consultas, reportes, analíticas o endpoints REST/RPC.
   - **Cuándo actualizar**: **Siempre** que se cree o modifique cualquier tabla, vista, función RPC, índice, política RLS o consulta PostgREST, aplicando estrictamente las mejores prácticas de proyección (`?select=`), embedding, paginación por cursor, indexación y RLS descritas en dicho documento.

3. **Regla Oficial de Parámetros de Diseño UI/UX**: [parametros-diseno.md](./.agents/rules/parametros-diseno.md)
   - **Cuándo leer**: **Siempre** que se diseñe o modifique cualquier pantalla, modal, bottom sheet o widget visual en Flutter.
   - **Cumplimiento**: Mantener estrictamente la tipografía (`Plus Jakarta Sans` y `Manrope`), paleta dual Día/Noche de `AppTheme`, etiquetas de calidad/categoría/venta, choice chips, botones (`48px` + `BouncingButton` + `SoundService`), inputs (`AnimatedErrorField`) y skeletons (`SkeletonScreenLoader`).

---

## 2. Flujo de Trabajo Obligatorio en Cada Solicitud

1. **Inicio (Contexto)**: Consultar `MEMORIA_PROYECTO.md` (+ `DesarrolloDB.md` y `.agents/rules/parametros-diseno.md` según aplique) antes de planificar o delegar.
2. **Ejecución Especializada**:
   - `lead-orchestrator`: Define contratos e incluye los requisitos de DB y diseño en las subtareas delegadas.
   - `backend-core-specialist`: Implementa lógica/datos en Dart puro desacoplado de UI y actualiza `DesarrolloDB.md` ante cualquier cambio de esquema o consulta PostgREST.
   - `frontend-specialist`: Construye UI responsiva fiel a `.agents/rules/parametros-diseno.md` y `AppTheme`.
   - `qa-tester`: Valida tests (`flutter test`), análisis estático (`dart analyze`), cumplimiento de diseño, contratos de DB y actualización de memoria.
3. **Cierre**: Ninguna solicitud se considera concluida hasta actualizar `MEMORIA_PROYECTO.md` (y `DesarrolloDB.md` si aplica) tras la aprobación de QA.
