pragma solidity >=0.4.22 <0.6.0;

contract PropertyTransfer {
    enum Status { NotExist, Created, InTransit, PaidFor, Completed }
    
    struct Property {
        Status state;
        uint price;
        address currOwner;
    }

    mapping (address => uint) balances; 

    Property public house;
    
    event NewProperty(address _owner, uint _price); 
    event InitiateTransfer(address _from, address _to);
    event TransferedCoin(address _from, address _to, uint256 _value);
    event TransferedProperty(address _from, address _to, uint256 _price);
    
    modifier enoughEther(address _newOwner, uint _amount) {
        require(balances[_newOwner] >= _amount, "Not enough Ether");
        _;
    }
    
    modifier onlyOwner() {
		require(house.currOwner == msg.sender, "Only the owner of the property can execute the contract");
		_;
    }
    
    modifier differentOwner(address _newOwner) {
		require(house.currOwner != _newOwner, "Current owner and new owner are the same");
		_;
    }
    
    function registerProperty(uint _price, address _owner) public {
        house = Property(Status.Created, _price, _owner);
        emit NewProperty(msg.sender, _price);
    }
            
    function sendCoin(address _sender, address _receiver, uint _amount) public enoughEther(_sender, _amount) returns (bool sufficient) {
        balances[_sender] -= _amount;
        balances[_receiver] += _amount;
        house.state = Status.PaidFor;
        emit TransferedCoin(_sender, _receiver, _amount);
        return true;
    }
    
    function changeOwnershipRequest(address _newOwner) public differentOwner(_newOwner) onlyOwner() returns (bool) {
		house.state = Status.InTransit;
		balances[_newOwner] = 100;
		emit InitiateTransfer(msg.sender, _newOwner);
		sendCoin(_newOwner, msg.sender, house.price);
		return true;
    }
    
    function changeOwnershipApproval(address _newOwner) public differentOwner(_newOwner) onlyOwner() returns (bool) {
		require(house.state == Status.PaidFor, "The property has not been paid for");
		emit TransferedProperty(house.currOwner, _newOwner, house.price);
		house.currOwner = _newOwner;
		house.state = Status.Completed;
		return true;
    }
    
}
