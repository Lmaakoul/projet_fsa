package ma.uiz.fsa.management_system.model.entity;

import ma.uiz.fsa.management_system.model.audit.Auditable;
import ma.uiz.fsa.management_system.model.enums.DegreeType;
import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "filieres")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Filiere extends Auditable {

    @Column(nullable = false, length = 100)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private DegreeType degreeType;

    @Column(length = 1000)
    private String description;

    @Column(unique = true, length = 10)
    private String code;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "department_id")
    private Department department;

    @OneToMany(mappedBy = "filiere", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Semester> semesters = new ArrayList<>();

    @OneToMany(mappedBy = "filiere")
    @Builder.Default
    private List<Student> students = new ArrayList<>();

    @Column(nullable = false)
    @Builder.Default
    private Integer durationYears = 3;

    @Column(nullable = false)
    @Builder.Default
    private Boolean isActive = true;
}

