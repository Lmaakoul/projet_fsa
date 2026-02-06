package ma.uiz.fsa.management_system.repository;

import ma.uiz.fsa.management_system.model.entity.Group;
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
public interface GroupRepository extends JpaRepository<Group, UUID> {

    Optional<Group> findByCodeIgnoreCase(String code);

    Boolean existsByCodeIgnoreCase(String code);

    Page<Group> findByModuleId(UUID moduleId, Pageable pageable);

    List<Group> findByModuleId(UUID moduleId);

    Page<Group> findByIsActive(Boolean isActive, Pageable pageable);

    @Query("SELECT g FROM Group g JOIN g.students s WHERE s.id = :studentId")
    Page<Group> findByStudentId(@Param("studentId") UUID studentId, Pageable pageable);

    @Query("SELECT g FROM Group g WHERE g.module.semester.id = :semesterId")
    Page<Group> findBySemesterId(@Param("semesterId") UUID semesterId, Pageable pageable);

    @Query("SELECT g FROM Group g WHERE " +
            "LOWER(g.name) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(g.code) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(g.module.title) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    Page<Group> searchGroups(@Param("searchTerm") String searchTerm, Pageable pageable);

    @Query("SELECT COUNT(g) FROM Group g WHERE g.module.id = :moduleId")
    Long countByModuleId(@Param("moduleId") UUID moduleId);

    @Query("SELECT g FROM Group g WHERE g.isActive = true AND SIZE(g.students) < g.maxCapacity")
    Page<Group> findAvailableGroups(Pageable pageable);

    @Query("SELECT g FROM Group g WHERE g.module.id = :moduleId AND g.isActive = true AND SIZE(g.students) < g.maxCapacity")
    List<Group> findAvailableGroupsByModule(@Param("moduleId") UUID moduleId);

    @Query("SELECT g FROM Group g WHERE SIZE(g.students) >= g.maxCapacity")
    Page<Group> findFullGroups(Pageable pageable);

    @Query("SELECT g FROM Group g WHERE g.module.id = :moduleId AND g.isActive = true")
    List<Group> findActiveGroupsByModule(@Param("moduleId") UUID moduleId);
}