const Exchange = artifacts.require('Exchange');
require('chai').use(require('chai-as-promised')).should();
const Token = artifacts.require('Token');

const tokenf = (n) => {
    return web3.utils.BN(
        web3.utils.toWei(n.toString(), 'ether')
    )

}

contract('Exchange', ([deployer, feeaccount, user1]) => {
    let exchange;
    let feepercent;
    let token;
    beforeEach(async () => {
        feepercent = 10
        token = await Token.new();
        exchange = await Exchange.new(feeaccount, feepercent);
        token.transfer(user1, tokenf(50), { from: deployer });
    })
    describe('deployment', () => {
        it('track fee account', async () => {
            const result = await exchange.feeaccount();
            result.should.equal(feeaccount);

        })
        it('track fee percent', async () => {
            const result = await exchange.feepercent();
            result.toString().should.equal(feepercent.toString());
        })

    })
    describe('depositing token', () => {
        let amount = tokenf(10);
        beforeEach(async () => {
            await token.approve(exchange.address, tokenf(50), { from: user1 });
            const result = await exchange.depositToken(token.address, tokenf(10), { from: user1 })
        })
        // describe('success', () => {
            it('exchange', async () => {
                let balance = await token.balanceOf(exchange.address);
                balance.toString().should.equal(amount.toString());

                //check token for particular user in the exchange
                // balance = await exchange.tokens(exchange.address, user1);
            })
        // })
        describe('deposit ether',async()=>
        {
            it('send Ether',async()=>
            {
                await exchange.depositETHER({from:user1, value:tokenf(5)});
                // let log= result.logs[0];
                // log.event.should.equal('Deposit');
                // const event= log.args
                // // const amount= event.amount;
                // console.log(event);
                // console.log(amount.toString());
                // console.log(result.logs[0].args.token);

            })
            })
        describe('failure', () => {

        })
    })
})