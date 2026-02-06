package ma.uiz.fsa.management_system.repository;

import ma.uiz.fsa.management_system.model.entity.Admin;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface AdminRepository extends JpaRepository<Admin, UUID> {

    Optional<Admin> findByUsername(String username);

    Optional<Admin> findByEmail(String email);

    Boolean existsByUsername(String username);

    Boolean existsByEmail(String email);
}