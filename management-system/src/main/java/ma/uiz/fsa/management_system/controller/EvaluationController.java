package ma.uiz.fsa.management_system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.BulkEvaluationDto;
import ma.uiz.fsa.management_system.dto.request.EvaluationRequestDto;
import ma.uiz.fsa.management_system.dto.request.EvaluationUpdateDto;
import ma.uiz.fsa.management_system.dto.response.*;
import ma.uiz.fsa.management_system.model.enums.EvaluationType;
import ma.uiz.fsa.management_system.service.EvaluationService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/evaluations")
@RequiredArgsConstructor
@Tag(name = "Evaluation", description = "Grade and evaluation management APIs")
@SecurityRequirement(name = "bearerAuth")
public class EvaluationController {

    private final EvaluationService evaluationService;

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Create an evaluation", description = "Admin or Professor - Create a new evaluation/grade")
    public ResponseEntity<EvaluationResponseDto> createEvaluation(
            @Valid @RequestBody EvaluationRequestDto requestDto) {
        EvaluationResponseDto response = evaluationService.createEvaluation(requestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/bulk")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Create bulk evaluations", description = "Admin or Professor - Create evaluations for multiple students at once")
    public ResponseEntity<MessageResponse> createBulkEvaluations(
            @Valid @RequestBody BulkEvaluationDto bulkDto) {
        MessageResponse response = evaluationService.createBulkEvaluations(bulkDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Update an evaluation", description = "Admin or Professor - Update an existing evaluation")
    public ResponseEntity<EvaluationResponseDto> updateEvaluation(
            @PathVariable UUID id,
            @Valid @RequestBody EvaluationUpdateDto requestDto) {
        EvaluationResponseDto response = evaluationService.updateEvaluation(id, requestDto);
        return ResponseEntity.ok(response);
    }

    @PatchMapping("/{id}/validate")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Validate an evaluation", description = "Admin or Professor - Validate and lock an evaluation")
    public ResponseEntity<EvaluationResponseDto> validateEvaluation(@PathVariable UUID id) {
        EvaluationResponseDto response = evaluationService.validateEvaluation(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get evaluation by ID", description = "Get a single evaluation by its ID")
    public ResponseEntity<EvaluationResponseDto> getEvaluationById(@PathVariable UUID id) {
        EvaluationResponseDto response = evaluationService.getEvaluationById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get all evaluations", description = "Get all evaluations with pagination")
    public ResponseEntity<PageResponse<EvaluationResponseDto>> getAllEvaluations(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "date") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<EvaluationResponseDto> response = evaluationService.getAllEvaluations(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/simple")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get all evaluations (simple)", description = "Get all evaluations with minimal information")
    public ResponseEntity<List<EvaluationSimpleResponseDto>> getAllEvaluationsSimple() {
        List<EvaluationSimpleResponseDto> response = evaluationService.getAllEvaluationsSimple();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/student/{studentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get evaluations by student", description = "Get all evaluations for a specific student")
    public ResponseEntity<PageResponse<EvaluationResponseDto>> getEvaluationsByStudent(
            @PathVariable UUID studentId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "date") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<EvaluationResponseDto> response = evaluationService.getEvaluationsByStudent(studentId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/module/{moduleId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get evaluations by module", description = "Get all evaluations for a specific module")
    public ResponseEntity<PageResponse<EvaluationResponseDto>> getEvaluationsByModule(
            @PathVariable UUID moduleId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "date") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<EvaluationResponseDto> response = evaluationService.getEvaluationsByModule(moduleId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/student/{studentId}/module/{moduleId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get evaluations by student and module", description = "Get evaluations for a student in a specific module")
    public ResponseEntity<List<EvaluationResponseDto>> getEvaluationsByStudentAndModule(
            @PathVariable UUID studentId,
            @PathVariable UUID moduleId) {
        List<EvaluationResponseDto> response = evaluationService.getEvaluationsByStudentAndModule(studentId, moduleId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/type/{type}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get evaluations by type", description = "Get all evaluations of a specific type")
    public ResponseEntity<PageResponse<EvaluationResponseDto>> getEvaluationsByType(
            @PathVariable EvaluationType type,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "date") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<EvaluationResponseDto> response = evaluationService.getEvaluationsByType(type, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/semester/{semesterId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get evaluations by semester", description = "Get all evaluations for a specific semester")
    public ResponseEntity<PageResponse<EvaluationResponseDto>> getEvaluationsBySemester(
            @PathVariable UUID semesterId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "date") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<EvaluationResponseDto> response = evaluationService.getEvaluationsBySemester(semesterId, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/validated")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get validated evaluations", description = "Get all validated evaluations")
    public ResponseEntity<PageResponse<EvaluationResponseDto>> getValidatedEvaluations(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "date") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<EvaluationResponseDto> response = evaluationService.getValidatedEvaluations(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/pending")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get pending evaluations", description = "Get all pending (unvalidated) evaluations")
    public ResponseEntity<PageResponse<EvaluationResponseDto>> getPendingEvaluations(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "date") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<EvaluationResponseDto> response = evaluationService.getPendingEvaluations(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/date-range")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get evaluations by date range", description = "Get evaluations within a specific date range")
    public ResponseEntity<PageResponse<EvaluationResponseDto>> getEvaluationsByDateRange(
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
        Page<EvaluationResponseDto> response = evaluationService.getEvaluationsByDateRange(startDate, endDate, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/student/{studentId}/date-range")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get student evaluations by date range", description = "Get evaluations for a student within a date range")
    public ResponseEntity<List<EvaluationResponseDto>> getStudentEvaluationsByDateRange(
            @PathVariable UUID studentId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        List<EvaluationResponseDto> response = evaluationService.getStudentEvaluationsByDateRange(studentId, startDate, endDate);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/failing")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get failing grades", description = "Get all evaluations with failing grades")
    public ResponseEntity<PageResponse<EvaluationResponseDto>> getFailingGrades(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "date") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<EvaluationResponseDto> response = evaluationService.getFailingGrades(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/student/{studentId}/failing")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get student's failing grades", description = "Get all failing grades for a specific student")
    public ResponseEntity<List<EvaluationSimpleResponseDto>> getFailingGradesByStudent(
            @PathVariable UUID studentId) {
        List<EvaluationSimpleResponseDto> response = evaluationService.getFailingGradesByStudent(studentId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Search evaluations", description = "Search evaluations by student name, CNE, or module")
    public ResponseEntity<PageResponse<EvaluationResponseDto>> searchEvaluations(
            @RequestParam String searchTerm,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "date") String sortBy,
            @RequestParam(required = false, defaultValue = "DESC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<EvaluationResponseDto> response = evaluationService.searchEvaluations(searchTerm, pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/statistics/student/{studentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get student grade statistics", description = "Get comprehensive grade statistics for a student")
    public ResponseEntity<GradeStatisticsDto> getStudentGradeStatistics(
            @PathVariable UUID studentId) {
        GradeStatisticsDto response = evaluationService.getStudentGradeStatistics(studentId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/statistics/module/{moduleId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get module grade statistics", description = "Get comprehensive grade statistics for a module")
    public ResponseEntity<GradeStatisticsDto> getModuleGradeStatistics(
            @PathVariable UUID moduleId) {
        GradeStatisticsDto response = evaluationService.getModuleGradeStatistics(moduleId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/transcript/student/{studentId}/semester/{semesterId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR', 'STUDENT')")
    @Operation(summary = "Get student transcript", description = "Get complete transcript for a student in a semester")
    public ResponseEntity<StudentTranscriptDto> getStudentTranscript(
            @PathVariable UUID studentId,
            @PathVariable UUID semesterId) {
        StudentTranscriptDto response = evaluationService.getStudentTranscript(studentId, semesterId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete an evaluation", description = "Admin only - Delete an evaluation by ID")
    public ResponseEntity<MessageResponse> deleteEvaluation(@PathVariable UUID id) {
        evaluationService.deleteEvaluation(id);
        return ResponseEntity.ok(new MessageResponse("Evaluation deleted successfully", true));
    }
}