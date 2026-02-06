package ma.uiz.fsa.management_system.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;
import ma.uiz.fsa.management_system.model.enums.EvaluationType;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BulkEvaluationDto {

    @NotNull(message = "Module ID is required")
    private UUID moduleId;

    @NotNull(message = "Evaluation type is required")
    private EvaluationType type;

    @NotNull(message = "Date is required")
    private LocalDate date;

    @NotNull(message = "Coefficient is required")
    @DecimalMin(value = "0.1", message = "Coefficient must be at least 0.1")
    private Double coefficient;

    @NotNull(message = "Max grade is required")
    @DecimalMin(value = "0.0", message = "Max grade must be at least 0")
    private Double maxGrade;

    @NotEmpty(message = "Student grades list cannot be empty")
    private List<StudentGradeDto> studentGrades;
}