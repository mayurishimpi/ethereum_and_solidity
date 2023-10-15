const path = require("path");
const fs = require("fs");
const solc = require('solc');
const coinflip = path.resolve(__dirname, 'Contracts', '_coinFlip.sol');
const source = fs.readFileSync(coinflip, 'utf8');
module.exports = solc.compile(source,1).contracts[':CoinFlip'];