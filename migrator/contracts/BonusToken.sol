pragma solidity=0.6.6;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract BonusToken is ERC20{
    address public admin;
    address public liquidator;
    
    constructor() ERC20('Bonus Token','BTK') public{
        admin=msg.sender;
    }

    function setLiquidator(address _liquidator) external{
        require(msg.sender==admin,"Only admin!");
        liquidator=_liquidator;
    }

    function mint(address to,uint amount) external{
        require(msg.sender==liquidator,"Only liquidator!");
        _mint(to,amount);
    }
}

