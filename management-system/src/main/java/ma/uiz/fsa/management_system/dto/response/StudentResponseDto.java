package ma.uiz.fsa.management_system.dto.response;

import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Set;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StudentResponseDto {

    private UUID id;
    private String username;
    private String email;
    private String cne;
    private String cin;
    private String firstName;
    private String lastName;
    private String fullName;
    private LocalDate dateOfBirth;
    private String phoneNumber;
    private String address;
    private String photoUrl;
    private String qrCode;
    private String qrCodeImage;  // Base64 encoded image

    // Filiere info
    private UUID filiereId;
    private String filiereName;
    private String filiereCode;
    private String departmentName;

    // Statistics
    private Integer totalGroups;
    private Integer totalEvaluations;
    private Integer totalAttendanceRecords;
    private Double averageGrade;

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

    // Or provide data URI for direct use in <img> tags
    public String getQrCodeDataUri() {
        if (qrCodeImage != null) {
            return "data:image/png;base64," + qrCodeImage;
        }
        return null;
    }
}
