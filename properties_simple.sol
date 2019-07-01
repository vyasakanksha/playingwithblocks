pragma solidity >=0.4.22 <0.6.0;

contract provincial {
    enum Status { Created, InTransit, PaidFor, Completed }
    
    struct Properties {
        Status state;
        uint price;
        address currOwner;
    }

    mapping (address => uint) balances; 

    Properties house;
    
    function registerProperty(uint _price, address _owner) public {
        house = Properties(Status.Created, _price, _owner);
    }
            
    function sendCoin(address _sender, address _receiver, uint _amount) public returns (bool sufficient) {
        balances[_sender] -= _amount;
        balances[_receiver] += _amount;
        house.state = Status.PaidFor;
        
        return true;
    }
    
    function changeOwnershipRequest(address _newOwner) public returns (bool) {
		require(house.currOwner != _newOwner);
		sendCoin(msg.sender, _newOwner, house.price);
		return true;
    }
    
    function changeOwnershipApproval(address _newOwner) public returns (bool) {
		require(house.currOwner != _newOwner);
		require(house.state == Status.PaidFor);
		house.currOwner = _newOwner;
		return true;
    }
}
