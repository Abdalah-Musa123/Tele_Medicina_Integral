# Guía práctica de exposición (sin diapositivas)

## Antes de la grabación

1. Ejecutar `npm start` dentro de `api/`; comprobar `http://localhost:3000/pacientes`.
2. Ejecutar `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000` desde la raíz.
3. Entrar con **demo / 1234** y seleccionar un rol de demostración.
4. Para mostrar cierre y seguimiento inmediatamente, elegir la cita **c2 (Luis Gómez, demo)**. Tiene consulta `realizada` sin factura ni seguimiento.
5. Si todos los datos de la práctica fueron modificados, detener la API y ejecutar `npm run reset` desde `api/`.
6. Mostrar **pantalla real funcionando** y luego el **archivo de código correspondiente en VS Code**.

## Secuencia recomendada de la demostración

| Tiempo aproximado | Acción visible | Archivo que se puede explicar |
|---|---|---|
| 0:00–0:30 | Login con rol + panel de las 10 etapas | `lib/main.dart`, `login_screen.dart`, `inicio_screen.dart` |
| 0:30–1:30 | Crear cita por el portal, recibir, validar seguro y agendar | `lib/features/proceso/ui/proceso_screen.dart` |
| 1:30–2:30 | Confirmación, consentimiento, simulación de videollamada y resultados | `lib/features/proceso/ui/proceso_screen.dart` |
| 2:30–3:30 | Factura, reclamación, pago y seguimiento | `lib/features/administracion/ui/administracion_screen.dart` |
| 3:30–4:15 | Abrir `http://localhost:3000/facturas` y mostrar el guardado | `lib/core/repositorio/api_client.dart`, `api/db.json` |
| 4:15–4:45 | Catálogo y arquitectura | `servicios_screen.dart`, `docs/diagramas/arquitectura.png` |

### Explicación que deben dominar

- **Flutter** crea la interfaz; **Dart** implementa la lógica.
- `ProviderScope` conecta **Riverpod** con el árbol de widgets.
- `FutureProvider<PanelDatos>` solicita los datos al repositorio; `ref.invalidate` vuelve a consultarlos después de guardar.
- `TelemedicinaRepository` separa la lógica de acceso a datos de la interfaz.
- `ApiClient` convierte Dart a JSON y hace peticiones HTTP a `json-server`.
- `db.json` contiene los datos ficticios; al registrar un pago cambia `facturas[].estado` a `pagada`.
- La cámara, el pago, el seguro, los recordatorios y el login son **simulados**; no hay conexiones externas reales.

## Para capturas auténticas

- **P1**: login, panel, `main.dart`, `session_provider.dart`.
- **P2**: formularios de los pasos 1 y 3, registro de cita en JSON.
- **P3**: vista de videollamada y formulario de receta/orden.
- **P4**: factura creada, estado `pagada` y seguimiento con encuesta.
- **P5**: catálogo y diagramas PNG ya incluidos.

No afirmes que se realizaron acciones reales con seguros, bancos o pacientes. Tampoco presentes capturas del editor inventadas: toma las capturas al ejecutar el proyecto en tu equipo.
