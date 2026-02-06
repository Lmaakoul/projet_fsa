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
public class AssignProfessorsDto {

    @NotNull(message = "Module ID is required")
    private UUID moduleId;

    @NotEmpty(message = "At least one professor ID is required")
    private Set<UUID> professorIds;
}