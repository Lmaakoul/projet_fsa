# Academic Management System

A comprehensive academic institution management system built with Spring Boot, featuring advanced attendance tracking through multiple QR code scanning methods, session management, and student evaluation.

## Table of Contents

- [Features](#features)
- [Technology Stack](#technology-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [Attendance Workflow](#attendance-workflow)
  - [Overview](#overview)
  - [Attendance Modes](#attendance-modes)
  - [QR Code Generation](#qr-code-generation)
  - [Check-In Process](#check-in-process)
  - [Status Determination](#status-determination)
  - [Justifying Absences](#justifying-absences)
- [API Documentation](#api-documentation)
- [Database Schema](#database-schema)
- [Usage Guide](#usage-guide)
- [Development](#development)

---

## Features

### Core Functionality
- **User Management**: Role-based access control for Admins, Professors, and Students
- **Academic Structure**: Department, Program (Filiere), Semester, and Module management
- **Session Management**: Schedule lectures, labs, exams, and workshops with conflict detection
- **Location Management**: Classroom/lab booking with capacity and availability tracking
- **Group Management**: Organize students into classes and sections

### Advanced Attendance System
- **Multiple Attendance Modes**:
  - Manual entry by professor or admin
  - Mark attendance by student CNE (National Student Code)
  - Professor scans student QR codes
  - Students scan session QR codes
- **QR Code Technology**:
  - Secure QR code generation with expiration
  - Base64-encoded PNG images for easy display
  - Replay attack prevention
- **Smart Status Detection**: Automatic PRESENT/LATE determination based on scan timing
- **Automated Absent-Marking**: Scheduled job automatically marks absent students at 1 PM and 7 PM daily
- **Attendance Validation**:
  - Timing windows (15 min early, 30 min grace period)
  - Location verification (optional GPS-based)
  - Enrollment verification
  - Duplicate prevention
- **Absence Justification**: Allow students to provide documentation for absences
- **Comprehensive Statistics**: Real-time attendance rates and reports with 24+ endpoints

### Additional Features
- **JWT Authentication**: Secure token-based authentication with refresh tokens
- **Student Evaluation**: Grade management and transcript generation
- **Audit Trail**: Track device info, IP addresses, and timestamps
- **RESTful API**: Well-documented endpoints with Swagger/OpenAPI

---

## Technology Stack

**Backend Framework**:
- Spring Boot 3.5.6
- Spring Data JPA
- Spring Security
- Spring Web (REST)
- Spring Actuator

**Database**:
- PostgreSQL 15
- HikariCP Connection Pooling
- Hibernate ORM

**Security & Authentication**:
- JWT (JSON Web Tokens) with jjwt 0.12.3
- BCrypt password encoding
- Role-based access control

**Libraries & Tools**:
- Google ZXing 3.5.3 (QR Code generation)
- Lombok (reduce boilerplate)
- SpringDoc OpenAPI 2.8.13 (API documentation)
- Maven (build tool)
- Docker & Docker Compose

**Java Version**: 21

---

## Prerequisites

Before you begin, ensure you have the following installed:

- **Java 21** or higher ([Download](https://adoptium.net/))
- **Maven 3.6+** or use the included Maven Wrapper
- **Docker & Docker Compose** ([Download](https://www.docker.com/))
- **Git** ([Download](https://git-scm.com/))

---

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/management-system.git
cd management-system
```

### 2. Set Up Environment Variables

Copy the example environment file and configure it:

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```env
# Database Configuration
DATABASE_URL=jdbc:postgresql://localhost:5432/academic_db
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=your_secure_password

# JWT Configuration (use a strong secret key)
JWT_SECRET=mySecretKeyForJWTTokenGenerationThatIsAtLeast512BitsLongForHS512Algorithm

# Server Configuration
SERVER_PORT=8080

# CORS Configuration
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:4200

# Email Configuration (optional - for password reset)
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
```

### 3. Start the Database

Using Docker Compose:

```bash
docker-compose up -d
```

This will start:
- **PostgreSQL** on port `5432`
- **pgAdmin** on port `5050` (access at `http://localhost:5050`)

**pgAdmin Credentials**:
- Email: `admin@academic.com`
- Password: `admin123`

### 4. Build the Application

Using Maven:

```bash
./mvnw clean install
```

Or if you have Maven installed:

```bash
mvn clean install
```

---

## Configuration

The application uses `src/main/resources/application.yml` for configuration. Key settings include:

### Database Configuration
```yaml
spring:
  datasource:
    url: ${DATABASE_URL:jdbc:postgresql://localhost:5432/academic_db}
    username: ${DATABASE_USERNAME:postgres}
    password: ${DATABASE_PASSWORD:postgres123}
```

### JWT Configuration
```yaml
jwt:
  secret: ${JWT_SECRET:your-secret-key}
  expiration: 86400000  # 24 hours
  refresh-expiration: 604800000  # 7 days
```

### Attendance Configuration
```yaml
attendance:
  early-period-minutes: 15   # Students can scan 15 min before session
  grace-period-minutes: 30   # Students can scan up to 30 min after session ends
  late-threshold-minutes: 15 # After 15 min from start, marked as LATE
```

### CORS Configuration
```yaml
cors:
  allowed-origins: http://localhost:3000,http://localhost:4200,http://localhost:8081
```

---

## Running the Application

### Using Maven

```bash
./mvnw spring-boot:run
```

Or:

```bash
mvn spring-boot:run
```

### Using Java

```bash
java -jar target/management-system-0.0.1-SNAPSHOT.jar
```

The application will start on `http://localhost:8080`

---

## Attendance Workflow

### Overview

The attendance system supports three distinct modes to accommodate different institutional needs and scenarios. The workflow ensures accurate tracking, prevents fraud, and provides comprehensive audit trails.

```
┌─────────────────────────────────────────────────────────────────┐
│                    ATTENDANCE WORKFLOW                           │
└─────────────────────────────────────────────────────────────────┘

1. SESSION SETUP
   └─ Create Session → Set Attendance Mode → Add Student Groups

2. ATTENDANCE MODE SELECTION
   ├─ MANUAL: Professor/Admin enters attendance manually
   ├─ PROFESSOR_SCAN: Professor scans student QR codes
   └─ STUDENT_SCAN: Students scan session QR code

3. CHECK-IN PROCESS
   └─ Validation → Status Determination → Record Creation

4. POST-ATTENDANCE
   ├─ View Attendance Statistics
   ├─ Justify Absences
   └─ Generate Reports

5. SESSION COMPLETION
   └─ Mark Attendance Taken → Complete Session
```

### Attendance Modes

The system supports three attendance modes, each suited for different scenarios:

#### 1. MANUAL Mode

**Use Case**: Traditional attendance taking or makeup entries

**Process**:
1. Professor or Admin accesses the attendance API
2. Manually enters attendance for each student
3. Specifies status: PRESENT, ABSENT, LATE, EXCUSED, or CATCHING_UP

**API Endpoints**:
- `POST /api/attendance` (using student UUID)
- `POST /api/attendance/by-cne` (using student CNE)

**Request Example (by UUID)**:
```json
{
  "studentId": "uuid-here",
  "sessionId": "uuid-here",
  "date": "2024-03-15",
  "status": "PRESENT",
  "scannedAt": "2024-03-15T10:05:00"
}
```

**Request Example (by CNE)**:
```json
{
  "cne": "CNE123456",
  "sessionId": "uuid-here",
  "deviceInfo": "Professor's Device",
  "ipAddress": "192.168.1.100"
}
```

**Note**: The by-CNE endpoint automatically determines status (PRESENT/LATE) based on scan timing, making it ideal when professors have a list of CNE numbers but not UUIDs.

#### 2. PROFESSOR_SCAN Mode

**Use Case**: Professor has a scanning device, students show their QR codes

**Process**:
1. Each student has a unique QR code (format: `STUDENT:{UUID}:{CNE}`)
2. Students display their QR codes (printed ID cards or mobile phones)
3. Professor scans each student's QR code using their device
4. System validates and records attendance automatically

**API Endpoint**: `POST /api/attendance/scan-qr`

**Request Example**:
```json
{
  "sessionId": "uuid-here",
  "studentQrCode": "STUDENT:123e4567-e89b-12d3-a456-426614174000:CNE123456",
  "deviceInfo": "Professor's iPhone 12",
  "ipAddress": "192.168.1.100"
}
```

**Validation Steps**:
- Parse QR code format
- Verify student exists and CNE matches
- Check session timing window
- Verify student enrollment in session groups
- Prevent duplicate attendance
- Determine status based on scan time

#### 3. STUDENT_SCAN Mode

**Use Case**: Contactless attendance, students use their own devices

**Process**:
1. Professor generates and activates session QR code
2. QR code displayed on projector/screen (format: `SESSION:{UUID}:{DATETIME}`)
3. Each student scans the QR code with their device
4. System validates and records attendance for each student

**API Endpoint**: `POST /api/attendance/scan-session-qr`

**Request Example**:
```json
{
  "studentId": "uuid-here",
  "sessionQrCode": "SESSION:123e4567-e89b-12d3-a456-426614174000:2024-03-15T10:00:00",
  "latitude": 34.0522,
  "longitude": -118.2437,
  "deviceInfo": "Student's Android Phone",
  "ipAddress": "192.168.1.150"
}
```

**Advanced Validation**:
- Parse and verify QR format
- Validate QR code matches current session
- Check QR code expiration (default 30 minutes)
- Verify session timing window
- Confirm student enrollment
- Optional: Location verification (within 500m radius)
- Prevent duplicate scans
- Determine attendance status

### QR Code Generation

#### Student QR Codes

**Format**: `STUDENT:{studentId}:{cne}`

**Characteristics**:
- Generated once during student registration
- Never expires
- Stored as Base64-encoded PNG image (300x300px)
- Can be printed on student ID cards
- Used for PROFESSOR_SCAN mode

**Generation**: Automatic when student account is created

#### Session QR Codes

**Format**: `SESSION:{sessionId}:{timestamp}`

**Characteristics**:
- Generated per session
- Time-limited (default 30 minutes)
- Can be regenerated for security
- Prevents replay attacks
- Used for STUDENT_SCAN mode

**API Endpoints**:
- Generate: `POST /api/sessions/{id}/generate-qr`
- Activate: `POST /api/sessions/{id}/activate-qr`
- Regenerate: `POST /api/sessions/{id}/regenerate-qr`
- Deactivate: `POST /api/sessions/{id}/deactivate-qr`
- Download Image: `GET /api/sessions/{id}/qr-code` (returns PNG)

**Activation Example**:
```json
POST /api/sessions/{id}/activate-qr
{
  "validityPeriodMinutes": 30
}
```

### Check-In Process

#### Timing Windows

The system uses configurable timing windows to determine when students can check in:

```
Session Start Time: 10:00 AM
Session Duration: 60 minutes
Session End Time: 11:00 AM

┌─────────────────────────────────────────────────────────────┐
│ Timeline                                                     │
├─────────────────────────────────────────────────────────────┤
│ 9:45 AM  │ 10:00 AM │ 10:15 AM │ 11:00 AM │ 11:30 AM       │
│ ────────┼──────────┼──────────┼──────────┼────────         │
│ Early   │  Start   │  Late    │   End    │ Grace          │
│ Period  │          │ Threshold│          │ Period End     │
└─────────────────────────────────────────────────────────────┘

Check-in Allowed: 9:45 AM - 11:30 AM
├─ PRESENT: 9:45 AM - 10:15 AM (within 15 min of start)
└─ LATE: 10:15 AM - 11:30 AM (after 15 min threshold)

After 11:30 AM: Cannot check in (error)
```

**Configuration**:
- **Early Period**: 15 minutes before session (configurable)
- **Late Threshold**: 15 minutes after session start (configurable)
- **Grace Period**: 30 minutes after session end (configurable)

### Status Determination

The system automatically determines attendance status based on check-in timing:

| Status | Condition | Description |
|--------|-----------|-------------|
| **PRESENT** | Scanned ≤ 15 min after start | Student arrived on time |
| **LATE** | Scanned > 15 min after start | Student arrived late but within grace period |
| **ABSENT** | No scan recorded | Student did not attend (auto-marked by system or manually) |
| **EXCUSED** | Manually set | Student absence is justified (manual entry) |
| **CATCHING_UP** | Manually set | Student is making up for a missed session |

**Logic**:
```java
if (scanTime <= sessionStart.plusMinutes(15)) {
    status = PRESENT;
} else {
    status = LATE;
}
```

### Justifying Absences

Students, professors, or admins can justify absences after they've been recorded.

**API Endpoint**: `PATCH /api/attendance/{id}/justify`

**Request Example**:
```json
{
  "justificationNote": "Medical appointment with doctor's note",
  "justificationDocumentUrl": "https://storage.example.com/documents/medical-note-123.pdf"
}
```

**Process**:
1. Locate the attendance record by ID
2. Update `isJustified = true`
3. Add justification note (max 1000 characters)
4. Optionally attach document URL (medical certificate, etc.)
4. Return updated attendance record

**Permissions**:
- **ADMIN**: Can justify any absence
- **PROFESSOR**: Can justify absences in their sessions
- **STUDENT**: Can justify only their own absences

### Attendance Statistics

Get real-time statistics for students, modules, or sessions:

**API Endpoints**:
- Student Stats: `GET /api/attendance/statistics/student/{studentId}`
- Module Stats: `GET /api/attendance/statistics/module/{moduleId}`
- Session Stats: `GET /api/attendance/statistics/session/{sessionId}`

**Response Example**:
```json
{
  "entityId": "uuid-here",
  "entityName": "John Doe",
  "totalSessions": 20,
  "presentCount": 15,
  "absentCount": 3,
  "lateCount": 2,
  "excusedCount": 0,
  "attendanceRate": 85.0,
  "absenteeismRate": 15.0
}
```

---

## Scheduled Tasks & Automation

The system includes automated background jobs to streamline attendance management and reduce manual workload.

### Automatic Absent-Marking (Daily)

**Description**: Automatically marks students as ABSENT if they don't check in for scheduled sessions.

**Schedule**: Runs twice daily at **1:00 PM (13:00)** and **7:00 PM (19:00)**

**Cron Expression**: `0 0 13,19 * * *`

**Process**:
1. Identifies all sessions from today that have passed their grace period
2. Grace period is calculated as: `session_start + duration + grace_period_minutes (30 min)`
3. For each applicable session:
   - Retrieves all students enrolled in the session's groups
   - Identifies students without any attendance record
   - Creates ABSENT records with `markedBy = "SYSTEM"`
   - Marks session's `attendanceTaken` flag as `true`

**Configuration**:
```yaml
attendance:
  grace-period-minutes: 30  # Time after session ends before auto-marking
```

**Benefits**:
- Eliminates need for professors to manually mark absent students
- Ensures complete attendance records for all sessions
- Only processes today's sessions (preserves historical data integrity)
- Provides audit trail with "SYSTEM" as marker

**Implementation**: `AttendanceScheduledService.java:15`

---

## API Documentation

The application provides interactive API documentation using Swagger/OpenAPI.

### Accessing Swagger UI

Once the application is running, navigate to:

```
http://localhost:8080/swagger-ui.html
```

### OpenAPI Specification

Access the raw OpenAPI specification at:

```
http://localhost:8080/v3/api-docs
```

### Key API Endpoints

#### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/logout` - User logout
- `POST /api/auth/reset-password` - Request password reset

#### Attendance
- `POST /api/attendance` - Manual attendance entry
- `POST /api/attendance/by-cne` - Mark attendance by student CNE (Admin/Professor)
- `POST /api/attendance/scan-qr` - Professor scans student QR
- `POST /api/attendance/scan-session-qr` - Student scans session QR
- `POST /api/attendance/bulk` - Bulk attendance entry
- `PUT /api/attendance/{id}` - Update attendance record
- `PATCH /api/attendance/{id}/justify` - Justify absence
- `DELETE /api/attendance/{id}` - Delete attendance record (Admin only)
- `GET /api/attendance/{id}` - Get single attendance record
- `GET /api/attendance` - Get all attendance records (paginated)
- `GET /api/attendance/simple` - Get all attendance records (simple)
- `GET /api/attendance/student/{studentId}` - Get student's attendance records
- `GET /api/attendance/session/{sessionId}` - Get session's attendance records
- `GET /api/attendance/module/{moduleId}` - Get module's attendance records
- `GET /api/attendance/module/{moduleId}/student/{studentId}` - Module + student attendance
- `GET /api/attendance/status/{status}` - Filter by attendance status
- `GET /api/attendance/date-range` - Filter by date range
- `GET /api/attendance/student/{studentId}/date-range` - Student date range filter
- `GET /api/attendance/unjustified-absences` - Get all unjustified absences
- `GET /api/attendance/student/{studentId}/unjustified-absences` - Student unjustified absences
- `GET /api/attendance/search` - Search by student name or CNE
- `GET /api/attendance/check` - Check if attendance exists
- `GET /api/attendance/statistics/student/{studentId}` - Student statistics
- `GET /api/attendance/statistics/module/{moduleId}` - Module statistics
- `GET /api/attendance/statistics/session/{sessionId}` - Session statistics

#### Sessions
- `POST /api/sessions` - Create new session
- `PUT /api/sessions/{id}` - Update session
- `GET /api/sessions/{id}` - Get session details
- `PATCH /api/sessions/{id}/attendance-mode` - Set attendance mode
- `POST /api/sessions/{id}/generate-qr` - Generate session QR code
- `POST /api/sessions/{id}/activate-qr` - Activate session QR code
- `GET /api/sessions/{id}/qr-code` - Download QR code image
- `PATCH /api/sessions/{id}/complete` - Mark session as completed

#### Students
- `POST /api/students` - Register new student
- `GET /api/students/{id}` - Get student details
- `PUT /api/students/{id}` - Update student information
- `GET /api/students` - List all students (paginated)

#### Professors
- `POST /api/professors` - Register new professor
- `GET /api/professors/{id}` - Get professor details
- `PUT /api/professors/{id}` - Update professor information

#### Modules
- `POST /api/modules` - Create module
- `GET /api/modules/{id}` - Get module details
- `GET /api/modules` - List all modules

#### Locations
- `POST /api/locations` - Create location
- `GET /api/locations/{id}` - Get location details
- `GET /api/locations/available` - Get available locations for time slot

---

## Database Schema

### Core Entities

#### Users (Abstract Base)
- **Student**: CNE, CIN, filiere, groups, attendance records, QR code
- **Professor**: Grade, department, modules, sessions, specialization
- **Admin**: Full system access

#### Academic Structure
- **Department**: Manages filieres and locations
- **Filiere**: Study programs (e.g., Computer Science)
- **Semester**: Academic periods within programs
- **Module**: Courses taught in semesters
- **Group**: Student classes/sections

#### Session Management
- **Session**: Class sessions with type (lecture, lab, exam, etc.)
  - Links: module, professor, location, groups
  - QR Code: content, image, expiry
  - Attendance: mode, status flags

- **Location**: Classrooms/labs with capacity and equipment

#### Attendance
- **AttendanceRecord**: Individual attendance entries
  - Student, Session references
  - Status: PRESENT, ABSENT, LATE, EXCUSED
  - Metadata: scan time, device info, IP address
  - Justification: note, document URL

### Entity Relationships

```
Department (1) ──── (N) Filiere
Filiere (1) ──── (N) Semester
Semester (1) ──── (N) Module
Module (N) ──── (N) Professor
Module (1) ──── (N) Group
Group (N) ──── (N) Student
Group (N) ──── (N) Session
Session (N) ──── (1) Module
Session (N) ──── (1) Professor
Session (N) ──── (1) Location
Session (1) ──── (N) AttendanceRecord
Student (1) ──── (N) AttendanceRecord
```

---

## Usage Guide

### Complete Workflow Example

#### 1. Initial Setup (Admin)

**Create Department**:
```bash
POST /api/departments
{
  "name": "Computer Science",
  "description": "Department of Computer Science"
}
```

**Create Filiere**:
```bash
POST /api/filieres
{
  "name": "Software Engineering",
  "departmentId": "dept-uuid"
}
```

**Create Module**:
```bash
POST /api/modules
{
  "name": "Database Systems",
  "code": "CS301",
  "semesterId": "semester-uuid"
}
```

**Create Location**:
```bash
POST /api/locations
{
  "building": "Science Building",
  "roomNumber": "S101",
  "roomType": "CLASSROOM",
  "capacity": 40,
  "departmentId": "dept-uuid"
}
```

**Register Students and Professor**: Use respective endpoints

#### 2. Create Session (Professor/Admin)

```bash
POST /api/sessions
{
  "name": "Database Systems - Lecture 1",
  "type": "LECTURE",
  "moduleId": "module-uuid",
  "professorId": "prof-uuid",
  "locationId": "location-uuid",
  "schedule": "2024-03-15T10:00:00",
  "duration": 120,
  "attendanceMode": "STUDENT_SCAN"
}
```

#### 3. Add Student Groups to Session

```bash
POST /api/sessions/{sessionId}/groups
{
  "groupIds": ["group-uuid-1", "group-uuid-2"]
}
```

#### 4. Take Attendance (Student Scan Mode)

**Generate and Activate QR Code** (Professor):
```bash
POST /api/sessions/{sessionId}/generate-qr
```

```bash
POST /api/sessions/{sessionId}/activate-qr
{
  "validityPeriodMinutes": 30
}
```

**Display QR Code**: Get the QR code image
```bash
GET /api/sessions/{sessionId}/qr-code
```

**Students Scan** (Each Student):
```bash
POST /api/attendance/scan-session-qr
{
  "studentId": "student-uuid",
  "sessionQrCode": "SESSION:session-uuid:2024-03-15T10:00:00",
  "deviceInfo": "iPhone 12",
  "ipAddress": "192.168.1.150"
}
```

#### 5. View Attendance

**Get Session Attendance**:
```bash
GET /api/attendance/session/{sessionId}
```

**Get Student Statistics**:
```bash
GET /api/attendance/statistics/student/{studentId}
```

#### 6. Justify Absence (if needed)

```bash
PATCH /api/attendance/{attendanceId}/justify
{
  "justificationNote": "Medical emergency - doctor's appointment",
  "justificationDocumentUrl": "https://storage.example.com/docs/medical-cert.pdf"
}
```

#### 7. Complete Session (Professor/Admin)

```bash
PATCH /api/sessions/{sessionId}/attendance-taken
```

```bash
PATCH /api/sessions/{sessionId}/complete
```

---

## Development

### Project Structure

```
management-system/
├── src/
│   ├── main/
│   │   ├── java/ma/uiz/fsa/management_system/
│   │   │   ├── config/          # Security, CORS, JWT config
│   │   │   ├── controller/      # REST API controllers
│   │   │   ├── dto/             # Data Transfer Objects
│   │   │   ├── entity/          # JPA entities
│   │   │   ├── exception/       # Custom exceptions
│   │   │   ├── repository/      # Data repositories
│   │   │   ├── security/        # JWT filters, authentication
│   │   │   ├── service/         # Business logic
│   │   │   └── util/            # Utility classes (QR code, etc.)
│   │   └── resources/
│   │       ├── application.yml  # Application configuration
│   │       └── static/          # Static resources
│   └── test/                    # Unit and integration tests
├── docker-compose.yml           # Docker services
├── pom.xml                      # Maven dependencies
└── .env.example                 # Environment variables template
```

### Running Tests

```bash
./mvnw test
```

### Database Migrations

The application uses Hibernate's `ddl-auto: update` strategy. For production, consider using a migration tool like Flyway or Liquibase.

### Code Quality

The project uses:
- **Lombok**: Reduce boilerplate code
- **Spring Validation**: Input validation
- **Spring Security**: Authentication & authorization
- **Exception Handling**: Global exception handlers

### Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## Troubleshooting

### Common Issues

**Database Connection Error**:
- Ensure PostgreSQL is running: `docker-compose ps`
- Check database credentials in `.env`
- Verify port 5432 is not in use

**QR Code Not Generating**:
- Check ZXing library is included in dependencies
- Verify QR generation service logs

**JWT Token Expired**:
- Use the refresh token endpoint to get a new access token
- Check JWT expiration configuration in `application.yml`

**Cannot Scan Attendance**:
- Verify session timing windows
- Check if QR code is activated and not expired
- Ensure student is enrolled in session groups

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## Support

For issues and questions:
- Open an issue on GitHub
- Contact the development team at: support@academic-system.com

---

## Acknowledgments

- Spring Boot Team for the excellent framework
- Google ZXing for QR code generation
- PostgreSQL community
- All contributors to this project
