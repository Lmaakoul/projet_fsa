package ma.uiz.fsa.management_system.dto.response;

import lombok.*;

import java.util.List;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ModuleGradeDto {

    private UUID moduleId;
    private String moduleTitle;
    private String moduleCode;
    private Integer credits;
    private Double passingGrade;

    private List<EvaluationSimpleResponseDto> evaluations;

    private Double moduleAverage;
    private String letterGrade;
    private Boolean isPassing;
}