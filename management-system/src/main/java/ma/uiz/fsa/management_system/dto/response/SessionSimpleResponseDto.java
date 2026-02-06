package ma.uiz.fsa.management_system.dto.response;

import lombok.*;
import ma.uiz.fsa.management_system.model.enums.SessionType;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SessionSimpleResponseDto {

    private UUID id;
    private String name;
    private SessionType type;
    private LocalDateTime schedule;
    private Integer duration;
    private UUID locationId;
    private String moduleTitle;
    private String professorName;
    private Boolean isCompleted;
    private Boolean attendanceTaken;
}