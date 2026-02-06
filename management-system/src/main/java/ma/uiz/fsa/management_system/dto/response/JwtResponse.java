package ma.uiz.fsa.management_system.dto.response;

import lombok.*;

import java.util.Set;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class JwtResponse {

    private String accessToken;
    private String refreshToken;

    @Builder.Default
    private String tokenType = "Bearer";

    private UUID userId;
    private String username;
    private String email;
    private Set<String> roles;

    private Long expiresIn; // in milliseconds
}