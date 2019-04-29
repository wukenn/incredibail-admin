pragma solidity ^0.5.1;

contract ERC20Token {
    string public name;
    mapping(address => uint) public balances;
    
    function mint(uint amount) public {
        balances[tx.origin] += amount;
    }
}

contract bail {
    
    uint percent = 5;
    string public name;
    uint public bail_amount;
    uint total;
    mapping(uint => Donation) public donations;
    uint donation_count = 0;
    enum State {Open, Closed, Complete, Incomplete}
    State public state;
    
    mapping(address => uint) public balances;
    address payable wallet;
    
    event Purchase(
        address _buyer,
        uint _amount
        );
    
    address owner;
    address token;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyWhileOpen {
        require(total < bail_amount);
        _;
    }
    
    constructor(uint _bail_amount, 
    string memory _name, address payable _wallet,
    address _token) public {
        name = _name;
        bail_amount = _bail_amount;
        total = 0;
        state = State.Open;
        owner = msg.sender;
        wallet = _wallet;
        token = _token;
    } 
    
    struct Donation {
        uint _id;
        address name;
        uint donation;
    }
    
    function isOpen() public view returns(bool) {
        return state == State.Open;
    }
    
    
    function donate(uint donation, address donor) public onlyOwner onlyWhileOpen{
        donation_count += 1;
        donations[donation_count] = Donation(donation_count, donor, donation);
    }
    
    function sendTokens(uint donation) public payable{
        if (state == State.Open) {
            ERC20Token _token = ERC20Token(address(token));
            _token.mint(donation);
            donate(donation, msg.sender);
            emit Purchase(msg.sender, donation);
        }
        if (total >= bail_amount) {
            state == State.Closed;
        }
    }
    
    function closeCase() internal onlyOwner{
        state == State.Closed;
    }
    
    function completeCase() internal onlyOwner{
        state == State.Complete;
    }
    
    function incompeleteCase() internal onlyOwner{
        state == State.Incomplete;
    }
    
    function refund() public payable{
        for (uint i = donation_count; i >= 0; i--) {
            Donation memory x = donations[i];
            delete donations[i];
            x.name.transfer(x.donation * percent/100);
        }
    }
}