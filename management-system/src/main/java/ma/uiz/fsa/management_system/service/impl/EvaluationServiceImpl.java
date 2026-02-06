package ma.uiz.fsa.management_system.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.uiz.fsa.management_system.dto.request.BulkEvaluationDto;
import ma.uiz.fsa.management_system.dto.request.EvaluationRequestDto;
import ma.uiz.fsa.management_system.dto.request.EvaluationUpdateDto;
import ma.uiz.fsa.management_system.dto.request.StudentGradeDto;
import ma.uiz.fsa.management_system.dto.response.*;
import ma.uiz.fsa.management_system.exception.BadRequestException;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.mapper.EvaluationMapper;
import ma.uiz.fsa.management_system.model.entity.Evaluation;
import ma.uiz.fsa.management_system.model.entity.Module;
import ma.uiz.fsa.management_system.model.entity.Student;
import ma.uiz.fsa.management_system.model.enums.EvaluationType;
import ma.uiz.fsa.management_system.repository.EvaluationRepository;
import ma.uiz.fsa.management_system.repository.ModuleRepository;
import ma.uiz.fsa.management_system.repository.StudentRepository;
import ma.uiz.fsa.management_system.service.EvaluationService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class EvaluationServiceImpl implements EvaluationService {

    private final EvaluationRepository evaluationRepository;
    private final StudentRepository studentRepository;
    private final ModuleRepository moduleRepository;
    private final EvaluationMapper evaluationMapper;

    @Override
    @Transactional
    public EvaluationResponseDto createEvaluation(EvaluationRequestDto requestDto) {
        log.debug("Creating evaluation for student ID: {} and module ID: {}",
                requestDto.getStudentId(), requestDto.getModuleId());

        // Validate grade is within max grade
        if (requestDto.getGrade() > requestDto.getMaxGrade()) {
            throw new BadRequestException(
                    "Grade (" + requestDto.getGrade() + ") cannot exceed max grade (" + requestDto.getMaxGrade() + ")"
            );
        }

        Evaluation evaluation = evaluationMapper.toEntity(requestDto);
        Evaluation savedEvaluation = evaluationRepository.save(evaluation);

        log.info("Evaluation created successfully with ID: {}", savedEvaluation.getId());
        return evaluationMapper.toResponseDto(savedEvaluation);
    }

    @Override
    @Transactional
    public MessageResponse createBulkEvaluations(BulkEvaluationDto bulkDto) {
        log.debug("Creating bulk evaluations for module ID: {}", bulkDto.getModuleId());

        Module module = moduleRepository.findById(bulkDto.getModuleId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Module not found with ID: " + bulkDto.getModuleId()));

        int successCount = 0;
        int failureCount = 0;
        List<String> errors = new ArrayList<>();

        for (StudentGradeDto studentGrade : bulkDto.getStudentGrades()) {
            try {
                // Validate grade
                if (studentGrade.getGrade() > bulkDto.getMaxGrade()) {
                    errors.add("Student " + studentGrade.getStudentId() + ": Grade exceeds max grade");
                    failureCount++;
                    continue;
                }

                Student student = studentRepository.findById(studentGrade.getStudentId())
                        .orElseThrow(() -> new ResourceNotFoundException(
                                "Student not found with ID: " + studentGrade.getStudentId()));

                Evaluation evaluation = Evaluation.builder()
                        .type(bulkDto.getType())
                        .student(student)
                        .module(module)
                        .date(bulkDto.getDate())
                        .grade(studentGrade.getGrade())
                        .coefficient(bulkDto.getCoefficient())
                        .maxGrade(bulkDto.getMaxGrade())
                        .comments(studentGrade.getComments())
                        .isValidated(false)
                        .build();

                evaluationRepository.save(evaluation);
                successCount++;

            } catch (Exception e) {
                errors.add("Student " + studentGrade.getStudentId() + ": " + e.getMessage());
                failureCount++;
                log.error("Error creating evaluation for student {}: {}",
                        studentGrade.getStudentId(), e.getMessage());
            }
        }

        String message = String.format(
                "Bulk evaluations created: %d successful, %d failed. %s",
                successCount, failureCount,
                errors.isEmpty() ? "" : "Errors: " + String.join("; ", errors)
        );

        log.info(message);
        return new MessageResponse(message, failureCount == 0);
    }

    @Override
    @Transactional
    public EvaluationResponseDto updateEvaluation(UUID id, EvaluationUpdateDto requestDto) {
        log.debug("Updating evaluation with ID: {}", id);

        Evaluation evaluation = evaluationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evaluation not found with ID: " + id));

        // Prevent updating validated evaluations
        if (evaluation.getIsValidated() && requestDto.getGrade() != null) {
            throw new BadRequestException("Cannot modify grade of a validated evaluation");
        }

        // Validate grade if being updated
        if (requestDto.getGrade() != null) {
            Double maxGrade = requestDto.getMaxGrade() != null ? requestDto.getMaxGrade() : evaluation.getMaxGrade();
            if (requestDto.getGrade() > maxGrade) {
                throw new BadRequestException("Grade cannot exceed max grade");
            }
        }

        evaluationMapper.updateEntityFromUpdateDto(requestDto, evaluation);
        Evaluation updatedEvaluation = evaluationRepository.save(evaluation);

        log.info("Evaluation updated successfully with ID: {}", updatedEvaluation.getId());
        return evaluationMapper.toResponseDto(updatedEvaluation);
    }

    @Override
    @Transactional
    public EvaluationResponseDto validateEvaluation(UUID id) {
        log.debug("Validating evaluation with ID: {}", id);

        Evaluation evaluation = evaluationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evaluation not found with ID: " + id));

        if (evaluation.getIsValidated()) {
            throw new BadRequestException("Evaluation is already validated");
        }

        evaluation.setIsValidated(true);
        Evaluation validatedEvaluation = evaluationRepository.save(evaluation);

        log.info("Evaluation validated successfully with ID: {}", id);
        return evaluationMapper.toResponseDto(validatedEvaluation);
    }

    @Override
    @Transactional(readOnly = true)
    public EvaluationResponseDto getEvaluationById(UUID id) {
        log.debug("Fetching evaluation with ID: {}", id);

        Evaluation evaluation = evaluationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evaluation not found with ID: " + id));

        return evaluationMapper.toResponseDto(evaluation);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<EvaluationResponseDto> getAllEvaluations(Pageable pageable) {
        log.debug("Fetching all evaluations with pagination");

        Page<Evaluation> evaluations = evaluationRepository.findAll(pageable);
        return evaluations.map(evaluationMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<EvaluationSimpleResponseDto> getAllEvaluationsSimple() {
        log.debug("Fetching all evaluations (simple)");

        List<Evaluation> evaluations = evaluationRepository.findAll();
        return evaluations.stream()
                .map(evaluationMapper::toSimpleResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<EvaluationResponseDto> getEvaluationsByStudent(UUID studentId, Pageable pageable) {
        log.debug("Fetching evaluations for student ID: {}", studentId);

        Page<Evaluation> evaluations = evaluationRepository.findByStudentId(studentId, pageable);
        return evaluations.map(evaluationMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<EvaluationResponseDto> getEvaluationsByModule(UUID moduleId, Pageable pageable) {
        log.debug("Fetching evaluations for module ID: {}", moduleId);

        Page<Evaluation> evaluations = evaluationRepository.findByModuleId(moduleId, pageable);
        return evaluations.map(evaluationMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<EvaluationResponseDto> getEvaluationsByStudentAndModule(UUID studentId, UUID moduleId) {
        log.debug("Fetching evaluations for student ID: {} and module ID: {}", studentId, moduleId);

        List<Evaluation> evaluations = evaluationRepository.findByStudentIdAndModuleId(studentId, moduleId);
        return evaluations.stream()
                .map(evaluationMapper::toResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<EvaluationResponseDto> getEvaluationsByType(EvaluationType type, Pageable pageable) {
        log.debug("Fetching evaluations of type: {}", type);

        Page<Evaluation> evaluations = evaluationRepository.findByType(type, pageable);
        return evaluations.map(evaluationMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<EvaluationResponseDto> getEvaluationsBySemester(UUID semesterId, Pageable pageable) {
        log.debug("Fetching evaluations for semester ID: {}", semesterId);

        Page<Evaluation> evaluations = evaluationRepository.findBySemesterId(semesterId, pageable);
        return evaluations.map(evaluationMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<EvaluationResponseDto> getValidatedEvaluations(Pageable pageable) {
        log.debug("Fetching validated evaluations");

        Page<Evaluation> evaluations = evaluationRepository.findByIsValidated(true, pageable);
        return evaluations.map(evaluationMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<EvaluationResponseDto> getPendingEvaluations(Pageable pageable) {
        log.debug("Fetching pending evaluations");

        Page<Evaluation> evaluations = evaluationRepository.findByIsValidated(false, pageable);
        return evaluations.map(evaluationMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<EvaluationResponseDto> getEvaluationsByDateRange(
            LocalDate startDate, LocalDate endDate, Pageable pageable) {
        log.debug("Fetching evaluations between {} and {}", startDate, endDate);

        if (startDate.isAfter(endDate)) {
            throw new BadRequestException("Start date must be before end date");
        }

        Page<Evaluation> evaluations = evaluationRepository.findByDateBetween(startDate, endDate, pageable);
        return evaluations.map(evaluationMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<EvaluationResponseDto> getStudentEvaluationsByDateRange(
            UUID studentId, LocalDate startDate, LocalDate endDate) {
        log.debug("Fetching evaluations for student ID: {} between {} and {}",
                studentId, startDate, endDate);

        if (startDate.isAfter(endDate)) {
            throw new BadRequestException("Start date must be before end date");
        }

        List<Evaluation> evaluations = evaluationRepository.findByStudentIdAndDateBetween(
                studentId, startDate, endDate);
        return evaluations.stream()
                .map(evaluationMapper::toResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<EvaluationResponseDto> getFailingGrades(Pageable pageable) {
        log.debug("Fetching failing grades");

        Page<Evaluation> evaluations = evaluationRepository.findFailingGrades(pageable);
        return evaluations.map(evaluationMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<EvaluationSimpleResponseDto> getFailingGradesByStudent(UUID studentId) {
        log.debug("Fetching failing grades for student ID: {}", studentId);

        List<Evaluation> evaluations = evaluationRepository.findFailingGradesByStudent(studentId);
        return evaluations.stream()
                .map(evaluationMapper::toSimpleResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<EvaluationResponseDto> searchEvaluations(String searchTerm, Pageable pageable) {
        log.debug("Searching evaluations with term: {}", searchTerm);

        Page<Evaluation> evaluations = evaluationRepository.searchEvaluations(searchTerm, pageable);
        return evaluations.map(evaluationMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public GradeStatisticsDto getStudentGradeStatistics(UUID studentId) {
        log.debug("Calculating grade statistics for student ID: {}", studentId);

        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with ID: " + studentId));

        List<Evaluation> evaluations = evaluationRepository.findByStudentId(studentId, Pageable.unpaged()).getContent();

        if (evaluations.isEmpty()) {
            return GradeStatisticsDto.builder()
                    .entityId(studentId)
                    .entityName(student.getFirstName() + " " + student.getLastName())
                    .totalEvaluations(0)
                    .build();
        }

        return calculateStatistics(studentId, student.getFirstName() + " " + student.getLastName(), evaluations);
    }

    @Override
    @Transactional(readOnly = true)
    public GradeStatisticsDto getModuleGradeStatistics(UUID moduleId) {
        log.debug("Calculating grade statistics for module ID: {}", moduleId);

        Module module = moduleRepository.findById(moduleId)
                .orElseThrow(() -> new ResourceNotFoundException("Module not found with ID: " + moduleId));

        List<Evaluation> evaluations = evaluationRepository.findByModuleId(moduleId, Pageable.unpaged()).getContent();

        if (evaluations.isEmpty()) {
            return GradeStatisticsDto.builder()
                    .entityId(moduleId)
                    .entityName(module.getTitle())
                    .totalEvaluations(0)
                    .build();
        }

        return calculateStatistics(moduleId, module.getTitle(), evaluations);
    }

    @Override
    @Transactional(readOnly = true)
    public StudentTranscriptDto getStudentTranscript(UUID studentId, UUID semesterId) {
        log.debug("Generating transcript for student ID: {} and semester ID: {}", studentId, semesterId);

        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with ID: " + studentId));

        // Implementation for transcript generation would go here
        // This is a simplified version
        return StudentTranscriptDto.builder()
                .studentId(studentId)
                .studentName(student.getFirstName() + " " + student.getLastName())
                .studentCne(student.getCne())
                .filiereName(student.getFiliere() != null ? student.getFiliere().getName() : null)
                .build();
    }

    @Override
    @Transactional
    public void deleteEvaluation(UUID id) {
        log.debug("Deleting evaluation with ID: {}", id);

        Evaluation evaluation = evaluationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evaluation not found with ID: " + id));

        if (evaluation.getIsValidated()) {
            throw new BadRequestException("Cannot delete a validated evaluation");
        }

        evaluationRepository.delete(evaluation);
        log.info("Evaluation deleted successfully with ID: {}", id);
    }

    private GradeStatisticsDto calculateStatistics(UUID entityId, String entityName, List<Evaluation> evaluations) {
        List<Double> normalizedGrades = evaluations.stream()
                .map(e -> (e.getGrade() / e.getMaxGrade()) * 20.0)
                .sorted()
                .collect(Collectors.toList());

        Double average = normalizedGrades.stream()
                .mapToDouble(Double::doubleValue)
                .average()
                .orElse(0.0);

        Double highest = normalizedGrades.stream()
                .max(Double::compare)
                .orElse(0.0);

        Double lowest = normalizedGrades.stream()
                .min(Double::compare)
                .orElse(0.0);

        Double median = calculateMedian(normalizedGrades);
        Double stdDev = calculateStandardDeviation(normalizedGrades, average);

        // Grade distribution
        int excellent = (int) normalizedGrades.stream().filter(g -> g >= 16.0).count();
        int good = (int) normalizedGrades.stream().filter(g -> g >= 14.0 && g < 16.0).count();
        int satisfactory = (int) normalizedGrades.stream().filter(g -> g >= 12.0 && g < 14.0).count();
        int passing = (int) normalizedGrades.stream().filter(g -> g >= 10.0 && g < 12.0).count();
        int failing = (int) normalizedGrades.stream().filter(g -> g < 10.0).count();

        int total = normalizedGrades.size();
        Double passRate = ((total - failing) * 100.0) / total;
        Double failRate = (failing * 100.0) / total;
        Double excellenceRate = (excellent * 100.0) / total;

        return GradeStatisticsDto.builder()
                .entityId(entityId)
                .entityName(entityName)
                .totalEvaluations(total)
                .averageGrade(average)
                .highestGrade(highest)
                .lowestGrade(lowest)
                .medianGrade(median)
                .standardDeviation(stdDev)
                .excellentCount(excellent)
                .goodCount(good)
                .satisfactoryCount(satisfactory)
                .passingCount(passing)
                .failingCount(failing)
                .passRate(passRate)
                .failRate(failRate)
                .excellenceRate(excellenceRate)
                .build();
    }

    private Double calculateMedian(List<Double> sortedGrades) {
        int size = sortedGrades.size();
        if (size == 0) return 0.0;
        if (size % 2 == 0) {
            return (sortedGrades.get(size / 2 - 1) + sortedGrades.get(size / 2)) / 2.0;
        } else {
            return sortedGrades.get(size / 2);
        }
    }

    private Double calculateStandardDeviation(List<Double> grades, Double mean) {
        if (grades.size() <= 1) return 0.0;

        double variance = grades.stream()
                .mapToDouble(g -> Math.pow(g - mean, 2))
                .average()
                .orElse(0.0);

        return Math.sqrt(variance);
    }
}