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
public class AttendanceRecordSimpleResponseDto {

    private UUID id;
    private LocalDate date;
    private AttendanceStatus status;
    private LocalDateTime scannedAt;
    private String studentName;
    private String moduleTitle;
    private Boolean isJustified;
}