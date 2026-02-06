package ma.uiz.fsa.management_system.dto.response;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ModuleSimpleResponseDto {

    private UUID id;
    private String title;
    private String code;
    private Integer credits;
    private String semesterName;
    private Boolean isActive;
}