package ma.uiz.fsa.management_system.repository;

import ma.uiz.fsa.management_system.model.entity.Module;
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
public interface ModuleRepository extends JpaRepository<Module, UUID> {

    Optional<Module> findByCodeIgnoreCase(String code);

    Boolean existsByCodeIgnoreCase(String code);

    List<Module> findBySemesterId(UUID semesterId);

    Page<Module> findBySemesterId(UUID semesterId, Pageable pageable);

    List<Module> findByIsActive(Boolean isActive);

    Page<Module> findByIsActive(Boolean isActive, Pageable pageable);

    @Query("SELECT m FROM Module m JOIN m.professors p WHERE p.id = :professorId")
    Page<Module> findByProfessorId(@Param("professorId") UUID professorId, Pageable pageable);

    @Query("SELECT m FROM Module m WHERE m.semester.filiere.id = :filiereId")
    Page<Module> findByFiliereId(@Param("filiereId") UUID filiereId, Pageable pageable);

    @Query("SELECT m FROM Module m WHERE m.semester.academicYear = :academicYear")
    Page<Module> findByAcademicYear(@Param("academicYear") String academicYear, Pageable pageable);

    @Query("SELECT m FROM Module m WHERE " +
            "LOWER(m.title) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(m.code) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(m.semester.name) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    Page<Module> searchModules(@Param("searchTerm") String searchTerm, Pageable pageable);

    @Query("SELECT COUNT(m) FROM Module m WHERE m.semester.id = :semesterId")
    Long countBySemesterId(@Param("semesterId") UUID semesterId);

    @Query("SELECT m FROM Module m JOIN m.professors p WHERE p.id = :professorId AND m.isActive = true")
    List<Module> findActiveModulesByProfessor(@Param("professorId") UUID professorId);

    @Query("SELECT m FROM Module m WHERE m.semester.id = :semesterId AND m.isActive = true")
    List<Module> findActiveModulesBySemester(@Param("semesterId") UUID semesterId);
}