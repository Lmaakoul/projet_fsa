package ma.uiz.fsa.management_system.dto.response;

import lombok.*;
import ma.uiz.fsa.management_system.model.enums.AttendanceMode;
import ma.uiz.fsa.management_system.model.enums.SessionType;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SessionResponseDto {

    private UUID id;
    private String name;
    private SessionType type;
    private LocalDateTime schedule;
    private Integer duration;
    private String description;
    private Boolean isCompleted;
    private Boolean attendanceTaken;
    private AttendanceMode attendanceMode;
    private String qrCode;
    private String qrCodeImage;  // Base64 encoded image

    // location details
    private UUID locationId;
    private String locationName;        // e.g., "Building A - Room 101"
    private String locationBuilding;
    private String locationRoomNumber;
    private Integer locationCapacity;

    // Module info
    private UUID moduleId;
    private String moduleTitle;
    private String moduleCode;

    // Professor info
    private UUID professorId;
    private String professorName;
    private String professorEmail;

    // Groups
    private List<GroupSimpleResponseDto> groups;

    // Statistics
    private Integer totalGroups;
    private Integer totalAttendanceRecords;
    private Integer presentCount;
    private Integer absentCount;
    private Double attendanceRate;

    // Audit fields
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String createdBy;
    private String lastModifiedBy;
}