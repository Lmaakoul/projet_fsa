package ma.uiz.fsa.management_system.dto.response;

import lombok.*;

import java.util.List;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StudentTranscriptDto {

    private UUID studentId;
    private String studentName;
    private String studentCne;
    private String filiereName;
    private String academicYear;

    private List<ModuleGradeDto> moduleGrades;

    private Double overallAverage;
    private Double totalCredits;
    private Double earnedCredits;
    private String overallLetterGrade;
    private Boolean isPassing;
}