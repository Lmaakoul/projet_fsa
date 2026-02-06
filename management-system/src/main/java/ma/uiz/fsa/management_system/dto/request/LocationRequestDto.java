package ma.uiz.fsa.management_system.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;
import ma.uiz.fsa.management_system.model.enums.RoomType;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LocationRequestDto {

    @NotBlank(message = "Building name is required")
    @Size(max = 100, message = "Building name must not exceed 100 characters")
    private String building;

    @NotBlank(message = "Room number is required")
    @Size(max = 50, message = "Room number must not exceed 50 characters")
    private String roomNumber;

    @NotNull(message = "Room type is required")
    private RoomType roomType;

    @NotNull(message = "Capacity is required")
    @Min(value = 1, message = "Capacity must be at least 1")
    @Max(value = 500, message = "Capacity must not exceed 500")
    private Integer capacity;

    @Size(max = 1000, message = "Equipment description must not exceed 1000 characters")
    private String equipment;

    @Size(max = 500, message = "Notes must not exceed 500 characters")
    private String notes;

    private UUID departmentId;

    @Builder.Default
    private Boolean isActive = true;
}