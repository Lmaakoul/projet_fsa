package ma.uiz.fsa.management_system.dto.response;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SemesterSimpleResponseDto {

    private UUID id;
    private String name;
    private Integer semesterNumber;
    private String academicYear;
    private String filiereName;
    private Boolean isActive;
}