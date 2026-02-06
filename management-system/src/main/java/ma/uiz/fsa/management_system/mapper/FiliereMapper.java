package ma.uiz.fsa.management_system.mapper;

import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.FiliereRequestDto;
import ma.uiz.fsa.management_system.dto.response.FiliereResponseDto;
import ma.uiz.fsa.management_system.dto.response.FiliereSimpleResponseDto;
import ma.uiz.fsa.management_system.dto.response.SemesterSimpleResponseDto;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.model.entity.Department;
import ma.uiz.fsa.management_system.model.entity.Filiere;
import ma.uiz.fsa.management_system.repository.DepartmentRepository;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class FiliereMapper implements BaseMapper<Filiere, FiliereRequestDto, FiliereResponseDto> {

    private final DepartmentRepository departmentRepository;
    private final SemesterMapper semesterMapper;

    @Override
    public Filiere toEntity(FiliereRequestDto dto) {
        if (dto == null) return null;

        Department department = departmentRepository.findById(dto.getDepartmentId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Department not found with ID: " + dto.getDepartmentId()));

        return Filiere.builder()
                .name(dto.getName())
                .code(dto.getCode().toUpperCase())
                .degreeType(dto.getDegreeType())
                .description(dto.getDescription())
                .durationYears(dto.getDurationYears())
                .isActive(dto.getIsActive() != null ? dto.getIsActive() : true)
                .department(department)
                .build();
    }

    @Override
    public FiliereResponseDto toResponseDto(Filiere entity) {
        if (entity == null) return null;

        List<SemesterSimpleResponseDto> semesters = entity.getSemesters() != null
                ? entity.getSemesters().stream()
                .map(semesterMapper::toSimpleResponseDto)
                .sorted(Comparator.comparing(SemesterSimpleResponseDto::getSemesterNumber))
                .collect(Collectors.toList())
                : new ArrayList<>();

        return FiliereResponseDto.builder()
                .id(entity.getId())
                .name(entity.getName())
                .code(entity.getCode())
                .degreeType(entity.getDegreeType())
                .description(entity.getDescription())
                .durationYears(entity.getDurationYears())
                .isActive(entity.getIsActive())
                .departmentId(entity.getDepartment() != null ? entity.getDepartment().getId() : null)
                .departmentName(entity.getDepartment() != null ? entity.getDepartment().getName() : null)
                .departmentCode(entity.getDepartment() != null ? entity.getDepartment().getCode() : null)
                .totalSemesters(entity.getSemesters() != null ? entity.getSemesters().size() : 0)
                .totalStudents(entity.getStudents() != null ? entity.getStudents().size() : 0)
                .semesters(semesters)
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .createdBy(entity.getCreatedBy())
                .lastModifiedBy(entity.getLastModifiedBy())
                .build();
    }

    public FiliereSimpleResponseDto toSimpleResponseDto(Filiere entity) {
        if (entity == null) return null;

        return FiliereSimpleResponseDto.builder()
                .id(entity.getId())
                .name(entity.getName())
                .code(entity.getCode())
                .degreeType(entity.getDegreeType())
                .departmentName(entity.getDepartment() != null ? entity.getDepartment().getName() : null)
                .isActive(entity.getIsActive())
                .build();
    }

    @Override
    public void updateEntityFromDto(FiliereRequestDto dto, Filiere entity) {
        if (dto == null || entity == null) return;

        if (dto.getName() != null) {
            entity.setName(dto.getName());
        }
        if (dto.getCode() != null) {
            entity.setCode(dto.getCode().toUpperCase());
        }
        if (dto.getDegreeType() != null) {
            entity.setDegreeType(dto.getDegreeType());
        }
        if (dto.getDescription() != null) {
            entity.setDescription(dto.getDescription());
        }
        if (dto.getDurationYears() != null) {
            entity.setDurationYears(dto.getDurationYears());
        }
        if (dto.getIsActive() != null) {
            entity.setIsActive(dto.getIsActive());
        }
        if (dto.getDepartmentId() != null &&
                (entity.getDepartment() == null || !entity.getDepartment().getId().equals(dto.getDepartmentId()))) {
            Department department = departmentRepository.findById(dto.getDepartmentId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Department not found with ID: " + dto.getDepartmentId()));
            entity.setDepartment(department);
        }
    }
}