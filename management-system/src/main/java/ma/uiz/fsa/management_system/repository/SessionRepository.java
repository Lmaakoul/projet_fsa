package ma.uiz.fsa.management_system.repository;

import ma.uiz.fsa.management_system.model.entity.Session;
import ma.uiz.fsa.management_system.model.enums.SessionType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface SessionRepository extends JpaRepository<Session, UUID> {

    Page<Session> findByModuleId(UUID moduleId, Pageable pageable);

    Page<Session> findByProfessorId(UUID professorId, Pageable pageable);

    Page<Session> findByType(SessionType type, Pageable pageable);

    Page<Session> findByIsCompleted(Boolean isCompleted, Pageable pageable);

    @Query("SELECT s FROM Session s WHERE s.schedule BETWEEN :startDate AND :endDate")
    Page<Session> findByScheduleBetween(
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate,
            Pageable pageable);

    @Query("SELECT s FROM Session s WHERE s.professor.id = :professorId AND s.schedule >= :startDate")
    List<Session> findUpcomingSessionsByProfessor(
            @Param("professorId") UUID professorId,
            @Param("startDate") LocalDateTime startDate);

    @Query("SELECT s FROM Session s JOIN s.groups g WHERE g.id = :groupId")
    Page<Session> findByGroupId(@Param("groupId") UUID groupId, Pageable pageable);

    @Query("SELECT s FROM Session s WHERE s.module.id = :moduleId AND s.schedule BETWEEN :startDate AND :endDate")
    List<Session> findByModuleIdAndScheduleBetween(
            @Param("moduleId") UUID moduleId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);

    @Query("SELECT s FROM Session s WHERE s.professor.id = :professorId AND s.isCompleted = false AND s.schedule >= :now ORDER BY s.schedule ASC")
    List<Session> findUpcomingSessionsByProfessorOrderBySchedule(
            @Param("professorId") UUID professorId,
            @Param("now") LocalDateTime now);

    @Query("SELECT s FROM Session s WHERE s.module.id = :moduleId AND s.isCompleted = false ORDER BY s.schedule ASC")
    List<Session> findIncompleteSessionsByModule(@Param("moduleId") UUID moduleId);

    @Query("SELECT COUNT(s) FROM Session s WHERE s.module.id = :moduleId")
    Long countByModuleId(@Param("moduleId") UUID moduleId);

    @Query("SELECT COUNT(s) FROM Session s WHERE s.professor.id = :professorId AND s.schedule BETWEEN :startDate AND :endDate")
    Long countByProfessorIdAndScheduleBetween(
            @Param("professorId") UUID professorId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);

    @Query("SELECT s FROM Session s WHERE " +
            "LOWER(s.location) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(s.module.title) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(s.professor.firstName) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(s.professor.lastName) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    Page<Session> searchSessions(@Param("searchTerm") String searchTerm, Pageable pageable);

    @Query("SELECT s FROM Session s WHERE s.schedule >= :now AND s.isCompleted = false ORDER BY s.schedule ASC")
    Page<Session> findUpcomingSessions(@Param("now") LocalDateTime now, Pageable pageable);

    @Query("SELECT s FROM Session s WHERE s.schedule < :now AND s.isCompleted = false")
    List<Session> findPastIncompleteSessions(@Param("now") LocalDateTime now);
}