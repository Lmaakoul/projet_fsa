package ma.uiz.fsa.management_system.model.enums;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;

@JsonFormat(shape = JsonFormat.Shape.OBJECT)
@Getter
public enum AttendanceMode {
    MANUAL("Manual", "Manuel"),
    PROFESSOR_SCAN("Professor Scan", "Scan Professeur"),
    STUDENT_SCAN("Student Scan", "Scan Étudiant");

    private final String label;
    private final String labelFr;

    AttendanceMode(String label, String labelFr) {
        this.label = label;
        this.labelFr = labelFr;
    }

    @JsonValue
    public String getName() {
        return this.name();
    }
}