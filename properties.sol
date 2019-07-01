pragma solidity >=0.4.22 <0.6.0;

contract provincial {
    enum Status { NotExist, Created, InTransit, PaidFor, Completed }
    
    struct Properties {
        Status state;
        uint price;
        address currOwner;
    }
    
    struct Parties {
        address InitiatingParty;
        address RecivingParty;
    }

    mapping (address => uint) balances; 
    
    Parties parties;
    Properties house;

    constructor() public {
        parties = Parties(msg.sender, 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB);
    }
    
    function registerProperty(uint _price, address _owner) public {
        house = Properties(Status.Created, _price, _owner);
    }
            
    modifier enoughEther() {
        require(balances[parties.RecivingParty] >= house.price, "Not enough Ether");
        _;
    }
    
    modifier onlyOwner() {
		require(house.currOwner == msg.sender);
		_;
    }
    
    event TransferCoin(address _from, address _to, uint256 _value); 
    event TransferProperty(address _from, address _to, uint256 _price);
    
    function sendCoin(address _sender, address _receiver, uint _amount) public enoughEther() returns (bool sufficient) {
        balances[_sender] -= _amount;
        balances[_receiver] += _amount;
        house.state = Status.PaidFor;
        
        emit TransferCoin(_sender, _receiver, _amount); 
        return true;
    }
    
    function changeOwnershipRequest(address _newOwner) public onlyOwner() returns (bool) {
		require(house.currOwner != _newOwner);
		sendCoin(msg.sender, _newOwner, house.price);
		return true;
    }
    
    function changeOwnershipApproval(address _newOwner) public onlyOwner() returns (bool) {
		require(house.currOwner != _newOwner);
		require(house.state == Status.PaidFor);
		house.currOwner = _newOwner;
		return true;
    }
    
}
