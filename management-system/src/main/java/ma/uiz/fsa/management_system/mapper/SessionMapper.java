package ma.uiz.fsa.management_system.mapper;

import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.SessionRequestDto;
import ma.uiz.fsa.management_system.dto.request.SessionUpdateDto;
import ma.uiz.fsa.management_system.dto.response.GroupSimpleResponseDto;
import ma.uiz.fsa.management_system.dto.response.SessionResponseDto;
import ma.uiz.fsa.management_system.dto.response.SessionSimpleResponseDto;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.model.entity.*;
import ma.uiz.fsa.management_system.model.entity.Module;
import ma.uiz.fsa.management_system.model.enums.AttendanceStatus;
import ma.uiz.fsa.management_system.repository.GroupRepository;
import ma.uiz.fsa.management_system.repository.LocationRepository;
import ma.uiz.fsa.management_system.repository.ModuleRepository;
import ma.uiz.fsa.management_system.repository.ProfessorRepository;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class SessionMapper implements BaseMapper<Session, SessionRequestDto, SessionResponseDto> {

    private final ModuleRepository moduleRepository;
    private final ProfessorRepository professorRepository;
    private final GroupRepository groupRepository;
    private final LocationRepository locationRepository;

    @Override
    public Session toEntity(SessionRequestDto dto) {
        if (dto == null) return null;

        Module module = moduleRepository.findById(dto.getModuleId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Module not found with ID: " + dto.getModuleId()));

        Professor professor = professorRepository.findById(dto.getProfessorId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Professor not found with ID: " + dto.getProfessorId()));

        Location location = locationRepository.findById(dto.getLocationId()).
                orElseThrow(() -> new ResourceNotFoundException(
                        "Location not found with ID: " + dto.getLocationId()));

        Set<Group> groups = new HashSet<>();
        if (dto.getGroupIds() != null && !dto.getGroupIds().isEmpty()) {
            groups = dto.getGroupIds().stream()
                    .map(id -> groupRepository.findById(id)
                            .orElseThrow(() -> new ResourceNotFoundException(
                                    "Group not found with ID: " + id)))
                    .collect(Collectors.toSet());
        }

        return Session.builder()
                .name(dto.getName())
                .type(dto.getType())
                .module(module)
                .professor(professor)
                .schedule(dto.getSchedule())
                .duration(dto.getDuration())
                .location(location)
                .description(dto.getDescription())
                .groups(groups)
                .isCompleted(dto.getIsCompleted() != null ? dto.getIsCompleted() : false)
                .attendanceTaken(dto.getAttendanceTaken() != null ? dto.getAttendanceTaken() : false)
                .build();
    }

    @Override
    public SessionResponseDto toResponseDto(Session entity) {
        if (entity == null) return null;

        List<GroupSimpleResponseDto> groups = entity.getGroups() != null
                ? entity.getGroups().stream()
                .map(this::toGroupSimpleDto)
                .collect(Collectors.toList())
                : new ArrayList<>();

        // Calculate attendance statistics
        long presentCount = 0;
        long absentCount = 0;
        if (entity.getAttendanceRecords() != null && !entity.getAttendanceRecords().isEmpty()) {
            presentCount = entity.getAttendanceRecords().stream()
                    .filter(record -> record.getStatus() == AttendanceStatus.PRESENT)
                    .count();
            absentCount = entity.getAttendanceRecords().stream()
                    .filter(record -> record.getStatus() == AttendanceStatus.ABSENT)
                    .count();
        }

        Double attendanceRate = null;
        if (entity.getAttendanceRecords() != null && !entity.getAttendanceRecords().isEmpty()) {
            attendanceRate = (presentCount * 100.0) / entity.getAttendanceRecords().size();
        }

        return SessionResponseDto.builder()
                .id(entity.getId())
                .name(entity.getName())
                .type(entity.getType())
                .schedule(entity.getSchedule())
                .duration(entity.getDuration())
                .locationId(entity.getLocation().getId())
                .locationName(entity.getLocation().getFullName())
                .locationBuilding(entity.getLocation().getBuilding())
                .locationRoomNumber(entity.getLocation().getRoomNumber())
                .locationCapacity(entity.getLocation().getCapacity())
                .description(entity.getDescription())
                .attendanceMode(entity.getAttendanceMode())
                .qrCode(entity.getQrCode())
                .qrCodeImage(entity.getQrCodeImage())
                .isCompleted(entity.getIsCompleted())
                .attendanceTaken(entity.getAttendanceTaken())
                .moduleId(entity.getModule() != null ? entity.getModule().getId() : null)
                .moduleTitle(entity.getModule() != null ? entity.getModule().getTitle() : null)
                .moduleCode(entity.getModule() != null ? entity.getModule().getCode() : null)
                .professorId(entity.getProfessor() != null ? entity.getProfessor().getId() : null)
                .professorName(entity.getProfessor() != null
                        ? entity.getProfessor().getFirstName() + " " + entity.getProfessor().getLastName()
                        : null)
                .professorEmail(entity.getProfessor() != null ? entity.getProfessor().getEmail() : null)
                .groups(groups)
                .totalGroups(entity.getGroups() != null ? entity.getGroups().size() : 0)
                .totalAttendanceRecords(entity.getAttendanceRecords() != null
                        ? entity.getAttendanceRecords().size() : 0)
                .presentCount((int) presentCount)
                .absentCount((int) absentCount)
                .attendanceRate(attendanceRate)
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .createdBy(entity.getCreatedBy())
                .lastModifiedBy(entity.getLastModifiedBy())
                .build();
    }

    public SessionSimpleResponseDto toSimpleResponseDto(Session entity) {
        if (entity == null) return null;

        return SessionSimpleResponseDto.builder()
                .id(entity.getId())
                .name(entity.getName())
                .type(entity.getType())
                .schedule(entity.getSchedule())
                .duration(entity.getDuration())
                .locationId(entity.getLocation().getId())
                .moduleTitle(entity.getModule() != null ? entity.getModule().getTitle() : null)
                .professorName(entity.getProfessor() != null
                        ? entity.getProfessor().getFirstName() + " " + entity.getProfessor().getLastName()
                        : null)
                .isCompleted(entity.getIsCompleted())
                .attendanceTaken(entity.getAttendanceTaken())
                .build();
    }

    private GroupSimpleResponseDto toGroupSimpleDto(Group group) {
        if (group == null) return null;

        return GroupSimpleResponseDto.builder()
                .id(group.getId())
                .name(group.getName())
                .code(group.getCode())
                .studentCount(group.getStudents() != null ? group.getStudents().size() : 0)
                .build();
    }

    @Override
    public void updateEntityFromDto(SessionRequestDto dto, Session entity) {
        if (dto == null || entity == null) return;

        if (dto.getName() != null) {
            entity.setName(dto.getName());
        }
        if (dto.getType() != null) {
            entity.setType(dto.getType());
        }
        if (dto.getSchedule() != null) {
            entity.setSchedule(dto.getSchedule());
        }
        if (dto.getDuration() != null) {
            entity.setDuration(dto.getDuration());
        }
        if (dto.getLocationId() != null &&
                (entity.getLocation() == null || !entity.getLocation().getId().equals(dto.getLocationId()))) {
            Location location = locationRepository.findById(dto.getLocationId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Location not found with ID: " + dto.getLocationId()));
            entity.setLocation(location);
        }
        if (dto.getDescription() != null) {
            entity.setDescription(dto.getDescription());
        }
        if (dto.getIsCompleted() != null) {
            entity.setIsCompleted(dto.getIsCompleted());
        }
        if (dto.getAttendanceTaken() != null) {
            entity.setAttendanceTaken(dto.getAttendanceTaken());
        }
        if (dto.getModuleId() != null &&
                (entity.getModule() == null || !entity.getModule().getId().equals(dto.getModuleId()))) {
            Module module = moduleRepository.findById(dto.getModuleId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Module not found with ID: " + dto.getModuleId()));
            entity.setModule(module);
        }
        if (dto.getProfessorId() != null &&
                (entity.getProfessor() == null || !entity.getProfessor().getId().equals(dto.getProfessorId()))) {
            Professor professor = professorRepository.findById(dto.getProfessorId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Professor not found with ID: " + dto.getProfessorId()));
            entity.setProfessor(professor);
        }
        if (dto.getGroupIds() != null) {
            Set<Group> groups = dto.getGroupIds().stream()
                    .map(id -> groupRepository.findById(id)
                            .orElseThrow(() -> new ResourceNotFoundException(
                                    "Group not found with ID: " + id)))
                    .collect(Collectors.toSet());
            entity.setGroups(groups);
        }
    }

    public void updateEntityFromUpdateDto(SessionUpdateDto dto, Session entity) {
        if (dto == null || entity == null) return;

        if (dto.getName() != null) {
            entity.setName(dto.getName());
        }
        if (dto.getType() != null) {
            entity.setType(dto.getType());
        }
        if (dto.getSchedule() != null) {
            entity.setSchedule(dto.getSchedule());
        }
        if (dto.getDuration() != null) {
            entity.setDuration(dto.getDuration());
        }
        if (dto.getLocationId() != null &&
                (entity.getLocation() == null || !entity.getLocation().getId().equals(dto.getLocationId()))) {
            Location location = locationRepository.findById(dto.getLocationId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Location not found with ID: " + dto.getLocationId()));
            entity.setLocation(location);
        }
        if (dto.getDescription() != null) {
            entity.setDescription(dto.getDescription());
        }
        if (dto.getIsCompleted() != null) {
            entity.setIsCompleted(dto.getIsCompleted());
        }
        if (dto.getAttendanceTaken() != null) {
            entity.setAttendanceTaken(dto.getAttendanceTaken());
        }
        if (dto.getModuleId() != null &&
                (entity.getModule() == null || !entity.getModule().getId().equals(dto.getModuleId()))) {
            Module module = moduleRepository.findById(dto.getModuleId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Module not found with ID: " + dto.getModuleId()));
            entity.setModule(module);
        }
        if (dto.getProfessorId() != null &&
                (entity.getProfessor() == null || !entity.getProfessor().getId().equals(dto.getProfessorId()))) {
            Professor professor = professorRepository.findById(dto.getProfessorId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Professor not found with ID: " + dto.getProfessorId()));
            entity.setProfessor(professor);
        }
        if (dto.getGroupIds() != null) {
            Set<Group> groups = dto.getGroupIds().stream()
                    .map(id -> groupRepository.findById(id)
                            .orElseThrow(() -> new ResourceNotFoundException(
                                    "Group not found with ID: " + id)))
                    .collect(Collectors.toSet());
            entity.setGroups(groups);
        }
    }

    /**
     * Convert list of entities to list of DTOs
     */
    public List<SessionResponseDto> toResponseDtoList(List<Session> entities) {
        if (entities == null) return null;

        return entities.stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Convert list of entities to list of DTOs (alternative name for consistency)
     */
    public List<SessionResponseDto> toListDto(List<Session> entities) {
        return toResponseDtoList(entities);
    }
}