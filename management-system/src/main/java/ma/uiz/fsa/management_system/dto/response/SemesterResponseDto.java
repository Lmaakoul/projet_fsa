package ma.uiz.fsa.management_system.dto.response;

import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SemesterResponseDto {

    private UUID id;
    private String name;
    private String academicYear;
    private Integer semesterNumber;
    private String description;
    private Boolean isActive;

    // Filiere info
    private UUID filiereId;
    private String filiereName;
    private String filiereCode;
    private String departmentName;

    // Statistics
    private Integer totalModules;

    // Audit fields
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String createdBy;
    private String lastModifiedBy;
}