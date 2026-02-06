package ma.uiz.fsa.management_system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.ChangePasswordRequest;
import ma.uiz.fsa.management_system.dto.request.ProfessorRequestDto;
import ma.uiz.fsa.management_system.dto.request.ProfessorUpdateDto;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.dto.response.PageResponse;
import ma.uiz.fsa.management_system.dto.response.ProfessorResponseDto;
import ma.uiz.fsa.management_system.dto.response.ProfessorSimpleResponseDto;
import ma.uiz.fsa.management_system.service.ProfessorService;
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
@RequestMapping("/api/professors")
@RequiredArgsConstructor
@Tag(name = "Professor", description = "Professor management APIs")
@SecurityRequirement(name = "bearerAuth")
public class ProfessorController {

    private final ProfessorService professorService;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Create a new professor", description = "Admin only - Register a new professor")
    public ResponseEntity<ProfessorResponseDto> createProfessor(
            @Valid @RequestBody ProfessorRequestDto requestDto) {
        ProfessorResponseDto response = professorService.createProfessor(requestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Update a professor", description = "Admin or self - Update professor information")
    public ResponseEntity<ProfessorResponseDto> updateProfessor(
            @PathVariable UUID id,
            @Valid @RequestBody ProfessorUpdateDto requestDto) {
        ProfessorResponseDto response = professorService.updateProfessor(id, requestDto);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get professor by ID", description = "Get a single professor by their ID")
    public ResponseEntity<ProfessorResponseDto> getProfessorById(@PathVariable UUID id) {
        ProfessorResponseDto response = professorService.getProfessorById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/email/{email}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get professor by email", description = "Get a single professor by their email")
    public ResponseEntity<ProfessorResponseDto> getProfessorByEmail(@PathVariable String email) {
        ProfessorResponseDto response = professorService.getProfessorByEmail(email);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get all professors", description = "Get all professors with pagination")
    public ResponseEntity<PageResponse<ProfessorResponseDto>> getAllProfessors(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "lastName") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<ProfessorResponseDto> response = professorService.getAllProfessors(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/simple")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get all professors (simple)", description = "Get all professors with minimal information")
    public ResponseEntity<List<ProfessorSimpleResponseDto>> getAllProfessorsSimple() {
        List<ProfessorSimpleResponseDto> response = professorService.getAllProfessorsSimple();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/department/{departmentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get professors by department", description = "Get all professors in a specific department")
    public ResponseEntity<PageResponse<ProfessorResponseDto>> getProfessorsByDepartment(
            @PathVariable UUID departmentId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "lastName") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<ProfessorResponseDto> response = professorService.getProfessorsByDepartment(departmentId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/grade/{grade}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get professors by grade", description = "Get all professors with a specific grade")
    public ResponseEntity<PageResponse<ProfessorResponseDto>> getProfessorsByGrade(
            @PathVariable String grade,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "lastName") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<ProfessorResponseDto> response = professorService.getProfessorsByGrade(grade, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Search professors", description = "Search professors by name, email, specialization, or department")
    public ResponseEntity<PageResponse<ProfessorResponseDto>> searchProfessors(
            @RequestParam String searchTerm,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "lastName") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<ProfessorResponseDto> response = professorService.searchProfessors(searchTerm, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/active")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get active professors", description = "Get all active professors")
    public ResponseEntity<PageResponse<ProfessorResponseDto>> getActiveProfessors(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "lastName") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<ProfessorResponseDto> response = professorService.getActiveProfessors(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @PatchMapping("/{id}/toggle-status")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Toggle professor status", description = "Admin only - Enable or disable a professor account")
    public ResponseEntity<MessageResponse> toggleProfessorStatus(@PathVariable UUID id) {
        MessageResponse response = professorService.toggleProfessorStatus(id);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete a professor", description = "Admin only - Delete a professor by ID")
    public ResponseEntity<MessageResponse> deleteProfessor(@PathVariable UUID id) {
        professorService.deleteProfessor(id);
        return ResponseEntity.ok(new MessageResponse("Professor deleted successfully", true));
    }

    @PatchMapping("/{id}/change-password")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Change professor password", description = "Admin or self - Change professor password")
    public ResponseEntity<MessageResponse> changeProfessorPassword(
            @PathVariable UUID id,
            @Valid @RequestBody ChangePasswordRequest request) {
        MessageResponse response = professorService.changeProfessorPassword(id, request);
        return ResponseEntity.ok(response);
    }
}