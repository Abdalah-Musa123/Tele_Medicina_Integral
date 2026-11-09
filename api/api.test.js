// Pruebas de contrato HTTP. Requieren json-server en localhost:3000.
const assert = require('node:assert/strict');
const url = process.env.API_BASE_URL || 'http://localhost:3000';
async function req(path, options) {
  const r = await fetch(`${url}${path}`, options);
  assert.ok(r.ok, `${path} HTTP ${r.status}`);
  return r.json();
}
(async () => {
  const [pacientes, citas, facturas] = await Promise.all([
    req('/pacientes'), req('/citas'), req('/facturas')
  ]);
  assert.ok(pacientes.length >= 2);
  assert.ok(citas.some(c => c.pacienteId === pacientes[0].id));
  assert.ok(Array.isArray(facturas));
  const registro = await req('/recepciones', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({citaId:citas[0].id, pacienteId:pacientes[0].id,
      observaciones:'Prueba de contrato REST'}),
  });
  assert.ok(typeof registro.id === 'string' && registro.id.length > 0);
  const restaurado = await req(`/recepciones/${registro.id}`);
  assert.equal(restaurado.id, registro.id);
  const borrado = await fetch(`${url}/recepciones/${registro.id}`, {method:'DELETE'});
  assert.ok(borrado.ok);
  console.log('OK: API responde GET, POST, GET por ID y DELETE.');
})().catch(e => {console.error(e); process.exit(1);});
