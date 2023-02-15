// Import the required Hardhat libraries
import "hardhat/console.sol";
import { ethers } from "hardhat";
import { expect } from "chai";

// Import the contract(s) to be tested
import "../contracts/StudentPerformance.sol";

// Start of the test suite
describe("StudentPerformance", function () {
  // Declare variables to be used in the tests
  let school;
  let owner;
  let addr1;
  let addr2;
  const SCHOOL_NAME = "ABC School";
  const SCHOOL_FEES = ethers.utils.parseEther("1");
  const CLASS_NAME = "Mathematics";
  const STUDENT_NAME = "John";
  const STUDENT_SURNAME = "Doe";
  const STUDENT_BIRTHDAY = "01/01/2000";
  const STUDENT_GENDER = "Male";
  const STUDENT_RESIDENCE = "USA";
  const STUDENT_EMAIL = "john.doe@example.com";
  const STUDENT_PHONE = "+1 123-456-7890";

  // Before the tests, deploy the contract and get the necessary accounts
  before(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    school = await ethers.getContractFactory("SchoolManagementSystem").then((contract) => {
      return contract.deploy(SCHOOL_NAME, SCHOOL_FEES);
    });
    await school.deployed();
  });

  // Test the depositFees() function
  it("Should deposit fees", async function () {
    const initialBalance = await ethers.provider.getBalance(school.address);
    const depositAmount = ethers.utils.parseEther("10");
    await school.connect(owner).depositFees({ value: depositAmount });
    const newBalance = await ethers.provider.getBalance(school.address);
    expect(newBalance).to.equal(initialBalance.add(depositAmount));
  });

  // Test the withdrawFees() function
  it("Should withdraw fees", async function () {
    const initialBalance = await ethers.provider.getBalance(school.address);
    const depositAmount = ethers.utils.parseEther("10");
    await school.connect(owner).depositFees({ value: depositAmount });
    await school.connect(owner).deleguateWithdrawTo(addr1.address);
    await school.connect(addr1).withdrawFees(owner.address, SCHOOL_FEES);
    const newBalance = await ethers.provider.getBalance(school.address);
    expect(newBalance).to.equal(initialBalance.add(depositAmount).sub(SCHOOL_FEES));
  });

  // Test the addRegisterAuthority() function
  it("Should add a register authority", async function () {
    const name = "Alice";
    const surname = "Smith";
    const residence = "Canada";
    const email = "alice.smith@example.com";
    const phone = "+1 234-567-8901";
    await school.connect(owner).addRegisterAuthority(addr1.address, name, surname, residence, email, phone);
    const authority = await school.allowancesRegister(addr1.address);
    expect(authority.name).to.equal(name);
    expect(authority.surname).to.equal(surname);
    expect(authority.residence).to.equal(residence);
    expect(authority.email).to.equal(email);
    expect(authority.phone).to.equal(phone);
    expect(authority.isAutorizedToWithdraw).to.equal(false);
  });

  // Test the deleguateWithdrawTo() function
  it("Should deleguate withdraw authority", async function () {
    await school.connect(owner).addRegisterAuthority(addr1.address, "Alice", "Smith", "Canada","exempl@gmail.com","90500075");
});
}
)
