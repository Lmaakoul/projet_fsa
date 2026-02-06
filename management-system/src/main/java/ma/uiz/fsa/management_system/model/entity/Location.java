package ma.uiz.fsa.management_system.model.entity;

import jakarta.persistence.*;
import lombok.*;
import ma.uiz.fsa.management_system.model.audit.Auditable;
import ma.uiz.fsa.management_system.model.enums.RoomType;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "locations", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"building", "room_number"})
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Location extends Auditable {

    @Column(nullable = false, length = 100)
    private String building;

    @Column(name = "room_number", nullable = false, length = 50)
    private String roomNumber;

    @Enumerated(EnumType.STRING)
    @Column(name = "room_type", nullable = false, length = 30)
    private RoomType roomType;

    @Column(nullable = false)
    @Builder.Default
    private Integer capacity = 30;

    @Column(length = 1000)
    private String equipment;  // e.g., "Projector, Whiteboard, 30 Computers"

    @Column(nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    @Column(length = 500)
    private String notes;  // Additional information about the location

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "department_id")
    private Department department;  // Which department manages this location

    @OneToMany(mappedBy = "location", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @Builder.Default
    private List<Session> sessions = new ArrayList<>();

    // Helper method to get full location name
    public String getFullName() {
        return building + " - " + roomNumber;
    }

    // Helper method to check if location can accommodate a group size
    public boolean canAccommodate(int studentCount) {
        return isActive && studentCount <= capacity;
    }
}