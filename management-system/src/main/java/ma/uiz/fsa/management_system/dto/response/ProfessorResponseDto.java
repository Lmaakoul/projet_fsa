package ma.uiz.fsa.management_system.dto.response;

import lombok.*;

import java.time.LocalDateTime;
import java.util.Set;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProfessorResponseDto {

    private UUID id;
    private String username;
    private String email;
    private String firstName;
    private String lastName;
    private String fullName;
    private String grade;
    private String phoneNumber;
    private String officeLocation;
    private String specialization;
    private String photoUrl;
    private String scanningDeviceInfo;

    // Department info
    private UUID departmentId;
    private String departmentName;
    private String departmentCode;

    // Statistics
    private Integer totalModules;
    private Integer totalSessions;

    // Account status
    private Boolean enabled;
    private Boolean accountNonExpired;
    private Boolean accountNonLocked;
    private Boolean credentialsNonExpired;

    // Roles
    private Set<String> roles;

    // Audit fields
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String createdBy;
    private String lastModifiedBy;
}