package ma.uiz.fsa.management_system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.DepartmentRequestDto;
import ma.uiz.fsa.management_system.dto.response.DepartmentResponseDto;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.dto.response.PageResponse;
import ma.uiz.fsa.management_system.service.DepartmentService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/departments")
@RequiredArgsConstructor
@Tag(name = "Department", description = "Department management APIs")
@SecurityRequirement(name = "bearerAuth")
public class DepartmentController {

    private final DepartmentService departmentService;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Create a new department", description = "Admin only - Create a new department")
    public ResponseEntity<DepartmentResponseDto> createDepartment(
            @Valid @RequestBody DepartmentRequestDto requestDto) {
        DepartmentResponseDto response = departmentService.createDepartment(requestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Update a department", description = "Admin only - Update an existing department")
    public ResponseEntity<DepartmentResponseDto> updateDepartment(
            @PathVariable UUID id,
            @Valid @RequestBody DepartmentRequestDto requestDto) {
        DepartmentResponseDto response = departmentService.updateDepartment(id, requestDto);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get department by ID", description = "Get a single department by its ID")
    public ResponseEntity<DepartmentResponseDto> getDepartmentById(@PathVariable UUID id) {
        DepartmentResponseDto response = departmentService.getDepartmentById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/code/{code}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get department by code", description = "Get a single department by its code")
    public ResponseEntity<DepartmentResponseDto> getDepartmentByCode(@PathVariable String code) {
        DepartmentResponseDto response = departmentService.getDepartmentByCode(code);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get all departments", description = "Get all departments with optional pagination")
    public ResponseEntity<PageResponse<DepartmentResponseDto>> getAllDepartments(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "name") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<DepartmentResponseDto> response = departmentService.getAllDepartments(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete a department", description = "Admin only - Delete a department by ID")
    public ResponseEntity<MessageResponse> deleteDepartment(@PathVariable UUID id) {
        departmentService.deleteDepartment(id);
        return ResponseEntity.ok(new MessageResponse("Department deleted successfully", true));
    }

    @GetMapping("/exists/code/{code}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Check if code exists", description = "Admin only - Check if a department code already exists")
    public ResponseEntity<Boolean> existsByCode(@PathVariable String code) {
        boolean exists = departmentService.existsByCode(code);
        return ResponseEntity.ok(exists);
    }

    @GetMapping("/exists/name/{name}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Check if name exists", description = "Admin only - Check if a department name already exists")
    public ResponseEntity<Boolean> existsByName(@PathVariable String name) {
        boolean exists = departmentService.existsByName(name);
        return ResponseEntity.ok(exists);
    }
}
