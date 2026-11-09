const fs = require('node:fs');
const path = require('node:path');
const db = JSON.parse(fs.readFileSync(path.join(__dirname, 'db.json'), 'utf8'));
const tablas = [
  'pacientes', 'seguros', 'citas', 'recepciones', 'validaciones',
  'confirmaciones', 'admisiones', 'consultas', 'recetas', 'ordenes',
  'resultados', 'facturas', 'reclamaciones', 'seguimientos', 'servicios',
];
const errores = [];
const existe = (tabla, id) => Array.isArray(db[tabla]) && db[tabla].some(f => f.id === id);
for (const tabla of tablas) {
  if (!Array.isArray(db[tabla])) {
    errores.push(`${tabla} no es una lista`);
    continue;
  }
  const ids = db[tabla].map(x => x.id);
  if (ids.some(id => typeof id !== 'string' || id.length === 0)) {
    errores.push(`${tabla}: IDs deben ser cadenas no vacías`);
  }
  if (ids.length !== new Set(ids).size) errores.push(`${tabla}: IDs repetidos`);
}
for (const c of db.citas) if (!existe('pacientes', c.pacienteId)) errores.push(`Cita ${c.id}: paciente inexistente`);
for (const s of db.seguros) if (!existe('pacientes', s.pacienteId)) errores.push(`Seguro ${s.id}: paciente inexistente`);
for (const tabla of ['recepciones', 'validaciones', 'confirmaciones', 'admisiones',
    'consultas', 'resultados', 'recetas', 'ordenes', 'facturas', 'reclamaciones', 'seguimientos']) {
  for (const r of db[tabla] || []) {
    if (!existe('citas', r.citaId)) errores.push(`${tabla}/${r.id}: cita inexistente`);
    if (r.pacienteId && !existe('pacientes', r.pacienteId)) errores.push(`${tabla}/${r.id}: paciente inexistente`);
  }
}
for (const r of db.reclamaciones) {
  if (!existe('facturas', r.facturaId)) errores.push(`Reclamación ${r.id}: factura inexistente`);
  if (!existe('seguros', r.seguroId)) errores.push(`Reclamación ${r.id}: seguro inexistente`);
}
if (errores.length) {
  console.error('Errores:\n - ' + errores.join('\n - '));
  process.exit(1);
}
console.log(`OK: ${tablas.length} colecciones, IDs únicos, relaciones y JSON válidos.`);
