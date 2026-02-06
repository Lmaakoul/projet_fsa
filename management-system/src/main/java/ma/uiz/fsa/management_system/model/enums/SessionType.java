package ma.uiz.fsa.management_system.model.enums;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;

@JsonFormat(shape = JsonFormat.Shape.OBJECT)
@Getter
public enum SessionType {
    LECTURE("Lecture", "Cours magistral"),
    TP("Practical Work", "Travaux pratiques"),
    TD("Tutorial", "Travaux dirigés"),
    SEMINAR("Seminar", "Séminaire"),
    PROJECT("Project", "Projet");

    private final String label;
    private final String labelFr;

    SessionType(String label, String labelFr) {
        this.label = label;
        this.labelFr = labelFr;
    }

    @JsonValue
    public String getName() {
        return this.name();
    }
}