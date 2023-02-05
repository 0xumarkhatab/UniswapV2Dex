
//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <=0.8.7;

import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Factory.sol";

// Network          : Goerli
// Router Addresss  : 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
// Our Pair         : 0x2C844a32e1fb83A3Cfd22cAb1e6C784414cf489B
// TokenA Address   : 0x61870060a49e5AfbC11aE8E32336427d49AE2863
// TokenB Address   : 0x2a588d4cBD09714CbB354c36C563f5ec1f959783
// 100 ERC20 Tokens : 100000000000000000000

contract UniswapDex{
IUniswapV2Factory factory;
IUniswapV2Router02 router;
IUniswapV2Pair pair;


constructor(address factoryAddress,address uniswapRouterAddress,address _pairAddress)public {
factory=IUniswapV2Factory(factoryAddress);
router=IUniswapV2Router02(uniswapRouterAddress);
pair=IUniswapV2Pair(_pairAddress);

}

/*
*       Pair Creation
*
*/

function createPair(address tokenA,address tokenB)public returns(address){
   (address pair) = factory.createPair(tokenA, tokenB);
   return address(pair);

}

 function getPair(address tokenA,address tokenB) public view returns (IUniswapV2Pair) {
    return IUniswapV2Pair(factory.getPair(tokenA, tokenB));
}

/*
*
*       Adding liquidity
*/



function addLiquidity(uint256 minimumLiquidity,uint amount1,uint amount2) public payable returns(uint,uint,uint) {
    address[] memory tokensArr = toAddressArray(pair); // give it in the correct format of array of addresses
    // check if the contract is allowed to trade enough tokens
    require(
        IERC20(tokensArr[0]).allowance(
        msg.sender,address(this))>= minimumLiquidity 
        &&
        IERC20(tokensArr[1]).allowance(
            msg.sender,address(this))>= minimumLiquidity             
        , "Insufficient deposit");

    // Transfer tokens from User's pocket to Contract's pocket
    require(IERC20(tokensArr[0]).transferFrom(msg.sender,address(this),amount1),"TokenA transfer failed");
    require(IERC20(tokensArr[1]).transferFrom(msg.sender,address(this),amount2),"TokenB transfer failed");
    // Aprove Router Contract
    IERC20(tokensArr[0]).approve( address( router),amount1);
    IERC20(tokensArr[1]).approve(address(router),amount2);
    
    (uint _amountA, uint _amountB, uint _liquidity) = router.addLiquidity(
        tokensArr[0],
        tokensArr[1],
        amount1, // desired token1 amount
        amount2,// desired token2 amount
        amount1,// minimum token1 amount
        amount2,// minimum token2 amount
        msg.sender,
        block.timestamp+120 // cancel if the transaction is not processed after 2 minutes
        );

    return (_amountA, _amountB, _liquidity);

}


/*
*
*   Swapping assets in realtime using Uniswap
*/
function swap(address tokenIn,uint amountIn, uint amountOutMin, address to) public {
    address[] memory path = toAddressArray(pair); // give it in the correct format of array of addresses for swap function
    require(tokenIn==path[0]|| tokenIn==path[1],"Invalid Token Address");
    if(tokenIn==path[1]){
        // change the arrangement of input token and output token
        address temp=path[1];
        path[1]=path[0];
        path[0]=temp;
    }
    // else let the arrangment be same , 0th index token as input and 1th index token as output.

    // take tokens from user
    IERC20(tokenIn).transferFrom( msg.sender,address(this),amountIn);
    // approve the router contract to spend the tokens
    IERC20(tokenIn).approve( address( router),amountIn);
     
    // spend the tokens
    router.swapExactTokensForTokens(
        amountIn,
        amountOutMin,
        path,
        to, 
        block.timestamp + 60// if swap has not occured in a minute , cancle it
        ); 
  }



// utitlity function to convert UniswapV2 pair into an array of addresses of tokens involved
function toAddressArray(IUniswapV2Pair _pair) private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = address(IUniswapV2Pair(_pair).token0());
        path[1] = address(IUniswapV2Pair(_pair).token1());
        return path;
    }


   
}
