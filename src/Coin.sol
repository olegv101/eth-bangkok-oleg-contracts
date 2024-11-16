// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Coin is ERC20, Ownable, ERC20Permit {
  mapping(address => bool) public whitelist;

  constructor() Ownable(msg.sender) ERC20(unicode"💵", unicode"💵") ERC20Permit(unicode"💵") {
    _mint(msg.sender, 1_000_000 * 10 ** decimals());
  }

  function mint(
    address to,
    uint256 amount
  ) public {
    _mint(to, amount);
  }

  function burn(
    address from,
    uint256 amount
  ) public {
    _burn(from, amount);
  }
}
