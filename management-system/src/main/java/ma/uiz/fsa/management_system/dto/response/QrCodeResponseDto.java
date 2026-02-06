package ma.uiz.fsa.management_system.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QrCodeResponseDto {
    private byte[] imageBytes;
    private String filename;
    private String cne;
}