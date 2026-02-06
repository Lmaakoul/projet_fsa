package ma.uiz.fsa.management_system.repository;

import ma.uiz.fsa.management_system.model.entity.Filiere;
import ma.uiz.fsa.management_system.model.enums.DegreeType;
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
public interface FiliereRepository extends JpaRepository<Filiere, UUID> {

    Optional<Filiere> findByCodeIgnoreCase(String code);

    Boolean existsByCodeIgnoreCase(String code);

    Boolean existsByNameIgnoreCase(String name);

    List<Filiere> findByDepartmentId(UUID departmentId);

    List<Filiere> findByDegreeType(DegreeType degreeType);

    List<Filiere> findByIsActive(Boolean isActive);

    Page<Filiere> findByDepartmentId(UUID departmentId, Pageable pageable);

    Page<Filiere> findByDegreeType(DegreeType degreeType, Pageable pageable);

    Page<Filiere> findByIsActive(Boolean isActive, Pageable pageable);

    @Query("SELECT f FROM Filiere f WHERE " +
            "LOWER(f.name) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(f.code) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(f.department.name) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    Page<Filiere> searchFilieres(@Param("searchTerm") String searchTerm, Pageable pageable);

    @Query("SELECT COUNT(f) FROM Filiere f WHERE f.department.id = :departmentId")
    Long countByDepartmentId(@Param("departmentId") UUID departmentId);
}