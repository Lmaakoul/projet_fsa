package ma.uiz.fsa.management_system.dto.request;

import jakarta.persistence.Column;
import jakarta.validation.constraints.*;
import lombok.*;
import ma.uiz.fsa.management_system.model.enums.AttendanceMode;
import ma.uiz.fsa.management_system.model.enums.SessionType;

import java.time.LocalDateTime;
import java.util.Set;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SessionRequestDto {

    @NotNull(message = "Session name is required")
    @Size(min = 3, max = 100, message = "Session name must be between 3 and 100 characters")
    private String name;

    @NotNull(message = "Session type is required")
    private SessionType type;

    @NotNull(message = "Module ID is required")
    private UUID moduleId;

    @NotNull(message = "Professor ID is required")
    private UUID professorId;

    @NotNull(message = "Schedule is required")
    @Future(message = "Schedule must be in the future")
    private LocalDateTime schedule;

    @NotNull(message = "Duration is required")
    @Min(value = 30, message = "Duration must be at least 30 minutes")
    @Max(value = 300, message = "Duration must not exceed 300 minutes (5 hours)")
    private Integer duration;

    @NotNull(message = "Location ID is required")
    private UUID locationId;

    @Size(max = 1000, message = "Description must not exceed 1000 characters")
    private String description;

    private Set<UUID> groupIds;

    @Builder.Default
    private AttendanceMode attendanceMode = AttendanceMode.PROFESSOR_SCAN;

    @Builder.Default
    private Boolean isCompleted = false;

    @Builder.Default
    private Boolean attendanceTaken = false;
}