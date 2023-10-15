const assert = require('assert');
const { Web3 } = require('web3');
const ganache = require('ganache');
const web3 = new Web3(ganache.provider());
const {interface, bytecode} = require('../compile')
let flip;
class Car{
    park()
    {
        return "stopped";
    }
    drive(){
        return "vroom";
    }
}

let accounts
beforeEach(async () =>{
    //  Get a list of all accounts
    //  Use one of those accounts to deploy
   accounts = await web3.eth.getAccounts();

   flip =  await new web3.eth.Contract(JSON.parse(interface))
   .deploy( {data: bytecode, arguments:[accounts[1], accounts[2]]})
   .send({from: accounts[0], gas: 1000000})
});

describe("Coin Flip",() =>{
    it("Deploys a contract", () =>{
        assert.ok(flip.options.address);   
 });

 it('should add 1 ether to the contract balance', async function () {
    const initialBalance = await web3.eth.getBalance(flip.options.address);
    const amountToSend = web3.utils.toWei('1', 'ether');
    await flip.methods.addEther().send({ from: accounts[0], value: amountToSend });
    const newBalance = await web3.eth.getBalance(flip.options.address);

    assert.equal(
      newBalance - initialBalance,
      amountToSend,
      'Balance was not updated correctly'
    );
  });

  it('should distribute the contract balance to player1 or player2 when distributeEther is called', async () => {
    const initialBalance = await web3.eth.getBalance(flip.options.address);
    const amountToSend = web3.utils.toWei('1', 'ether');
    const player1BalanceBefore = await web3.eth.getBalance(accounts[1]);
    const player2BalanceBefore = await web3.eth.getBalance(accounts[2]);
    console.log("Player 1 balance before:", player1BalanceBefore);
    console.log("Player 2 balance before:", player2BalanceBefore)
    // Add 1 ETH to the contract balance
    await flip.methods.addEther().send({ from: accounts[0], value: amountToSend });
  
    // Call distributeEther
    await flip.methods.distributeEther().send({ from: accounts[0] });
  
    const player1BalanceAfter = await web3.eth.getBalance(accounts[1]);
    const player2BalanceAfter = await web3.eth.getBalance(accounts[2]);
    console.log("Player 1 balance after:", player1BalanceAfter);
    console.log("Player 2 balance after:", player2BalanceAfter)
    const newBalance = await web3.eth.getBalance(flip.options.address);
  
    assert.equal(newBalance, 0, 'Balance was not reset to 0');
    // assert.equal(
    //   player1BalanceAfter - player1BalanceBefore,
    //   amountToSend,
    //   'Player 1 did not receive the correct amount'
    // );
    // assert.equal(
    //   player2BalanceAfter - player2BalanceBefore,
    //   amountToSend,
    //   'Player 2 did not receive the correct amount'
    // );
    
  });
  


});