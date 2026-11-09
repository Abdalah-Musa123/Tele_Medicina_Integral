# TeleSalud | Proyecto completo de Telemedicina (Flutter)

**Asignatura:** Arquitectura de Software · **Fecha de entrega indicada:** 10 de noviembre de 2026, 23:59.

Proyecto académico de código fuente para los **10 pasos** del proceso de telemedicina. Mantiene Flutter + Dart, estado con `flutter_riverpod`, repositorio HTTP y API REST simulada con `json-server`. Incluye cinco roles de demostración y catálogo de servicios. **No contiene diapositivas**, como se solicitó.

> Este simulador usa exclusivamente datos ficticios. No tiene autenticación real, cifrado clínico, integración bancaria/ARS, videollamada real, envío de mensajes ni validación de identidad. No está destinado a pacientes reales.

## 1. Requisitos

- Visual Studio **Code** con extensiones **Flutter** y **Dart**.
- **Flutter SDK** instalado y accesible con `flutter --version`.
- Navegador **Chrome** (recomendado para la primera exposición).
- **Node.js** (preferentemente versión 20 o superior) y `npm`.
- Conexión a internet en la primera instalación de dependencias.

> Importante: Visual Studio 2022 y Visual Studio Code son editores distintos. Este proyecto usa Flutter/Dart y se puede abrir desde **VS Code** o Android Studio.

## 2. Arranque en Windows / Visual Studio Code

1. Extrae el ZIP completo en una carpeta, por ejemplo `Documentos/telemedicina_integral`.
2. En VS Code selecciona **Archivo > Abrir carpeta** y abre **telemedicina_integral** (la carpeta que contiene `pubspec.yaml`).
3. Abre una terminal (`Terminal > Nueva terminal`) en la raíz y ejecuta **una sola vez**:

```powershell
flutter doctor
flutter create . --platforms=web,android
flutter pub get
```

El comando `flutter create .` genera los archivos nativos/web de Flutter (no se incluyen en el ZIP porque el SDK de Flutter no está instalado en el entorno de elaboración). Se conserva el código fuente `lib/` del equipo.

4. Abre **Terminal A** para la API:

```powershell
cd api
npm install
npm run check
npm start
```

Deja **Terminal A abierta**. Comprueba en Chrome: `http://localhost:3000/pacientes`.

5. Abre **Terminal B** en la carpeta raíz:

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

También se incluyen los accesos directos para Windows `iniciar_api.bat` e `iniciar_flutter_web.bat` (úsalos desde la raíz del proyecto). **Primero inicia la API y después la app.**

### Android (opcional)

Si usas el emulador de Android en la misma PC:

```powershell
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

Confirma el identificador del emulador con `flutter devices`. Android puede requerir configuración de permisos y tráfico HTTP local según la versión; para exponer, Chrome es la ruta más sencilla. En un teléfono físico, reemplaza `localhost` por la IP LAN del PC y configura el firewall/servidor LAN.

## 3. Acceso y recorrido de demostración

1. Selecciona **Paciente**, **Admisión**, **Médico**, **Apoyo y tecnología** o **Facturación**. Las credenciales ficticias son **demo / 1234** (acceso simulado, sin seguridad real).
2. En el panel principal, encontrarás diez tarjetas numeradas que abren todas las etapas.
3. Paso 1: crea una cita nueva y un paciente de demostración.
4. Pasos 2 a 4: recepción, seguro (puedes asociar una ARS ficticia al paciente nuevo o dejarlo pendiente) y agenda.
5. Pasos 5 a 6: confirmación y consentimiento.
6. Pasos 7 a 8: videollamada **simulada** y receta/orden/referimiento **ficticios**.
7. Pasos 9 a 10: genera factura, registra reclamación, simula pago y programa seguimiento.
8. Abre `http://localhost:3000/citas` o `http://localhost:3000/facturas` para comprobar la persistencia.

**Atajo para grabar un video:** la cita **c2** del paciente **Luis Gómez (demo)** ya está marcada como `realizada` y **no tiene factura ni seguimiento**. Puedes entrar al paso 9, seleccionarla y demostrar todo el cierre y seguimiento de manera inmediata. La cita c1 dispone de una factura y un seguimiento predefinidos.

## 4. Cobertura funcional y responsables

| Persona | Módulo | Pantallas / código |
|---|---|---|
| 1 | Base y arquitectura | `lib/main.dart`, `lib/core/`, login por roles, panel, Riverpod |
| 2 | Pasos 1–4 | `lib/features/proceso/ui/proceso_screen.dart` (1–4) |
| 3 | Pasos 5–8 | `lib/features/proceso/ui/proceso_screen.dart` (5–8) |
| 4 | Modelos, API, pasos 9–10 | `lib/core/modelos/`, `lib/core/repositorio/`, `api/`, `lib/features/administracion/` |
| 5 | Servicios y diagramas | `lib/features/servicios/`, `docs/diagramas/` |

Las funcionalidades están desarrolladas como una **integración única**, no como cinco aplicaciones separadas. **Las diapositivas y el video grabado por los integrantes no se incluyen**, ya que el usuario excluyó las diapositivas y el video requiere la participación real del grupo.

## 5. Arquitectura

```text
main.dart → ProviderScope (Riverpod)
            ↓
       Presentación/UI (login, inicio, proceso, facturación, servicios)
            ↓
       Providers (sesión y panel de datos)
            ↓
       Repositorio (TelemedicinaRepository)
            ↓
       ApiClient (HTTP: GET/POST/PATCH)
            ↓
       json-server (API REST puerto 3000)
            ↓
       api/db.json (15 colecciones)
```

- **Modelo**: estructuras Dart para `Cita`, `Paciente`, `Seguro`, `Receta`, `OrdenMedica`, `Factura`, `Reclamacion`, `Seguimiento`.
- **Vista**: pantallas y componentes Flutter Material 3.
- **Estado**: Riverpod (`Provider`, `FutureProvider`, `StateProvider`).
- **Repositorio**: centraliza las operaciones de red, evita mezclar HTTP con widgets.
- **Backend simulado**: `json-server` persiste cambios en `db.json`.

Consulta `docs/ARQUITECTURA.md`, `docs/ARCHIVOS_POR_PERSONA.md`, `docs/GUIA_DEMO_Y_EXPOSICION.md` y `docs/diagramas/`.

## 6. Rutas de la API

Los endpoints admiten `GET` de colección y `GET /<coleccion>/<id>`; las colecciones usadas por los formularios admiten `POST`, y `citas`, `facturas`, `seguimientos` admiten `PATCH`:

```text
/pacientes       /seguros          /citas
/recepciones     /validaciones     /confirmaciones
/admisiones      /consultas        /resultados
/recetas         /ordenes          /facturas
/reclamaciones   /seguimientos     /servicios
```

Los campos y ejemplos están en `docs/CONTRATO_API.md` y `api/db.seed.json`.

## 7. Pruebas

```powershell
npm --prefix api run check
flutter analyze
flutter test
```

Prueba HTTP opcional (requiere que la API esté encendida):

```powershell
npm --prefix api test
```

Restaurar datos de ejemplo: **detén la API**, y luego ejecuta:

```powershell
npm --prefix api run reset
```

**Cuidado:** el reset reemplaza todos los registros actuales por los ficticios iniciales.

## 8. Integración con el repositorio del grupo

- Usen una sola copia del proyecto y un solo `pubspec.yaml`; mantengan las versiones compatibles de Flutter y paquetes.
- No sobrescriban `lib/main.dart` de un compañero sin acordar quién lo mantiene.
- Todos deben compartir los identificadores `citaId`, `pacienteId`, `seguroId`, `facturaId`.
- Los módulos y la API de este ZIP ya están conectados entre sí. Si otro compañero utiliza otras tecnologías, debe acordarse el contrato de la API antes de reemplazar nada.
- Eviten subir `api/node_modules` y `build/` a OneDrive; sí suban `lib/`, `pubspec.yaml`, `api/*.json`, `api/*.js`, `docs/` y los archivos generados de plataforma si les piden el proyecto Flutter íntegro.

## 9. Estado de comprobación

Se comprobó la **validez de `api/db.json` y sus relaciones**, y se incluyen pruebas Dart y de contrato REST para ejecutar localmente. **No se ha ejecutado `flutter analyze`, `flutter test` ni compilado la aplicación en este entorno**, porque no dispone del SDK de Flutter ni acceso de red para instalarlo. Debes validar esos comandos en tu PC antes de la grabación; si aparece un error de compilación, comparte el mensaje exacto para corregirlo.

## 10. Fuentes / bibliografía

Ver `docs/BIBLIOGRAFIA.md`: documentación oficial Flutter, Dart, Riverpod, `http`, `json-server`.
