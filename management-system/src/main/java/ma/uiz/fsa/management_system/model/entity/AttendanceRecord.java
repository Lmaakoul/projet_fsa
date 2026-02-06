package ma.uiz.fsa.management_system.model.entity;

import jakarta.persistence.*;
import lombok.*;
import ma.uiz.fsa.management_system.model.audit.Auditable;
import ma.uiz.fsa.management_system.model.enums.AttendanceStatus;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "attendance_records")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AttendanceRecord extends Auditable {

    @Column(nullable = false)
    private LocalDate date;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private AttendanceStatus status;

    @Column(nullable = false)
    private LocalDateTime scannedAt;

    @Column(nullable = false)
    @Builder.Default
    private Boolean isJustified = false;

    @Column(length = 1000)
    private String justificationNote;

    @Column(length = 500)
    private String justificationDocumentUrl;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false)
    private Session session;

    @Column(length = 255)
    private String deviceInfo;

    @Column(length = 50)
    private String ipAddress;

    @Column(length = 100)
    private String markedBy;
}
