package ma.uiz.fsa.management_system.dto.response;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MessageResponse {

    private String message;

    @Builder.Default
    private LocalDateTime timestamp = LocalDateTime.now();

    private Boolean success;

    public MessageResponse(String message) {
        this.message = message;
        this.timestamp = LocalDateTime.now();
        this.success = true;
    }

    public MessageResponse(String message, Boolean success) {
        this.message = message;
        this.timestamp = LocalDateTime.now();
        this.success = success;
    }
}