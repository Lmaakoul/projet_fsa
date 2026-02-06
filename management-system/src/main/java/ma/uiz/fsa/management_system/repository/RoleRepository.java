package ma.uiz.fsa.management_system.repository;

import ma.uiz.fsa.management_system.model.entity.Role;
import ma.uiz.fsa.management_system.model.enums.RoleType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface RoleRepository extends JpaRepository<Role, UUID> {

    Optional<Role> findByName(RoleType name);

    Boolean existsByName(RoleType name);
}