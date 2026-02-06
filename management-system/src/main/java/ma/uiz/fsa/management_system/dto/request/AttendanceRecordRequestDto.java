package ma.uiz.fsa.management_system.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;
import ma.uiz.fsa.management_system.model.enums.AttendanceStatus;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AttendanceRecordRequestDto {

    @NotNull(message = "Student ID is required")
    private UUID studentId;

    @NotNull(message = "Session ID is required")
    private UUID sessionId;

    @NotNull(message = "Date is required")
    private LocalDate date;

    @NotNull(message = "Attendance status is required")
    private AttendanceStatus status;

    @NotNull(message = "Scanned at timestamp is required")
    private LocalDateTime scannedAt;

    @Size(max = 1000, message = "Justification note must not exceed 1000 characters")
    private String justificationNote;

    @Size(max = 500, message = "Justification document URL must not exceed 500 characters")
    private String justificationDocumentUrl;

    @Builder.Default
    private Boolean isJustified = false;

    @Size(max = 255, message = "Device info must not exceed 255 characters")
    private String deviceInfo;

    @Size(max = 50, message = "IP address must not exceed 50 characters")
    private String ipAddress;
}