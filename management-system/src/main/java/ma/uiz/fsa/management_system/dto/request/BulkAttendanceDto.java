package ma.uiz.fsa.management_system.dto.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import ma.uiz.fsa.management_system.model.enums.AttendanceStatus;

import java.util.List;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BulkAttendanceDto {

    @NotNull(message = "Session ID is required")
    private UUID sessionId;

    @NotEmpty(message = "Student IDs list cannot be empty")
    private List<UUID> studentIds;

    @NotNull(message = "Attendance status is required")
    private AttendanceStatus status;
}