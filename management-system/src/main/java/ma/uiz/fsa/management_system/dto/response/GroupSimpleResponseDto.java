package ma.uiz.fsa.management_system.dto.response;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GroupSimpleResponseDto {

    private UUID id;
    private String name;
    private String code;
    private Integer studentCount;
    private Integer maxCapacity;
    private String moduleTitle;
    private Boolean isActive;
}