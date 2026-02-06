package ma.uiz.fsa.management_system.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;
import ma.uiz.fsa.management_system.model.enums.SessionType;

import java.time.LocalDateTime;
import java.util.Set;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SessionUpdateDto {

    @Size(min = 3, max = 100, message = "Session name must be between 3 and 100 characters")
    private String name;

    private SessionType type;

    private UUID moduleId;

    private UUID professorId;

    private LocalDateTime schedule;

    @Min(value = 30, message = "Duration must be at least 30 minutes")
    @Max(value = 300, message = "Duration must not exceed 300 minutes")
    private Integer duration;

    private UUID locationId;

    @Size(max = 1000, message = "Description must not exceed 1000 characters")
    private String description;

    private Set<UUID> groupIds;

    private Boolean isCompleted;

    private Boolean attendanceTaken;
}