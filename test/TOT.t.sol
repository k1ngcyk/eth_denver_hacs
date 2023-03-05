// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TOT.sol";

contract TOTTest is Test {
    TOT public tot;

    function setUp() public {
        tot = new TOT("https://ooo.do/tot/");
    }
}
