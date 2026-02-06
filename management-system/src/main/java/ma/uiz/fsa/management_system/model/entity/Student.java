package ma.uiz.fsa.management_system.model.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Table(name = "students")
@PrimaryKeyJoinColumn(name = "user_id")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class Student extends User {

    @Column(unique = true, nullable = false, length = 20)
    private String cne;

    @Column(unique = true, nullable = false, length = 20)
    private String cin;

    @Column(nullable = false, length = 100)
    private String firstName;

    @Column(nullable = false, length = 100)
    private String lastName;

    @Column(nullable = false)
    private LocalDate dateOfBirth;

    @Column(length = 500)
    private String photoUrl;

    @Column(length = 20)
    private String phoneNumber;

    @Column(length = 255)
    private String address;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "filiere_id")
    private Filiere filiere;

    @ManyToMany(mappedBy = "students", cascade = {CascadeType.PERSIST, CascadeType.MERGE})
    @Builder.Default
    private Set<Group> groups = new HashSet<>();

    @OneToMany(mappedBy = "student", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Evaluation> evaluations = new ArrayList<>();

    @OneToMany(mappedBy = "student", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<AttendanceRecord> attendanceRecords = new ArrayList<>();

    // QR Code content (format: "STUDENT:UUID:CNE")
    @Column(unique = true, length = 500)
    private String qrCode;

    // Store QR Code image as Base64
    @Column(name = "qr_code_image", columnDefinition = "TEXT")
    private String qrCodeImage;  // Base64 encoded PNG image

    @PreRemove
    private void removeStudentFromGroups() {
        for (Group group : this.groups) {
            group.getStudents().remove(this);
        }
        this.groups.clear();
    }
}