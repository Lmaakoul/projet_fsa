package ma.uiz.fsa.management_system.dto.response;

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
public class AttendanceRecordResponseDto {

    private UUID id;
    private LocalDate date;
    private AttendanceStatus status;
    private LocalDateTime scannedAt;
    private Boolean isJustified;
    private String justificationNote;
    private String justificationDocumentUrl;

    // Student info
    private UUID studentId;
    private String studentName;
    private String studentCne;
    private String studentEmail;

    // Session info
    private UUID sessionId;
    private String sessionType;
    private LocalDateTime sessionSchedule;

    // Location info
    private String locationName;
    private String locationBuilding;
    private String locationRoomNumber;

    // Module info
    private String moduleTitle;
    private String moduleCode;

    // Technical info
    private String deviceInfo;
    private String ipAddress;
    private String markedBy;

    // Audit fields
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String createdBy;
    private String lastModifiedBy;
}