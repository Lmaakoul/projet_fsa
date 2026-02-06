package ma.uiz.fsa.management_system.mapper;

import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.GroupRequestDto;
import ma.uiz.fsa.management_system.dto.request.GroupUpdateDto;
import ma.uiz.fsa.management_system.dto.response.GroupResponseDto;
import ma.uiz.fsa.management_system.dto.response.GroupSimpleResponseDto;
import ma.uiz.fsa.management_system.dto.response.StudentSimpleResponseDto;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.model.entity.Group;
import ma.uiz.fsa.management_system.model.entity.Module;
import ma.uiz.fsa.management_system.model.entity.Student;
import ma.uiz.fsa.management_system.repository.ModuleRepository;
import ma.uiz.fsa.management_system.repository.StudentRepository;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class GroupMapper implements BaseMapper<Group, GroupRequestDto, GroupResponseDto> {

    private final ModuleRepository moduleRepository;
    private final StudentRepository studentRepository;
    private final StudentMapper studentMapper;

    @Override
    public Group toEntity(GroupRequestDto dto) {
        if (dto == null) return null;

        Module module = moduleRepository.findById(dto.getModuleId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Module not found with ID: " + dto.getModuleId()));

        Set<Student> students = new HashSet<>();
        if (dto.getStudentIds() != null && !dto.getStudentIds().isEmpty()) {
            students = dto.getStudentIds().stream()
                    .map(id -> studentRepository.findById(id)
                            .orElseThrow(() -> new ResourceNotFoundException(
                                    "Student not found with ID: " + id)))
                    .collect(Collectors.toSet());
        }

        return Group.builder()
                .name(dto.getName())
                .code(dto.getCode().toUpperCase())
                .description(dto.getDescription())
                .module(module)
                .students(students)
                .maxCapacity(dto.getMaxCapacity())
                .isActive(dto.getIsActive() != null ? dto.getIsActive() : true)
                .build();
    }

    @Override
    public GroupResponseDto toResponseDto(Group entity) {
        if (entity == null) return null;

        List<StudentSimpleResponseDto> students = entity.getStudents() != null
                ? entity.getStudents().stream()
                .map(studentMapper::toSimpleResponseDto)
                .sorted(Comparator.comparing(StudentSimpleResponseDto::getFullName))
                .collect(Collectors.toList())
                : new ArrayList<>();

        int currentCapacity = entity.getStudents() != null ? entity.getStudents().size() : 0;
        int availableSlots = entity.getMaxCapacity() - currentCapacity;
        boolean isFull = currentCapacity >= entity.getMaxCapacity();
        double fillRate = entity.getMaxCapacity() > 0
                ? (currentCapacity * 100.0) / entity.getMaxCapacity()
                : 0.0;

        return GroupResponseDto.builder()
                .id(entity.getId())
                .name(entity.getName())
                .code(entity.getCode())
                .description(entity.getDescription())
                .maxCapacity(entity.getMaxCapacity())
                .currentCapacity(currentCapacity)
                .isActive(entity.getIsActive())
                .isFull(isFull)
                .fillRate(fillRate)
                .moduleId(entity.getModule() != null ? entity.getModule().getId() : null)
                .moduleTitle(entity.getModule() != null ? entity.getModule().getTitle() : null)
                .moduleCode(entity.getModule() != null ? entity.getModule().getCode() : null)
                .students(students)
                .totalStudents(currentCapacity)
                .totalSessions(entity.getSessions() != null ? entity.getSessions().size() : 0)
                .availableSlots(availableSlots)
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .createdBy(entity.getCreatedBy())
                .lastModifiedBy(entity.getLastModifiedBy())
                .build();
    }

    public GroupSimpleResponseDto toSimpleResponseDto(Group entity) {
        if (entity == null) return null;

        return GroupSimpleResponseDto.builder()
                .id(entity.getId())
                .name(entity.getName())
                .code(entity.getCode())
                .studentCount(entity.getStudents() != null ? entity.getStudents().size() : 0)
                .maxCapacity(entity.getMaxCapacity())
                .moduleTitle(entity.getModule() != null ? entity.getModule().getTitle() : null)
                .isActive(entity.getIsActive())
                .build();
    }

    @Override
    public void updateEntityFromDto(GroupRequestDto dto, Group entity) {
        if (dto == null || entity == null) return;

        if (dto.getName() != null) {
            entity.setName(dto.getName());
        }
        if (dto.getCode() != null) {
            entity.setCode(dto.getCode().toUpperCase());
        }
        if (dto.getDescription() != null) {
            entity.setDescription(dto.getDescription());
        }
        if (dto.getMaxCapacity() != null) {
            entity.setMaxCapacity(dto.getMaxCapacity());
        }
        if (dto.getIsActive() != null) {
            entity.setIsActive(dto.getIsActive());
        }
        if (dto.getModuleId() != null &&
                (entity.getModule() == null || !entity.getModule().getId().equals(dto.getModuleId()))) {
            Module module = moduleRepository.findById(dto.getModuleId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Module not found with ID: " + dto.getModuleId()));
            entity.setModule(module);
        }
        if (dto.getStudentIds() != null) {
            Set<Student> students = dto.getStudentIds().stream()
                    .map(id -> studentRepository.findById(id)
                            .orElseThrow(() -> new ResourceNotFoundException(
                                    "Student not found with ID: " + id)))
                    .collect(Collectors.toSet());
            entity.setStudents(students);
        }
    }

    public void updateEntityFromUpdateDto(GroupUpdateDto dto, Group entity) {
        if (dto == null || entity == null) return;

        if (dto.getName() != null) {
            entity.setName(dto.getName());
        }
        if (dto.getCode() != null) {
            entity.setCode(dto.getCode().toUpperCase());
        }
        if (dto.getDescription() != null) {
            entity.setDescription(dto.getDescription());
        }
        if (dto.getMaxCapacity() != null) {
            entity.setMaxCapacity(dto.getMaxCapacity());
        }
        if (dto.getIsActive() != null) {
            entity.setIsActive(dto.getIsActive());
        }
        if (dto.getModuleId() != null &&
                (entity.getModule() == null || !entity.getModule().getId().equals(dto.getModuleId()))) {
            Module module = moduleRepository.findById(dto.getModuleId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Module not found with ID: " + dto.getModuleId()));
            entity.setModule(module);
        }
        if (dto.getStudentIds() != null) {
            Set<Student> students = dto.getStudentIds().stream()
                    .map(id -> studentRepository.findById(id)
                            .orElseThrow(() -> new ResourceNotFoundException(
                                    "Student not found with ID: " + id)))
                    .collect(Collectors.toSet());
            entity.setStudents(students);
        }
    }
}