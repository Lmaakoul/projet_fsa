package ma.uiz.fsa.management_system.model.enums;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;

@JsonFormat(shape = JsonFormat.Shape.OBJECT)
@Getter
public enum RoleType {
    ROLE_SUPER_ADMIN("Super Admin", "Super Administrateur"),
    ROLE_ADMIN("Admin", "Administrateur"),
    ROLE_PROFESSOR("Professor", "Professeur"),
    ROLE_STUDENT("Student", "Étudiant");

    private final String label;
    private final String labelFr;

    RoleType(String label, String labelFr) {
        this.label = label;
        this.labelFr = labelFr;
    }

    @JsonValue
    public String getName() {
        return this.name();
    }
}
