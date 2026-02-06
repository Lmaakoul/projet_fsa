package ma.uiz.fsa.management_system.repository;

import ma.uiz.fsa.management_system.model.entity.Department;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface DepartmentRepository extends JpaRepository<Department, UUID> {

    Optional<Department> findByCodeIgnoreCase(String code);

    Optional<Department> findByNameIgnoreCase(String name);

    Boolean existsByCodeIgnoreCase(String code);

    Boolean existsByNameIgnoreCase(String name);
}