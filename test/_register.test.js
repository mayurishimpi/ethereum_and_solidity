// Import necessary libraries for testing
const assert = require('assert');
const { Web3 } = require('web3');
const ganache = require('ganache');
const web3 = new Web3(ganache.provider());
const {interface, bytecode} = require('../compile')


let register;


let accounts
beforeEach(async () =>{
    accounts = await web3.eth.getAccounts();

   register =  await new web3.eth.Contract(JSON.parse(interface))
   .deploy( {data: bytecode})
   .send({from: accounts[0], gas: 1000000})
});

describe(" register",() =>{
    it("Deploys a contract", () =>{
        assert.ok(register.options.address);   
 });

   it('should check the balance of accounts', async () => {
    
    for (let i = 0; i < accounts.length; i++) {
      const balance = await web3.eth.getBalance(accounts[i]);
      console.log(`Balance of accounts[${i}]: ${balance} ETH`);}
  });

  
    
    it('should initialize score ledger', async () => {
      const borrower = accounts[9];
      console.log(borrower);
      const ficoScore = 750;
      const timestamp = Math.floor(Date.now() / 1000);
      console.log('Before transaction');
      const isUnusedBefore = await register.methods.verifyUnusedAddress(borrower).call();
      console.log('Is Unused Before:', isUnusedBefore);


      console.log("sender: ", accounts[0]);
      await register.methods.initScoreLedger(borrower, ficoScore, timestamp).send({ from: accounts[0],
         gas : 1000000 }
        );
        console.log('After transaction');
        const isUnusedAfter = await register.methods.verifyUnusedAddress(borrower).call();
        console.log('Is Unused After:', isUnusedAfter);

      const score = await register.methods.getScore(borrower).call();
      const isUnused = await register.methods.verifyUnusedAddress(borrower).call();

      assert.equal(score, ficoScore, 'Score not set correctly');
      assert.ok(!isUnused, 'Address should be marked as initialized');
  });

  it('should verify unused address', async () => {
      const borrower = accounts[2];

      const isInitiallyUnused = await register.methods.verifyUnusedAddress(borrower).call();
      assert.ok(isInitiallyUnused, 'Address should be initially unused');

      const ficoScore = 720;
      const timestamp = Math.floor(Date.now() / 1000);

      await register.methods.initScoreLedger(borrower, ficoScore, timestamp).send({
          from: accounts[0],
          gas: '1000000'
      });

      const isUnusedAfterInit = await register.methods.verifyUnusedAddress(borrower).call();
      assert.ok(!isUnusedAfterInit, 'Address should not be unused after initialization');
  });
});
  


