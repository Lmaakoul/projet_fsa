package ma.uiz.fsa.management_system.model.enums;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;

@JsonFormat(shape = JsonFormat.Shape.OBJECT)
@Getter
public enum EvaluationType {
    EXAM("Exam", "Examen"),
    MIDTERM("Midterm", "Partiel"),
    QUIZ("Quiz", "Quiz"),
    HOMEWORK("Homework", "Devoir"),
    PROJECT("Project", "Projet"),
    PRESENTATION("Presentation", "Présentation"),
    LAB("Lab", "Travaux pratiques"),
    PRACTICAL("Practical", "Pratique"),
    ORAL("Oral", "Oral");

    private final String label;
    private final String labelFr;

    EvaluationType(String label, String labelFr) {
        this.label = label;
        this.labelFr = labelFr;
    }

    @JsonValue
    public String getName() {
        return this.name();
    }
}