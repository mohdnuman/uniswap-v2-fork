const LiquidityMigrator=artifacts.require("LiquidityMigrator.sol");
const BonusToken=artifacts.require("BonusToken.sol");




module.exports=async function(deployer,network,addresses){
    await deployer.deploy(BonusToken);
    const bonusToken=await BonusToken.deployed();

    const routerAddress="";
    const pairAddress="";
    const routerForkAddress="";
    const pairForkAddress="";

    await deployer.deploy(
        LiquidityMigrator,
        routerAddress,
        pairAddress,
        routerForkAddress,
        pairForkAddress,
        bonusToken.address
    );

    const liquidityMigrator=await LiquidityMigrator.deployed();
    await bonusToken.setLiquidator(liquidityMigrator.address);
}