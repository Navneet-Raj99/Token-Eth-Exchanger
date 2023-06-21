const Token = artifacts.require("Token")
require('chai').use(require('chai-as-promised')).should();

const tokenf = (n) => {
    return web3.utils.BN(
        web3.utils.toWei(n.toString(), 'ether')
    )

}
contract('Token', ([deployer, receiver, exchange]) => {
    let token;
    beforeEach(async () => {
        token = await Token.new();

    })
    describe('deployment', () => {

        it('tracks the name', async () => {

            const name = await token.name();
            name.should.equal('navneet');

        })
        it('tracks the symbol', async () => {

            const name = await token.decimal();
            name.toString().should.equal('18');

        })
        it('tracks the decimals', async () => {

            const name = await token.symbol();

            name.should.equal('DApp');

        })
        it('tracks the totalSupply', async () => {

            const name = await token.totalSupply();
            name.toString().should.equal(tokenf(1000000).toString());

        })
        // it('tracks the balance', async () => {

        //     const name = await token.balanceOf(deployer);
        //     name.toString().should.equal(tokenf(1000000).toString());

        // })

    })
    describe('succekss', () => {
        let result;
        beforeEach(async () => {
            result = await token.transfer(receiver, tokenf(1000).toString(), { from: deployer });

        })
        it('transferbalance', async () => {
            let balanceOf;
            // token = await Token.new();

            balanceOf = await token.balanceOf(deployer);
            console.log(balanceOf.toString(), "A");

            balanceOf = await token.balanceOf(receiver);
            console.log(balanceOf.toString(), "B");

            await token.transfer(receiver, tokenf(1000), { from: deployer });

            balanceOf = await token.balanceOf(receiver);
            console.log(balanceOf.toString(), "A");

            balanceOf = await token.balanceOf(deployer);
            console.log(balanceOf.toString(), "B");

        })
        it("emit event", () => {
            // console.log(result.logs[0].args);
            let log = result.logs[0];
            log.event.should.equal('Transfer');
            const event = log.args;
            event.from.toString().should.equal(deployer);
            event.to.toString().should.equal(receiver);

        })

    })

    describe('approve token', () => {
        console.log(exchange);
        let amount2;
      let result;
        beforeEach(async () => {
            // token= await Token.new()
            //   console.log("hello")
            amount2 = tokenf(100);
            result = await token.approve(exchange, amount2, { from: deployer });

        })
        describe('success', () => {
            it ('allocates token spending', async () => {
                const allowanc2e = await token.allowance(deployer, exchange);
                allowanc2e.toString().should.equal(amount2.toString());
            });
        })
        describe('failed', () => {
            // console.log("hello navneet bye bye")
        })
    })

    // describe('failure', async () => {
    //     it('reject', async () => {
    //         let amount = tokenf(10000000);
    //         await token.transfer(receiver, amount, { from: deployer }).should.be.rejectedWith("VM Exception while processing transaction")

    //         amount = tokenf(10);
    //         await token.transfer(deployer, amount, { from: receiver }).should.be.rejectedWith("VM Exception while processing transaction")

    //         await token.transfer(0x0, amount, { from: deployer }).should.be.rejected;
    //     })
    // })

})