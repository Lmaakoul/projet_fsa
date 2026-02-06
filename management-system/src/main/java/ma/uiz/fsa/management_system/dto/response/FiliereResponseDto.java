package ma.uiz.fsa.management_system.dto.response;

import lombok.*;
import ma.uiz.fsa.management_system.model.enums.DegreeType;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FiliereResponseDto {

    private UUID id;
    private String name;
    private String code;
    private DegreeType degreeType;
    private String description;
    private Integer durationYears;
    private Boolean isActive;

    // Department info
    private UUID departmentId;
    private String departmentName;
    private String departmentCode;

    // Semester info
    private List<SemesterSimpleResponseDto> semesters;

    // Statistics
    private Integer totalSemesters;
    private Integer totalStudents;

    // Audit fields
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String createdBy;
    private String lastModifiedBy;
}