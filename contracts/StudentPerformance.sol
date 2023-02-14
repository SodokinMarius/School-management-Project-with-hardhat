// SPDX-License-Identifier: MIT

import "./SchoolObjects.sol";

pragma solidity 0.8.17;

contract SchoolPerformanceSystem  is SchoolObjects{

string public  SCHOOL_NAME;
uint256  public SCHOOL_FEES;

uint256 public subjectCount ;
uint256 public classCount ;
uint256 public assignmentCount ;
uint256 public subscriptionCount ;
uint256 private allanceAuthorityCount;
uint256 private allanceWithdrawAuthorityCount;


event Deposit(address,uint256);

constructor(string memory name,uint256 fees)
{
    require(bytes(name).length >0,"School name must be provided");
    require(fees >0,"Fees must be greater than 0");
    
    SCHOOL_NAME = name;
    SCHOOL_FEES = fees;
    assignmentCount = 0;
    subjectCount = 0;
    classCount = 0;
    subscriptionCount = 0;
    allanceAuthorityCount = 0;

}

  modifier onlyRegisterAuthority {
       
        require(bytes(allowancesRegister[msg.sender].name).length != 0 , "Not authorized to subscribe student !");
        _;
    }


modifier onlyRegisterAndWithdrawAuthority
{
    require(bytes(allowancesRegister[msg.sender].name).length != 0
    && allowancesRegister[msg.sender].isAutorizedToWithdraw ,
     "Not authorized to withdraw school fees !");
        _;
}


/*
- Check if the sudent has paid
- if yes, change the substratiion state to paid
- create the student and add him to students mapping
- check id the classes id exists
- subscription code increment*/

function subscribe(
    address student_adress,  
    string memory _name,
    string memory _surname,
    string memory _birthday,
    string memory gender,
    string memory _residence,
    string memory _email,
    string memory _phone,
    uint256 classId,
    uint256 sub_year
      ) public   onlyRegisterAuthority virtual returns(bool) 
{ 
subscriptionCount ++;
   
    require(student_adress != address(0),"Invalid provided adress");
    require(bytes(_name).length >0, "Authority name does not exists !!");
    require(allStudentwhoPaid.contains(student_adress),"This studenthas not yet paid scholl fees !!");
     
     //Creating the student
    students[student_adress].name = _name;
    students[student_adress].surname = _surname;
    students[student_adress].birthday = _birthday;
    students[student_adress].gender = MALE;
    students[student_adress].residence = _residence;
    students[student_adress].email = _email;
    students[student_adress].phone = _phone;
    students[student_adress].havePaidFees = true;


    //Let check if the provid class exists
    require(classId >0,"CLasse ID must be greater than )");
    require(bytes(classes[classId].name).length > 0,"THe provided class doesn't exists yet !!");

    //Creating the subsciption

    subscriptions[subscriptionCount].year = sub_year;
    subscriptions[subscriptionCount].date  = "14/02/20233";
    subscriptions[subscriptionCount].studentAd  = student_adress;
    subscriptions[subscriptionCount].classeId  = classeId;
    subscriptions[subscriptionCount].state  = PAID;    

}


 /*Add register Authority */

function addRegisterAuthority(
    address _autorityAdress,
    string memory _name,
    string memory _surname,
    string memory _residence,
    string memory _email,
    string memory _phone
    ) public returns(bool)
{
    require(_autorityAdress != address(0),"Invalid provided adress");
    require(allanceAuthorityCount <3,"Only 3 Persons must be authorized");
    allanceAuthorityCount++;

    allowancesRegister[_autorityAdress].name = _name;
    allowancesRegister[_autorityAdress].surname = _surname;
    allowancesRegister[_autorityAdress].residence = _residence;
    allowancesRegister[_autorityAdress].email = _email;
    allowancesRegister[_autorityAdress].phone = _phone;
    allowancesRegister[_autorityAdress].isAutorizedToWithdraw = false;
    
    return true;
}
 
 /*Deleguate a withdraw authorization to an authority
 -we verify the address 
 -we verity if the authorized authority doesn't reach 3
 we change the status of isAutorizedToWithdraw then  */
 function deleguateWithdrawTo(address authorityAdress) public virtual returns(bool)
 {
    require(authorityAdress != address(0),"Invalid provided adress");
    require(allanceWithdrawAuthorityCount <3,"Only 1 Persons must be authorized for withdraw perform !!");
    require(bytes(allowancesRegister[authorityAdress].name).length >0, "Authority does not exists !!");
     allanceWithdrawAuthorityCount++;
    allowancesRegister[authorityAdress].isAutorizedToWithdraw = true;
 }

/* Function to deposit fund on the contract*/
function depositFees() external payable 
{
    require(msg.value > 0, "Deposit amount must be greater than 0");
    balances[msg.sender] += msg.value;
    emit Deposit(msg.sender,msg.value);

}

/*Function to wihdraw funds on the contract*/
function withdrawFees(address studentAdress, uint256 amount) public  onlyRegisterAndWithdrawAuthority virtual  returns(bool)
{
    require(studentAdress != address(0),"Invalid Adress");
    require(amount>=SCHOOL_FEES,"Invalid Amount ! ");
    require(balances[studentAdress] >= amount,"Insufficient Amount in this ballance");

    allStudentwhoPaid.push(studentAdress);

    balances[studentAdress] -= amount;

    payable(address(this)).transfer(amount);

}

/* Get all ballances on the contracts*/

  function  getAllBallances() public onlyRegisterAuthority view returns(uint256)
  {
      return address(this).balance;
  }

/*Add class function
only one of register authority can add
-*/
function addClasse(uint256 _code, string memory _name) public  onlyRegisterAuthority  returns(bool)
{
classCount++;
require(bytes(_name).length >0,"Kindly provide a class name Value");
require(_code >0,"Provide a positive class code !");

 classes[classCount] = Classe({code:_code,name:_name});

return true;
}

/*Add Subject function
only one of register authority can add
-*/
function addSubject(uint256 _code, string memory _name,uint256 _coef) public  onlyRegisterAuthority  returns(bool)
{
subjectCount++;
require(bytes(_name).length >0,"Kindly provide a class name Value");
require(_code >0,"Provide a positive class code !");
require(_coef >0,"Provide a positive subject  coefficient !");

 subjects[subjectCount] = Subject({code:_code,name:_name,coefficient:_coef});

return true;
}

/*==================
this function will take : student address and check esictence, subject id and ckeck existence, code, year,semester, date, mark
- will check the subscription amout, and the requested classe, if valid , he student will be added
- the subscription will be created
*/

function addAssignment(
    uint256 code,
    uint256 year,
    Semester semester,
    string memory date,
    address studentAddress,
    uint256 subjectId,
    uint256 mark,
    uint256 coef_mark
) public returns(bool){
    // Verify that the student and subject exist
    require(bytes(students[studentAddress].name).length > 0, "Student does not exist");
    require(bytes(subjects[subjectId].name).length > 0, "Subject does not exist");
  assignmentCount++;

    Assignment memory newAssignment = Assignment(
        code,
        year,
        semester,
        date,
        studentAddress,
        subjectId,
        mark,
        coef_mark
    );

    assignements[assignmentCount] = newAssignment;

    return true;
}

 function removeStudent(address studentAdress) public onlyRegisterAuthority view returns(string memory)
 {
        require(bytes(students[studentAdress].name).length > 0, "Student does not exist");
        delete students[studentAdress];
        return "Student "+studentAdress+"removed successfully";        

 }


 
 function researchStudent(address studentAdress) public onlyRegisterAuthority view returns(
   string memory,string memory,string memory,Gender,string memory,string memory,string memory,bool
 )
  
  {      
      require(bytes(students[studentAdress].name).length > 0, "Student does not exist");
        return (
            students[studentAdress].name,
            students[studentAdress].surname,
            students[studentAdress].birthday,
            students[studentAdress].gender,
            students[studentAdress].residence,
            students[studentAdress].email,
            students[studentAdress].phone,
            students[studentAdress].havePaidFees,
                 )     ; 

 }


function performance() public view returns (StudentsPerformances) {

    // Initialize an empty mapping to store the calculated performance for each class, semester, subject, and student
    StudentsPerformances memory allPerformances;

    // Loop through all classes
    for (uint256 i = 0; i < classes.length; i++) {
        
        // Loop through all semesters
        for (uint j = 0; j < 2; j++) {
            Semester semester = Semester(j);
            
            // Loop through all subscriptions of the current class in the current semester
            for (uint256 k = 0; k < subscriptionCount; k++) {
                Subscription memory currentSubscription = subscriptions[k];
                if (classes[currentSubscription.classeId].code == classes[i].code) {
                    if (currentSubscription.state == State.PAID) {
                        Student memory currentStudent = students[currentSubscription.studentAd];
                        uint256 studentSum = 0;
                        uint256 studentCoefficientSum = 0;
                        uint256 studentMarkCount = 0;
                        uint256 studentRank = 1;
                        
                        // Loop through all assignments of the current student in the current semester
                        for (uint256 l = 0; l < assignmentCount; l++) {
                            Assignment memory currentAssignment = assignements[l];
                            if (currentAssignment.studentAd == currentSubscription.studentAd &&
                                currentAssignment.year == currentSubscription.year &&
                                currentAssignment.semester == semester) {
                                
                                uint256 weightedMark = currentAssignment.mark * currentAssignment.coef_mark;
                                studentSum += currentAssignment.mark;
                                studentCoefficientSum += currentAssignment.coef_mark;
                                studentMarkCount++;
                                
                                // Count the number of students with a higher total mark than the current student
                                if (weightedMark > StudentsPerformances[currentAssignment.subjectId][semester][currentSubscription.studentAd].weightedAverage) {
                                    studentRank++;
                                }
                            }
                        }
                        
                        // Calculate the weighted and unweighted average for the current student
                        uint256 studentWeightedAverage = 0;
                        uint256 studentUnweightedAverage = 0;
                        if (studentMarkCount > 0) {
                            studentWeightedAverage = studentSum / studentCoefficientSum;
                            studentUnweightedAverage = studentSum / studentMarkCount;
                        }
                        
                        // Create a new Performance object for the current student and semester
                        Performance memory currentPerformance = Performance({
                            somme: studentSum,
                            average: studentUnweightedAverage,
                            weightedAverage: studentWeightedAverage,
                            rank: studentRank
                        });
                        
                        // Store the Performance object in the AllPerformances mapping
                        allPerformances[currentAssignment.subjectId][semester][currentSubscription.studentAd] = currentPerformance;
                        
                    }
                }
            }
        }
    }
    
    // Return the AllPerformances mapping
    return allPerformances;
}
}


