package ma.uiz.fsa.management_system.dto.response;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProfessorSimpleResponseDto {

    private UUID id;
    private String fullName;
    private String email;
    private String grade;
    private String departmentName;
    private String specialization;
}