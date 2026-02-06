package ma.uiz.fsa.management_system.dto.response;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AttendanceStatisticsDto {

    private UUID entityId;
    private String entityName;
    private Integer totalSessions;
    private Integer presentCount;
    private Integer absentCount;
    private Integer lateCount;
    private Integer excusedCount;
    private Double attendanceRate;
    private Double absenteeismRate;
}