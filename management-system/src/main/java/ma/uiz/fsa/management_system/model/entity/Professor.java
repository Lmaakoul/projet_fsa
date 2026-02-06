package ma.uiz.fsa.management_system.model.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Table(name = "professors")
@PrimaryKeyJoinColumn(name = "user_id")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class Professor extends User {

    @Column(nullable = false, length = 100)
    private String firstName;

    @Column(nullable = false, length = 100)
    private String lastName;

    @Column(length = 50)
    private String grade;

    @Column(length = 255)
    private String scanningDeviceInfo;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "department_id")
    private Department department;

    @ManyToMany(mappedBy = "professors")
    @Builder.Default
    private Set<Module> modules = new HashSet<>();

    @OneToMany(mappedBy = "professor", cascade = CascadeType.ALL)
    @Builder.Default
    private List<Session> sessions = new ArrayList<>();

    @Column(length = 500)
    private String photoUrl;

    @Column(length = 20)
    private String phoneNumber;

    @Column(length = 255)
    private String officeLocation;

    @Column(length = 500)
    private String specialization;
}