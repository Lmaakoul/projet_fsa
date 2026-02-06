package ma.uiz.fsa.management_system.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;
import ma.uiz.fsa.management_system.model.enums.EvaluationType;

import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EvaluationRequestDto {

    @NotNull(message = "Evaluation type is required")
    private EvaluationType type;

    @NotNull(message = "Student ID is required")
    private UUID studentId;

    @NotNull(message = "Module ID is required")
    private UUID moduleId;

    @NotNull(message = "Date is required")
    @PastOrPresent(message = "Date must be in the past or present")
    private LocalDate date;

    @NotNull(message = "Grade is required")
    @DecimalMin(value = "0.0", message = "Grade must be at least 0")
    @DecimalMax(value = "20.0", message = "Grade must not exceed 20")
    private Double grade;

    @NotNull(message = "Coefficient is required")
    @DecimalMin(value = "0.1", message = "Coefficient must be at least 0.1")
    @DecimalMax(value = "10.0", message = "Coefficient must not exceed 10")
    private Double coefficient;

    @NotNull(message = "Max grade is required")
    @DecimalMin(value = "0.0", message = "Max grade must be at least 0")
    @DecimalMax(value = "100.0", message = "Max grade must not exceed 100")
    @Builder.Default
    private Double maxGrade = 20.0;

    @Size(max = 1000, message = "Comments must not exceed 1000 characters")
    private String comments;

    @Builder.Default
    private Boolean isValidated = false;
}