package ma.uiz.fsa.management_system.dto.response;

import lombok.*;
import ma.uiz.fsa.management_system.model.enums.RoomType;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LocationResponseDto {

    private UUID id;
    private String building;
    private String roomNumber;
    private String fullName;
    private RoomType roomType;
    private Integer capacity;
    private String equipment;
    private String notes;
    private Boolean isActive;
    private String departmentName;
    private UUID departmentId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}