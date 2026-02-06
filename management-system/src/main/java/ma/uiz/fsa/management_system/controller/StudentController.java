package ma.uiz.fsa.management_system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.BulkStudentRequestDto;
import ma.uiz.fsa.management_system.dto.request.ChangePasswordRequest;
import ma.uiz.fsa.management_system.dto.request.StudentRequestDto;
import ma.uiz.fsa.management_system.dto.request.StudentUpdateDto;
import ma.uiz.fsa.management_system.dto.response.*;
import ma.uiz.fsa.management_system.service.StudentService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@RestController
@RequestMapping("/api/students")
@RequiredArgsConstructor
@Tag(name = "Student", description = "Student management APIs")
@SecurityRequirement(name = "bearerAuth")
public class StudentController {

    private final StudentService studentService;

    @PostMapping("/bulk")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Create multiple students in a filiere",
            description = "Admin only - Register multiple students for the same filiere at once. " +
                    "All students in the request will be enrolled in the specified filiere. Returns detailed success/failure information for each student.")
    public ResponseEntity<BulkStudentResponseDto> createBulkStudents(
            @Valid @RequestBody BulkStudentRequestDto requestDto) {
        BulkStudentResponseDto response = studentService.createBulkStudents(requestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Create a new student", description = "Admin only - Register a new student")
    public ResponseEntity<StudentResponseDto> createStudent(
            @Valid @RequestBody StudentRequestDto requestDto) {
        StudentResponseDto response = studentService.createStudent(requestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'STUDENT')")
    @Operation(summary = "Update a student", description = "Admin or self - Update student information")
    public ResponseEntity<StudentResponseDto> updateStudent(
            @PathVariable UUID id,
            @Valid @RequestBody StudentUpdateDto requestDto) {
        StudentResponseDto response = studentService.updateStudent(id, requestDto);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get student by ID", description = "Get a single student by their ID")
    public ResponseEntity<StudentResponseDto> getStudentById(@PathVariable UUID id) {
        StudentResponseDto response = studentService.getStudentById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/email/{email}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get student by email", description = "Get a single student by their email")
    public ResponseEntity<StudentResponseDto> getStudentByEmail(@PathVariable String email) {
        StudentResponseDto response = studentService.getStudentByEmail(email);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/cne/{cne}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get student by CNE", description = "Get a single student by their CNE")
    public ResponseEntity<StudentResponseDto> getStudentByCne(@PathVariable String cne) {
        StudentResponseDto response = studentService.getStudentByCne(cne);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/cin/{cin}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get student by CIN", description = "Get a single student by their CIN")
    public ResponseEntity<StudentResponseDto> getStudentByCin(@PathVariable String cin) {
        StudentResponseDto response = studentService.getStudentByCin(cin);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get all students", description = "Get all students with pagination")
    public ResponseEntity<PageResponse<StudentResponseDto>> getAllStudents(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "lastName") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<StudentResponseDto> response = studentService.getAllStudents(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/simple")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get all students (simple)", description = "Get all students with minimal information")
    public ResponseEntity<List<StudentSimpleResponseDto>> getAllStudentsSimple() {
        List<StudentSimpleResponseDto> response = studentService.getAllStudentsSimple();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/filiere/{filiereId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get students by filiere", description = "Get all students in a specific filiere")
    public ResponseEntity<PageResponse<StudentResponseDto>> getStudentsByFiliere(
            @PathVariable UUID filiereId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "lastName") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<StudentResponseDto> response = studentService.getStudentsByFiliere(filiereId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/group/{groupId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get students by group", description = "Get all students in a specific group")
    public ResponseEntity<PageResponse<StudentResponseDto>> getStudentsByGroup(
            @PathVariable UUID groupId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "lastName") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<StudentResponseDto> response = studentService.getStudentsByGroup(groupId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Search students", description = "Search students by name, email, CNE, CIN, or filiere")
    public ResponseEntity<PageResponse<StudentResponseDto>> searchStudents(
            @RequestParam String searchTerm,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "lastName") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<StudentResponseDto> response = studentService.searchStudents(searchTerm, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/active")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get active students", description = "Get all active students")
    public ResponseEntity<PageResponse<StudentResponseDto>> getActiveStudents(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "lastName") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<StudentResponseDto> response = studentService.getActiveStudents(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @PatchMapping("/{id}/toggle-status")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Toggle student status", description = "Admin only - Enable or disable a student account")
    public ResponseEntity<MessageResponse> toggleStudentStatus(@PathVariable UUID id) {
        MessageResponse response = studentService.toggleStudentStatus(id);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete a student", description = "Admin only - Delete a student by ID")
    public ResponseEntity<MessageResponse> deleteStudent(@PathVariable UUID id) {
        studentService.deleteStudent(id);
        return ResponseEntity.ok(new MessageResponse("Student deleted successfully", true));
    }

    @PatchMapping("/{id}/change-password")
    @PreAuthorize("hasAnyRole('ADMIN', 'STUDENT')")
    @Operation(summary = "Change student password", description = "Admin or self - Change student password")
    public ResponseEntity<MessageResponse> changeStudentPassword(
            @PathVariable UUID id,
            @Valid @RequestBody ChangePasswordRequest request) {
        MessageResponse response = studentService.changeStudentPassword(id, request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{id}/generate-qr")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Generate QR code", description = "Admin or Professor - Generate QR code for student")
    public ResponseEntity<MessageResponse> generateQrCode(@PathVariable UUID id) {
        String qrCode = studentService.generateQrCodeForStudent(id);
        return ResponseEntity.ok(new MessageResponse("QR code generated: " + qrCode, true));
    }

    @GetMapping("/{id}/qr-code")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get student QR code", description = "Display student QR code as image")
    public ResponseEntity<byte[]> getStudentQrCode(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserDetails currentUser) {
        return buildQrCodeResponse(id, currentUser, false);
    }

    @GetMapping("/{id}/qr-code/download")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Download student QR code", description = "Download student QR code as PNG file")
    public ResponseEntity<byte[]> downloadStudentQrCode(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserDetails currentUser) {
        return buildQrCodeResponse(id, currentUser, true);
    }

    private ResponseEntity<byte[]> buildQrCodeResponse(
            UUID studentId,
            UserDetails currentUser,
            boolean forceDownload) {

        // Get current user ID if they're a student
        UUID currentUserId = getCurrentStudentId(currentUser);

        // Delegate to service
        QrCodeResponseDto qrCodeData = studentService.getStudentQrCodeData(studentId, currentUserId);

        // Build response
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.IMAGE_PNG);
        headers.setContentDisposition(
                ContentDisposition.builder(forceDownload ? "attachment" : "inline")
                        .filename(qrCodeData.getFilename())
                        .build()
        );

        if (!forceDownload) {
            headers.setCacheControl(CacheControl.maxAge(7, TimeUnit.DAYS).cachePublic());
        }

        return new ResponseEntity<>(qrCodeData.getImageBytes(), headers, HttpStatus.OK);
    }

    private UUID getCurrentStudentId(UserDetails currentUser) {
        boolean isStudent = currentUser.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_STUDENT"));

        if (isStudent) {
            return studentService.getStudentByEmail(currentUser.getUsername()).getId();
        }

        return null; // Admin or Professor - no restriction
    }
}