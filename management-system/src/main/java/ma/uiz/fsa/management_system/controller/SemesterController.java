package ma.uiz.fsa.management_system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.SemesterRequestDto;
import ma.uiz.fsa.management_system.dto.request.SemesterUpdateDto;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.dto.response.PageResponse;
import ma.uiz.fsa.management_system.dto.response.SemesterResponseDto;
import ma.uiz.fsa.management_system.dto.response.SemesterSimpleResponseDto;
import ma.uiz.fsa.management_system.service.SemesterService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/semesters")
@RequiredArgsConstructor
@Tag(name = "Semester", description = "Semester management APIs")
@SecurityRequirement(name = "bearerAuth")
public class SemesterController {

    private final SemesterService semesterService;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Create a new semester", description = "Admin only - Create a new semester for a filiere")
    public ResponseEntity<SemesterResponseDto> createSemester(
            @Valid @RequestBody SemesterRequestDto requestDto) {
        SemesterResponseDto response = semesterService.createSemester(requestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Update a semester", description = "Admin only - Update an existing semester")
    public ResponseEntity<SemesterResponseDto> updateSemester(
            @PathVariable UUID id,
            @Valid @RequestBody SemesterUpdateDto requestDto) {
        SemesterResponseDto response = semesterService.updateSemester(id, requestDto);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get semester by ID", description = "Get a single semester by its ID")
    public ResponseEntity<SemesterResponseDto> getSemesterById(@PathVariable UUID id) {
        SemesterResponseDto response = semesterService.getSemesterById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get all semesters", description = "Get all semesters with pagination")
    public ResponseEntity<PageResponse<SemesterResponseDto>> getAllSemesters(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "semesterNumber") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<SemesterResponseDto> response = semesterService.getAllSemesters(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/simple")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get all semesters (simple)", description = "Get all semesters with minimal information")
    public ResponseEntity<List<SemesterSimpleResponseDto>> getAllSemestersSimple() {
        List<SemesterSimpleResponseDto> response = semesterService.getAllSemestersSimple();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/filiere/{filiereId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get semesters by filiere", description = "Get all semesters for a specific filiere")
    public ResponseEntity<PageResponse<SemesterResponseDto>> getSemestersByFiliere(
            @PathVariable UUID filiereId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "semesterNumber") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<SemesterResponseDto> response = semesterService.getSemestersByFiliere(filiereId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/filiere/{filiereId}/active")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get active semesters by filiere", description = "Get all active semesters for a filiere, ordered by semester number")
    public ResponseEntity<List<SemesterSimpleResponseDto>> getActiveSemestersByFiliere(
            @PathVariable UUID filiereId) {
        List<SemesterSimpleResponseDto> response = semesterService.getActiveSemestersByFiliere(filiereId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/academic-year/{academicYear}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get semesters by academic year", description = "Get all semesters for a specific academic year")
    public ResponseEntity<PageResponse<SemesterResponseDto>> getSemestersByAcademicYear(
            @PathVariable String academicYear,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "semesterNumber") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<SemesterResponseDto> response = semesterService.getSemestersByAcademicYear(academicYear, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/active")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get active semesters", description = "Get all active semesters")
    public ResponseEntity<PageResponse<SemesterResponseDto>> getActiveSemesters(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "semesterNumber") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<SemesterResponseDto> response = semesterService.getActiveSemesters(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Search semesters", description = "Search semesters by name, academic year, or filiere")
    public ResponseEntity<PageResponse<SemesterResponseDto>> searchSemesters(
            @RequestParam String searchTerm,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "semesterNumber") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<SemesterResponseDto> response = semesterService.searchSemesters(searchTerm, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @PatchMapping("/{id}/toggle-status")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Toggle semester status", description = "Admin only - Activate or deactivate a semester")
    public ResponseEntity<SemesterResponseDto> toggleSemesterStatus(@PathVariable UUID id) {
        SemesterResponseDto response = semesterService.toggleSemesterStatus(id);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete a semester", description = "Admin only - Delete a semester by ID")
    public ResponseEntity<MessageResponse> deleteSemester(@PathVariable UUID id) {
        semesterService.deleteSemester(id);
        return ResponseEntity.ok(new MessageResponse("Semester deleted successfully", true));
    }

    @GetMapping("/exists")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Check if semester exists", description = "Admin only - Check if a semester number exists for a filiere")
    public ResponseEntity<Boolean> existsBySemesterNumber(
            @RequestParam UUID filiereId,
            @RequestParam Integer semesterNumber) {
        boolean exists = semesterService.existsByFiliereAndSemesterNumber(filiereId, semesterNumber);
        return ResponseEntity.ok(exists);
    }
}