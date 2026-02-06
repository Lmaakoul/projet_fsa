package ma.uiz.fsa.management_system.dto.response;

import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DepartmentResponseDto {

    private UUID id;
    private String name;
    private String code;
    private String description;
    private Integer totalFilieres;
    private Integer totalProfessors;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String createdBy;
    private String lastModifiedBy;
}