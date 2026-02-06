package ma.uiz.fsa.management_system.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;

import java.util.Set;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GroupUpdateDto {

    @Size(min = 2, max = 50, message = "Group name must be between 2 and 50 characters")
    private String name;

    @Size(min = 2, max = 20, message = "Group code must be between 2 and 20 characters")
    private String code;

    private UUID moduleId;

    @Size(max = 500, message = "Description must not exceed 500 characters")
    private String description;

    @Min(value = 1, message = "Max capacity must be at least 1")
    @Max(value = 200, message = "Max capacity must not exceed 200")
    private Integer maxCapacity;

    private Set<UUID> studentIds;

    private Boolean isActive;
}