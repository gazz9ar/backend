const Election = artifacts.require("Election");
var Web3 = require('web3');

contract("Election", function (accounts) {
  
  it("should assert true", async function () {
    const contract = await Election.deployed();	
    return assert.notEqual(contract.address,'0x0000000000000000000000000000000000000000');
  });

  it("should verify candidate has/pays 1 ether", async function () {
    const contract = await Election.deployed();

    const candidateAddress = accounts[1]; 
    
    try {     
        await contract.payFee({ from: candidateAddress, value: Web3.utils.toWei('1', 'ether')});      
    } catch (error) {
        return assert.fail();
    }
    return assert.isOk(true);
  });

  it("should check election is in state 'Created'", async function () {
    const contract = await Election.deployed();	
    let contractState;

    await contract.state().then(( state ) => {        
        contractState = state;
    });
   
    return assert.equal(contractState,0); // 0 = State.Created
  });

});