package ma.uiz.fsa.management_system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.LocationAvailabilityRequestDto;
import ma.uiz.fsa.management_system.dto.request.LocationRequestDto;
import ma.uiz.fsa.management_system.dto.response.LocationAvailabilityResponseDto;
import ma.uiz.fsa.management_system.dto.response.LocationResponseDto;
import ma.uiz.fsa.management_system.dto.response.PageResponse;
import ma.uiz.fsa.management_system.dto.response.SessionResponseDto;
import ma.uiz.fsa.management_system.model.enums.RoomType;
import ma.uiz.fsa.management_system.service.LocationService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/locations")
@RequiredArgsConstructor
@Tag(name = "Location", description = "Location management APIs")
@SecurityRequirement(name = "bearerAuth")
public class LocationController {

    private final LocationService locationService;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Create a new location", description = "Create a new room/location in the system")
    public ResponseEntity<LocationResponseDto> createLocation(@Valid @RequestBody LocationRequestDto requestDto) {
        LocationResponseDto response = locationService.createLocation(requestDto);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Update location", description = "Update an existing location")
    public ResponseEntity<LocationResponseDto> updateLocation(
            @PathVariable UUID id,
            @Valid @RequestBody LocationRequestDto requestDto) {
        LocationResponseDto response = locationService.updateLocation(id, requestDto);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get location by ID", description = "Retrieve location details by ID")
    public ResponseEntity<LocationResponseDto> getLocationById(@PathVariable UUID id) {
        LocationResponseDto response = locationService.getLocationById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get all locations", description = "Retrieve all locations with pagination")
    public ResponseEntity<PageResponse<LocationResponseDto>> getAllLocations(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "roomNumber") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<LocationResponseDto> response = locationService.getAllLocations(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/active")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get active locations", description = "Retrieve all active locations")
    public ResponseEntity<PageResponse<LocationResponseDto>> getActiveLocations(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestParam(required = false, defaultValue = "roomNumber") String sortBy,
            @RequestParam(required = false, defaultValue = "ASC") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("DESC")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<LocationResponseDto> response = locationService.getActiveLocations(pageable);
        return ResponseEntity.ok(PageResponse.of(response));
    }

    @GetMapping("/department/{departmentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get locations by department", description = "Retrieve all locations managed by a department")
    public ResponseEntity<List<LocationResponseDto>> getLocationsByDepartment(@PathVariable UUID departmentId) {
        List<LocationResponseDto> response = locationService.getLocationsByDepartment(departmentId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/room-type/{roomType}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get locations by room type", description = "Retrieve locations filtered by room type")
    public ResponseEntity<List<LocationResponseDto>> getLocationsByRoomType(@PathVariable RoomType roomType) {
        List<LocationResponseDto> response = locationService.getLocationsByRoomType(roomType);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/capacity/{minCapacity}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get locations by minimum capacity", description = "Find locations with minimum capacity")
    public ResponseEntity<List<LocationResponseDto>> getLocationsByMinimumCapacity(@PathVariable Integer minCapacity) {
        List<LocationResponseDto> response = locationService.getLocationsByMinimumCapacity(minCapacity);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete location", description = "Delete a location (only if no future sessions)")
    public ResponseEntity<Map<String, String>> deleteLocation(@PathVariable UUID id) {
        locationService.deleteLocation(id);
        return ResponseEntity.ok(Map.of("message", "Location deleted successfully"));
    }

    @PatchMapping("/{id}/deactivate")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Deactivate location", description = "Mark location as inactive")
    public ResponseEntity<Map<String, String>> deactivateLocation(@PathVariable UUID id) {
        locationService.deactivateLocation(id);
        return ResponseEntity.ok(Map.of("message", "Location deactivated successfully"));
    }

    @PatchMapping("/{id}/activate")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Activate location", description = "Mark location as active")
    public ResponseEntity<Map<String, String>> activateLocation(@PathVariable UUID id) {
        locationService.activateLocation(id);
        return ResponseEntity.ok(Map.of("message", "Location activated successfully"));
    }

    @PostMapping("/availability")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Find available locations", description = "Find locations available for a specific time slot")
    public ResponseEntity<LocationAvailabilityResponseDto> findAvailableLocations(
            @Valid @RequestBody LocationAvailabilityRequestDto requestDto) {
        LocationAvailabilityResponseDto response = locationService.findAvailableLocations(requestDto);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}/availability")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Check location availability", description = "Check if a specific location is available")
    public ResponseEntity<Map<String, Boolean>> checkLocationAvailability(
            @PathVariable UUID id,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @RequestParam Integer durationMinutes) {
        boolean isAvailable = locationService.isLocationAvailable(id, startTime, durationMinutes);
        return ResponseEntity.ok(Map.of("available", isAvailable));
    }

    @GetMapping("/{id}/schedule")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get location schedule", description = "Get all sessions scheduled at a location")
    public ResponseEntity<List<SessionResponseDto>> getLocationSchedule(
            @PathVariable UUID id,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        List<SessionResponseDto> response = locationService.getLocationSchedule(id, startDate, endDate);
        return ResponseEntity.ok(response);
    }
}