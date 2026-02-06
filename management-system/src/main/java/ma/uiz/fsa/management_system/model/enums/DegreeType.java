package ma.uiz.fsa.management_system.model.enums;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;

@JsonFormat(shape = JsonFormat.Shape.OBJECT)
@Getter
public enum DegreeType {
    DEUG("DEUG", "DEUG"),
    LP("LP", "Licence Professionnelle"),
    LICENCE("Licence", "Licence"),
    MASTER("Master", "Master"),
    DOCTORAT("Doctorate", "Doctorat");

    private final String label;
    private final String labelFr;

    DegreeType(String label, String labelFr) {
        this.label = label;
        this.labelFr = labelFr;
    }

    @JsonValue
    public String getName() {
        return this.name();
    }
}