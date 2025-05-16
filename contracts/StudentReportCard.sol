// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title StudentReportCard
 * @dev A smart contract for storing and managing student academic records on blockchain
 */
contract StudentReportCard {
    address public owner;
    
    // Struct to store student information
    struct Student {
        string name;
        string studentId;
        bool isRegistered;
        mapping(string => SubjectGrade) grades; // Map subject to grade
        string[] subjects; // List of subjects for iteration
    }
    
    // Struct to store grade information
    struct SubjectGrade {
        uint8 score;
        string remarks;
        uint256 timestamp;
    }
    
    // Student data accessible by student ID
    mapping(string => Student) private students;
    string[] private studentIds; // For iteration
    
    // Access control for teachers
    mapping(address => bool) public authorizedTeachers;
    
    // Events
    event StudentRegistered(string studentId, string name);
    event GradeAdded(string studentId, string subject, uint8 score, string remarks);
    event TeacherAuthorized(address teacherAddress);
    event TeacherRevoked(address teacherAddress);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyAuthorized() {
        require(
            msg.sender == owner || authorizedTeachers[msg.sender],
            "Only authorized personnel can perform this action"
        );
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Authorize a new teacher to add grades
     * @param teacher Address of the teacher to authorize
     */
    function authorizeTeacher(address teacher) external onlyOwner {
        authorizedTeachers[teacher] = true;
        emit TeacherAuthorized(teacher);
    }
    
    /**
     * @dev Revoke a teacher's authorization
     * @param teacher Address of the teacher to revoke
     */
    function revokeTeacher(address teacher) external onlyOwner {
        authorizedTeachers[teacher] = false;
        emit TeacherRevoked(teacher);
    }
    
    /**
     * @dev Register a new student
     * @param studentId Unique ID for the student
     * @param name Student's full name
     */
    function registerStudent(string calldata studentId, string calldata name) external onlyAuthorized {
        require(bytes(studentId).length > 0, "Student ID cannot be empty");
        require(bytes(name).length > 0, "Student name cannot be empty");
        require(!students[studentId].isRegistered, "Student already registered");
        
        Student storage newStudent = students[studentId];
        newStudent.name = name;
        newStudent.studentId = studentId;
        newStudent.isRegistered = true;
        
        studentIds.push(studentId);
        emit StudentRegistered(studentId, name);
    }
    
    /**
     * @dev Add or update a grade for a student in a particular subject
     * @param studentId ID of the student
     * @param subject Name of the subject
     * @param score Numerical score (0-100)
     * @param remarks Additional comments on the grade
     */
    function addGrade(
        string calldata studentId,
        string calldata subject,
        uint8 score,
        string calldata remarks
    ) external onlyAuthorized {
        require(students[studentId].isRegistered, "Student not registered");
        require(score <= 100, "Score must be between 0 and 100");
        require(bytes(subject).length > 0, "Subject cannot be empty");
        
        Student storage student = students[studentId];
        
        // Check if this is a new subject for the student
        if (student.grades[subject].timestamp == 0) {
            student.subjects.push(subject);
        }
        
        // Add the grade
        student.grades[subject] = SubjectGrade({
            score: score,
            remarks: remarks,
            timestamp: block.timestamp
        });
        
        emit GradeAdded(studentId, subject, score, remarks);
    }
    
    /**
     * @dev Get a student's basic information
     * @param studentId ID of the student
     * @return name Student's name
     * @return isRegistered Registration status
     * @return subjectCount Number of subjects the student has grades for
     */
    function getStudentInfo(string calldata studentId) 
        external 
        view 
        returns (
            string memory name,
            bool isRegistered,
            uint256 subjectCount
        ) 
    {
        Student storage student = students[studentId];
        return (
            student.name,
            student.isRegistered,
            student.subjects.length
        );
    }
    
    /**
     * @dev Get a student's grade for a specific subject
     * @param studentId ID of the student
     * @param subject Name of the subject
     * @return score Numerical score
     * @return remarks Teacher's remarks
     * @return timestamp When the grade was recorded
     */
    function getGrade(string calldata studentId, string calldata subject) 
        external 
        view 
        returns (
            uint8 score,
            string memory remarks,
            uint256 timestamp
        ) 
    {
        require(students[studentId].isRegistered, "Student not registered");
        
        SubjectGrade storage grade = students[studentId].grades[subject];
        require(grade.timestamp > 0, "Grade not found for this subject");
        
        return (
            grade.score,
            grade.remarks,
            grade.timestamp
        );
    }
    
    /**
     * @dev Get all subjects for a student
     * @param studentId ID of the student
     * @return List of subjects
     */
    function getStudentSubjects(string calldata studentId) 
        external 
        view 
        returns (string[] memory) 
    {
        require(students[studentId].isRegistered, "Student not registered");
        return students[studentId].subjects;
    }
}
