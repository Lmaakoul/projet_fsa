package ma.uiz.fsa.management_system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.SessionRequestDto;
import ma.uiz.fsa.management_system.dto.request.SessionUpdateDto;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.dto.response.PageResponse;
import ma.uiz.fsa.management_system.dto.response.SessionResponseDto;
import ma.uiz.fsa.management_system.dto.response.SessionSimpleResponseDto;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.model.enums.AttendanceMode;
import ma.uiz.fsa.management_system.model.enums.SessionType;
import ma.uiz.fsa.management_system.service.SessionService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/sessions")
@RequiredArgsConstructor
@Tag(name = "Session", description = "Class session management APIs")
@SecurityRequirement(name = "bearerAuth")
public class SessionController {

    private final SessionService sessionService;

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Create a new session", description = "Admin or Professor - Create a new class session")
    public ResponseEntity<SessionResponseDto> createSession(
            @Valid @RequestBody SessionRequestDto requestDto) {
        SessionResponseDto response = sessionService.createSession(requestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Update a session", description = "Admin or Professor - Update an existing session")
    public ResponseEntity<SessionResponseDto> updateSession(
            @PathVariable UUID id,
            @Valid @RequestBody SessionUpdateDto requestDto) {
        SessionResponseDto response = sessionService.updateSession(id, requestDto);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get session by ID", description = "Get a single session by its ID")
    public ResponseEntity<SessionResponseDto> getSessionById(@PathVariable UUID id) {
        SessionResponseDto response = sessionService.getSessionById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get all sessions", description = "Get all sessions with pagination")
    public ResponseEntity<PageResponse<SessionResponseDto>> getAllSessions(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "schedule") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<SessionResponseDto> response = sessionService.getAllSessions(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/simple")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get all sessions (simple)", description = "Get all sessions with minimal information")
    public ResponseEntity<List<SessionSimpleResponseDto>> getAllSessionsSimple() {
        List<SessionSimpleResponseDto> response = sessionService.getAllSessionsSimple();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/module/{moduleId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get sessions by module", description = "Get all sessions for a specific module")
    public ResponseEntity<PageResponse<SessionResponseDto>> getSessionsByModule(
            @PathVariable UUID moduleId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "schedule") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<SessionResponseDto> response = sessionService.getSessionsByModule(moduleId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/professor/{professorId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get sessions by professor", description = "Get all sessions for a specific professor")
    public ResponseEntity<PageResponse<SessionResponseDto>> getSessionsByProfessor(
            @PathVariable UUID professorId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "schedule") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<SessionResponseDto> response = sessionService.getSessionsByProfessor(professorId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/professor/{professorId}/upcoming")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get upcoming sessions by professor", description = "Get upcoming sessions for a professor")
    public ResponseEntity<List<SessionSimpleResponseDto>> getUpcomingSessionsByProfessor(
            @PathVariable UUID professorId) {
        List<SessionSimpleResponseDto> response = sessionService.getUpcomingSessionsByProfessor(professorId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/professor/{professorId}/today")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get today's sessions", description = "Get today's sessions for a professor")
    public ResponseEntity<List<SessionSimpleResponseDto>> getSessionsForToday(
            @PathVariable UUID professorId) {
        List<SessionSimpleResponseDto> response = sessionService.getSessionsForToday(professorId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/group/{groupId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get sessions by group", description = "Get all sessions for a specific group")
    public ResponseEntity<PageResponse<SessionResponseDto>> getSessionsByGroup(
            @PathVariable UUID groupId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "schedule") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<SessionResponseDto> response = sessionService.getSessionsByGroup(groupId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/type/{type}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get sessions by type", description = "Get all sessions of a specific type")
    public ResponseEntity<PageResponse<SessionResponseDto>> getSessionsByType(
            @PathVariable SessionType type,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "schedule") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<SessionResponseDto> response = sessionService.getSessionsByType(type, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/date-range")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get sessions by date range", description = "Get sessions within a specific date range")
    public ResponseEntity<PageResponse<SessionResponseDto>> getSessionsByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "schedule") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<SessionResponseDto> response = sessionService.getSessionsByDateRange(startDate, endDate, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/completed")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get completed sessions", description = "Get all completed sessions")
    public ResponseEntity<PageResponse<SessionResponseDto>> getCompletedSessions(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "schedule") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<SessionResponseDto> response = sessionService.getCompletedSessions(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/incomplete")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get incomplete sessions", description = "Get all incomplete sessions")
    public ResponseEntity<PageResponse<SessionResponseDto>> getIncompleteSessions(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "schedule") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<SessionResponseDto> response = sessionService.getIncompleteSessions(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/upcoming")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get upcoming sessions", description = "Get all upcoming sessions")
    public ResponseEntity<PageResponse<SessionResponseDto>> getUpcomingSessions(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "schedule") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<SessionResponseDto> response = sessionService.getUpcomingSessions(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Search sessions", description = "Search sessions by location, module, or professor")
    public ResponseEntity<PageResponse<SessionResponseDto>> searchSessions(
            @RequestParam String searchTerm,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "schedule") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<SessionResponseDto> response = sessionService.searchSessions(searchTerm, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @PatchMapping("/{id}/complete")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Mark session as completed", description = "Admin or Professor - Mark a session as completed")
    public ResponseEntity<SessionResponseDto> markSessionAsCompleted(@PathVariable UUID id) {
        SessionResponseDto response = sessionService.markSessionAsCompleted(id);
        return ResponseEntity.ok(response);
    }

    @PatchMapping("/{id}/attendance-taken")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Mark attendance as taken", description = "Admin or Professor - Mark attendance as taken for a session")
    public ResponseEntity<SessionResponseDto> markAttendanceTaken(@PathVariable UUID id) {
        SessionResponseDto response = sessionService.markAttendanceTaken(id);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{sessionId}/groups")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Add groups to session", description = "Admin or Professor - Add groups to a session")
    public ResponseEntity<MessageResponse> addGroupsToSession(
            @PathVariable UUID sessionId,
            @RequestBody List<UUID> groupIds) {
        MessageResponse response = sessionService.addGroupsToSession(sessionId, groupIds);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{sessionId}/groups/{groupId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Remove group from session", description = "Admin or Professor - Remove a group from a session")
    public ResponseEntity<MessageResponse> removeGroupFromSession(
            @PathVariable UUID sessionId,
            @PathVariable UUID groupId) {
        MessageResponse response = sessionService.removeGroupFromSession(sessionId, groupId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Delete a session", description = "Admin or Professor - Delete a session by ID")
    public ResponseEntity<MessageResponse> deleteSession(@PathVariable UUID id) {
        sessionService.deleteSession(id);
        return ResponseEntity.ok(new MessageResponse("Session deleted successfully", true));
    }

    @PostMapping("/{id}/generate-qr")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Generate session QR code",
            description = "Generate QR code for students to scan")
    public ResponseEntity<Map<String, String>> generateSessionQrCode(@PathVariable UUID id) {
        String qrCode = sessionService.generateSessionQrCode(id);
        return ResponseEntity.ok(Map.of(
                "qrCode", qrCode,
                "message", "QR code generated successfully"
        ));
    }

    @PostMapping("/{id}/regenerate-qr")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Regenerate session QR code",
            description = "Generate new QR code (invalidates old one)")
    public ResponseEntity<Map<String, String>> regenerateSessionQrCode(@PathVariable UUID id) {
        String qrCode = sessionService.regenerateSessionQrCode(id);
        return ResponseEntity.ok(Map.of(
                "qrCode", qrCode,
                "message", "QR code regenerated successfully"
        ));
    }

    @PostMapping("/{id}/activate-qr")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Activate session QR code",
            description = "Activate QR code with custom validity period")
    public ResponseEntity<Map<String, String>> activateSessionQrCode(
            @PathVariable UUID id,
            @RequestParam(defaultValue = "30") Integer validityMinutes) {
        sessionService.activateSessionQrCode(id, validityMinutes);
        return ResponseEntity.ok(Map.of(
                "message", "QR code activated for " + validityMinutes + " minutes"
        ));
    }

    @PostMapping("/{id}/deactivate-qr")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Deactivate session QR code",
            description = "Immediately expire the session QR code")
    public ResponseEntity<Map<String, String>> deactivateSessionQrCode(@PathVariable UUID id) {
        sessionService.deactivateSessionQrCode(id);
        return ResponseEntity.ok(Map.of(
                "message", "QR code deactivated successfully"
        ));
    }

    @GetMapping("/{id}/qr-code")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get session QR code image",
            description = "Get session QR code as PNG image")
    public ResponseEntity<byte[]> getSessionQrCode(@PathVariable UUID id) {
        SessionResponseDto session = sessionService.getSessionById(id);

        if (session.getQrCodeImage() == null) {
            throw new ResourceNotFoundException("QR code not generated for this session");
        }

        byte[] imageBytes = Base64.getDecoder().decode(session.getQrCodeImage());

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.IMAGE_PNG);
        headers.setContentDisposition(
                ContentDisposition.builder("inline")
                        .filename("session_" + id + "_qrcode.png")
                        .build()
        );

        return new ResponseEntity<>(imageBytes, headers, HttpStatus.OK);
    }

    @PatchMapping("/{id}/attendance-mode")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Set attendance mode",
            description = "Change how attendance is taken for this session")
    public ResponseEntity<SessionResponseDto> setAttendanceMode(
            @PathVariable UUID id,
            @RequestParam AttendanceMode mode) {
        SessionResponseDto session = sessionService.setAttendanceMode(id, mode);
        return ResponseEntity.ok(session);
    }
}