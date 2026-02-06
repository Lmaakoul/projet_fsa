package ma.uiz.fsa.management_system.dto.response;

import lombok.*;
import ma.uiz.fsa.management_system.model.enums.EvaluationType;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EvaluationResponseDto {

    private UUID id;
    private EvaluationType type;
    private LocalDate date;
    private Double grade;
    private Double coefficient;
    private Double maxGrade;
    private String comments;
    private Boolean isValidated;

    // Calculated fields
    private Double normalizedGrade; // Grade out of 20
    private Double weightedGrade;   // Grade × coefficient
    private String letterGrade;     // A+, A, B+, etc.
    private Boolean isPassing;      // Grade >= passing grade

    // Student info
    private UUID studentId;
    private String studentName;
    private String studentCne;
    private String studentEmail;

    // Module info
    private UUID moduleId;
    private String moduleTitle;
    private String moduleCode;
    private Double modulePassingGrade;

    // Audit fields
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String createdBy;
    private String lastModifiedBy;
}