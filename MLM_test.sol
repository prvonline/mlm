// Import the required libraries and contracts for testing
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/MLM.sol";
contract TestMLM {
    // Get the deployed MLM contract for testing
    MLM mlm = MLM(DeployedAddresses.MLM());
    // Test case for applying franchise and approving it
    function testApplyAndApproveFranchise() public {
        uint32 pincode = 123456;
        address franchiseAddr = address(0x123);
         // Apply for franchise
        mlm.applyFranchise(pincode);
         // Approve the franchise application
        mlm.approveFranchise(franchiseAddr);
        // Verify that the franchise was approved
        bool isFranchise = mlm.isValidFranchisee(franchiseAddr);
        Assert.isTrue(isFranchise, "Franchise should be approved");
    }
    // Test case for applying membership under a franchise
    function testApplyMembership() public {
        address franchiseAddr = address(0x123);
        address memberAddr = address(0x456);      
        // Apply for membership under the franchise
        mlm.applyMembership(franchiseAddr);        
        // Verify that the member was added to the franchise
        bool isMember = mlm.isValidMember(memberAddr);
        Assert.isTrue(isMember, "Member should be added to the franchise");
    }
    // Test case for transferring registration balance to company
    function testTransferRegistrationBalance() public payable {
        uint256 initialBalance = mlm.getRegistrationBalance();        
        // Transfer registration balance to the company
        mlm.transferRegistrationBalance();        
        // Verify that the registration balance is transferred
        uint256 finalBalance = mlm.getRegistrationBalance();
        Assert.equal(finalBalance, initialBalance + msg.value, "Registration balance transfer failed");
    }
    // Test case for checking manager availability
    function testManagerAvailability() public {
        uint32 pincode = 123456;
        address managerAddr = address(0x789);        
        // Recruit manager for a pincode
        mlm.recruitManager(pincode, managerAddr);        
        // Verify that the manager is available for the pincode
        bool isAvailable = mlm.isManagerAvailable(pincode, managerAddr);
        Assert.isTrue(isAvailable, "Manager should be available for the pincode");
    }
}
