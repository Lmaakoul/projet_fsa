package ma.uiz.fsa.management_system.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class JustifyAbsenceDto {

    @NotBlank(message = "Justification note is required")
    @Size(min = 10, max = 1000, message = "Justification note must be between 10 and 1000 characters")
    private String justificationNote;

    @Size(max = 500, message = "Document URL must not exceed 500 characters")
    private String justificationDocumentUrl;
}