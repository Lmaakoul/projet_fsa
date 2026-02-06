package ma.uiz.fsa.management_system.dto.request;

import jakarta.validation.constraints.Size;
import lombok.*;
import ma.uiz.fsa.management_system.model.enums.AttendanceStatus;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AttendanceRecordUpdateDto {

    private AttendanceStatus status;

    private Boolean isJustified;

    @Size(max = 1000, message = "Justification note must not exceed 1000 characters")
    private String justificationNote;

    @Size(max = 500, message = "Justification document URL must not exceed 500 characters")
    private String justificationDocumentUrl;
}