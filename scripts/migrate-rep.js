const fs = require("fs");
const path = require("path");
const rpc = require("ethrpc");
const migrateRep = require("./lib/migrate-rep").migrateRep;

const LEGACY_REP_CONTRACT_UPLOAD_BLOCK = parseInt(process.env.LEGACY_REP_CONTRACT_UPLOAD_BLOCK, 10);
const REP_ADDRESS_FILE = path.join(__dirname, "..", "data", "all-rep-addresses.txt");

const allRepAddresses = fs.readFileSync(REP_ADDRESS_FILE, "utf8").split("\n");
console.log("Loaded", allRepAddresses.length, "addresses");

rpc.setDebugOptions({ connect: true, broadcast: false });

const startTime = Date.now();

rpc.connect({
  httpAddresses: ["http://127.0.0.1:8545"],
  wsAddresses: ["ws://127.0.0.1:8546"],
  ipcAddresses: ["/home/jack/.ethereum-1/geth.ipc"],
  errorHandler: () => {}
}, () => {
  migrateRep(rpc, allRepAddresses, (err) => {
    console.log("Time elapsed:", (Date.now() - startTime) / 1000 / 60, "minutes");
    if (err) console.error(err);
    process.exit(0);
  });
});