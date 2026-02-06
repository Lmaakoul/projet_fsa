package ma.uiz.fsa.management_system.model.enums;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;

@JsonFormat(shape = JsonFormat.Shape.OBJECT)
@Getter
public enum RoomType {
    AMPHITHEATER("Amphitheater", "Amphithéâtre"),
    CLASSROOM("Classroom", "Salle de classe"),
    LABORATORY("Laboratory", "Laboratoire"),
    COMPUTER_LAB("Computer Lab", "Laboratoire informatique"),
    SEMINAR_ROOM("Seminar Room", "Salle de séminaire"),
    WORKSHOP("Workshop", "Atelier"),
    LIBRARY("Library", "Bibliothèque"),
    OFFICE("Office", "Bureau");

    private final String label;
    private final String labelFr;

    RoomType(String label, String labelFr) {
        this.label = label;
        this.labelFr = labelFr;
    }

    @JsonValue
    public String getName() {
        return this.name();
    }
}