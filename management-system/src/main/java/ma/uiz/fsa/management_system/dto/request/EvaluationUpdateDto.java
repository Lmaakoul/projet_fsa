package ma.uiz.fsa.management_system.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;
import ma.uiz.fsa.management_system.model.enums.EvaluationType;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EvaluationUpdateDto {

    private EvaluationType type;

    @PastOrPresent(message = "Date must be in the past or present")
    private LocalDate date;

    @DecimalMin(value = "0.0", message = "Grade must be at least 0")
    @DecimalMax(value = "20.0", message = "Grade must not exceed 20")
    private Double grade;

    @DecimalMin(value = "0.1", message = "Coefficient must be at least 0.1")
    @DecimalMax(value = "10.0", message = "Coefficient must not exceed 10")
    private Double coefficient;

    @DecimalMin(value = "0.0", message = "Max grade must be at least 0")
    @DecimalMax(value = "100.0", message = "Max grade must not exceed 100")
    private Double maxGrade;

    @Size(max = 1000, message = "Comments must not exceed 1000 characters")
    private String comments;

    private Boolean isValidated;
}