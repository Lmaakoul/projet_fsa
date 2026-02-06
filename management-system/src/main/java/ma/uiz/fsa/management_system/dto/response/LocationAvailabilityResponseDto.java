package ma.uiz.fsa.management_system.dto.response;

import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LocationAvailabilityResponseDto {

    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Integer requestedCapacity;
    private List<LocationResponseDto> availableLocations;
    private Integer totalAvailable;
}