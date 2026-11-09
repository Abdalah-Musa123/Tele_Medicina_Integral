# Contrato API REST · TeleSalud (simulada)

**Base:** `http://localhost:3000`

| Colección | Uso | Campos principales |
|---|---|---|
| `pacientes` | Solicitud | `id`, `nombre`, `correo`, `telefono`, `seguroId` |
| `seguros` | Validación | `pacienteId`, `aseguradora`, `numeroAfiliacion`, `coberturaPorcentaje`, `autorizacion`, `vigente` |
| `citas` | Pasos 1–8 | `id`, `pacienteId`, `fechaHora` (ISO), `motivo`, `estado`, `medico`, `canal` |
| `recepciones` | Paso 2 | `citaId`, `pacienteId`, `motivoConfirmado`, `observaciones`, `fechaRecepcion` |
| `validaciones` | Paso 3 | `citaId`, `seguroId`, `coberturaPorcentaje`, `resultado`, `autorizacion` |
| `confirmaciones` | Paso 5 | `citaId`, `canal`, `mensaje`, `fechaConfirmacion` |
| `admisiones` | Paso 6 | `citaId`, `consentimiento`, `identificacion` |
| `consultas` | Paso 7 | `citaId`, `medio`, `estado`, `fechaFinalizacion` |
| `recetas` | Paso 8 | `citaId`, `medicamentos` (lista), `instrucciones`, `fecha` |
| `ordenes` | Paso 8 | `citaId`, `tipo`, `descripcion`, `estado` |
| `resultados` | Paso 8 | `citaId`, `referimiento`, `fecha` |
| `facturas` | Paso 9 | `citaId`, `pacienteId`, `subtotal`, `total`, `estado`, `metodoPago`, `fechaEmision`, `fechaPago` |
| `reclamaciones` | Paso 9 | `citaId`, `facturaId`, `seguroId`, `montoReclamado`, `estado`, `fechaEnvio` |
| `seguimientos` | Paso 10 | `citaId`, `pacienteId`, `fechaRecordatorio`, `canal`, `encuestaPuntuacion`, `encuestaComentario`, `proximaCita`, `estado` |
| `servicios` | Catálogo | `nombre`, `categoria`, `descripcion` |

## Ejemplos

Crear cita:

```http
POST /citas
Content-Type: application/json

{"pacienteId":"p1","fechaHora":"2026-11-10T10:00:00","motivo":"Consulta de demostración","estado":"solicitada","medico":"Por asignar","canal":"Portal"}
```

Actualizar estado de cita:

```http
PATCH /citas/c3
Content-Type: application/json

{"estado":"confirmada"}
```

Registrar el pago de una factura simulada:

```http
PATCH /facturas/f1
Content-Type: application/json

{"estado":"pagada","fechaPago":"2026-11-10"}
```

**Convención:** `json-server` genera identificadores `id` tipo cadena para nuevos registros enviados sin `id`. Los registros semilla usan IDs como `p1`, `c1`, `f1`. Eviten relaciones por nombres de pacientes; utilicen siempre `...Id`. Si un formulario de otra persona usa un campo diferente, ajustarlo mediante este contrato, no duplicar una colección paralela.
