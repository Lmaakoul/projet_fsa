package ma.uiz.fsa.management_system.dto.request;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import ma.uiz.fsa.management_system.model.enums.RoomType;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LocationAvailabilityRequestDto {

    @NotNull(message = "Start time is required")
    @Future(message = "Start time must be in the future")
    private LocalDateTime startTime;

    @NotNull(message = "Duration is required")
    private Integer durationMinutes;

    private Integer minCapacity;

    private RoomType roomType;

    private UUID departmentId;
}