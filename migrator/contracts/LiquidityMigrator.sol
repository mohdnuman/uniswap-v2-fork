pragma solidity=0.6.6;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapv2Router02.sol';
import './IUniswapV2Pair.sol';
import './BonusToken.sol';

contract LiquidityMigrator{
    IUniswapV2Router02 public router;
    IUniswapV2Pair public pair;
    IUniswapV2Router02 public routerFork;
    IUniswapV2Pair public pairFork;
    BonusToken public bonusToken;
    address public admin;
    mapping(address=>uint) public unclaimedBalances;
    bool public migrationDone;

    constructor(
        address _router,
        address _pair,
        address _routerFork,
        address _pairFork,
        address _bonusToken
    ) public {
        router=IUniswapV2Router02(_router);
        pair=IUniswapV2Pair(_pair);
        routerFork=IUniswapV2Router02(_routerFork);
        pairFork=IUniswapV2Pair(_pairFork);
        bonusToken=BonusToken(_bonusToken);
        admin=msg.sender;
    }

    function deposit(uint amount) external{
        require(migrationDone==false,"Migration already done!");
        pair.transferFrom(msg.sender,address(this),amount);
        bonusToken.mint(msg.sender,amount);
        unclaimedBalances[msg.sender]+=amount;
    }

    function migrate() external{
        require(msg.sender==admin,"Only admin!");
        require(migrationDone==false,"Migration already done!");
        IERC20 token0=IERC20(pair.token0());
        IERC20 token1=IERC20(pair.token1());
        uint totalBalance=pair.balanceOf(address(this));
        router.removeLiquidity(
            address(token0),
            address(token1),
            totalBalance,
            0,
            0,
            address(this),
            block.timestamp
        );


        uint token0balance=token0.balanceOf(address(this));
        uint token1balance=token1.balanceOf(address(this));
        token0.approve(address(routerFork),token0balance);
        token1.approve(address(routerFork),token1balance);
        routerFork.addLiquidity(
            address(token0),
            address(token1),
            token0balance,
            token1balance,
            token0balance,
            token1balance,
            address(this),
            block.timestamp
        );
        migrationDone=true; 
    }

     function claimLptokens() external{
            require(migrationDone==true,"Migration not done yet!");
            require(unclaimedBalances[msg.sender]>=0,"No unlciamed balance");
            uint amountToSend=unclaimedBalances[msg.sender];
            unclaimedBalances[msg.sender]=0;
            pairFork.transfer(msg.sender,amountToSend);
        }


}