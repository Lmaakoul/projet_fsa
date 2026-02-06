package ma.uiz.fsa.management_system.model.entity;

import ma.uiz.fsa.management_system.model.audit.Auditable;
import jakarta.persistence.*;
import lombok.*;

import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "groups")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Group extends Auditable {

    @Column(nullable = false, length = 50)
    private String name;

    @Column(length = 500)
    private String description;

    @Column(unique = true, length = 20)
    private String code;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "module_id")
    private Module module;

    @ManyToMany
    @JoinTable(
            name = "group_students",
            joinColumns = @JoinColumn(name = "group_id"),
            inverseJoinColumns = @JoinColumn(name = "student_id")
    )
    @Builder.Default
    private Set<Student> students = new HashSet<>();

    @ManyToMany(mappedBy = "groups")
    @Builder.Default
    private Set<Session> sessions = new HashSet<>();

    @Column(nullable = false)
    @Builder.Default
    private Integer maxCapacity = 30;

    @Column(nullable = false)
    @Builder.Default
    private Boolean isActive = true;
}