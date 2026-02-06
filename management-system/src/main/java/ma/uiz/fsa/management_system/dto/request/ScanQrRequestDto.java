package ma.uiz.fsa.management_system.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScanQrRequestDto {

    @NotNull(message = "Session ID is required")
    private UUID sessionId;

    @NotBlank(message = "Student QR code is required")
    private String studentQrCode;

    @Size(max = 255, message = "Device info must not exceed 255 characters")
    private String deviceInfo;

    @Size(max = 50, message = "IP address must not exceed 50 characters")
    private String ipAddress;
}