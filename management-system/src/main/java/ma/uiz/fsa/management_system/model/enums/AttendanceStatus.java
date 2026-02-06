package ma.uiz.fsa.management_system.model.enums;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;

@JsonFormat(shape = JsonFormat.Shape.OBJECT)
@Getter
public enum AttendanceStatus {
    PRESENT("Present", "Présent"),
    ABSENT("Absent", "Absent"),
    LATE("Late", "En retard"),
    CATCHING_UP("Catching Up", "Rattrapage"),
    EXCUSED("Excused", "Excusé");

    private final String label;
    private final String labelFr;

    AttendanceStatus(String label, String labelFr) {
        this.label = label;
        this.labelFr = labelFr;
    }

    @JsonValue
    public String getName() {
        return this.name();
    }
}