package ma.uiz.fsa.management_system.repository;

import ma.uiz.fsa.management_system.model.entity.Location;
import ma.uiz.fsa.management_system.model.entity.Session;
import ma.uiz.fsa.management_system.model.enums.RoomType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface LocationRepository extends JpaRepository<Location, UUID> {

    Optional<Location> findByBuildingAndRoomNumber(String building, String roomNumber);

    List<Location> findByDepartmentId(UUID departmentId);

    List<Location> findByRoomType(RoomType roomType);

    List<Location> findByIsActiveTrue();

    Page<Location> findByIsActiveTrue(Pageable pageable);

    @Query("SELECT l FROM Location l WHERE l.capacity >= :minCapacity AND l.isActive = true")
    List<Location> findByMinimumCapacity(@Param("minCapacity") Integer minCapacity);

    @Query("SELECT l FROM Location l WHERE l.roomType = :roomType AND l.capacity >= :minCapacity AND l.isActive = true")
    List<Location> findByRoomTypeAndMinimumCapacity(
            @Param("roomType") RoomType roomType,
            @Param("minCapacity") Integer minCapacity
    );

    /**
     * Find available locations for a given time slot
     */
    @Query("SELECT l FROM Location l WHERE l.isActive = true " +
            "AND l.id NOT IN (" +
            "  SELECT s.location.id FROM Session s " +
            "  WHERE s.location IS NOT NULL " +
            "  AND s.schedule < :endTime " +
            "  AND FUNCTION('TIMESTAMPADD', MINUTE, s.duration, s.schedule) > :startTime" +
            ")")
    List<Location> findAvailableLocations(
            @Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime
    );

    /**
     * Find available locations with specific capacity for a time slot
     */
    @Query("SELECT l FROM Location l WHERE l.isActive = true " +
            "AND l.capacity >= :minCapacity " +
            "AND l.id NOT IN (" +
            "  SELECT s.location.id FROM Session s " +
            "  WHERE s.location IS NOT NULL " +
            "  AND s.schedule < :endTime " +
            "  AND FUNCTION('TIMESTAMPADD', MINUTE, s.duration, s.schedule) > :startTime" +
            ")")
    List<Location> findAvailableLocationsWithCapacity(
            @Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime,
            @Param("minCapacity") Integer minCapacity
    );

    /**
     * Check if a location is available for a specific time slot
     */
    @Query("SELECT COUNT(s) = 0 FROM Session s " +
            "WHERE s.location.id = :locationId " +
            "AND s.schedule < :endTime " +
            "AND FUNCTION('TIMESTAMPADD', MINUTE, s.duration, s.schedule) > :startTime")
    boolean isLocationAvailable(
            @Param("locationId") UUID locationId,
            @Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime
    );

    /**
     * Find sessions scheduled at a location
     */
    @Query("SELECT s FROM Session s WHERE s.location.id = :locationId " +
            "AND s.schedule BETWEEN :startDate AND :endDate " +
            "ORDER BY s.schedule ASC")
    List<Session> findSessionsByLocationAndDateRange(
            @Param("locationId") UUID locationId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate
    );

    @Query("SELECT CASE WHEN COUNT(l) > 0 THEN true ELSE false END " +
            "FROM Location l WHERE l.building = :building AND l.roomNumber = :roomNumber")
    boolean existsByBuildingAndRoomNumber(
            @Param("building") String building,
            @Param("roomNumber") String roomNumber
    );
}