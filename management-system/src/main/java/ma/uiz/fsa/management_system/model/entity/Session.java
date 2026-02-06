package ma.uiz.fsa.management_system.model.entity;

import ma.uiz.fsa.management_system.model.audit.Auditable;
import ma.uiz.fsa.management_system.model.enums.AttendanceMode;
import ma.uiz.fsa.management_system.model.enums.SessionType;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Table(name = "sessions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Session extends Auditable {

    @Column(nullable = false, unique = true, length = 100)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private SessionType type;

    @Column(nullable = false)
    private Integer duration;

    @Column(nullable = false)
    private LocalDateTime schedule;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "location_id")
    private Location location;

    @Column(length = 1000)
    private String description;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "module_id")
    private Module module;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "professor_id")
    private Professor professor;

    @ManyToMany
    @JoinTable(
            name = "session_groups",
            joinColumns = @JoinColumn(name = "session_id"),
            inverseJoinColumns = @JoinColumn(name = "group_id")
    )
    @Builder.Default
    private Set<Group> groups = new HashSet<>();

    @OneToMany(mappedBy = "session", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<AttendanceRecord> attendanceRecords = new ArrayList<>();

    @Column(nullable = false)
    @Builder.Default
    private Boolean isCompleted = false;

    @Column(nullable = false)
    @Builder.Default
    private Boolean attendanceTaken = false;

    @Column(name = "qr_code", length = 500)
    private String qrCode;  // QR code content: "SESSION:UUID:DATETIME"

    @Column(name = "qr_code_image", columnDefinition = "TEXT")
    private String qrCodeImage;  // Base64 encoded PNG image

    @Column(name = "qr_code_expiry")
    private LocalDateTime qrCodeExpiry;  // QR code expiration time

    @Column(name = "attendance_mode")
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private AttendanceMode attendanceMode = AttendanceMode.PROFESSOR_SCAN;  // MANUAL, PROFESSOR_SCAN, STUDENT_SCAN

    // Helper method to check if QR code is valid
    public boolean isQrCodeValid() {
        if (qrCode == null || qrCodeExpiry == null) {
            return false;
        }
        return LocalDateTime.now().isBefore(qrCodeExpiry);
    }
}