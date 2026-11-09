const fs = require('node:fs');
const path = require('node:path');
const origen = path.join(__dirname, 'db.seed.json');
const destino = path.join(__dirname, 'db.json');
fs.copyFileSync(origen, destino);
console.log('Datos de demostración restaurados en db.json.');
