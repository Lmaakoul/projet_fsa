package ma.uiz.fsa.management_system.dto.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.util.Set;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EnrollStudentsDto {

    @NotNull(message = "Group ID is required")
    private UUID groupId;

    @NotEmpty(message = "At least one student ID is required")
    private Set<UUID> studentIds;
}