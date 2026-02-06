package ma.uiz.fsa.management_system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.AssignProfessorsDto;
import ma.uiz.fsa.management_system.dto.request.ModuleRequestDto;
import ma.uiz.fsa.management_system.dto.request.ModuleUpdateDto;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.dto.response.ModuleResponseDto;
import ma.uiz.fsa.management_system.dto.response.ModuleSimpleResponseDto;
import ma.uiz.fsa.management_system.dto.response.PageResponse;
import ma.uiz.fsa.management_system.service.ModuleService;
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
@RequestMapping("/api/modules")
@RequiredArgsConstructor
@Tag(name = "Module", description = "Module (Course) management APIs")
@SecurityRequirement(name = "bearerAuth")
public class ModuleController {

    private final ModuleService moduleService;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Create a new module", description = "Admin only - Create a new course module")
    public ResponseEntity<ModuleResponseDto> createModule(
            @Valid @RequestBody ModuleRequestDto requestDto) {
        ModuleResponseDto response = moduleService.createModule(requestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Update a module", description = "Admin or Professor - Update an existing module")
    public ResponseEntity<ModuleResponseDto> updateModule(
            @PathVariable UUID id,
            @Valid @RequestBody ModuleUpdateDto requestDto) {
        ModuleResponseDto response = moduleService.updateModule(id, requestDto);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get module by ID", description = "Get a single module by its ID")
    public ResponseEntity<ModuleResponseDto> getModuleById(@PathVariable UUID id) {
        ModuleResponseDto response = moduleService.getModuleById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/code/{code}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get module by code", description = "Get a single module by its code")
    public ResponseEntity<ModuleResponseDto> getModuleByCode(@PathVariable String code) {
        ModuleResponseDto response = moduleService.getModuleByCode(code);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get all modules", description = "Get all modules with pagination")
    public ResponseEntity<PageResponse<ModuleResponseDto>> getAllModules(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "title") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<ModuleResponseDto> response = moduleService.getAllModules(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/simple")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get all modules (simple)", description = "Get all modules with minimal information")
    public ResponseEntity<List<ModuleSimpleResponseDto>> getAllModulesSimple() {
        List<ModuleSimpleResponseDto> response = moduleService.getAllModulesSimple();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/semester/{semesterId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get modules by semester", description = "Get all modules in a specific semester")
    public ResponseEntity<PageResponse<ModuleResponseDto>> getModulesBySemester(
            @PathVariable UUID semesterId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "title") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<ModuleResponseDto> response = moduleService.getModulesBySemester(semesterId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/semester/{semesterId}/active")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get active modules by semester", description = "Get all active modules in a semester")
    public ResponseEntity<List<ModuleSimpleResponseDto>> getActiveModulesBySemester(
            @PathVariable UUID semesterId) {
        List<ModuleSimpleResponseDto> response = moduleService.getActiveModulesBySemester(semesterId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/filiere/{filiereId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get modules by filiere", description = "Get all modules in a specific filiere")
    public ResponseEntity<PageResponse<ModuleResponseDto>> getModulesByFiliere(
            @PathVariable UUID filiereId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "title") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<ModuleResponseDto> response = moduleService.getModulesByFiliere(filiereId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/professor/{professorId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get modules by professor", description = "Get all modules taught by a specific professor")
    public ResponseEntity<PageResponse<ModuleResponseDto>> getModulesByProfessor(
            @PathVariable UUID professorId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "title") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<ModuleResponseDto> response = moduleService.getModulesByProfessor(professorId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/professor/{professorId}/active")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get active modules by professor", description = "Get active modules taught by a professor")
    public ResponseEntity<List<ModuleSimpleResponseDto>> getActiveModulesByProfessor(
            @PathVariable UUID professorId) {
        List<ModuleSimpleResponseDto> response = moduleService.getActiveModulesByProfessor(professorId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/academic-year/{academicYear}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get modules by academic year", description = "Get all modules for a specific academic year")
    public ResponseEntity<PageResponse<ModuleResponseDto>> getModulesByAcademicYear(
            @PathVariable String academicYear,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "title") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<ModuleResponseDto> response = moduleService.getModulesByAcademicYear(academicYear, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/active")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get active modules", description = "Get all active modules")
    public ResponseEntity<PageResponse<ModuleResponseDto>> getActiveModules(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "title") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<ModuleResponseDto> response = moduleService.getActiveModules(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Search modules", description = "Search modules by title, code, or semester")
    public ResponseEntity<PageResponse<ModuleResponseDto>> searchModules(
            @RequestParam String searchTerm,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "title") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<ModuleResponseDto> response = moduleService.searchModules(searchTerm, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @PostMapping("/{moduleId}/assign-professors")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Assign professors to module", description = "Admin only - Assign one or more professors to a module")
    public ResponseEntity<ModuleResponseDto> assignProfessors(
            @PathVariable UUID moduleId,
            @Valid @RequestBody AssignProfessorsDto assignDto) {
        assignDto.setModuleId(moduleId);
        ModuleResponseDto response = moduleService.assignProfessors(moduleId, assignDto);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{moduleId}/professors/{professorId}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Remove professor from module", description = "Admin only - Remove a professor from a module")
    public ResponseEntity<MessageResponse> removeProfessorFromModule(
            @PathVariable UUID moduleId,
            @PathVariable UUID professorId) {
        MessageResponse response = moduleService.removeProfessorFromModule(moduleId, professorId);
        return ResponseEntity.ok(response);
    }

    @PatchMapping("/{id}/toggle-status")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Toggle module status", description = "Admin only - Activate or deactivate a module")
    public ResponseEntity<ModuleResponseDto> toggleModuleStatus(@PathVariable UUID id) {
        ModuleResponseDto response = moduleService.toggleModuleStatus(id);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete a module", description = "Admin only - Delete a module by ID")
    public ResponseEntity<MessageResponse> deleteModule(@PathVariable UUID id) {
        moduleService.deleteModule(id);
        return ResponseEntity.ok(new MessageResponse("Module deleted successfully", true));
    }

    @GetMapping("/exists/code/{code}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Check if code exists", description = "Admin only - Check if a module code already exists")
    public ResponseEntity<Boolean> existsByCode(@PathVariable String code) {
        boolean exists = moduleService.existsByCode(code);
        return ResponseEntity.ok(exists);
    }
}