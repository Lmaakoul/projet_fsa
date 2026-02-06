package ma.uiz.fsa.management_system.dto.response;

import lombok.*;
import ma.uiz.fsa.management_system.model.enums.DegreeType;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FiliereSimpleResponseDto {

    private UUID id;
    private String name;
    private String code;
    private DegreeType degreeType;
    private String departmentName;
    private Boolean isActive;
}