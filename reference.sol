// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./XRC4907.sol";

contract KeepItSafe is XRC4907 {

    struct Institute {
        string instituteName;
        string instituteLocation;
        string instituteDomain;
        bool registered;
    }

    struct Student {
        string studentName;
        address institueAddress;
        string instituteDomain;
        bool registered;
    }

    struct DocumentRequest {
        address student;
        string docType;
        bool exists;
    }

    error KeepItSafe__InstituteAlreadyExists();
    error KeepItSafe__StudentAlreadyExists();
    error KeepItSafe__OnlyForStudentRole();
    error KeepItSafe__OnlyForInstituteRole();
    error KeepItSafe__InstituteDoesNotExists();
    error KeepItSafe__StudentDoesNotExists();
    error KeepItSafe__DomainAlreadyExists();
    error KeepItSafe__InstituteCannotAddStudents();

    enum Roles {
        NA,
        INSTITUTE,
        STUDENT
    }

    mapping(address => Roles) private s_roles;
    mapping(address => Institute) private s_institutes;
    mapping(address => Student) private s_students;
    mapping(string => address) private s_instituteAddress;
    mapping(address => DocumentRequest[]) private s_requests;
    mapping(address => address[]) private s_instituteStudents;

    constructor(){}

    function getInstituteAddress(string memory _domain) public view returns(address) {
        return s_instituteAddress[_domain];
    }

    function addInstitute(string memory _instituteName, string memory _instituteLocation, string memory _instituteDomain) public {
        if(s_institutes[msg.sender].registered == true) {
            revert KeepItSafe__InstituteAlreadyExists();
        }
        if(s_instituteAddress[_instituteDomain]!=address(0)){
            revert KeepItSafe__DomainAlreadyExists();
        }
        s_institutes[msg.sender] = Institute(_instituteName, _instituteLocation, _instituteDomain, true);
        s_roles[msg.sender] = Roles.INSTITUTE;
        s_instituteAddress[_instituteDomain] = msg.sender;
    }

    // Only Adding After the Student verifies using his institute email (Off-Chain).
    // ****Warning: This is a very basic implementation, we need to add more security checks here.****
    function addStudent(string memory _studentName, address _instituteAddress, string memory _instituteDomain) public {
        if(s_students[msg.sender].registered == true){
            revert KeepItSafe__StudentAlreadyExists();
        }
        if(s_roles[msg.sender]==Roles.INSTITUTE){
            revert KeepItSafe__InstituteCannotAddStudents();
        }
        s_roles[msg.sender] = Roles.STUDENT;
        s_instituteStudents[_instituteAddress].push(msg.sender);
        s_students[msg.sender] = Student(_studentName, _instituteAddress, _instituteDomain, true);
    }

    function requestDocument(address _instituteAddress, string memory _docType) public {
        if(s_roles[msg.sender]!=Roles.STUDENT){
            revert KeepItSafe__OnlyForStudentRole();
        }
        if(s_institutes[_instituteAddress].registered == false){
            revert KeepItSafe__InstituteDoesNotExists();
        }
        if(s_students[msg.sender].registered == false){
            revert KeepItSafe__StudentDoesNotExists();
        }
        s_requests[msg.sender].push(DocumentRequest(msg.sender, _docType, true));
    }

    function getYourRole() public view returns(Roles){
        return s_roles[msg.sender];
    }
    
    function getInstituteDetails(address _instituteAddress) public view returns(Institute memory){
        return s_institutes[_instituteAddress];
    }

    function getStudentDetails(address _studentAddress) public view returns(Student memory){
        return s_students[_studentAddress];
    }

    function getAllRequestsForInstitutes() public view returns (DocumentRequest[] memory) {
        uint256 totalRequests;
        for (uint256 i = 0; i < s_instituteStudents[msg.sender].length; i++) {
            totalRequests += s_requests[s_instituteStudents[msg.sender][i]].length;
        }

        DocumentRequest[] memory requests = new DocumentRequest[](totalRequests);
        uint256 index = 0;

        for (uint256 i = 0; i < s_instituteStudents[msg.sender].length; i++) {
            address student = s_instituteStudents[msg.sender][i];
            for (uint256 j = 0; j < s_requests[student].length; j++) {
                if (s_requests[student][j].exists) {
                    requests[index] = s_requests[student][j];
                    index++;
                }
            }
        }

        DocumentRequest[] memory filteredRequests = new DocumentRequest[](index);
        for (uint256 i = 0; i < index; i++) {
            filteredRequests[i] = requests[i];
        }

        return filteredRequests;
    }

    function approveDocumentRequest(address _studentAddress, string memory _docType, string memory _ipfsHash, uint64 _expiresIn) public {
        if(s_roles[msg.sender]!=Roles.INSTITUTE){
            revert KeepItSafe__OnlyForInstituteRole();
        }
        for(uint i=0; i<s_requests[_studentAddress].length; i++){
            if(s_requests[_studentAddress][i].exists && keccak256(abi.encodePacked(s_requests[_studentAddress][i].docType)) == keccak256(abi.encodePacked(_docType))){
                s_requests[_studentAddress][i].exists = false; // Mark as deleted
                break;
            }
        }
        // Here StudentAddress will be the owner
        if(_expiresIn==0){
            super.mint(_studentAddress, _studentAddress, _docType, _ipfsHash, 0);
        }
        // Here Institute will be the original owner and will be minting the Doc to the student for a particular time.
        else{
            super.mint(msg.sender, _studentAddress, _docType, _ipfsHash, _expiresIn);
        }
    }

    function getAllStudentsRequests() public view returns(DocumentRequest[] memory){
        if(s_roles[msg.sender]!=Roles.STUDENT){
            revert KeepItSafe__OnlyForStudentRole();
        }
        DocumentRequest[] memory requests = new DocumentRequest[](s_requests[msg.sender].length);
        for(uint256 i=0; i<s_requests[msg.sender].length; i++){
            if(s_requests[msg.sender][i].exists){
                requests[i] = s_requests[msg.sender][i];
            }
        }
        return requests;
    }

    function getStudentDocs() public view returns(StudentDocs[] memory){
        if(s_roles[msg.sender]!=Roles.STUDENT){
            revert KeepItSafe__OnlyForStudentRole();
        }
        return super.getDocsForAStudent(msg.sender);
    }
}