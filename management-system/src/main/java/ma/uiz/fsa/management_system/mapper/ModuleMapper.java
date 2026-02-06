package ma.uiz.fsa.management_system.mapper;

import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.ModuleRequestDto;
import ma.uiz.fsa.management_system.dto.request.ModuleUpdateDto;
import ma.uiz.fsa.management_system.dto.response.ModuleResponseDto;
import ma.uiz.fsa.management_system.dto.response.ModuleSimpleResponseDto;
import ma.uiz.fsa.management_system.dto.response.ProfessorSimpleResponseDto;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.model.entity.Module;
import ma.uiz.fsa.management_system.model.entity.Professor;
import ma.uiz.fsa.management_system.model.entity.Semester;
import ma.uiz.fsa.management_system.repository.ProfessorRepository;
import ma.uiz.fsa.management_system.repository.SemesterRepository;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class ModuleMapper implements BaseMapper<Module, ModuleRequestDto, ModuleResponseDto> {

    private final SemesterRepository semesterRepository;
    private final ProfessorRepository professorRepository;
    private final ProfessorMapper professorMapper;

    @Override
    public Module toEntity(ModuleRequestDto dto) {
        if (dto == null) return null;

        Semester semester = semesterRepository.findById(dto.getSemesterId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Semester not found with ID: " + dto.getSemesterId()));

        Set<Professor> professors = new HashSet<>();
        if (dto.getProfessorIds() != null && !dto.getProfessorIds().isEmpty()) {
            professors = dto.getProfessorIds().stream()
                    .map(id -> professorRepository.findById(id)
                            .orElseThrow(() -> new ResourceNotFoundException(
                                    "Professor not found with ID: " + id)))
                    .collect(Collectors.toSet());
        }

        return Module.builder()
                .title(dto.getTitle())
                .code(dto.getCode().toUpperCase())
                .credits(dto.getCredits())
                .description(dto.getDescription())
                .semester(semester)
                .professors(professors)
                .passingGrade(dto.getPassingGrade())
                .isActive(dto.getIsActive() != null ? dto.getIsActive() : true)
                .build();
    }

    @Override
    public ModuleResponseDto toResponseDto(Module entity) {
        if (entity == null) return null;

        List<ProfessorSimpleResponseDto> professors = entity.getProfessors() != null
                ? entity.getProfessors().stream()
                .map(professorMapper::toSimpleResponseDto)
                .collect(Collectors.toList())
                : new ArrayList<>();

        return ModuleResponseDto.builder()
                .id(entity.getId())
                .title(entity.getTitle())
                .code(entity.getCode())
                .credits(entity.getCredits())
                .description(entity.getDescription())
                .passingGrade(entity.getPassingGrade())
                .isActive(entity.getIsActive())
                .semesterId(entity.getSemester() != null ? entity.getSemester().getId() : null)
                .semesterName(entity.getSemester() != null ? entity.getSemester().getName() : null)
                .semesterNumber(entity.getSemester() != null ? entity.getSemester().getSemesterNumber() : null)
                .academicYear(entity.getSemester() != null ? entity.getSemester().getAcademicYear() : null)
                .filiereName(entity.getSemester() != null && entity.getSemester().getFiliere() != null
                        ? entity.getSemester().getFiliere().getName() : null)
                .filiereCode(entity.getSemester() != null && entity.getSemester().getFiliere() != null
                        ? entity.getSemester().getFiliere().getCode() : null)
                .departmentName(entity.getSemester() != null && entity.getSemester().getFiliere() != null
                        && entity.getSemester().getFiliere().getDepartment() != null
                        ? entity.getSemester().getFiliere().getDepartment().getName() : null)
                .professors(professors)
                .totalProfessors(entity.getProfessors() != null ? entity.getProfessors().size() : 0)
                .totalSessions(entity.getSessions() != null ? entity.getSessions().size() : 0)
                .totalGroups(entity.getGroups() != null ? entity.getGroups().size() : 0)
                .totalEvaluations(entity.getEvaluations() != null ? entity.getEvaluations().size() : 0)
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .createdBy(entity.getCreatedBy())
                .lastModifiedBy(entity.getLastModifiedBy())
                .build();
    }

    public ModuleSimpleResponseDto toSimpleResponseDto(Module entity) {
        if (entity == null) return null;

        return ModuleSimpleResponseDto.builder()
                .id(entity.getId())
                .title(entity.getTitle())
                .code(entity.getCode())
                .credits(entity.getCredits())
                .semesterName(entity.getSemester() != null ? entity.getSemester().getName() : null)
                .isActive(entity.getIsActive())
                .build();
    }

    @Override
    public void updateEntityFromDto(ModuleRequestDto dto, Module entity) {
        if (dto == null || entity == null) return;

        if (dto.getTitle() != null) {
            entity.setTitle(dto.getTitle());
        }
        if (dto.getCode() != null) {
            entity.setCode(dto.getCode().toUpperCase());
        }
        if (dto.getCredits() != null) {
            entity.setCredits(dto.getCredits());
        }
        if (dto.getDescription() != null) {
            entity.setDescription(dto.getDescription());
        }
        if (dto.getPassingGrade() != null) {
            entity.setPassingGrade(dto.getPassingGrade());
        }
        if (dto.getIsActive() != null) {
            entity.setIsActive(dto.getIsActive());
        }
        if (dto.getSemesterId() != null &&
                (entity.getSemester() == null || !entity.getSemester().getId().equals(dto.getSemesterId()))) {
            Semester semester = semesterRepository.findById(dto.getSemesterId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Semester not found with ID: " + dto.getSemesterId()));
            entity.setSemester(semester);
        }
        if (dto.getProfessorIds() != null) {
            Set<Professor> professors = dto.getProfessorIds().stream()
                    .map(id -> professorRepository.findById(id)
                            .orElseThrow(() -> new ResourceNotFoundException(
                                    "Professor not found with ID: " + id)))
                    .collect(Collectors.toSet());
            entity.setProfessors(professors);
        }
    }

    public void updateEntityFromUpdateDto(ModuleUpdateDto dto, Module entity) {
        if (dto == null || entity == null) return;

        if (dto.getTitle() != null) {
            entity.setTitle(dto.getTitle());
        }
        if (dto.getCode() != null) {
            entity.setCode(dto.getCode().toUpperCase());
        }
        if (dto.getCredits() != null) {
            entity.setCredits(dto.getCredits());
        }
        if (dto.getDescription() != null) {
            entity.setDescription(dto.getDescription());
        }
        if (dto.getPassingGrade() != null) {
            entity.setPassingGrade(dto.getPassingGrade());
        }
        if (dto.getIsActive() != null) {
            entity.setIsActive(dto.getIsActive());
        }
        if (dto.getSemesterId() != null &&
                (entity.getSemester() == null || !entity.getSemester().getId().equals(dto.getSemesterId()))) {
            Semester semester = semesterRepository.findById(dto.getSemesterId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Semester not found with ID: " + dto.getSemesterId()));
            entity.setSemester(semester);
        }
        if (dto.getProfessorIds() != null) {
            Set<Professor> professors = dto.getProfessorIds().stream()
                    .map(id -> professorRepository.findById(id)
                            .orElseThrow(() -> new ResourceNotFoundException(
                                    "Professor not found with ID: " + id)))
                    .collect(Collectors.toSet());
            entity.setProfessors(professors);
        }
    }
}