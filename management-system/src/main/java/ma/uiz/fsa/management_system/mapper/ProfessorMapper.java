package ma.uiz.fsa.management_system.mapper;

import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.ProfessorRequestDto;
import ma.uiz.fsa.management_system.dto.request.ProfessorUpdateDto;
import ma.uiz.fsa.management_system.dto.response.ProfessorResponseDto;
import ma.uiz.fsa.management_system.dto.response.ProfessorSimpleResponseDto;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.model.entity.Department;
import ma.uiz.fsa.management_system.model.entity.Professor;
import ma.uiz.fsa.management_system.model.entity.Role;
import ma.uiz.fsa.management_system.model.enums.RoleType;
import ma.uiz.fsa.management_system.repository.DepartmentRepository;
import ma.uiz.fsa.management_system.repository.RoleRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.HashSet;
import java.util.Set;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class ProfessorMapper {

    private final DepartmentRepository departmentRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;

    public Professor toEntity(ProfessorRequestDto dto) {
        if (dto == null) return null;

        Department department = departmentRepository.findById(dto.getDepartmentId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Department not found with ID: " + dto.getDepartmentId()));

        Role professorRole = roleRepository.findByName(RoleType.ROLE_PROFESSOR)
                .orElseThrow(() -> new ResourceNotFoundException("Professor role not found"));

        Set<Role> roles = new HashSet<>();
        roles.add(professorRole);

        return Professor.builder()
                .username(dto.getUsername())
                .email(dto.getEmail())
                .passwordHash(passwordEncoder.encode(dto.getPassword()))
                .roles(roles)
                .enabled(true)
                .accountNonExpired(true)
                .accountNonLocked(true)
                .credentialsNonExpired(true)
                .firstName(dto.getFirstName())
                .lastName(dto.getLastName())
                .grade(dto.getGrade())
                .department(department)
                .phoneNumber(dto.getPhoneNumber())
                .officeLocation(dto.getOfficeLocation())
                .specialization(dto.getSpecialization())
                .photoUrl(dto.getPhotoUrl())
                .scanningDeviceInfo(dto.getScanningDeviceInfo())
                .build();
    }

    public ProfessorResponseDto toResponseDto(Professor entity) {
        if (entity == null) return null;

        Set<String> roleNames = entity.getRoles().stream()
                .map(role -> role.getName().name())
                .collect(Collectors.toSet());

        return ProfessorResponseDto.builder()
                .id(entity.getId())
                .username(entity.getUsername())
                .email(entity.getEmail())
                .firstName(entity.getFirstName())
                .lastName(entity.getLastName())
                .fullName(entity.getFirstName() + " " + entity.getLastName())
                .grade(entity.getGrade())
                .phoneNumber(entity.getPhoneNumber())
                .officeLocation(entity.getOfficeLocation())
                .specialization(entity.getSpecialization())
                .photoUrl(entity.getPhotoUrl())
                .scanningDeviceInfo(entity.getScanningDeviceInfo())
                .departmentId(entity.getDepartment() != null ? entity.getDepartment().getId() : null)
                .departmentName(entity.getDepartment() != null ? entity.getDepartment().getName() : null)
                .departmentCode(entity.getDepartment() != null ? entity.getDepartment().getCode() : null)
                .totalModules(entity.getModules() != null ? entity.getModules().size() : 0)
                .totalSessions(entity.getSessions() != null ? entity.getSessions().size() : 0)
                .enabled(entity.getEnabled())
                .accountNonExpired(entity.getAccountNonExpired())
                .accountNonLocked(entity.getAccountNonLocked())
                .credentialsNonExpired(entity.getCredentialsNonExpired())
                .roles(roleNames)
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .createdBy(entity.getCreatedBy())
                .lastModifiedBy(entity.getLastModifiedBy())
                .build();
    }

    public ProfessorSimpleResponseDto toSimpleResponseDto(Professor entity) {
        if (entity == null) return null;

        return ProfessorSimpleResponseDto.builder()
                .id(entity.getId())
                .fullName(entity.getFirstName() + " " + entity.getLastName())
                .email(entity.getEmail())
                .grade(entity.getGrade())
                .departmentName(entity.getDepartment() != null ? entity.getDepartment().getName() : null)
                .specialization(entity.getSpecialization())
                .build();
    }

    public void updateEntityFromDto(ProfessorUpdateDto dto, Professor entity) {
        if (dto == null || entity == null) return;

        if (dto.getUsername() != null) {
            entity.setUsername(dto.getUsername());
        }
        if (dto.getFirstName() != null) {
            entity.setFirstName(dto.getFirstName());
        }
        if (dto.getLastName() != null) {
            entity.setLastName(dto.getLastName());
        }
        if (dto.getGrade() != null) {
            entity.setGrade(dto.getGrade());
        }
        if (dto.getPhoneNumber() != null) {
            entity.setPhoneNumber(dto.getPhoneNumber());
        }
        if (dto.getOfficeLocation() != null) {
            entity.setOfficeLocation(dto.getOfficeLocation());
        }
        if (dto.getSpecialization() != null) {
            entity.setSpecialization(dto.getSpecialization());
        }
        if (dto.getPhotoUrl() != null) {
            entity.setPhotoUrl(dto.getPhotoUrl());
        }
        if (dto.getScanningDeviceInfo() != null) {
            entity.setScanningDeviceInfo(dto.getScanningDeviceInfo());
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