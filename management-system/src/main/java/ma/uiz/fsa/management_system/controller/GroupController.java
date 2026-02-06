package ma.uiz.fsa.management_system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.EnrollStudentsDto;
import ma.uiz.fsa.management_system.dto.request.GroupRequestDto;
import ma.uiz.fsa.management_system.dto.request.GroupUpdateDto;
import ma.uiz.fsa.management_system.dto.response.GroupResponseDto;
import ma.uiz.fsa.management_system.dto.response.GroupSimpleResponseDto;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.dto.response.PageResponse;
import ma.uiz.fsa.management_system.service.GroupService;
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
@RequestMapping("/api/groups")
@RequiredArgsConstructor
@Tag(name = "Group", description = "Student group management APIs")
@SecurityRequirement(name = "bearerAuth")
public class GroupController {

    private final GroupService groupService;

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Create a new group", description = "Admin or Professor - Create a new student group")
    public ResponseEntity<GroupResponseDto> createGroup(
            @Valid @RequestBody GroupRequestDto requestDto) {
        GroupResponseDto response = groupService.createGroup(requestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Update a group", description = "Admin or Professor - Update an existing group")
    public ResponseEntity<GroupResponseDto> updateGroup(
            @PathVariable UUID id,
            @Valid @RequestBody GroupUpdateDto requestDto) {
        GroupResponseDto response = groupService.updateGroup(id, requestDto);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get group by ID", description = "Get a single group by its ID")
    public ResponseEntity<GroupResponseDto> getGroupById(@PathVariable UUID id) {
        GroupResponseDto response = groupService.getGroupById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/code/{code}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get group by code", description = "Get a single group by its code")
    public ResponseEntity<GroupResponseDto> getGroupByCode(@PathVariable String code) {
        GroupResponseDto response = groupService.getGroupByCode(code);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get all groups", description = "Get all groups with pagination")
    public ResponseEntity<PageResponse<GroupResponseDto>> getAllGroups(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "name") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<GroupResponseDto> response = groupService.getAllGroups(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/simple")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get all groups (simple)", description = "Get all groups with minimal information")
    public ResponseEntity<List<GroupSimpleResponseDto>> getAllGroupsSimple() {
        List<GroupSimpleResponseDto> response = groupService.getAllGroupsSimple();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/module/{moduleId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get groups by module", description = "Get all groups for a specific module")
    public ResponseEntity<PageResponse<GroupResponseDto>> getGroupsByModule(
            @PathVariable UUID moduleId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "name") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<GroupResponseDto> response = groupService.getGroupsByModule(moduleId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/module/{moduleId}/active")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get active groups by module", description = "Get all active groups for a module")
    public ResponseEntity<List<GroupSimpleResponseDto>> getActiveGroupsByModule(
            @PathVariable UUID moduleId) {
        List<GroupSimpleResponseDto> response = groupService.getActiveGroupsByModule(moduleId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/student/{studentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get groups by student", description = "Get all groups for a specific student")
    public ResponseEntity<PageResponse<GroupResponseDto>> getGroupsByStudent(
            @PathVariable UUID studentId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "name") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<GroupResponseDto> response = groupService.getGroupsByStudent(studentId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/semester/{semesterId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get groups by semester", description = "Get all groups for a specific semester")
    public ResponseEntity<PageResponse<GroupResponseDto>> getGroupsBySemester(
            @PathVariable UUID semesterId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "name") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<GroupResponseDto> response = groupService.getGroupsBySemester(semesterId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/active")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get active groups", description = "Get all active groups")
    public ResponseEntity<PageResponse<GroupResponseDto>> getActiveGroups(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "name") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<GroupResponseDto> response = groupService.getActiveGroups(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/available")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get available groups", description = "Get all groups that are not full")
    public ResponseEntity<PageResponse<GroupResponseDto>> getAvailableGroups(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "name") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<GroupResponseDto> response = groupService.getAvailableGroups(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/module/{moduleId}/available")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get available groups by module", description = "Get available groups for a specific module")
    public ResponseEntity<List<GroupSimpleResponseDto>> getAvailableGroupsByModule(
            @PathVariable UUID moduleId) {
        List<GroupSimpleResponseDto> response = groupService.getAvailableGroupsByModule(moduleId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/full")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get full groups", description = "Get all groups that have reached max capacity")
    public ResponseEntity<PageResponse<GroupResponseDto>> getFullGroups(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "name") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<GroupResponseDto> response = groupService.getFullGroups(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Search groups", description = "Search groups by name, code, or module")
    public ResponseEntity<PageResponse<GroupResponseDto>> searchGroups(
            @RequestParam String searchTerm,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "name") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<GroupResponseDto> response = groupService.searchGroups(searchTerm, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @PostMapping("/{groupId}/enroll")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Enroll students in group", description = "Admin or Professor - Enroll one or more students in a group")
    public ResponseEntity<GroupResponseDto> enrollStudents(
            @PathVariable UUID groupId,
            @Valid @RequestBody EnrollStudentsDto enrollDto) {
        enrollDto.setGroupId(groupId);
        GroupResponseDto response = groupService.enrollStudents(groupId, enrollDto);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{groupId}/students/{studentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Remove student from group", description = "Admin or Professor - Remove a student from a group")
    public ResponseEntity<MessageResponse> removeStudentFromGroup(
            @PathVariable UUID groupId,
            @PathVariable UUID studentId) {
        MessageResponse response = groupService.removeStudentFromGroup(groupId, studentId);
        return ResponseEntity.ok(response);
    }

    @PatchMapping("/{id}/toggle-status")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Toggle group status", description = "Admin or Professor - Activate or deactivate a group")
    public ResponseEntity<GroupResponseDto> toggleGroupStatus(@PathVariable UUID id) {
        GroupResponseDto response = groupService.toggleGroupStatus(id);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Delete a group", description = "Admin or Professor - Delete a group by ID")
    public ResponseEntity<MessageResponse> deleteGroup(@PathVariable UUID id) {
        groupService.deleteGroup(id);
        return ResponseEntity.ok(new MessageResponse("Group deleted successfully", true));
    }

    @GetMapping("/exists/code/{code}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Check if code exists", description = "Admin or Professor - Check if a group code already exists")
    public ResponseEntity<Boolean> existsByCode(@PathVariable String code) {
        boolean exists = groupService.existsByCode(code);
        return ResponseEntity.ok(exists);
    }

    @GetMapping("/{id}/is-full")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Check if group is full", description = "Check if a group has reached max capacity")
    public ResponseEntity<Boolean> isGroupFull(@PathVariable UUID id) {
        boolean isFull = groupService.isGroupFull(id);
        return ResponseEntity.ok(isFull);
    }
}