package ma.uiz.fsa.management_system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.*;
import ma.uiz.fsa.management_system.dto.response.*;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.model.entity.Student;
import ma.uiz.fsa.management_system.model.enums.AttendanceStatus;
import ma.uiz.fsa.management_system.repository.StudentRepository;
import ma.uiz.fsa.management_system.service.AttendanceService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/attendance")
@RequiredArgsConstructor
@Tag(name = "Attendance", description = "Attendance tracking and management APIs")
@SecurityRequirement(name = "bearerAuth")
public class AttendanceController {

    private final AttendanceService attendanceService;
    private final StudentRepository studentRepository;

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Record attendance", description = "Admin or Professor - Manually record attendance for a student")
    public ResponseEntity<AttendanceRecordResponseDto> recordAttendance(
            @Valid @RequestBody AttendanceRecordRequestDto requestDto) {
        AttendanceRecordResponseDto response = attendanceService.recordAttendance(requestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/by-cne")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(
            summary = "Mark attendance by student CNE",
            description = "Admin or Professor - Mark attendance for a student using their CNE (National Student Code). " +
                    "This endpoint allows marking attendance without needing to know the student's UUID."
    )
    public ResponseEntity<AttendanceRecordResponseDto> markAttendanceByCne(
            @Valid @RequestBody AttendanceByCneRequestDto requestDto) {
        AttendanceRecordResponseDto response = attendanceService.markAttendanceByCne(requestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/scan-qr")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(
            summary = "Scan student QR code for attendance",
            description = "Records student attendance by scanning their QR code. " +
                    "Attendance can be taken 15 minutes before session start until " +
                    "30 minutes after session end. Status is PRESENT if scanned within " +
                    "15 minutes of session start, otherwise LATE."
    )
    public ResponseEntity<AttendanceRecordResponseDto> scanQrCode(
            @Valid @RequestBody ScanQrRequestDto scanQrRequestDto) {
        AttendanceRecordResponseDto response = attendanceService.scanQrCode(scanQrRequestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/bulk")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Record bulk attendance", description = "Admin or Professor - Record attendance for multiple students at once")
    public ResponseEntity<MessageResponse> recordBulkAttendance(
            @Valid @RequestBody BulkAttendanceDto bulkDto) {
        MessageResponse response = attendanceService.recordBulkAttendance(bulkDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Update attendance record", description = "Admin or Professor - Update an existing attendance record")
    public ResponseEntity<AttendanceRecordResponseDto> updateAttendanceRecord(
            @PathVariable UUID id,
            @Valid @RequestBody AttendanceRecordUpdateDto requestDto) {
        AttendanceRecordResponseDto response = attendanceService.updateAttendanceRecord(id, requestDto);
        return ResponseEntity.ok(response);
    }

    @PatchMapping("/{id}/justify")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Justify absence", description = "Justify an absence with a note and optional document")
    public ResponseEntity<AttendanceRecordResponseDto> justifyAbsence(
            @PathVariable UUID id,
            @Valid @RequestBody JustifyAbsenceDto justifyDto) {
        AttendanceRecordResponseDto response = attendanceService.justifyAbsence(id, justifyDto);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get attendance record by ID", description = "Get a single attendance record by its ID")
    public ResponseEntity<AttendanceRecordResponseDto> getAttendanceRecordById(@PathVariable UUID id) {
        AttendanceRecordResponseDto response = attendanceService.getAttendanceRecordById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get all attendance records", description = "Get all attendance records with pagination")
    public ResponseEntity<PageResponse<AttendanceRecordResponseDto>> getAllAttendanceRecords(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "date") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<AttendanceRecordResponseDto> response = attendanceService.getAllAttendanceRecords(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/simple")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get all attendance records (simple)", description = "Get all attendance records with minimal information")
    public ResponseEntity<List<AttendanceRecordSimpleResponseDto>> getAllAttendanceRecordsSimple() {
        List<AttendanceRecordSimpleResponseDto> response = attendanceService.getAllAttendanceRecordsSimple();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/student/{studentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get attendance by student", description = "Get all attendance records for a specific student")
    public ResponseEntity<PageResponse<AttendanceRecordResponseDto>> getAttendanceByStudent(
            @PathVariable UUID studentId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "date") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<AttendanceRecordResponseDto> response = attendanceService.getAttendanceByStudent(studentId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/session/{sessionId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get attendance by session", description = "Get all attendance records for a specific session")
    public ResponseEntity<PageResponse<AttendanceRecordResponseDto>> getAttendanceBySession(
            @PathVariable UUID sessionId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "scannedAt") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<AttendanceRecordResponseDto> response = attendanceService.getAttendanceBySession(sessionId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/module/{moduleId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get attendance by module", description = "Get all attendance records for a specific module")
    public ResponseEntity<PageResponse<AttendanceRecordResponseDto>> getAttendanceByModule(
            @PathVariable UUID moduleId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "date") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<AttendanceRecordResponseDto> response = attendanceService.getAttendanceByModule(moduleId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/module/{moduleId}/student/{studentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get attendance by module and student", description = "Get attendance records for a specific student in a module")
    public ResponseEntity<List<AttendanceRecordResponseDto>> getAttendanceByModuleAndStudent(
            @PathVariable UUID moduleId,
            @PathVariable UUID studentId) {
        List<AttendanceRecordResponseDto> response = attendanceService.getAttendanceByModuleAndStudent(moduleId, studentId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/status/{status}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get attendance by status", description = "Get all attendance records with a specific status")
    public ResponseEntity<PageResponse<AttendanceRecordResponseDto>> getAttendanceByStatus(
            @PathVariable AttendanceStatus status,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "date") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<AttendanceRecordResponseDto> response = attendanceService.getAttendanceByStatus(status, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/date-range")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get attendance by date range", description = "Get attendance records within a specific date range")
    public ResponseEntity<PageResponse<AttendanceRecordResponseDto>> getAttendanceByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "date") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<AttendanceRecordResponseDto> response = attendanceService.getAttendanceByDateRange(startDate, endDate, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/student/{studentId}/date-range")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get student attendance by date range", description = "Get attendance records for a student within a date range")
    public ResponseEntity<List<AttendanceRecordResponseDto>> getStudentAttendanceByDateRange(
            @PathVariable UUID studentId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        List<AttendanceRecordResponseDto> response = attendanceService.getStudentAttendanceByDateRange(studentId, startDate, endDate);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/unjustified-absences")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get unjustified absences", description = "Get all unjustified absences")
    public ResponseEntity<PageResponse<AttendanceRecordResponseDto>> getUnjustifiedAbsences(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "date") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<AttendanceRecordResponseDto> response = attendanceService.getUnjustifiedAbsences(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/student/{studentId}/unjustified-absences")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get student's unjustified absences", description = "Get all unjustified absences for a specific student")
    public ResponseEntity<List<AttendanceRecordSimpleResponseDto>> getUnjustifiedAbsencesByStudent(
            @PathVariable UUID studentId) {
        List<AttendanceRecordSimpleResponseDto> response = attendanceService.getUnjustifiedAbsencesByStudent(studentId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Search attendance records", description = "Search attendance records by student name or CNE")
    public ResponseEntity<PageResponse<AttendanceRecordResponseDto>> searchAttendanceRecords(
            @RequestParam String searchTerm,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "date") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<AttendanceRecordResponseDto> response = attendanceService.searchAttendanceRecords(searchTerm, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/statistics/student/{studentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get student attendance statistics", description = "Get attendance statistics for a specific student")
    public ResponseEntity<AttendanceStatisticsDto> getStudentAttendanceStatistics(
            @PathVariable UUID studentId) {
        AttendanceStatisticsDto response = attendanceService.getStudentAttendanceStatistics(studentId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/statistics/module/{moduleId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get module attendance statistics", description = "Get attendance statistics for a specific module")
    public ResponseEntity<AttendanceStatisticsDto> getModuleAttendanceStatistics(
            @PathVariable UUID moduleId) {
        AttendanceStatisticsDto response = attendanceService.getModuleAttendanceStatistics(moduleId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/statistics/session/{sessionId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get session attendance statistics", description = "Get attendance statistics for a specific session")
    public ResponseEntity<AttendanceStatisticsDto> getSessionAttendanceStatistics(
            @PathVariable UUID sessionId) {
        AttendanceStatisticsDto response = attendanceService.getSessionAttendanceStatistics(sessionId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete attendance record", description = "Admin only - Delete an attendance record by ID")
    public ResponseEntity<MessageResponse> deleteAttendanceRecord(@PathVariable UUID id) {
        attendanceService.deleteAttendanceRecord(id);
        return ResponseEntity.ok(new MessageResponse("Attendance record deleted successfully", true));
    }

    @GetMapping("/check")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Check if attendance exists", description = "Check if attendance has been recorded for a student and session")
    public ResponseEntity<Boolean> hasAttendanceForSession(
            @RequestParam UUID studentId,
            @RequestParam UUID sessionId) {
        boolean exists = attendanceService.hasAttendanceForSession(studentId, sessionId);
        return ResponseEntity.ok(exists);
    }

    @PostMapping("/scan-session-qr")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(
            summary = "Student scans session QR code",
            description = "Students scan the session QR code displayed by professor to mark attendance"
    )
    public ResponseEntity<AttendanceRecordResponseDto> scanSessionQrCode(
            @Valid @RequestBody StudentScanSessionQrRequestDto requestDto,
            @AuthenticationPrincipal UserDetails currentUser) {

        // Ensure student can only scan for themselves
        Student student = studentRepository.findByEmail(currentUser.getUsername())
                .orElseThrow(() -> new ResourceNotFoundException("Student not found"));

        if (!student.getId().equals(requestDto.getStudentId())) {
            throw new AccessDeniedException("You can only mark attendance for yourself");
        }

        AttendanceRecordResponseDto response = attendanceService.scanSessionQrCode(requestDto);
        return ResponseEntity.ok(response);
    }
}