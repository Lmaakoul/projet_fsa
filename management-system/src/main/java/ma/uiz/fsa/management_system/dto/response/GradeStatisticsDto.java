package ma.uiz.fsa.management_system.dto.response;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GradeStatisticsDto {

    private UUID entityId;
    private String entityName;

    // Basic statistics
    private Integer totalEvaluations;
    private Double averageGrade;
    private Double highestGrade;
    private Double lowestGrade;
    private Double medianGrade;
    private Double standardDeviation;

    // Grade distribution
    private Integer excellentCount;  // >= 16/20
    private Integer goodCount;       // 14-16
    private Integer satisfactoryCount; // 12-14
    private Integer passingCount;    // 10-12
    private Integer failingCount;    // < 10

    // Percentages
    private Double passRate;
    private Double failRate;
    private Double excellenceRate;
}