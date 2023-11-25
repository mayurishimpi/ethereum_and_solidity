const path = require("path");
const fs = require("fs");
const solc = require('solc');
const reg = path.resolve(__dirname, 'Contracts', '_register.sol');
const registration = path.resolve(__dirname, 'Contracts', '_register.sol');
const source = fs.readFileSync(reg, 'utf8');

console.log(solc.compile(source,1).contracts[':Register']);
module.exports = solc.compile(source,1).contracts[':Register'];