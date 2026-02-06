package ma.uiz.fsa.management_system.model.entity;

import jakarta.persistence.*;
import lombok.*;
import ma.uiz.fsa.management_system.model.enums.RoleType;

import java.util.UUID;

@Entity
@Table(name = "roles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Role {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Enumerated(EnumType.STRING)
    @Column(unique = true, nullable = false, length = 50)
    private RoleType name;

    @Column(length = 255)
    private String description;
}
