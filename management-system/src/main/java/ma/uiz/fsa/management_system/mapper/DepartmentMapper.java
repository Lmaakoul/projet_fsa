package ma.uiz.fsa.management_system.mapper;

import ma.uiz.fsa.management_system.dto.request.DepartmentRequestDto;
import ma.uiz.fsa.management_system.dto.response.DepartmentResponseDto;
import ma.uiz.fsa.management_system.model.entity.Department;
import org.springframework.stereotype.Component;

@Component
public class DepartmentMapper implements BaseMapper<Department, DepartmentRequestDto, DepartmentResponseDto> {

    @Override
    public Department toEntity(DepartmentRequestDto dto) {
        if (dto == null) return null;

        return Department.builder()
                .name(dto.getName())
                .code(dto.getCode().toUpperCase()) // Standardize to uppercase
                .description(dto.getDescription())
                .build();
    }

    @Override
    public DepartmentResponseDto toResponseDto(Department entity) {
        if (entity == null) return null;

        return DepartmentResponseDto.builder()
                .id(entity.getId())
                .name(entity.getName())
                .code(entity.getCode())
                .description(entity.getDescription())
                .totalFilieres(entity.getFilieres() != null ? entity.getFilieres().size() : 0)
                .totalProfessors(entity.getProfessors() != null ? entity.getProfessors().size() : 0)
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .createdBy(entity.getCreatedBy())
                .lastModifiedBy(entity.getLastModifiedBy())
                .build();
    }

    @Override
    public void updateEntityFromDto(DepartmentRequestDto dto, Department entity) {
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
    }
}
