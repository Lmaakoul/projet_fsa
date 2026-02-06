package ma.uiz.fsa.management_system.service;

import ma.uiz.fsa.management_system.dto.request.BulkEvaluationDto;
import ma.uiz.fsa.management_system.dto.request.EvaluationRequestDto;
import ma.uiz.fsa.management_system.dto.request.EvaluationUpdateDto;
import ma.uiz.fsa.management_system.dto.response.*;
import ma.uiz.fsa.management_system.model.enums.EvaluationType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface EvaluationService {

    EvaluationResponseDto createEvaluation(EvaluationRequestDto requestDto);

    MessageResponse createBulkEvaluations(BulkEvaluationDto bulkDto);

    EvaluationResponseDto updateEvaluation(UUID id, EvaluationUpdateDto requestDto);

    EvaluationResponseDto validateEvaluation(UUID id);

    EvaluationResponseDto getEvaluationById(UUID id);

    Page<EvaluationResponseDto> getAllEvaluations(Pageable pageable);

    List<EvaluationSimpleResponseDto> getAllEvaluationsSimple();

    Page<EvaluationResponseDto> getEvaluationsByStudent(UUID studentId, Pageable pageable);

    Page<EvaluationResponseDto> getEvaluationsByModule(UUID moduleId, Pageable pageable);

    List<EvaluationResponseDto> getEvaluationsByStudentAndModule(UUID studentId, UUID moduleId);

    Page<EvaluationResponseDto> getEvaluationsByType(EvaluationType type, Pageable pageable);

    Page<EvaluationResponseDto> getEvaluationsBySemester(UUID semesterId, Pageable pageable);

    Page<EvaluationResponseDto> getValidatedEvaluations(Pageable pageable);

    Page<EvaluationResponseDto> getPendingEvaluations(Pageable pageable);

    Page<EvaluationResponseDto> getEvaluationsByDateRange(LocalDate startDate, LocalDate endDate, Pageable pageable);

    List<EvaluationResponseDto> getStudentEvaluationsByDateRange(UUID studentId, LocalDate startDate, LocalDate endDate);

    Page<EvaluationResponseDto> getFailingGrades(Pageable pageable);

    List<EvaluationSimpleResponseDto> getFailingGradesByStudent(UUID studentId);

    Page<EvaluationResponseDto> searchEvaluations(String searchTerm, Pageable pageable);

    GradeStatisticsDto getStudentGradeStatistics(UUID studentId);

    GradeStatisticsDto getModuleGradeStatistics(UUID moduleId);

    StudentTranscriptDto getStudentTranscript(UUID studentId, UUID semesterId);

    void deleteEvaluation(UUID id);
}