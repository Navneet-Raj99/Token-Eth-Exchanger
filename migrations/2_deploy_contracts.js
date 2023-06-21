const Token = artifacts.require("Token");
const Exchange = artifacts.require("Exchange");
module.exports = async function (deployer) {
    let acc1 = await web3.eth.getAccounts();
    let feeacc = acc1[0];
    await deployer.deploy(Token);
    await deployer.deploy(Exchange, feeacc, 10);
}