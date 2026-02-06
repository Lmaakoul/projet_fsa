package ma.uiz.fsa.management_system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.FiliereRequestDto;
import ma.uiz.fsa.management_system.dto.response.FiliereResponseDto;
import ma.uiz.fsa.management_system.dto.response.FiliereSimpleResponseDto;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.dto.response.PageResponse;
import ma.uiz.fsa.management_system.model.enums.DegreeType;
import ma.uiz.fsa.management_system.service.FiliereService;
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
@RequestMapping("/api/filieres")
@RequiredArgsConstructor
@Tag(name = "Filiere", description = "Filiere (Program) management APIs")
@SecurityRequirement(name = "bearerAuth")
public class FiliereController {

    private final FiliereService filiereService;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Create a new filiere", description = "Admin only - Create a new filiere/program")
    public ResponseEntity<FiliereResponseDto> createFiliere(
            @Valid @RequestBody FiliereRequestDto requestDto) {
        FiliereResponseDto response = filiereService.createFiliere(requestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Update a filiere", description = "Admin only - Update an existing filiere")
    public ResponseEntity<FiliereResponseDto> updateFiliere(
            @PathVariable UUID id,
            @Valid @RequestBody FiliereRequestDto requestDto) {
        FiliereResponseDto response = filiereService.updateFiliere(id, requestDto);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get filiere by ID", description = "Get a single filiere by its ID")
    public ResponseEntity<FiliereResponseDto> getFiliereById(@PathVariable UUID id) {
        FiliereResponseDto response = filiereService.getFiliereById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/code/{code}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get filiere by code", description = "Get a single filiere by its code")
    public ResponseEntity<FiliereResponseDto> getFiliereByCode(@PathVariable String code) {
        FiliereResponseDto response = filiereService.getFiliereByCode(code);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get all filieres", description = "Get all filieres with pagination")
    public ResponseEntity<PageResponse<FiliereResponseDto>> getAllFilieres(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "name") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<FiliereResponseDto> response = filiereService.getAllFilieres(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/simple")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get all filieres (simple)", description = "Get all filieres with minimal information")
    public ResponseEntity<List<FiliereSimpleResponseDto>> getAllFilieresSimple() {
        List<FiliereSimpleResponseDto> response = filiereService.getAllFilieresSimple();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/department/{departmentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get filieres by department", description = "Get all filieres in a specific department")
    public ResponseEntity<PageResponse<FiliereResponseDto>> getFilieresByDepartment(
            @PathVariable UUID departmentId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "name") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<FiliereResponseDto> response = filiereService.getFilieresByDepartment(departmentId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/degree-type/{degreeType}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get filieres by degree type", description = "Get all filieres of a specific degree type")
    public ResponseEntity<PageResponse<FiliereResponseDto>> getFilieresByDegreeType(
            @PathVariable DegreeType degreeType,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "name") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<FiliereResponseDto> response = filiereService.getFilieresByDegreeType(degreeType, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/active")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get active filieres", description = "Get all active filieres")
    public ResponseEntity<PageResponse<FiliereResponseDto>> getActiveFilieres(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "name") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<FiliereResponseDto> response = filiereService.getActiveFilieres(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Search filieres", description = "Search filieres by name, code, or department")
    public ResponseEntity<PageResponse<FiliereResponseDto>> searchFilieres(
            @RequestParam String searchTerm,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "name") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<FiliereResponseDto> response = filiereService.searchFilieres(searchTerm, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @PatchMapping("/{id}/toggle-status")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Toggle filiere status", description = "Admin only - Activate or deactivate a filiere")
    public ResponseEntity<FiliereResponseDto> toggleFiliereStatus(@PathVariable UUID id) {
        FiliereResponseDto response = filiereService.toggleFiliereStatus(id);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete a filiere", description = "Admin only - Delete a filiere by ID")
    public ResponseEntity<MessageResponse> deleteFiliere(@PathVariable UUID id) {
        filiereService.deleteFiliere(id);
        return ResponseEntity.ok(new MessageResponse("Filiere deleted successfully", true));
    }

    @GetMapping("/exists/code/{code}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Check if code exists", description = "Admin only - Check if a filiere code already exists")
    public ResponseEntity<Boolean> existsByCode(@PathVariable String code) {
        boolean exists = filiereService.existsByCode(code);
        return ResponseEntity.ok(exists);
    }

    @GetMapping("/exists/name/{name}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Check if name exists", description = "Admin only - Check if a filiere name already exists")
    public ResponseEntity<Boolean> existsByName(@PathVariable String name) {
        boolean exists = filiereService.existsByName(name);
        return ResponseEntity.ok(exists);
    }
}