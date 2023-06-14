/*
    Program: MLM.sol
    **********************************************************************************
    Note: The Following Program is not professionally tested. Use at own risk.
    *********************************************************************************
    *****************************************************************
    Blockchain Lecture Videos can be viewed in My YouTube Channel at
    https://www.youtube.com/channel/UC0oJO4o-UeMt5irLm6kxIWA
    ******************************************************************
    @Author: Dr. P. Raghu Vamsi, JIIT, Noida.
    @email: prvonline@yahoo.co.in
    Problem Statement:
    A product manufracturing company wants to make use of Blockchian technology for their Multi
    Level Marketing (MLM). The structure of MLM is as follows:
    Anyone who is interested in MLM should first need to get approval from company's Marketing
    manager and can start marketing franchise. Company has fixed 500 Wei as franchise registration
    fee. The franchisee can build small groups for daily marketing purpose. To this end, 
    franchisee can join members in the group. Also, the approved group members can also join 
    anyone in it. For this, new member needs to pay 100 Wei as membership fee. If the new joiner 
    is joined the group through franchisee then 100% membership fees is credited to franchisee 
    account. Otherwise, 30% of the membership fee will be credited to franchisee and remaining
    70% to the group member who joined the new member. The same share is applicable on the profits
    of the products sold by members. Further, to have control over the group, the maximum size of
    group is fixed to 25. 
    
    Refer document providing explantion of the problem statement for 
    better understanding of code. 
*/

pragma solidity ^0.5.0;

/*
Company, Franchisee, and Members have their own accounts. To this end
following smart contract (Account) defines required functions.
*/

contract Account {
    // To hold owner of the account
    address payable private myaddr;
    // fallback function to make account automatically payable
    function() external payable {}
    // Constructor to hold the owner of the account
    constructor(address payable addr) public {
        myaddr = addr;
    }
    // function to get the balance of the account
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    // function to get the owner of the account
    function getOwner() public view returns (address) {
        return myaddr;
    }
    // modifier to check the validity of the address
    modifier checkAddressValidity(address payable addr) {
        require(myaddr == addr,
        "Not a Valid address for Fund Transfer");
        _;
    }
    // modifier to check balance validity for fund tranfer
    modifier checkBalanceValidity {
        require(getBalance() > 0,
        "No Balance Exists to Transfer ..");
        _;
    }
    // function to tranfer the balance to EOA
    function transferBalance() 
                    public checkAddressValidity(msg.sender) checkBalanceValidity {
        msg.sender.transfer(address(this).balance);
    }
    // Function to kill the Account 
    function kill() public {
        if(msg.sender == myaddr) {
            transferBalance();
            selfdestruct(address(this));
        }
    }
}

// Contract Multi Level Makrting

contract MLM {
    /*
    As Solidity does not support floating point operations (such as divisions)
    let us decalare constants for the fee share according to the problem statement.
    */
    // franchise registration fee
    uint constant public franchiseFee = 500 wei;
    // General memebrship fee
    uint constant public membershipFee = 100 wei;
    // Franchisee share in the memebership fee
    uint constant public franchiseeShare = 30 wei;
    // Member share in the membership fee
    uint constant public memberShare = 70 wei;
    // Size of Franchisee group
    uint constant public groupSize = 25;
    // Company structure to hold details
    struct Company {
        // company address
        address addr;
        // company name
        string name;
        // company postal address
        string caddress;
        // mapping for pincode to manager address
        mapping(uint32=>address) pincodeManager;
        // mapping for valid managers list
        mapping(address=>bool) managerList;
        // mappinf for available pincode list
        mapping(uint32=>bool) pincodeList;
        // mapping for registration deposits, address to amount deposited
        mapping(address=>uint256) regDeposits;
        // mapping for franchise applicant address to pincode
        mapping(address=>uint32) depositorPincode;
        // mapping for availability of depositor's address
        mapping(address=>bool) depositorList;
        // array of depositors address
        address[] depositorIndex;
        // mapping for franchisee address and approved manager address
        mapping(address=>address) franchiseManager;
        // mapping for availability of franchisee
        mapping(address=>bool) franchiseList;
        // Array of franchisee adresses
        address[] franchiseIndex;
        // Company account to hold registration amount
        Account account;
    }
    
    // Structure to hold Franchisee details
    struct Franchisee {
        // Franchisee address
        address addr;
        // Address of manager who approved franchisee
        address approvedBy;
        // mapping for franchisee member availability
        mapping(address=>bool) memberList;
        // Array of members address
        address[] memberIndex;
        // Pincode of the franchisee
        uint32 pincode;
        // Franchisee group size
        uint size;
        // Franchisee account to hold membership and profit share
        Account account;
    }
    
    // Structure to hold Member details
    struct Member {
        // Member address
        address addr;
        // Franchisee address
        address faddr;
        // address of the member/franchisee who joined him/her
        address joinedBy;
        // Members account to hold membership and profit share
        Account account;
    }
    
    // Data structues for holding franchisee details
    mapping(address => Franchisee) private franchisee;
    mapping(uint32 => address) private pincodeFranchisee;
    mapping(address => bool) private franchiseeList;
    address[] private franchiseeIndex;
    
    // Data structures for holding member details
    mapping(address => Member) private member;
    mapping(address => bool) private memberList;
    address[] private memberIndex;
    
    // Mapping for member and franchisee
    mapping(address => address) private memberFranchisee;
    
    // Company structues variable
    Company private company;
    
    // MLM coconstructor
    constructor(string memory name, string memory caddress) public {
        // Address of one who intiated the contract
        company.addr = msg.sender;
        company.name = name;
        company.caddress = caddress;
        // Instantiate company account
        company.account = new Account(msg.sender);
    }
    // modifer to validite company address
    modifier onlyByCompany {
        require(msg.sender == company.addr,
        "Only Company can do this Operation ..");
        _;
    }
    // Function to check availability for manager for corresponding pincode
    function isManagerAvailable(uint32 pincode, address addr) public view returns(bool) {
        return (company.pincodeManager[pincode] == addr);
    }
    // Fucntion to check manager wrt to address
    function isManager(address addr) public view returns(bool) {
        return company.managerList[addr];
    }
    // Function to check manager wrt pincode
    function isManager(uint32 pincode) public view returns (bool) {
        return company.pincodeList[pincode];
    }
    // Function to get Company address
    function getCompanyAddress() public view returns (address) {
        return company.account.getOwner();
    }
    // Function to get manger address for a given pincode
    function getManagerAddress(uint32 pincode) public view returns (address) {
        return (company.pincodeManager[pincode]);
    }
    // Function to change manager for a given pincode
    function changeManager(uint32 pincode, address old_manager, address new_manager) public onlyByCompany {
        if(isManagerAvailable(pincode,old_manager)) {
            company.pincodeManager[pincode] = new_manager;
        } else revert();
    }
    // Function to recruit manager
    function recruitManager(uint32 pincode, address addr) public onlyByCompany {
        if(!isManagerAvailable(pincode,addr)) {
            company.pincodeManager[pincode] = addr;
            company.managerList[addr] = true;
            company.pincodeList[pincode] = true;
        } else revert();
    }
    // modifier to check franchisee fee
    modifier checkFranchiseFee {
        require(msg.value >= franchiseFee,
        "Require 500 wei towards Franchise Fee ..");
        _;
        if(msg.value > franchiseFee) {
            msg.sender.transfer(msg.value - franchiseFee);
        }
    }
    // modifier to check availability of manager for given pincode
    modifier checkManagerAvailability(uint32 pincode) {
        require(isManager(pincode),
        "No Manager Available for the Given Pincode..");
        _;
    }
    // Function to apply for franchise in a given pincode
    function applyFranchise(uint32 pincode) public 
                    payable checkFranchiseFee checkManagerAvailability(pincode) {
            // Transfer franchise fee to company account
            address(company.account).transfer(franchiseFee);
            // Update depositor details
            company.regDeposits[msg.sender] += franchiseFee;
            company.depositorIndex.push(msg.sender);
            company.depositorList[msg.sender] = true;
            company.depositorPincode[msg.sender] = pincode;
        
    }
    // modifier to check correct manager
    modifier isValidManager (address addr) {
        require(company.pincodeManager[company.depositorPincode[addr]] == msg.sender,
        "This Operation can be done only by Manager of Pincode ..");
        _;
    }
    // modifier to check availability of deposit
    modifier checkDeposit(address addr) {
        require(company.depositorList[addr],
        "No Franchise Fee Deposit Found ...");
        _;
    }
    // modifier to check pre existing of Franchise 
    modifier checkFranchise(address addr) {
        require(!company.franchiseList[addr],
        "Already Franchise Available with this Address ...");
        _;
    }
    // Function to approve the franchise application
    function approveFranchise(address payable addr) public 
            isValidManager(addr) checkDeposit(addr) checkFranchise(addr) {
        // remove the entry from depositors list
        delete company.regDeposits[addr];
        delete company.depositorList[addr];
        for(uint i=0; i< company.depositorIndex.length; i++) {
            if(company.depositorIndex[i] == addr) {
                delete company.depositorIndex[i];
                break;
            } else continue;
        }
        // Instantiate franchise details
        Franchisee memory fran;
        fran.addr = addr;
        fran.size = 1;
        fran.account = new Account(addr);
        fran.pincode = company.depositorPincode[addr];
        
        pincodeFranchisee[fran.pincode] = addr;
        delete company.depositorPincode[addr];
        // make an entry in to franchisee list
        company.franchiseList[addr] = true;
        company.franchiseManager[addr] = msg.sender;
        company.franchiseIndex.push(addr);
        
        franchisee[addr] = fran;
        franchiseeList[addr] = true;
        franchiseeIndex.push(addr);
    }
    // Function to get the registration balance by company
    function getRegistrationBalance() public onlyByCompany view returns (uint256) {
        return (company.account).getBalance();
    }
    // Function to get Franchisee address by pincode
    function getFranchiseeByPincode(uint32 pincode) public view returns (address) {
        return pincodeFranchisee[pincode];
    }
    // Function to get franchisee group size
    function getFranchiseeSize(address addr) public view returns (uint) {
        return franchisee[addr].size;
    }
    // Function to tranfer registration balnce to company EOA
    function transferRegistrationBalance() public onlyByCompany {
        (company.account).transferBalance();
    }
    // Modifier to check membership fee
    modifier checkMembershipFee {
        require(msg.value >= membershipFee,
        "Require 100 wei for applying Membership...");
        _;
        if(msg.value > membershipFee) {
            msg.sender.transfer(msg.value - membershipFee);
        }
    }
    // Modifier to check validity of franchisee
    modifier byValidFranchisee (address addr) {
        require(company.franchiseList[addr] == true,
        "Not a Valid Franchisee ..");
        _;
    }
    // Modifier to check vailidity of member
    modifier byValidMember (address addr) {
        require(memberList[addr] == true,
        "Not a Valid Member ..");
        _;
    }
    // Function to check valid Franchisee
    function isValidFranchisee(address addr) public view returns (bool) {
        return company.franchiseList[addr];
    }
    // Function to check valid member
    function isValidMember(address addr) public view returns (bool) {
        return memberList[addr];
    }
    // Function to apply membership 
    function applyMembership(address faddr) public 
            payable checkMembershipFee {
        if(isValidFranchisee(faddr) && getFranchiseeSize(faddr) < groupSize) {
               address(franchisee[faddr].account).transfer(membershipFee);
               Member memory mem;
               mem.addr = msg.sender;
               mem.faddr = faddr;
               mem.joinedBy = faddr;
               mem.account = new Account(msg.sender);
               franchisee[faddr].memberList[msg.sender] = true;
               franchisee[faddr].size += 1;
               franchisee[faddr].memberIndex.push(faddr);
               memberList[msg.sender] = true;
               member[msg.sender] = mem;
               memberIndex.push(msg.sender);
            
        } else if(isValidMember(faddr) && getFranchiseeSize(memberFranchisee[faddr]) < groupSize) {
                address(member[faddr].account).transfer(memberShare);
                address(franchisee[memberFranchisee[faddr]].account).transfer(franchiseeShare);
                Member memory mem;
                mem.addr = msg.sender;
                mem.faddr = memberFranchisee[faddr];
                mem.joinedBy = faddr;
                mem.account = new Account(msg.sender);
                // Insert the member information into franchisee
                franchisee[memberFranchisee[faddr]].memberList[msg.sender] = true;
                franchisee[memberFranchisee[faddr]].size += 1;
                franchisee[memberFranchisee[faddr]].memberIndex.push(msg.sender);
                // Insert the member information into member list
                memberList[msg.sender] = true;
                memberFranchisee[msg.sender] = memberFranchisee[faddr];
                member[msg.sender] = mem;
                memberIndex.push(msg.sender);
        } else revert();
    }
    // Function to check account balance
    function getAccountBalance() public view returns (uint256) {
        if(company.franchiseList[msg.sender]) {
            return (franchisee[msg.sender].account).getBalance();
        } else if(memberList[msg.sender]) {
            return (member[msg.sender].account).getBalance();
        } else if(msg.sender == company.addr) {
            return (company.account).getBalance();
        } else revert();
    }
    // Function to tranfer Balance
    function tranferBalance() public {
        if(company.franchiseList[msg.sender]) {
            (franchisee[msg.sender].account).transferBalance();
        } else if(memberList[msg.sender]) {
            (member[msg.sender].account).transferBalance();
        } else revert();
    }
    // Function to kill membership
    function killMembership() public byValidMember(msg.sender) {
        // Kill the account of the memebr
        (member[msg.sender].account).kill();
        // Remove Member Entry from the corresponding franchisee list
        delete franchisee[memberFranchisee[msg.sender]].memberList[msg.sender];
        for (uint i = 0; i < 
            franchisee[memberFranchisee[msg.sender]].memberIndex.length; i++) {
                if(franchisee[memberFranchisee[msg.sender]].memberIndex[i] == msg.sender) {
                    delete franchisee[memberFranchisee[msg.sender]].memberIndex[i];
                    break;
                } else continue;
            }
        // Remove Member entry from member list
        delete member[msg.sender];
        delete memberList[msg.sender];
        delete memberFranchisee[msg.sender];
        for (uint i=0; i < memberIndex.length; i++ ) {
            if(memberIndex[i] == msg.sender) {
                delete memberIndex[i];
                break;
            } else continue;
        }
        selfdestruct(msg.sender);
    }
    // Function to kill franchisee
    function killFranchisee() public byValidFranchisee(msg.sender) {
        // Tranfer the account balance
        (franchisee[msg.sender].account).kill();
        // Remove the Franchise entry from company
        delete company.franchiseList[msg.sender];
        for (uint i = 0; i < company.franchiseIndex.length; i++) {
            if(company.franchiseIndex[i] == msg.sender) {
                delete company.franchiseIndex[i];
                break;
            } else continue;
        }
        // Remove the Franchise from franchise list
        delete franchisee[msg.sender];
        delete franchiseeList[msg.sender];
        for (uint i = 0; i < franchiseeIndex.length; i++) {
            if(franchiseeIndex[i] == msg.sender) {
                delete franchiseeIndex[i];
                break;
            } else continue;
        }
        selfdestruct(msg.sender);
    }
    // Function to kill MLM
    function kill() public onlyByCompany {
        (company.account).transferBalance();
        (company.account).kill();
        selfdestruct(msg.sender);
    }
} // end of code