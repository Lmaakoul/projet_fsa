package ma.uiz.fsa.management_system.mapper;

import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.StudentRequestDto;
import ma.uiz.fsa.management_system.dto.request.StudentUpdateDto;
import ma.uiz.fsa.management_system.dto.response.StudentResponseDto;
import ma.uiz.fsa.management_system.dto.response.StudentSimpleResponseDto;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.model.entity.Filiere;
import ma.uiz.fsa.management_system.model.entity.Role;
import ma.uiz.fsa.management_system.model.entity.Student;
import ma.uiz.fsa.management_system.model.enums.RoleType;
import ma.uiz.fsa.management_system.repository.FiliereRepository;
import ma.uiz.fsa.management_system.repository.RoleRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.HashSet;
import java.util.Set;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class StudentMapper {

    private final FiliereRepository filiereRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;

    public Student toEntity(StudentRequestDto dto) {
        if (dto == null) return null;

        Filiere filiere = filiereRepository.findById(dto.getFiliereId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Filiere not found with ID: " + dto.getFiliereId()));

        Role studentRole = roleRepository.findByName(RoleType.ROLE_STUDENT)
                .orElseThrow(() -> new ResourceNotFoundException("Student role not found"));

        Set<Role> roles = new HashSet<>();
        roles.add(studentRole);

        return Student.builder()
                .username(dto.getUsername())
                .email(dto.getEmail())
                .passwordHash(passwordEncoder.encode(dto.getPassword()))
                .roles(roles)
                .enabled(true)
                .accountNonExpired(true)
                .accountNonLocked(true)
                .credentialsNonExpired(true)
                .cne(dto.getCne().toUpperCase())
                .cin(dto.getCin().toUpperCase())
                .firstName(dto.getFirstName())
                .lastName(dto.getLastName())
                .dateOfBirth(dto.getDateOfBirth())
                .filiere(filiere)
                .phoneNumber(dto.getPhoneNumber())
                .address(dto.getAddress())
                .photoUrl(dto.getPhotoUrl())
                .build();
    }

    public StudentResponseDto toResponseDto(Student entity) {
        if (entity == null) return null;

        Set<String> roleNames = entity.getRoles().stream()
                .map(role -> role.getName().name())
                .collect(Collectors.toSet());

        // Calculate average grade from evaluations
        Double averageGrade = null;
        if (entity.getEvaluations() != null && !entity.getEvaluations().isEmpty()) {
            averageGrade = entity.getEvaluations().stream()
                    .filter(eval -> eval.getGrade() != null)
                    .mapToDouble(eval -> eval.getGrade())
                    .average()
                    .orElse(0.0);
        }

        return StudentResponseDto.builder()
                .id(entity.getId())
                .username(entity.getUsername())
                .email(entity.getEmail())
                .cne(entity.getCne())
                .cin(entity.getCin())
                .firstName(entity.getFirstName())
                .lastName(entity.getLastName())
                .fullName(entity.getFirstName() + " " + entity.getLastName())
                .dateOfBirth(entity.getDateOfBirth())
                .phoneNumber(entity.getPhoneNumber())
                .address(entity.getAddress())
                .photoUrl(entity.getPhotoUrl())
                .qrCode(entity.getQrCode())
                .qrCodeImage(entity.getQrCodeImage())
                .filiereId(entity.getFiliere() != null ? entity.getFiliere().getId() : null)
                .filiereName(entity.getFiliere() != null ? entity.getFiliere().getName() : null)
                .filiereCode(entity.getFiliere() != null ? entity.getFiliere().getCode() : null)
                .departmentName(entity.getFiliere() != null && entity.getFiliere().getDepartment() != null
                        ? entity.getFiliere().getDepartment().getName() : null)
                .totalGroups(entity.getGroups() != null ? entity.getGroups().size() : 0)
                .totalEvaluations(entity.getEvaluations() != null ? entity.getEvaluations().size() : 0)
                .totalAttendanceRecords(entity.getAttendanceRecords() != null ? entity.getAttendanceRecords().size() : 0)
                .averageGrade(averageGrade)
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

    public StudentSimpleResponseDto toSimpleResponseDto(Student entity) {
        if (entity == null) return null;

        return StudentSimpleResponseDto.builder()
                .id(entity.getId())
                .fullName(entity.getFirstName() + " " + entity.getLastName())
                .email(entity.getEmail())
                .cne(entity.getCne())
                .filiereName(entity.getFiliere() != null ? entity.getFiliere().getName() : null)
                .photoUrl(entity.getPhotoUrl())
                .build();
    }

    public void updateEntityFromDto(StudentUpdateDto dto, Student entity) {
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
        if (dto.getDateOfBirth() != null) {
            entity.setDateOfBirth(dto.getDateOfBirth());
        }
        if (dto.getPhoneNumber() != null) {
            entity.setPhoneNumber(dto.getPhoneNumber());
        }
        if (dto.getAddress() != null) {
            entity.setAddress(dto.getAddress());
        }
        if (dto.getPhotoUrl() != null) {
            entity.setPhotoUrl(dto.getPhotoUrl());
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