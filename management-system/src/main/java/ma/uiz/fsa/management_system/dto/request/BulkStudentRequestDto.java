package ma.uiz.fsa.management_system.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.util.List;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BulkStudentRequestDto {

    @NotNull(message = "Filiere ID is required")
    private UUID filiereId;

    @NotEmpty(message = "Students list cannot be empty")
    @Valid
    private List<StudentBulkItemDto> students;
}