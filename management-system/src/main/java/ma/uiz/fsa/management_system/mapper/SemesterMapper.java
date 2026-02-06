package ma.uiz.fsa.management_system.mapper;

import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.SemesterRequestDto;
import ma.uiz.fsa.management_system.dto.request.SemesterUpdateDto;
import ma.uiz.fsa.management_system.dto.response.SemesterResponseDto;
import ma.uiz.fsa.management_system.dto.response.SemesterSimpleResponseDto;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.model.entity.Filiere;
import ma.uiz.fsa.management_system.model.entity.Semester;
import ma.uiz.fsa.management_system.repository.FiliereRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class SemesterMapper implements BaseMapper<Semester, SemesterRequestDto, SemesterResponseDto> {

    private final FiliereRepository filiereRepository;

    @Override
    public Semester toEntity(SemesterRequestDto dto) {
        if (dto == null) return null;

        Filiere filiere = filiereRepository.findById(dto.getFiliereId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Filiere not found with ID: " + dto.getFiliereId()));

        return Semester.builder()
                .name(dto.getName())
                .academicYear(dto.getAcademicYear())
                .semesterNumber(dto.getSemesterNumber())
                .description(dto.getDescription())
                .filiere(filiere)
                .isActive(dto.getIsActive() != null ? dto.getIsActive() : true)
                .build();
    }

    @Override
    public SemesterResponseDto toResponseDto(Semester entity) {
        if (entity == null) return null;

        return SemesterResponseDto.builder()
                .id(entity.getId())
                .name(entity.getName())
                .academicYear(entity.getAcademicYear())
                .semesterNumber(entity.getSemesterNumber())
                .description(entity.getDescription())
                .isActive(entity.getIsActive())
                .filiereId(entity.getFiliere() != null ? entity.getFiliere().getId() : null)
                .filiereName(entity.getFiliere() != null ? entity.getFiliere().getName() : null)
                .filiereCode(entity.getFiliere() != null ? entity.getFiliere().getCode() : null)
                .departmentName(entity.getFiliere() != null && entity.getFiliere().getDepartment() != null
                        ? entity.getFiliere().getDepartment().getName() : null)
                .totalModules(entity.getModules() != null ? entity.getModules().size() : 0)
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .createdBy(entity.getCreatedBy())
                .lastModifiedBy(entity.getLastModifiedBy())
                .build();
    }

    public SemesterSimpleResponseDto toSimpleResponseDto(Semester entity) {
        if (entity == null) return null;

        return SemesterSimpleResponseDto.builder()
                .id(entity.getId())
                .name(entity.getName())
                .semesterNumber(entity.getSemesterNumber())
                .academicYear(entity.getAcademicYear())
                .filiereName(entity.getFiliere() != null ? entity.getFiliere().getName() : null)
                .isActive(entity.getIsActive())
                .build();
    }

    @Override
    public void updateEntityFromDto(SemesterRequestDto dto, Semester entity) {
        if (dto == null || entity == null) return;

        if (dto.getName() != null) {
            entity.setName(dto.getName());
        }
        if (dto.getAcademicYear() != null) {
            entity.setAcademicYear(dto.getAcademicYear());
        }
        if (dto.getSemesterNumber() != null) {
            entity.setSemesterNumber(dto.getSemesterNumber());
        }
        if (dto.getDescription() != null) {
            entity.setDescription(dto.getDescription());
        }
        if (dto.getIsActive() != null) {
            entity.setIsActive(dto.getIsActive());
        }
        if (dto.getFiliereId() != null &&
                (entity.getFiliere() == null || !entity.getFiliere().getId().equals(dto.getFiliereId()))) {
            Filiere filiere = filiereRepository.findById(dto.getFiliereId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Filiere not found with ID: " + dto.getFiliereId()));
            entity.setFiliere(filiere);
        }
    }

    public void updateEntityFromUpdateDto(SemesterUpdateDto dto, Semester entity) {
        if (dto == null || entity == null) return;

        if (dto.getName() != null) {
            entity.setName(dto.getName());
        }
        if (dto.getAcademicYear() != null) {
            entity.setAcademicYear(dto.getAcademicYear());
        }
        if (dto.getSemesterNumber() != null) {
            entity.setSemesterNumber(dto.getSemesterNumber());
        }
        if (dto.getDescription() != null) {
            entity.setDescription(dto.getDescription());
        }
        if (dto.getIsActive() != null) {
            entity.setIsActive(dto.getIsActive());
        }
        if (dto.getFiliereId() != null &&
                (entity.getFiliere() == null || !entity.getFiliere().getId().equals(dto.getFiliereId()))) {
            Filiere filiere = filiereRepository.findById(dto.getFiliereId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Filiere not found with ID: " + dto.getFiliereId()));
            entity.setFiliere(filiere);
        }
    }
}