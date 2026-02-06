package ma.uiz.fsa.management_system.repository;

import ma.uiz.fsa.management_system.model.entity.AttendanceRecord;
import ma.uiz.fsa.management_system.model.enums.AttendanceStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AttendanceRecordRepository extends JpaRepository<AttendanceRecord, UUID> {

    Page<AttendanceRecord> findByStudentId(UUID studentId, Pageable pageable);

    Page<AttendanceRecord> findBySessionId(UUID sessionId, Pageable pageable);

    Page<AttendanceRecord> findByStatus(AttendanceStatus status, Pageable pageable);

    Page<AttendanceRecord> findByIsJustified(Boolean isJustified, Pageable pageable);

    Optional<AttendanceRecord> findByStudentIdAndSessionId(UUID studentId, UUID sessionId);

    @Query("SELECT ar FROM AttendanceRecord ar WHERE ar.student.id = :studentId AND ar.date BETWEEN :startDate AND :endDate")
    List<AttendanceRecord> findByStudentIdAndDateBetween(
            @Param("studentId") UUID studentId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    @Query("SELECT ar FROM AttendanceRecord ar WHERE ar.session.module.id = :moduleId")
    Page<AttendanceRecord> findByModuleId(@Param("moduleId") UUID moduleId, Pageable pageable);

    @Query("SELECT ar FROM AttendanceRecord ar WHERE ar.session.module.id = :moduleId AND ar.student.id = :studentId")
    List<AttendanceRecord> findByModuleIdAndStudentId(
            @Param("moduleId") UUID moduleId,
            @Param("studentId") UUID studentId);

    @Query("SELECT ar FROM AttendanceRecord ar WHERE ar.date BETWEEN :startDate AND :endDate")
    Page<AttendanceRecord> findByDateBetween(
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate,
            Pageable pageable);

    @Query("SELECT COUNT(ar) FROM AttendanceRecord ar WHERE ar.student.id = :studentId AND ar.status = :status")
    Long countByStudentIdAndStatus(
            @Param("studentId") UUID studentId,
            @Param("status") AttendanceStatus status);

    @Query("SELECT COUNT(ar) FROM AttendanceRecord ar WHERE ar.session.id = :sessionId AND ar.status = :status")
    Long countBySessionIdAndStatus(
            @Param("sessionId") UUID sessionId,
            @Param("status") AttendanceStatus status);

    @Query("SELECT COUNT(ar) FROM AttendanceRecord ar WHERE ar.session.module.id = :moduleId AND ar.status = :status")
    Long countByModuleIdAndStatus(
            @Param("moduleId") UUID moduleId,
            @Param("status") AttendanceStatus status);

    @Query("SELECT COUNT(ar) FROM AttendanceRecord ar WHERE ar.session.module.id = :moduleId")
    Long countByModuleId(@Param("moduleId") UUID moduleId);

    @Query("SELECT ar FROM AttendanceRecord ar WHERE ar.status = 'ABSENT' AND ar.isJustified = false")
    Page<AttendanceRecord> findUnjustifiedAbsences(Pageable pageable);

    @Query("SELECT ar FROM AttendanceRecord ar WHERE ar.student.id = :studentId AND ar.status = 'ABSENT' AND ar.isJustified = false")
    List<AttendanceRecord> findUnjustifiedAbsencesByStudent(@Param("studentId") UUID studentId);

    @Query("SELECT COUNT(ar) FROM AttendanceRecord ar WHERE ar.student.id = :studentId")
    Long countByStudentId(@Param("studentId") UUID studentId);

    Boolean existsByStudentIdAndSessionId(UUID studentId, UUID sessionId);

    @Query("SELECT ar FROM AttendanceRecord ar WHERE " +
            "LOWER(ar.student.firstName) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(ar.student.lastName) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(ar.student.cne) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    Page<AttendanceRecord> searchAttendanceRecords(@Param("searchTerm") String searchTerm, Pageable pageable);
}