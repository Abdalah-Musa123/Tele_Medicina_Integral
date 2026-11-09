# Cómo repartir y revisar el código integrado

| Persona | Archivos principales | Demostración |
|---|---|---|
| 1 | `lib/main.dart`, `lib/core/providers/session_provider.dart`, `lib/features/auth/login_screen.dart`, `lib/features/inicio/inicio_screen.dart` | Login por rol, navegación, tema y Riverpod |
| 2 | `lib/features/proceso/ui/proceso_screen.dart`: casos 1, 2, 3 y 4 | Formulario, recepción, seguro y agenda |
| 3 | `lib/features/proceso/ui/proceso_screen.dart`: casos 5, 6, 7 y 8 | Confirmación, consentimiento, videollamada simulada, resultado |
| 4 | `lib/core/modelos/*.dart`, `lib/core/repositorio/*.dart`, `lib/features/administracion/ui/administracion_screen.dart`, `api/` | REST, modelos, factura, reclamación, pago, encuesta y seguimiento |
| 5 | `lib/features/servicios/servicios_screen.dart`, `docs/diagramas/` | Catálogo, UML, arquitectura y flujo |

**Nota para integración:** todos estos archivos forman **una sola aplicación**. Si una persona abre otro proyecto en Android Studio, no se deben copiar sus archivos encima de este proyecto sin comparar primero modelos, dependencias y rutas de navegación.
