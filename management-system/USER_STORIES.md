# Academic Management System - User Stories

## Executive Summary

The Academic Management System is a comprehensive platform designed to streamline academic operations for educational institutions. It provides role-based functionality for three user types: **Students**, **Professors**, and **Administrators**, focusing on attendance tracking, session management, student evaluation, and academic structure organization.

---

## Table of Contents

1. [User Roles](#user-roles)
2. [Student User Stories](#student-user-stories)
3. [Professor User Stories](#professor-user-stories)
4. [Administrator User Stories](#administrator-user-stories)
5. [System Features Overview](#system-features-overview)
6. [Epic Stories](#epic-stories)
7. [Non-Functional Requirements](#non-functional-requirements)

---

## User Roles

### 1. Student
- Access personal academic information
- Mark attendance via multiple methods
- View attendance statistics and records
- Justify absences with documentation
- View grades and transcripts
- Belong to one or more groups/sections

### 2. Professor
- Manage teaching sessions
- Take attendance using multiple modes
- Generate and manage QR codes
- Grade students and manage evaluations
- View student performance statistics
- Manage modules and course materials

### 3. Administrator
- Full system access and configuration
- Manage academic structure (departments, programs, semesters)
- Manage users (students, professors, admins)
- Manage locations and resources
- Override and manage all attendance records
- Generate institutional reports

---

## Student User Stories

### Authentication & Profile Management

**US-S-001: Student Login**
- **As a** student
- **I want to** log in to the system using my credentials
- **So that** I can access my personal academic information securely
- **Acceptance Criteria:**
  - Student can log in with username/email and password
  - System returns JWT access token and refresh token
  - Student is redirected to their dashboard
  - Failed login attempts show appropriate error messages

**US-S-002: View My Profile**
- **As a** student
- **I want to** view my profile information (CNE, CIN, name, filiere, groups)
- **So that** I can verify my academic registration details
- **Acceptance Criteria:**
  - Display student's full name, CNE, CIN
  - Show enrolled filiere/program
  - List all groups/sections student belongs to
  - Display contact information

**US-S-003: Change Password**
- **As a** student
- **I want to** change my password
- **So that** I can maintain account security
- **Acceptance Criteria:**
  - Require current password verification
  - Enforce password strength requirements
  - Confirm password change via email
  - Invalidate old sessions after password change

### Attendance Management

**US-S-004: Scan Session QR Code**
- **As a** student
- **I want to** scan a displayed QR code during a session
- **So that** my attendance is automatically recorded
- **Acceptance Criteria:**
  - Student can open QR scanner on mobile device
  - System validates QR code format and expiration
  - System checks timing window (15 min before to 30 min after session end)
  - System records attendance with status (PRESENT if within 15 min, LATE if after)
  - Student receives confirmation message with timestamp
  - Duplicate scans are prevented
  - System records device info and IP address for audit

**US-S-005: View My Attendance Records**
- **As a** student
- **I want to** view all my attendance records
- **So that** I can track my attendance history across all modules
- **Acceptance Criteria:**
  - Display attendance records in chronological order
  - Filter by module, date range, or status
  - Show session details (date, time, module, professor)
  - Display status (PRESENT, LATE, ABSENT, EXCUSED, CATCHING_UP)
  - Show justification status for absences
  - Paginated results for performance

**US-S-006: View My Attendance Statistics**
- **As a** student
- **I want to** view my attendance statistics
- **So that** I can monitor my attendance rate and identify modules with low attendance
- **Acceptance Criteria:**
  - Display overall attendance rate (percentage)
  - Show breakdown by status: present, late, absent, excused
  - Display absenteeism rate
  - Show statistics per module
  - Highlight modules with attendance below 75%
  - Display total sessions vs attended sessions

**US-S-007: Justify My Absence**
- **As a** student
- **I want to** provide justification for my absences
- **So that** my absence can be marked as excused with proper documentation
- **Acceptance Criteria:**
  - Student can select an absence record
  - Provide text justification (max 1000 characters)
  - Upload supporting document URL (medical certificate, official letter, etc.)
  - Submit justification for professor/admin review
  - Receive confirmation of submission
  - View justification status (pending, approved, rejected)

**US-S-008: Receive Absence Notifications**
- **As a** student
- **I want to** receive notifications when I'm marked absent
- **So that** I can take corrective action or provide justification
- **Acceptance Criteria:**
  - Receive notification when system auto-marks as ABSENT
  - Notification includes session details and date
  - Able to click through to justify absence
  - Option to disable notifications in settings

### Academic Performance

**US-S-009: View My Grades**
- **As a** student
- **I want to** view my grades for all modules
- **So that** I can track my academic performance
- **Acceptance Criteria:**
  - Display grades grouped by semester
  - Show module name, code, and type
  - Display grade value and percentage
  - Show credit hours per module
  - Display grade status (graded, pending)
  - Calculate and display semester GPA

**US-S-010: View My Transcript**
- **As a** student
- **I want to** generate and view my academic transcript
- **So that** I can see my complete academic record
- **Acceptance Criteria:**
  - Display all completed modules with grades
  - Grouped by semester and academic year
  - Show cumulative GPA
  - Include credit hours earned vs required
  - Show academic standing (good standing, probation, etc.)
  - Option to download/print transcript

### Session Information

**US-S-011: View My Schedule**
- **As a** student
- **I want to** view my upcoming sessions/classes
- **So that** I can plan my day and avoid missing classes
- **Acceptance Criteria:**
  - Display sessions in calendar view or list view
  - Filter by day, week, or month
  - Show session details: module, professor, location, time, type
  - Display session type (lecture, lab, exam, workshop)
  - Highlight current/ongoing sessions
  - Show QR code status if applicable (active, inactive)

---

## Professor User Stories

### Authentication & Profile Management

**US-P-001: Professor Login**
- **As a** professor
- **I want to** log in to the system
- **So that** I can access teaching and student management features
- **Acceptance Criteria:**
  - Professor can log in with username and password
  - System returns JWT tokens
  - Redirect to professor dashboard
  - Display upcoming sessions and pending tasks

**US-P-002: View My Profile**
- **As a** professor
- **I want to** view my profile information
- **So that** I can verify my employment and teaching details
- **Acceptance Criteria:**
  - Display full name, grade, specialization
  - Show department affiliation
  - List assigned modules
  - Display contact information

### Session Management

**US-P-003: Create New Session**
- **As a** professor
- **I want to** create a new teaching session
- **So that** I can schedule classes, labs, or exams
- **Acceptance Criteria:**
  - Specify session name and type (lecture, lab, exam, workshop)
  - Select module from assigned modules
  - Choose location with availability checking
  - Set date, start time, and duration
  - Assign student groups
  - Select attendance mode (manual, professor scan, student scan)
  - System validates no scheduling conflicts
  - System validates location capacity vs enrolled students

**US-P-004: Update Session Details**
- **As a** professor
- **I want to** update session information
- **So that** I can accommodate schedule changes or room changes
- **Acceptance Criteria:**
  - Modify session date, time, or duration
  - Change location (with availability check)
  - Update attendance mode
  - Cannot modify completed sessions
  - System notifies affected students of changes
  - System checks for conflicts with new schedule

**US-P-005: Cancel Session**
- **As a** professor
- **I want to** cancel a scheduled session
- **So that** students are informed when class is not happening
- **Acceptance Criteria:**
  - Mark session as cancelled
  - Provide cancellation reason
  - System notifies all enrolled students
  - Cancelled sessions appear in schedule with cancelled status
  - Cannot cancel already-started or completed sessions

**US-P-006: Set Attendance Mode for Session**
- **As a** professor
- **I want to** choose how attendance will be taken
- **So that** I can use the most appropriate method for the session type
- **Acceptance Criteria:**
  - Select MANUAL, PROFESSOR_SCAN, or STUDENT_SCAN mode
  - Can change mode before session starts
  - Cannot change mode after attendance is taken
  - Mode affects available attendance marking options

### Attendance Management

**US-P-007: Generate Session QR Code**
- **As a** professor
- **I want to** generate a QR code for a session
- **So that** students can scan it to mark their attendance
- **Acceptance Criteria:**
  - Generate QR code with format: SESSION:{sessionId}:{timestamp}
  - QR code is Base64-encoded PNG image (300x300px)
  - Set validity period (default 30 minutes, configurable)
  - QR code is not active until explicitly activated
  - Can regenerate QR code for security
  - Display QR code in large format for projection

**US-P-008: Activate/Deactivate Session QR Code**
- **As a** professor
- **I want to** control when the session QR code is active
- **So that** students can only scan during the actual session
- **Acceptance Criteria:**
  - Activate QR code at session start
  - Set custom validity period (minutes)
  - Deactivate QR code after attendance period
  - Student scans after deactivation are rejected
  - System shows active/inactive status clearly

**US-P-009: Scan Student QR Codes (Professor Scan Mode)**
- **As a** professor
- **I want to** scan students' QR codes
- **So that** I can mark attendance using my device
- **Acceptance Criteria:**
  - Open QR scanner on professor's device
  - Scan student QR code (format: STUDENT:{id}:{CNE})
  - System validates student exists and CNE matches
  - System checks student is enrolled in session
  - System determines status based on current time
  - Prevent duplicate scans
  - Show confirmation with student name and status
  - Display running count of scanned students

**US-P-010: Manually Mark Attendance**
- **As a** professor
- **I want to** manually mark attendance for students
- **So that** I can record attendance for makeup sessions or override system records
- **Acceptance Criteria:**
  - View list of all enrolled students
  - Mark status for each: PRESENT, LATE, ABSENT, EXCUSED, CATCHING_UP
  - Specify scan time (defaults to current time)
  - Option to mark all remaining students as ABSENT
  - Save attendance with professor as marker
  - Display confirmation summary

**US-P-011: Mark Attendance by CNE**
- **As a** professor
- **I want to** mark attendance using student CNE numbers
- **So that** I can quickly record attendance from a paper list
- **Acceptance Criteria:**
  - Input student CNE (not UUID)
  - System finds student by CNE
  - Validates student enrollment in session
  - Checks timing constraints
  - Automatically determines status (PRESENT/LATE)
  - Records device info and IP address
  - Shows confirmation with student name
  - Continues to next CNE entry for batch processing

**US-P-012: View Session Attendance**
- **As a** professor
- **I want to** view attendance records for a specific session
- **So that** I can see who attended and who was absent
- **Acceptance Criteria:**
  - Display all students enrolled in session
  - Show attendance status for each student
  - Highlight students with no attendance record
  - Display scan time for each record
  - Show justification status for absences
  - Export attendance list to CSV/PDF
  - Calculate attendance rate for the session

**US-P-013: View Module Attendance Statistics**
- **As a** professor
- **I want to** view attendance statistics for my modules
- **So that** I can identify students with poor attendance
- **Acceptance Criteria:**
  - Select module from assigned modules
  - Display overall module attendance rate
  - List students with attendance below threshold (e.g., 75%)
  - Show per-student statistics (present, late, absent counts)
  - Filter by date range or specific groups
  - Identify patterns (e.g., students frequently late)
  - Export report for academic advising

**US-P-014: Approve or Reject Absence Justification**
- **As a** professor
- **I want to** review absence justifications
- **So that** I can approve valid excuses and maintain attendance integrity
- **Acceptance Criteria:**
  - View list of pending justifications for my sessions
  - Display student name, session, absence date
  - Read justification note
  - View attached documentation (if provided)
  - Approve or reject with optional notes
  - System updates attendance status if approved
  - Student receives notification of decision

**US-P-015: Mark Session Attendance as Complete**
- **As a** professor
- **I want to** mark attendance as finalized
- **So that** no further changes can be made accidentally
- **Acceptance Criteria:**
  - Mark session's attendanceTaken flag as true
  - Prevents further attendance modifications
  - System marks remaining students as ABSENT (if not already done)
  - Generate final attendance report
  - Session marked as completed

### Student Evaluation

**US-P-016: Grade Students**
- **As a** professor
- **I want to** enter grades for students
- **So that** they can see their academic performance
- **Acceptance Criteria:**
  - Select module and evaluation type (exam, quiz, project, etc.)
  - Enter grades for each student
  - Specify max points and weightage
  - System validates grade within range
  - Option for bulk grade import via CSV
  - Grades are immediately visible to students
  - System calculates overall module grade

**US-P-017: View Student Performance**
- **As a** professor
- **I want to** view a student's performance in my module
- **So that** I can provide feedback and identify struggling students
- **Acceptance Criteria:**
  - Select student from module enrollment
  - Display all grades (exams, quizzes, projects)
  - Show attendance records
  - Display calculated module grade
  - Compare to class average
  - View historical performance trends
  - Access student contact information for follow-up

**US-P-018: Manage Module Evaluations**
- **As a** professor
- **I want to** create and manage evaluation criteria
- **So that** I can define grading structure for my modules
- **Acceptance Criteria:**
  - Create evaluation types (midterm, final, project, etc.)
  - Set max points and weightage for each
  - Define passing criteria
  - Update evaluation details before grading starts
  - Delete unused evaluations
  - System prevents deletion of evaluations with existing grades

### Session QR Code Management

**US-P-019: Download QR Code Image**
- **As a** professor
- **I want to** download the session QR code as an image
- **So that** I can share it via projection or print it
- **Acceptance Criteria:**
  - Download QR code as PNG file
  - Image is 300x300 pixels, clear and scannable
  - Filename includes session name and date
  - Option to download in different sizes
  - Include session info text below QR code

---

## Administrator User Stories

### System Administration

**US-A-001: Admin Login**
- **As an** administrator
- **I want to** log in to the system
- **So that** I can manage the entire academic institution
- **Acceptance Criteria:**
  - Admin can log in with credentials
  - Access to admin dashboard
  - View system statistics and pending tasks
  - Access to all modules and management features

**US-A-002: Manage Departments**
- **As an** administrator
- **I want to** create and manage departments
- **So that** I can organize the academic institution structure
- **Acceptance Criteria:**
  - Create new department with name and description
  - Update department details
  - View all departments with filiere counts
  - Cannot delete department with active filieres
  - Assign department heads

**US-A-003: Manage Filieres (Programs)**
- **As an** administrator
- **I want to** create and manage study programs
- **So that** I can define academic pathways for students
- **Acceptance Criteria:**
  - Create filiere with name and department
  - Update filiere details
  - View all filieres with student counts
  - Assign filieres to departments
  - Define program duration and credit requirements

**US-A-004: Manage Semesters**
- **As an** administrator
- **I want to** create and manage semesters
- **So that** I can organize modules into academic periods
- **Acceptance Criteria:**
  - Create semester with number and filiere
  - Update semester details
  - View all semesters with module counts
  - Define semester start and end dates

**US-A-005: Manage Modules**
- **As an** administrator
- **I want to** create and manage modules/courses
- **So that** they can be assigned to professors and students
- **Acceptance Criteria:**
  - Create module with name, code, description
  - Assign to semester
  - Set credit hours and type
  - Assign professors to modules
  - View module details and statistics
  - Cannot delete modules with active sessions

**US-A-006: Manage Locations**
- **As an** administrator
- **I want to** create and manage classrooms and labs
- **So that** sessions can be scheduled in appropriate spaces
- **Acceptance Criteria:**
  - Create location with building, room number
  - Set capacity and room type (classroom, lab, amphitheater)
  - Assign to department
  - List available equipment
  - View location utilization statistics
  - Check availability for time slots

### User Management

**US-A-007: Register Students**
- **As an** administrator
- **I want to** register new students
- **So that** they can access the system
- **Acceptance Criteria:**
  - Enter student details (name, CNE, CIN, email)
  - Assign to filiere
  - Assign to one or more groups
  - Generate student QR code automatically
  - Create login credentials
  - Send welcome email with credentials
  - Option for bulk student import via CSV

**US-A-008: Register Professors**
- **As an** administrator
- **I want to** register new professors
- **So that** they can teach and manage sessions
- **Acceptance Criteria:**
  - Enter professor details (name, email, grade, specialization)
  - Assign to department
  - Assign modules to teach
  - Create login credentials
  - Send welcome email
  - Set office hours and contact info

**US-A-009: Register Administrators**
- **As an** administrator
- **I want to** register new administrators
- **So that** they can help manage the system
- **Acceptance Criteria:**
  - Enter admin details (name, email)
  - Set admin permission level
  - Create login credentials
  - Send welcome email
  - Define access restrictions (if needed)

**US-A-010: Update User Information**
- **As an** administrator
- **I want to** update user profiles
- **So that** information remains accurate
- **Acceptance Criteria:**
  - Search for user by name, email, or ID
  - Update personal information
  - Change role or permissions
  - Reset password if needed
  - Deactivate/reactivate accounts
  - View user activity history

**US-A-011: Bulk Student Import**
- **As an** administrator
- **I want to** import multiple students at once
- **So that** I can efficiently onboard large student cohorts
- **Acceptance Criteria:**
  - Upload CSV file with student data
  - System validates data format
  - Preview import with validation errors
  - Generate QR codes for all students
  - Create accounts in batch
  - Generate credential report for distribution
  - Handle duplicate CNE/CIN detection

### Group Management

**US-A-012: Create Student Groups**
- **As an** administrator
- **I want to** create and manage student groups/sections
- **So that** sessions can be assigned to specific student cohorts
- **Acceptance Criteria:**
  - Create group with name and type (class, section, lab group)
  - Assign to module or filiere
  - Set maximum capacity
  - View all groups with student counts

**US-A-013: Enroll Students in Groups**
- **As an** administrator
- **I want to** add students to groups
- **So that** they can attend sessions
- **Acceptance Criteria:**
  - Select group
  - Add students individually or in bulk
  - Check for capacity limits
  - Prevent duplicate enrollment
  - Remove students from groups
  - Transfer students between groups

**US-A-014: Assign Groups to Sessions**
- **As an** administrator
- **I want to** assign groups to sessions
- **So that** the correct students can attend
- **Acceptance Criteria:**
  - Select session
  - Add one or more groups
  - System calculates total enrolled students
  - Verify location capacity
  - Remove groups from sessions
  - View which students are enrolled

### Attendance Administration

**US-A-015: Override Attendance Records**
- **As an** administrator
- **I want to** modify any attendance record
- **So that** I can correct errors or handle special cases
- **Acceptance Criteria:**
  - Search for attendance record
  - Modify status, date, or time
  - Add or edit justification
  - Mark as justified/unjustified
  - View edit history and audit trail
  - Provide reason for modification

**US-A-016: Delete Attendance Records**
- **As an** administrator
- **I want to** delete incorrect attendance records
- **So that** the system maintains accurate data
- **Acceptance Criteria:**
  - Find and select attendance record
  - Confirm deletion with reason
  - System logs deletion in audit trail
  - Cannot be undone (permanent deletion)
  - Notification sent to affected student

**US-A-017: View System-Wide Attendance Statistics**
- **As an** administrator
- **I want to** view attendance statistics across the institution
- **So that** I can identify trends and issues
- **Acceptance Criteria:**
  - Overall institutional attendance rate
  - Breakdown by department, filiere, module
  - Identify modules with low attendance
  - View professor attendance taking compliance
  - Generate reports for academic committees
  - Export data for analysis

**US-A-018: Configure Attendance Settings**
- **As an** administrator
- **I want to** configure attendance parameters
- **So that** the system matches institutional policies
- **Acceptance Criteria:**
  - Set early period minutes (default 15)
  - Set grace period minutes (default 30)
  - Set late threshold minutes (default 15)
  - Configure auto-marking schedule (default 1 PM and 7 PM)
  - Set minimum attendance percentage for passing
  - Enable/disable location verification

**US-A-019: Monitor Automated Absent-Marking**
- **As an** administrator
- **I want to** monitor the automated absent-marking job
- **So that** I can ensure it's working correctly
- **Acceptance Criteria:**
  - View job execution history
  - See number of students marked absent per run
  - View sessions processed
  - Check for errors or failures
  - Manual trigger option for specific sessions
  - View job logs

### Session Administration

**US-A-020: View All Sessions**
- **As an** administrator
- **I want to** view all sessions across the institution
- **So that** I can monitor scheduling and attendance compliance
- **Acceptance Criteria:**
  - List all sessions with filters (date, module, professor, status)
  - View session details
  - See attendance status (not started, in progress, completed)
  - Identify sessions with attendance issues
  - Export session schedule

**US-A-021: Modify Any Session**
- **As an** administrator
- **I want to** modify any session
- **So that** I can handle conflicts or emergencies
- **Acceptance Criteria:**
  - Update session details (time, location, groups)
  - Change assigned professor
  - Cancel or reschedule sessions
  - Force mark attendance as taken
  - Override QR code settings
  - System notifies affected users

**US-A-022: Resolve Session Conflicts**
- **As an** administrator
- **I want to** detect and resolve session conflicts
- **So that** resources and users are not double-booked
- **Acceptance Criteria:**
  - System highlights conflicts (location, professor, groups)
  - View conflicting sessions side-by-side
  - Suggest alternative times or locations
  - Modify one session to resolve conflict
  - View conflict history

### Reporting & Analytics

**US-A-023: Generate Institutional Reports**
- **As an** administrator
- **I want to** generate comprehensive reports
- **So that** I can provide insights to leadership
- **Acceptance Criteria:**
  - Attendance reports by department, filiere, module
  - Student performance reports
  - Professor activity reports
  - Location utilization reports
  - Custom date ranges
  - Export to PDF, Excel, or CSV

**US-A-024: View System Audit Logs**
- **As an** administrator
- **I want to** view system activity logs
- **So that** I can track user actions and troubleshoot issues
- **Acceptance Criteria:**
  - View all user logins
  - Track attendance modifications
  - See grade changes with editor
  - Filter by user, action type, or date
  - Export audit logs
  - Search logs by keyword

---

## System Features Overview

### Core Features

1. **Multi-Role Authentication System**
   - JWT-based authentication with refresh tokens
   - Role-based access control (ADMIN, PROFESSOR, STUDENT)
   - Secure password reset flow

2. **Flexible Attendance Tracking**
   - Three attendance modes (Manual, Professor Scan, Student Scan)
   - QR code generation and validation
   - Automatic status determination (PRESENT/LATE)
   - Automated absent-marking via scheduled job (1 PM and 7 PM daily)
   - Attendance by CNE for quick entry

3. **Academic Structure Management**
   - Hierarchical organization: Department → Filiere → Semester → Module
   - Student group/section management
   - Professor-module assignments

4. **Session Management**
   - Multiple session types (lecture, lab, exam, workshop)
   - Location booking with conflict detection
   - QR code lifecycle management
   - Session completion workflow

5. **Student Evaluation**
   - Grade entry and management
   - Transcript generation
   - Performance statistics

6. **Comprehensive Reporting**
   - 24+ attendance endpoints
   - Real-time statistics
   - Export capabilities
   - Audit trail tracking

### Technical Features

1. **Security**
   - JWT authentication
   - BCrypt password encryption
   - Role-based authorization
   - Audit logging

2. **Database**
   - PostgreSQL with HikariCP
   - Hibernate ORM
   - Transactional integrity

3. **API**
   - RESTful design
   - Swagger/OpenAPI documentation
   - Pagination support
   - Comprehensive error handling

4. **Integration**
   - QR code generation (ZXing)
   - Email notifications (optional)
   - Scheduled tasks (Spring Scheduler)

---

## Epic Stories

### Epic 1: Attendance Revolution
**Goal**: Transform attendance tracking from manual paper-based to automated digital system

**User Stories Included**:
- US-S-004: Scan Session QR Code
- US-P-007: Generate Session QR Code
- US-P-008: Activate/Deactivate Session QR Code
- US-P-009: Scan Student QR Codes
- US-P-011: Mark Attendance by CNE
- US-A-018: Configure Attendance Settings
- US-A-019: Monitor Automated Absent-Marking

**Business Value**:
- Reduce attendance taking time from 10-15 minutes to under 2 minutes
- Eliminate paper-based attendance sheets
- Provide real-time attendance data
- Reduce fraud and proxy attendance
- Automatic absent-marking reduces professor workload

**Success Metrics**:
- 95% of sessions use digital attendance
- Average attendance marking time < 2 minutes
- 100% attendance coverage (no missing records)
- Zero manual absent-marking needed

### Epic 2: Student Self-Service Portal
**Goal**: Empower students with visibility and control over their academic records

**User Stories Included**:
- US-S-005: View My Attendance Records
- US-S-006: View My Attendance Statistics
- US-S-007: Justify My Absence
- US-S-009: View My Grades
- US-S-010: View My Transcript
- US-S-011: View My Schedule

**Business Value**:
- Reduce student inquiries to admin staff by 60%
- Improve student engagement with transparent data
- Enable proactive attendance management
- Facilitate academic advising

**Success Metrics**:
- 80% of students actively use the portal
- 50% reduction in attendance-related inquiries
- 90% of absences justified within 48 hours
- Student satisfaction score > 4.0/5.0

### Epic 3: Academic Administration Automation
**Goal**: Streamline administrative processes and reduce manual data entry

**User Stories Included**:
- US-A-002 through US-A-006: Manage Academic Structure
- US-A-007 through US-A-009: User Registration
- US-A-011: Bulk Student Import
- US-A-012 through US-A-014: Group Management
- US-A-019: Monitor Automated Absent-Marking

**Business Value**:
- Reduce registration time from 10 min/student to 30 sec/student
- Bulk import 1000+ students in under 5 minutes
- Automatic QR code generation eliminates manual work
- Scheduled jobs reduce manual absent-marking

**Success Metrics**:
- 95% time reduction in student registration
- Zero manual QR code generation needed
- 100% session attendance completion rate
- Admin time savings: 20 hours/week

### Epic 4: Professor Efficiency Tools
**Goal**: Provide professors with powerful tools to manage teaching activities

**User Stories Included**:
- US-P-003 through US-P-006: Session Management
- US-P-010 through US-P-015: Attendance Management
- US-P-016 through US-P-018: Student Evaluation
- US-P-019: Download QR Code Image

**Business Value**:
- Simplify session creation and scheduling
- Multiple attendance options for different scenarios
- Integrated grading and attendance analytics
- Early identification of at-risk students

**Success Metrics**:
- 90% of professors use the platform regularly
- Average session creation time < 3 minutes
- 80% of sessions use automated attendance
- Professor satisfaction score > 4.0/5.0

### Epic 5: Data-Driven Decision Making
**Goal**: Provide institutional leadership with actionable insights

**User Stories Included**:
- US-A-017: View System-Wide Attendance Statistics
- US-A-023: Generate Institutional Reports
- US-A-024: View System Audit Logs
- US-P-013: View Module Attendance Statistics
- US-P-017: View Student Performance

**Business Value**:
- Identify trends in attendance and performance
- Enable evidence-based policy decisions
- Early intervention for struggling students or problematic courses
- Accountability through audit trails

**Success Metrics**:
- Reports generated weekly for leadership
- 30% improvement in early intervention for at-risk students
- 20% reduction in course failure rates
- Complete audit trail for compliance

---

## Non-Functional Requirements

### Performance
- **NFR-1**: System shall support 10,000 concurrent users
- **NFR-2**: API response time shall be < 500ms for 95% of requests
- **NFR-3**: QR code generation shall complete within 2 seconds
- **NFR-4**: Scheduled jobs shall complete within 5 minutes

### Security
- **NFR-5**: All passwords shall be encrypted using BCrypt
- **NFR-6**: JWT tokens shall expire after 24 hours
- **NFR-7**: All API endpoints shall require authentication except login
- **NFR-8**: System shall log all data modifications with user and timestamp

### Scalability
- **NFR-9**: System shall support up to 50,000 students
- **NFR-10**: Database shall handle 1 million attendance records efficiently
- **NFR-11**: System shall support horizontal scaling for increased load

### Reliability
- **NFR-12**: System uptime shall be 99.5% excluding planned maintenance
- **NFR-13**: Automated backups shall run daily
- **NFR-14**: System shall recover from failure within 15 minutes

### Usability
- **NFR-15**: Mobile QR scanning shall work on iOS and Android
- **NFR-16**: UI shall be responsive for screens 320px to 2560px wide
- **NFR-17**: API documentation shall be accessible via Swagger UI
- **NFR-18**: Error messages shall be clear and actionable

### Maintainability
- **NFR-19**: Code shall follow Spring Boot best practices
- **NFR-20**: All public methods shall be documented
- **NFR-21**: Unit test coverage shall be > 70%
- **NFR-22**: System logs shall be structured and searchable

---

## Implementation Priorities

### Phase 1: Foundation (Completed)
- ✅ Authentication system (JWT)
- ✅ User management (Students, Professors, Admins)
- ✅ Academic structure (Departments, Filieres, Semesters, Modules)
- ✅ Basic session management

### Phase 2: Core Attendance (Completed)
- ✅ Manual attendance entry
- ✅ QR code generation and scanning
- ✅ Three attendance modes
- ✅ Attendance statistics
- ✅ Absence justification
- ✅ Automated absent-marking (scheduled job)
- ✅ Attendance by CNE endpoint

### Phase 3: Enhanced Features (Current)
- Student and professor dashboards
- Email notifications
- Advanced reporting
- Mobile app development
- Location-based verification

### Phase 4: Advanced Analytics (Future)
- Machine learning for attendance prediction
- Risk scoring for students
- Professor performance analytics
- Institutional benchmarking
- Predictive insights

---

## Conclusion

The Academic Management System provides a comprehensive solution for managing academic operations with a strong focus on modernizing attendance tracking. The system reduces administrative burden, improves data accuracy, empowers students with self-service capabilities, and provides actionable insights through analytics.

**Key Differentiators**:
1. **Flexible Attendance**: Three modes plus automated absent-marking
2. **CNE-Based Entry**: Quick attendance marking without looking up UUIDs
3. **Automated Workflows**: Scheduled jobs eliminate manual tasks
4. **Comprehensive API**: 24+ attendance endpoints for complete control
5. **Real-Time Statistics**: Instant visibility into attendance and performance
6. **Audit Trail**: Complete accountability for all actions

**Business Impact**:
- 90% reduction in attendance taking time
- 60% reduction in administrative inquiries
- 100% attendance record coverage
- 30% improvement in early intervention
- 20 hours/week admin time savings

This system positions the institution for digital transformation while maintaining flexibility to accommodate different teaching styles and institutional policies.
