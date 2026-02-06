package ma.uiz.fsa.management_system.service;

import ma.uiz.fsa.management_system.dto.request.LocationAvailabilityRequestDto;
import ma.uiz.fsa.management_system.dto.request.LocationRequestDto;
import ma.uiz.fsa.management_system.dto.response.LocationAvailabilityResponseDto;
import ma.uiz.fsa.management_system.dto.response.LocationResponseDto;
import ma.uiz.fsa.management_system.dto.response.SessionResponseDto;
import ma.uiz.fsa.management_system.model.enums.RoomType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface LocationService {

    LocationResponseDto createLocation(LocationRequestDto requestDto);

    LocationResponseDto updateLocation(UUID id, LocationRequestDto requestDto);

    LocationResponseDto getLocationById(UUID id);

    Page<LocationResponseDto> getAllLocations(Pageable pageable);

    Page<LocationResponseDto> getActiveLocations(Pageable pageable);

    List<LocationResponseDto> getLocationsByDepartment(UUID departmentId);

    List<LocationResponseDto> getLocationsByRoomType(RoomType roomType);

    List<LocationResponseDto> getLocationsByMinimumCapacity(Integer minCapacity);

    void deleteLocation(UUID id);

    void deactivateLocation(UUID id);

    void activateLocation(UUID id);

    // Availability methods
    LocationAvailabilityResponseDto findAvailableLocations(LocationAvailabilityRequestDto requestDto);

    boolean isLocationAvailable(UUID locationId, LocalDateTime startTime, Integer durationMinutes);

    List<SessionResponseDto> getLocationSchedule(UUID locationId, LocalDateTime startDate, LocalDateTime endDate);
}