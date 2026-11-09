# Arquitectura del simulador y de Flutter

## Arquitectura técnica de Flutter

- **Framework**: widgets Material, navegación, `StatefulWidget`, `ConsumerWidget` y composición de interfaz en Dart.
- **Engine**: núcleo de renderizado, texto y ejecución. En web, Flutter usa el renderizador correspondiente del navegador.
- **Embedder**: integración con la plataforma anfitriona (Chrome/Android), entrada y ventana.

## Arquitectura de nuestra app

1. `UI`: pantallas por funcionalidad, formularios, controles y avisos.
2. `Provider`: `ProviderScope` y Riverpod; sesión por rol y recarga del panel.
3. `Repositorio`: `TelemedicinaRepository`, operaciones de lectura y escritura sobre las colecciones REST.
4. `API`: `ApiClient`, manejo de JSON, HTTP y errores.
5. `Datos`: `json-server` con `api/db.json`.

El ciclo de datos es: **acción del usuario → repositorio → HTTP → json-server → JSON persistido → invalidación de provider → UI actualizada**.

## Patrones

- Capas: presentación, gestión de estado, acceso a datos.
- Repositorio: encapsula las consultas de cada colección.
- Inyección de dependencias: providers permiten sustituir el cliente HTTP en pruebas.
- Separación de responsabilidades: los widgets no guardan archivos JSON ni contienen URLs codificadas.

## Roles de la demo

El login simulado usa las credenciales ficticias `demo / 1234` y presenta los cinco roles definidos por el enunciado. El rol cambia la etiqueta de la sesión, **pero no establece control de acceso real**; las pantallas se pueden recorrer con cualquier rol para facilitar las pruebas. No debe presentarse como seguridad de producción.

## Entidades / relaciones principales

- `Paciente (1) → (N) Cita`
- `Paciente (0..1) → (1) Seguro` en la muestra
- `Cita (1) → (0..N) Receta / Orden / Resultado`
- `Cita (1) → (0..1) Factura` desde la interfaz
- `Factura (1) → (0..1) Reclamación` desde la interfaz
- `Cita (1) → (0..1) Seguimiento` desde la interfaz

## Limitaciones explícitas

El prototipo no integra servicios médicos de producción; `json-server` no proporciona por sí solo permisos, seguridad de datos de salud, auditoría o autenticación profesional. Los valores clínicos, pagos y autorizaciones son ficticios.
