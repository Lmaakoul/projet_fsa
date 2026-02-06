package ma.uiz.fsa.management_system.mapper;

import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.LocationRequestDto;
import ma.uiz.fsa.management_system.dto.response.LocationResponseDto;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.model.entity.Department;
import ma.uiz.fsa.management_system.model.entity.Location;
import ma.uiz.fsa.management_system.repository.DepartmentRepository;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class LocationMapper implements BaseMapper<Location, LocationRequestDto, LocationResponseDto> {

    private final DepartmentRepository departmentRepository;

    @Override
    public Location toEntity(LocationRequestDto dto) {
        if (dto == null) return null;

        Department department = null;
        if (dto.getDepartmentId() != null) {
            department = departmentRepository.findById(dto.getDepartmentId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Department not found with ID: " + dto.getDepartmentId()));
        }

        return Location.builder()
                .building(dto.getBuilding())
                .roomNumber(dto.getRoomNumber())
                .roomType(dto.getRoomType())
                .capacity(dto.getCapacity())
                .equipment(dto.getEquipment())
                .notes(dto.getNotes())
                .isActive(dto.getIsActive() != null ? dto.getIsActive() : true)
                .department(department)
                .build();
    }

    @Override
    public LocationResponseDto toResponseDto(Location entity) {
        if (entity == null) return null;

        return LocationResponseDto.builder()
                .id(entity.getId())
                .building(entity.getBuilding())
                .roomNumber(entity.getRoomNumber())
                .fullName(entity.getFullName())
                .roomType(entity.getRoomType())
                .capacity(entity.getCapacity())
                .equipment(entity.getEquipment())
                .notes(entity.getNotes())
                .isActive(entity.getIsActive())
                .departmentName(entity.getDepartment() != null ? entity.getDepartment().getName() : null)
                .departmentId(entity.getDepartment() != null ? entity.getDepartment().getId() : null)
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }

    @Override
    public void updateEntityFromDto(LocationRequestDto dto, Location entity) {
        if (dto == null || entity == null) return;

        if (dto.getBuilding() != null) {
            entity.setBuilding(dto.getBuilding());
        }
        if (dto.getRoomNumber() != null) {
            entity.setRoomNumber(dto.getRoomNumber());
        }
        if (dto.getRoomType() != null) {
            entity.setRoomType(dto.getRoomType());
        }
        if (dto.getCapacity() != null) {
            entity.setCapacity(dto.getCapacity());
        }
        if (dto.getEquipment() != null) {
            entity.setEquipment(dto.getEquipment());
        }
        if (dto.getNotes() != null) {
            entity.setNotes(dto.getNotes());
        }
        if (dto.getIsActive() != null) {
            entity.setIsActive(dto.getIsActive());
        }

        // Update department if changed
        if (dto.getDepartmentId() != null &&
                (entity.getDepartment() == null || !entity.getDepartment().getId().equals(dto.getDepartmentId()))) {
            Department department = departmentRepository.findById(dto.getDepartmentId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Department not found with ID: " + dto.getDepartmentId()));
            entity.setDepartment(department);
        } else if (dto.getDepartmentId() == null) {
            entity.setDepartment(null);
        }
    }

    /**
     * Convert list of entities to list of DTOs
     */
    public List<LocationResponseDto> toResponseDtoList(List<Location> entities) {
        if (entities == null) return null;

        return entities.stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Convert list of entities to list of DTOs (alternative name for consistency)
     */
    public List<LocationResponseDto> toListDto(List<Location> entities) {
        return toResponseDtoList(entities);
    }
}