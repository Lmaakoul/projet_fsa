package ma.uiz.fsa.management_system.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StudentScanSessionQrRequestDto {

    @NotNull(message = "Student ID is required")
    private UUID studentId;

    @NotBlank(message = "Session QR code is required")
    private String sessionQrCode;

    private String deviceInfo;
    private String ipAddress;
    private Double latitude;   // Optional: for location verification
    private Double longitude;  // Optional: for location verification
}