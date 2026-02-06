package ma.uiz.fsa.management_system.dto.response;

import lombok.*;
import ma.uiz.fsa.management_system.model.enums.EvaluationType;

import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EvaluationSimpleResponseDto {

    private UUID id;
    private EvaluationType type;
    private LocalDate date;
    private Double grade;
    private Double coefficient;
    private String studentName;
    private String moduleTitle;
    private Boolean isValidated;
}