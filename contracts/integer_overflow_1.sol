pragma solidity ^0.4.15;

contract IntegerOverflow {
    uint private sellerBalance=0;
    
    function add(uint value) returns (bool){
        sellerBalance += value;
    }
    
    function safe_add(uint value) returns (bool){
        require(value + sellerBalance >= sellerBalance);
        sellerBalance += value;
    }
}
