package ma.uiz.fsa.management_system.repository;

import ma.uiz.fsa.management_system.model.entity.Semester;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SemesterRepository extends JpaRepository<Semester, UUID> {

    List<Semester> findByFiliereId(UUID filiereId);

    Page<Semester> findByFiliereId(UUID filiereId, Pageable pageable);

    List<Semester> findByAcademicYear(String academicYear);

    Page<Semester> findByAcademicYear(String academicYear, Pageable pageable);

    List<Semester> findByIsActive(Boolean isActive);

    Page<Semester> findByIsActive(Boolean isActive, Pageable pageable);

    @Query("SELECT s FROM Semester s WHERE s.filiere.id = :filiereId AND s.semesterNumber = :semesterNumber")
    Optional<Semester> findByFiliereIdAndSemesterNumber(
            @Param("filiereId") UUID filiereId,
            @Param("semesterNumber") Integer semesterNumber);

    @Query("SELECT s FROM Semester s WHERE s.filiere.id = :filiereId AND s.academicYear = :academicYear")
    List<Semester> findByFiliereIdAndAcademicYear(
            @Param("filiereId") UUID filiereId,
            @Param("academicYear") String academicYear);

    @Query("SELECT s FROM Semester s WHERE " +
            "LOWER(s.name) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(s.academicYear) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(s.filiere.name) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    Page<Semester> searchSemesters(@Param("searchTerm") String searchTerm, Pageable pageable);

    @Query("SELECT COUNT(s) FROM Semester s WHERE s.filiere.id = :filiereId")
    Long countByFiliereId(@Param("filiereId") UUID filiereId);

    @Query("SELECT s FROM Semester s WHERE s.filiere.id = :filiereId AND s.isActive = true ORDER BY s.semesterNumber")
    List<Semester> findActiveSemestersByFiliere(@Param("filiereId") UUID filiereId);

    Boolean existsByFiliereIdAndSemesterNumber(UUID filiereId, Integer semesterNumber);
}