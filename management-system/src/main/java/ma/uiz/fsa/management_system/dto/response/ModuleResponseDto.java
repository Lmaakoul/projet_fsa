package ma.uiz.fsa.management_system.dto.response;

import lombok.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ModuleResponseDto {

    private UUID id;
    private String title;
    private String code;
    private Integer credits;
    private String description;
    private Double passingGrade;
    private Boolean isActive;

    // Semester info
    private UUID semesterId;
    private String semesterName;
    private Integer semesterNumber;
    private String academicYear;

    // Filiere and Department info
    private String filiereName;
    private String filiereCode;
    private String departmentName;

    // Professors
    private List<ProfessorSimpleResponseDto> professors;

    // Statistics
    private Integer totalProfessors;
    private Integer totalSessions;
    private Integer totalGroups;
    private Integer totalEvaluations;

    // Audit fields
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String createdBy;
    private String lastModifiedBy;
}