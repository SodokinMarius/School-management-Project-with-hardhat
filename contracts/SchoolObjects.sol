// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
contract SchoolObjects {


 //Enums to Use
 enum State {PAID, NOT_PAID}
 enum Semester {ONE,TWO}
 
enum Gender {MALE,FEMALE, OTHER}

//Objects/Structs to use

  struct Student {
        string name;
        string surname;
        string birthday;
        Gender gender;
        string residence;
        string email;
        string phone;
        bool havePaidFees;
               
    }

    struct Authority {
        string name;
        string surname;
        string residence;
        string email;
        string phone;
        bool isAutorizedToWithdraw;
    }

    struct Subject {
        uint256 code;
        string name;
        uint256 coefficient;
    }


    struct Classe {
        uint256 code;
        string name;
    }


    struct Subscription {
        uint256 code;
        uint256 year;
        string date;
        address studentAd;
        uint256 classeId;
        State state;
    }

    struct Assignment {
        uint256 code;
        uint256 year;
        Semester semester;
        string date;
        address studentAd;
        uint256 subjectId;
        uint256 mark;
        uint256 coef_mark;
    }

    struct Performance{
        uint256 somme;
        uint256 average;
        uint256 weightedAverage;
        uint256 rank;
    }
 

    mapping(address => Student) public  students;

    mapping(address => uint256) public balances;
    
    address[] public allStudentwhoPaid;

    mapping(uint256 => Classe)  public classes;

    mapping(uint256 => Subject) public  subjects;

    mapping(uint256 => Subscription) public  subscriptions;

    mapping(uint256 => Assignment) public assignements;

    mapping(address => Authority) public allowancesRegister;
    
    mapping(uint256 => mapping(Semester => mapping(address =>Performance))) StudentsPerformances;


}