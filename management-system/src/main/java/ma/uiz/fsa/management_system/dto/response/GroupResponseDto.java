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
public class GroupResponseDto {

    private UUID id;
    private String name;
    private String code;
    private String description;
    private Integer maxCapacity;
    private Integer currentCapacity;
    private Boolean isActive;
    private Boolean isFull;
    private Double fillRate;

    // Module info
    private UUID moduleId;
    private String moduleTitle;
    private String moduleCode;

    // Students
    private List<StudentSimpleResponseDto> students;

    // Statistics
    private Integer totalStudents;
    private Integer totalSessions;
    private Integer availableSlots;

    // Audit fields
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String createdBy;
    private String lastModifiedBy;
}