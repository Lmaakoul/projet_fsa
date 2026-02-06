package ma.uiz.fsa.management_system.mapper;

import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.EvaluationRequestDto;
import ma.uiz.fsa.management_system.dto.request.EvaluationUpdateDto;
import ma.uiz.fsa.management_system.dto.response.EvaluationResponseDto;
import ma.uiz.fsa.management_system.dto.response.EvaluationSimpleResponseDto;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.model.entity.Evaluation;
import ma.uiz.fsa.management_system.model.entity.Module;
import ma.uiz.fsa.management_system.model.entity.Student;
import ma.uiz.fsa.management_system.repository.ModuleRepository;
import ma.uiz.fsa.management_system.repository.StudentRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class EvaluationMapper implements BaseMapper<Evaluation, EvaluationRequestDto, EvaluationResponseDto> {

    private final StudentRepository studentRepository;
    private final ModuleRepository moduleRepository;

    @Override
    public Evaluation toEntity(EvaluationRequestDto dto) {
        if (dto == null) return null;

        Student student = studentRepository.findById(dto.getStudentId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Student not found with ID: " + dto.getStudentId()));

        Module module = moduleRepository.findById(dto.getModuleId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Module not found with ID: " + dto.getModuleId()));

        return Evaluation.builder()
                .type(dto.getType())
                .student(student)
                .module(module)
                .date(dto.getDate())
                .grade(dto.getGrade())
                .coefficient(dto.getCoefficient())
                .maxGrade(dto.getMaxGrade())
                .comments(dto.getComments())
                .isValidated(dto.getIsValidated() != null ? dto.getIsValidated() : false)
                .build();
    }

    @Override
    public EvaluationResponseDto toResponseDto(Evaluation entity) {
        if (entity == null) return null;

        // Calculate normalized grade (out of 20)
        Double normalizedGrade = (entity.getGrade() / entity.getMaxGrade()) * 20.0;

        // Calculate weighted grade
        Double weightedGrade = normalizedGrade * entity.getCoefficient();

        // Determine letter grade
        String letterGrade = calculateLetterGrade(normalizedGrade);

        // Check if passing
        Double passingGrade = entity.getModule() != null ? entity.getModule().getPassingGrade() : 10.0;
        Boolean isPassing = normalizedGrade >= passingGrade;

        return EvaluationResponseDto.builder()
                .id(entity.getId())
                .type(entity.getType())
                .date(entity.getDate())
                .grade(entity.getGrade())
                .coefficient(entity.getCoefficient())
                .maxGrade(entity.getMaxGrade())
                .comments(entity.getComments())
                .isValidated(entity.getIsValidated())
                .normalizedGrade(normalizedGrade)
                .weightedGrade(weightedGrade)
                .letterGrade(letterGrade)
                .isPassing(isPassing)
                .studentId(entity.getStudent() != null ? entity.getStudent().getId() : null)
                .studentName(entity.getStudent() != null
                        ? entity.getStudent().getFirstName() + " " + entity.getStudent().getLastName()
                        : null)
                .studentCne(entity.getStudent() != null ? entity.getStudent().getCne() : null)
                .studentEmail(entity.getStudent() != null ? entity.getStudent().getEmail() : null)
                .moduleId(entity.getModule() != null ? entity.getModule().getId() : null)
                .moduleTitle(entity.getModule() != null ? entity.getModule().getTitle() : null)
                .moduleCode(entity.getModule() != null ? entity.getModule().getCode() : null)
                .modulePassingGrade(passingGrade)
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .createdBy(entity.getCreatedBy())
                .lastModifiedBy(entity.getLastModifiedBy())
                .build();
    }

    public EvaluationSimpleResponseDto toSimpleResponseDto(Evaluation entity) {
        if (entity == null) return null;

        return EvaluationSimpleResponseDto.builder()
                .id(entity.getId())
                .type(entity.getType())
                .date(entity.getDate())
                .grade(entity.getGrade())
                .coefficient(entity.getCoefficient())
                .studentName(entity.getStudent() != null
                        ? entity.getStudent().getFirstName() + " " + entity.getStudent().getLastName()
                        : null)
                .moduleTitle(entity.getModule() != null ? entity.getModule().getTitle() : null)
                .isValidated(entity.getIsValidated())
                .build();
    }

    @Override
    public void updateEntityFromDto(EvaluationRequestDto dto, Evaluation entity) {
        if (dto == null || entity == null) return;

        if (dto.getType() != null) {
            entity.setType(dto.getType());
        }
        if (dto.getDate() != null) {
            entity.setDate(dto.getDate());
        }
        if (dto.getGrade() != null) {
            entity.setGrade(dto.getGrade());
        }
        if (dto.getCoefficient() != null) {
            entity.setCoefficient(dto.getCoefficient());
        }
        if (dto.getMaxGrade() != null) {
            entity.setMaxGrade(dto.getMaxGrade());
        }
        if (dto.getComments() != null) {
            entity.setComments(dto.getComments());
        }
        if (dto.getIsValidated() != null) {
            entity.setIsValidated(dto.getIsValidated());
        }
    }

    public void updateEntityFromUpdateDto(EvaluationUpdateDto dto, Evaluation entity) {
        if (dto == null || entity == null) return;

        if (dto.getType() != null) {
            entity.setType(dto.getType());
        }
        if (dto.getDate() != null) {
            entity.setDate(dto.getDate());
        }
        if (dto.getGrade() != null) {
            entity.setGrade(dto.getGrade());
        }
        if (dto.getCoefficient() != null) {
            entity.setCoefficient(dto.getCoefficient());
        }
        if (dto.getMaxGrade() != null) {
            entity.setMaxGrade(dto.getMaxGrade());
        }
        if (dto.getComments() != null) {
            entity.setComments(dto.getComments());
        }
        if (dto.getIsValidated() != null) {
            entity.setIsValidated(dto.getIsValidated());
        }
    }

    private String calculateLetterGrade(Double normalizedGrade) {
        if (normalizedGrade >= 18.0) return "A+";
        if (normalizedGrade >= 16.0) return "A";
        if (normalizedGrade >= 14.0) return "B+";
        if (normalizedGrade >= 12.0) return "B";
        if (normalizedGrade >= 10.0) return "C";
        if (normalizedGrade >= 8.0) return "D";
        return "F";
    }
}