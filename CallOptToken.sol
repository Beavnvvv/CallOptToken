//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract CallOptToken is ERC20, Ownable {
  using SafeERC20 for IERC20;
  address public udsc;
  uint public settlementTime;//开始行权
  uint public constant during = 5 days; // 行权期限
  uint ethprice;
  
  constructor(address _usdc) ERC20("CallOptToken", "AAA") {
    udsc = _usdc;
    ethprice = 3000;  
    settlementTime = block.timestamp + 10 days;
  }

  function mint() external payable onlyOwner {
    _mint(msg.sender,  msg.value);
  }
  
  function settlement(uint amount) external {
    require(block.timestamp >= settlementTime && block.timestamp < settlementTime + during, "invalid time");

    _burn(msg.sender, amount);

    uint UsdcAmount = ethprice * amount; 
    // 行权资金
    IERC20(udsc).safeTransferFrom(msg.sender, address(this), UsdcAmount);
    safeTransferETH(msg.sender, amount);
  }

  function safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{value: value}(new bytes(0));
    require(success, '');
  }

  function burnAll() external onlyOwner {
    require(block.timestamp >= settlementTime + during, "still ing");
    uint usdcAmount = IERC20(udsc).balanceOf(address(this));
    IERC20(udsc).safeTransfer(msg.sender, usdcAmount);
    selfdestruct(payable(msg.sender));
  }
}