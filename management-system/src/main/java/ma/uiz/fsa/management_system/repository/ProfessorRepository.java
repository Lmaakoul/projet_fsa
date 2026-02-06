package ma.uiz.fsa.management_system.repository;

import ma.uiz.fsa.management_system.model.entity.Professor;
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
public interface ProfessorRepository extends JpaRepository<Professor, UUID> {

    Optional<Professor> findByUsername(String username);

    Optional<Professor> findByEmail(String email);

    Boolean existsByUsername(String username);

    Boolean existsByEmail(String email);

    List<Professor> findByDepartmentId(UUID departmentId);

    Page<Professor> findByDepartmentId(UUID departmentId, Pageable pageable);

    @Query("SELECT p FROM Professor p WHERE " +
            "LOWER(p.firstName) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(p.lastName) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(p.email) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(p.specialization) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(p.department.name) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    Page<Professor> searchProfessors(@Param("searchTerm") String searchTerm, Pageable pageable);

    @Query("SELECT p FROM Professor p WHERE p.grade = :grade")
    Page<Professor> findByGrade(@Param("grade") String grade, Pageable pageable);

    @Query("SELECT COUNT(p) FROM Professor p WHERE p.department.id = :departmentId")
    Long countByDepartmentId(@Param("departmentId") UUID departmentId);

    @Query("SELECT p FROM Professor p WHERE p.enabled = :enabled")
    Page<Professor> findByEnabled(@Param("enabled") Boolean enabled, Pageable pageable);
}