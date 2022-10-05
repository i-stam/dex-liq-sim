// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {UniswapV2Router01} from "../src/UniswapV2Router01.sol";
import {UniswapV2Pair} from "../src/UniswapV2Pair.sol";
import {UniswapV2Library} from "../src/libraries/UniswapV2Library.sol";

contract UniswapV2Router01Test is DSTest {

    UniswapV2Factory public factory;
    UniswapV2Router01 public router;
    address public pair;

    MockERC20 public token0;
    MockERC20 public token1;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function setUp() public {
        factory = new UniswapV2Factory(address(0));
        router = new UniswapV2Router01(address(factory));

        token0 = new MockERC20("Dollar", "USD", 18);
        token1 = new MockERC20("Exotic Token", "EXT", 18);

        pair = factory.createPair(address(token0), address(token1));

        token0.mint(address(this), 1000 ether);
        token1.mint(address(this), 1000 ether);
    }

    //mock function since factory == address(this)
    function feeTo() public pure returns (address) {
        return address(0);
    }

    function testGetPair() public {
        (address _token0, address _token1) = (address(token0), address(token1));

        address factoryPair = factory.getPair(_token0, _token1);
        address libraryPair = UniswapV2Library.pairFor(address(factory), _token0, _token1);
        // bytes memory bytecode = type(UniswapV2Pair).creationCode;
        //magic for calculating the new code hash
        // bytes32 hash = keccak256(abi.encodePacked(bytecode));
        // assertEq(hash, 0x648e0bfa21be642668baca31768b843e0608899b6c1aa5dfd5b4119b3aa64c36);
        // assertEq(pair.codehash, 0x648e0bfa21be642668baca31768b843e0608899b6c1aa5dfd5b4119b3aa64c36);

        assertEq(factoryPair, libraryPair);
    }

    function testSwapExactTokensForTokens() public {
        (address _token0, address _token1) = (address(token0), address(token1));

        token0.approve(address(router), type(uint).max);
        token1.approve(address(router), type(uint).max);
        router.addLiquidity(address(token0), address(token1), 10 ether, 10 ether, 9 ether, 9 ether, address(this), block.timestamp + 1000);

        address[] memory path = new address[](2);
        path[0] = _token0;
        path[1] = _token1;
        
        router.swapExactTokensForTokens(0.5 ether, 0 ether, path, address(msg.sender), block.timestamp + 1000);

        //assertPairReserves(0.5 ether, 2 ether);
        //assertEq(token0.balanceOf(address(msg.sender)), 10 ether + 0.5 ether);

        assertEq(msg.sender, owner);
    }

}
