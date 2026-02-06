package ma.uiz.fsa.management_system.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.uiz.fsa.management_system.dto.request.LocationAvailabilityRequestDto;
import ma.uiz.fsa.management_system.dto.request.LocationRequestDto;
import ma.uiz.fsa.management_system.dto.response.LocationAvailabilityResponseDto;
import ma.uiz.fsa.management_system.dto.response.LocationResponseDto;
import ma.uiz.fsa.management_system.dto.response.SessionResponseDto;
import ma.uiz.fsa.management_system.exception.BadRequestException;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.mapper.LocationMapper;
import ma.uiz.fsa.management_system.mapper.SessionMapper;
import ma.uiz.fsa.management_system.model.entity.Department;
import ma.uiz.fsa.management_system.model.entity.Location;
import ma.uiz.fsa.management_system.model.entity.Session;
import ma.uiz.fsa.management_system.model.enums.RoomType;
import ma.uiz.fsa.management_system.repository.DepartmentRepository;
import ma.uiz.fsa.management_system.repository.LocationRepository;
import ma.uiz.fsa.management_system.service.LocationService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class LocationServiceImpl implements LocationService {

    private final LocationRepository locationRepository;
    private final DepartmentRepository departmentRepository;
    private final LocationMapper locationMapper;
    private final SessionMapper sessionMapper;

    @Override
    @Transactional
    public LocationResponseDto createLocation(LocationRequestDto requestDto) {
        log.debug("Creating new location: {} - {}", requestDto.getBuilding(), requestDto.getRoomNumber());

        // Check if location already exists
        if (locationRepository.existsByBuildingAndRoomNumber(requestDto.getBuilding(), requestDto.getRoomNumber())) {
            throw new BadRequestException("Location already exists with building: " + requestDto.getBuilding() +
                    " and room number: " + requestDto.getRoomNumber());
        }

        Location location = locationMapper.toEntity(requestDto);

        // Set department if provided
        if (requestDto.getDepartmentId() != null) {
            Department department = departmentRepository.findById(requestDto.getDepartmentId())
                    .orElseThrow(() -> new ResourceNotFoundException("Department not found with ID: " + requestDto.getDepartmentId()));
            location.setDepartment(department);
        }

        Location savedLocation = locationRepository.save(location);
        log.info("Location created successfully: {} with ID: {}", savedLocation.getFullName(), savedLocation.getId());

        return locationMapper.toResponseDto(savedLocation);
    }

    @Override
    @Transactional
    public LocationResponseDto updateLocation(UUID id, LocationRequestDto requestDto) {
        log.debug("Updating location with ID: {}", id);

        Location location = locationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Location not found with ID: " + id));

        // Check for duplicate if building or room number changed
        if (!location.getBuilding().equals(requestDto.getBuilding()) ||
                !location.getRoomNumber().equals(requestDto.getRoomNumber())) {
            if (locationRepository.existsByBuildingAndRoomNumber(requestDto.getBuilding(), requestDto.getRoomNumber())) {
                throw new BadRequestException("Location already exists with building: " + requestDto.getBuilding() +
                        " and room number: " + requestDto.getRoomNumber());
            }
        }

        locationMapper.updateEntityFromDto(requestDto, location);

        // Update department if changed
        if (requestDto.getDepartmentId() != null) {
            if (location.getDepartment() == null || !location.getDepartment().getId().equals(requestDto.getDepartmentId())) {
                Department department = departmentRepository.findById(requestDto.getDepartmentId())
                        .orElseThrow(() -> new ResourceNotFoundException("Department not found with ID: " + requestDto.getDepartmentId()));
                location.setDepartment(department);
            }
        } else {
            location.setDepartment(null);
        }

        Location updatedLocation = locationRepository.save(location);
        log.info("Location updated successfully with ID: {}", id);

        return locationMapper.toResponseDto(updatedLocation);
    }

    @Override
    @Transactional(readOnly = true)
    public LocationResponseDto getLocationById(UUID id) {
        log.debug("Retrieving location with ID: {}", id);

        Location location = locationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Location not found with ID: " + id));

        return locationMapper.toResponseDto(location);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<LocationResponseDto> getAllLocations(Pageable pageable) {
        log.debug("Retrieving all locations with pagination");

        Page<Location> locations = locationRepository.findAll(pageable);
        return locations.map(locationMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<LocationResponseDto> getActiveLocations(Pageable pageable) {
        log.debug("Retrieving active locations with pagination");

        Page<Location> locations = locationRepository.findByIsActiveTrue(pageable);
        return locations.map(locationMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<LocationResponseDto> getLocationsByDepartment(UUID departmentId) {
        log.debug("Retrieving locations for department ID: {}", departmentId);

        List<Location> locations = locationRepository.findByDepartmentId(departmentId);
        return locationMapper.toResponseDtoList(locations);
    }

    @Override
    @Transactional(readOnly = true)
    public List<LocationResponseDto> getLocationsByRoomType(RoomType roomType) {
        log.debug("Retrieving locations with room type: {}", roomType);

        List<Location> locations = locationRepository.findByRoomType(roomType);
        return locationMapper.toResponseDtoList(locations);
    }

    @Override
    @Transactional(readOnly = true)
    public List<LocationResponseDto> getLocationsByMinimumCapacity(Integer minCapacity) {
        log.debug("Retrieving locations with minimum capacity: {}", minCapacity);

        List<Location> locations = locationRepository.findByMinimumCapacity(minCapacity);
        return locationMapper.toResponseDtoList(locations);
    }

    @Override
    @Transactional
    public void deleteLocation(UUID id) {
        log.debug("Deleting location with ID: {}", id);

        Location location = locationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Location not found with ID: " + id));

        // Check if location has any scheduled sessions
        if (location.getSessions() != null && !location.getSessions().isEmpty()) {
            long futureSessionsCount = location.getSessions().stream()
                    .filter(session -> session.getSchedule().isAfter(LocalDateTime.now()))
                    .count();

            if (futureSessionsCount > 0) {
                throw new BadRequestException(
                        "Cannot delete location. It has " + futureSessionsCount + " future session(s) scheduled. " +
                                "Please reassign or cancel these sessions first."
                );
            }
        }

        locationRepository.delete(location);
        log.info("Location deleted successfully with ID: {}", id);
    }

    @Override
    @Transactional
    public void deactivateLocation(UUID id) {
        log.debug("Deactivating location with ID: {}", id);

        Location location = locationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Location not found with ID: " + id));

        location.setIsActive(false);
        locationRepository.save(location);

        log.info("Location deactivated successfully with ID: {}", id);
    }

    @Override
    @Transactional
    public void activateLocation(UUID id) {
        log.debug("Activating location with ID: {}", id);

        Location location = locationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Location not found with ID: " + id));

        location.setIsActive(true);
        locationRepository.save(location);

        log.info("Location activated successfully with ID: {}", id);
    }

    @Override
    @Transactional(readOnly = true)
    public LocationAvailabilityResponseDto findAvailableLocations(LocationAvailabilityRequestDto requestDto) {
        log.debug("Finding available locations for time slot: {} - duration: {} minutes",
                requestDto.getStartTime(), requestDto.getDurationMinutes());

        LocalDateTime startTime = requestDto.getStartTime();
        LocalDateTime endTime = startTime.plusMinutes(requestDto.getDurationMinutes());

        List<Location> availableLocations;

        if (requestDto.getMinCapacity() != null) {
            availableLocations = locationRepository.findAvailableLocationsWithCapacity(
                    startTime, endTime, requestDto.getMinCapacity());
        } else {
            availableLocations = locationRepository.findAvailableLocations(startTime, endTime);
        }

        // Filter by room type if specified
        if (requestDto.getRoomType() != null) {
            availableLocations = availableLocations.stream()
                    .filter(loc -> loc.getRoomType() == requestDto.getRoomType())
                    .toList();
        }

        // Filter by department if specified
        if (requestDto.getDepartmentId() != null) {
            availableLocations = availableLocations.stream()
                    .filter(loc -> loc.getDepartment() != null &&
                            loc.getDepartment().getId().equals(requestDto.getDepartmentId()))
                    .toList();
        }

        List<LocationResponseDto> locationDtos = locationMapper.toResponseDtoList(availableLocations);

        return LocationAvailabilityResponseDto.builder()
                .startTime(startTime)
                .endTime(endTime)
                .requestedCapacity(requestDto.getMinCapacity())
                .availableLocations(locationDtos)
                .totalAvailable(locationDtos.size())
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isLocationAvailable(UUID locationId, LocalDateTime startTime, Integer durationMinutes) {
        log.debug("Checking availability for location ID: {} at time: {}", locationId, startTime);

        LocalDateTime endTime = startTime.plusMinutes(durationMinutes);
        return locationRepository.isLocationAvailable(locationId, startTime, endTime);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SessionResponseDto> getLocationSchedule(UUID locationId, LocalDateTime startDate, LocalDateTime endDate) {
        log.debug("Retrieving schedule for location ID: {} from {} to {}", locationId, startDate, endDate);

        Location location = locationRepository.findById(locationId)
                .orElseThrow(() -> new ResourceNotFoundException("Location not found with ID: " + locationId));

        List<Session> sessions = locationRepository.findSessionsByLocationAndDateRange(locationId, startDate, endDate);
        return sessionMapper.toResponseDtoList(sessions);
    }
}