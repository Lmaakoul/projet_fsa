package ma.uiz.fsa.management_system.model.entity;

import ma.uiz.fsa.management_system.model.audit.Auditable;
import ma.uiz.fsa.management_system.model.enums.EvaluationType;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "evaluations")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Evaluation extends Auditable {

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private EvaluationType type;

    @Column(nullable = false)
    private LocalDate date;

    @Column(nullable = false)
    private Double grade;

    @Column(nullable = false)
    private Double coefficient;

    @Column(length = 1000)
    private String comments;

    @Column(nullable = false)
    @Builder.Default
    private Double maxGrade = 20.0;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "module_id", nullable = false)
    private Module module;

    @Column(nullable = false)
    @Builder.Default
    private Boolean isValidated = false;
}