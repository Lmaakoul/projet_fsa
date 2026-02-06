package ma.uiz.fsa.management_system.dto.request;

import lombok.Data;
import ma.uiz.fsa.management_system.model.entity.Role;

@Data
public class RegisterRequestDto {
    private String firstName;
    private String lastName;
    private String email;
    private String cne; // for students only (optional)
    private String cin; // for professors only (optional)
    private String password;
    private Role role; // STUDENT or PROFESSOR
}
