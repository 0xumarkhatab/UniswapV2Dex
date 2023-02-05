
//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <=0.8.7;

import "https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Factory.sol";
import "https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol";

contract UniswapPairCreator{
IUniswapV2Factory factory;
address tokenA;
address tokenB;

constructor(address uniswapFactoryAddress,address _tokenA,address _tokenB)public {
factory=IUniswapV2Factory(uniswapFactoryAddress);
tokenA=_tokenA;
tokenB=_tokenB;

}

function createPair()public returns(address){
   (address pair) = factory.createPair(tokenA, tokenB);
   return address(pair);
}

 function getPair() public view returns (IUniswapV2Pair) {
        return IUniswapV2Pair(factory.getPair(tokenA, tokenB));
    }


}
