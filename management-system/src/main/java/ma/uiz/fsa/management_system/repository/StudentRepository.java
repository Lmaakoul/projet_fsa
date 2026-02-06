package ma.uiz.fsa.management_system.repository;

import ma.uiz.fsa.management_system.model.entity.Student;
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
public interface StudentRepository extends JpaRepository<Student, UUID> {

    Optional<Student> findByCne(String cne);

    Optional<Student> findByCin(String cin);

    Optional<Student> findByUsername(String username);

    Optional<Student> findByEmail(String email);

    Boolean existsByCne(String cne);

    Boolean existsByCin(String cin);

    Boolean existsByUsername(String username);

    Boolean existsByEmail(String email);

    List<Student> findByFiliereId(UUID filiereId);

    Page<Student> findByFiliereId(UUID filiereId, Pageable pageable);

    @Query("SELECT s FROM Student s WHERE " +
            "LOWER(s.firstName) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(s.lastName) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(s.email) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(s.cne) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(s.cin) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(s.filiere.name) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    Page<Student> searchStudents(@Param("searchTerm") String searchTerm, Pageable pageable);

    @Query("SELECT COUNT(s) FROM Student s WHERE s.filiere.id = :filiereId")
    Long countByFiliereId(@Param("filiereId") UUID filiereId);

    @Query("SELECT s FROM Student s WHERE s.enabled = :enabled")
    Page<Student> findByEnabled(@Param("enabled") Boolean enabled, Pageable pageable);

    @Query("SELECT s FROM Student s JOIN s.groups g WHERE g.id = :groupId")
    Page<Student> findByGroupId(@Param("groupId") UUID groupId, Pageable pageable);
}