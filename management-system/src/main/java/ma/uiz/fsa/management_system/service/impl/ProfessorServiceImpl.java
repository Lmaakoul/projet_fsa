package ma.uiz.fsa.management_system.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.uiz.fsa.management_system.dto.request.ChangePasswordRequest;
import ma.uiz.fsa.management_system.dto.request.ProfessorRequestDto;
import ma.uiz.fsa.management_system.dto.request.ProfessorUpdateDto;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.dto.response.ProfessorResponseDto;
import ma.uiz.fsa.management_system.dto.response.ProfessorSimpleResponseDto;
import ma.uiz.fsa.management_system.exception.BadRequestException;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.mapper.ProfessorMapper;
import ma.uiz.fsa.management_system.model.entity.Professor;
import ma.uiz.fsa.management_system.repository.ProfessorRepository;
import ma.uiz.fsa.management_system.repository.RefreshTokenRepository;
import ma.uiz.fsa.management_system.service.ProfessorService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProfessorServiceImpl implements ProfessorService {

    private final ProfessorRepository professorRepository;
    private final ProfessorMapper professorMapper;
    private final PasswordEncoder passwordEncoder;
    private final RefreshTokenRepository refreshTokenRepository;

    @Override
    @Transactional
    public ProfessorResponseDto createProfessor(ProfessorRequestDto requestDto) {
        log.debug("Creating new professor with email: {}", requestDto.getEmail());

        // Validate unique email
        if (professorRepository.existsByEmail(requestDto.getEmail())) {
            throw new BadRequestException("Professor with email '" + requestDto.getEmail() + "' already exists");
        }

        // Validate unique username
        if (professorRepository.existsByUsername(requestDto.getUsername())) {
            throw new BadRequestException("Username '" + requestDto.getUsername() + "' is already taken");
        }

        Professor professor = professorMapper.toEntity(requestDto);
        Professor savedProfessor = professorRepository.save(professor);

        log.info("Professor created successfully with ID: {}", savedProfessor.getId());
        return professorMapper.toResponseDto(savedProfessor);
    }

    @Override
    @Transactional
    public ProfessorResponseDto updateProfessor(UUID id, ProfessorUpdateDto requestDto) {
        log.debug("Updating professor with ID: {}", id);

        Professor professor = professorRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Professor not found with ID: " + id));

        // Validate unique username (if changed)
        if (requestDto.getUsername() != null &&
                !professor.getUsername().equals(requestDto.getUsername()) &&
                professorRepository.existsByUsername(requestDto.getUsername())) {
            throw new BadRequestException("Username '" + requestDto.getUsername() + "' is already taken");
        }

        professorMapper.updateEntityFromDto(requestDto, professor);
        Professor updatedProfessor = professorRepository.save(professor);

        log.info("Professor updated successfully with ID: {}", updatedProfessor.getId());
        return professorMapper.toResponseDto(updatedProfessor);
    }

    @Override
    @Transactional(readOnly = true)
    public ProfessorResponseDto getProfessorById(UUID id) {
        log.debug("Fetching professor with ID: {}", id);

        Professor professor = professorRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Professor not found with ID: " + id));

        return professorMapper.toResponseDto(professor);
    }

    @Override
    @Transactional(readOnly = true)
    public ProfessorResponseDto getProfessorByEmail(String email) {
        log.debug("Fetching professor with email: {}", email);

        Professor professor = professorRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Professor not found with email: " + email));

        return professorMapper.toResponseDto(professor);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ProfessorResponseDto> getAllProfessors(Pageable pageable) {
        log.debug("Fetching all professors with pagination");

        Page<Professor> professors = professorRepository.findAll(pageable);
        return professors.map(professorMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ProfessorSimpleResponseDto> getAllProfessorsSimple() {
        log.debug("Fetching all professors (simple)");

        List<Professor> professors = professorRepository.findAll();
        return professors.stream()
                .map(professorMapper::toSimpleResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ProfessorResponseDto> getProfessorsByDepartment(UUID departmentId, Pageable pageable) {
        log.debug("Fetching professors for department ID: {}", departmentId);

        Page<Professor> professors = professorRepository.findByDepartmentId(departmentId, pageable);
        return professors.map(professorMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ProfessorResponseDto> getProfessorsByGrade(String grade, Pageable pageable) {
        log.debug("Fetching professors with grade: {}", grade);

        Page<Professor> professors = professorRepository.findByGrade(grade, pageable);
        return professors.map(professorMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ProfessorResponseDto> searchProfessors(String searchTerm, Pageable pageable) {
        log.debug("Searching professors with term: {}", searchTerm);

        Page<Professor> professors = professorRepository.searchProfessors(searchTerm, pageable);
        return professors.map(professorMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ProfessorResponseDto> getActiveProfessors(Pageable pageable) {
        log.debug("Fetching active professors");

        Page<Professor> professors = professorRepository.findByEnabled(true, pageable);
        return professors.map(professorMapper::toResponseDto);
    }

    @Override
    @Transactional
    public MessageResponse toggleProfessorStatus(UUID id) {
        log.debug("Toggling status for professor with ID: {}", id);

        Professor professor = professorRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Professor not found with ID: " + id));

        professor.setEnabled(!professor.getEnabled());
        professorRepository.save(professor);

        String status = professor.getEnabled() ? "enabled" : "disabled";
        log.info("Professor status toggled to {} for ID: {}", status, id);

        return new MessageResponse("Professor account " + status + " successfully", true);
    }

    @Override
    @Transactional
    public void deleteProfessor(UUID id) {
        log.debug("Deleting professor with ID: {}", id);

        Professor professor = professorRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Professor not found with ID: " + id));

        // Check if professor has modules
        if (professor.getModules() != null && !professor.getModules().isEmpty()) {
            throw new BadRequestException(
                    "Cannot delete professor. They are assigned to " + professor.getModules().size() + " module(s)."
            );
        }

        // Check if professor has sessions
        if (professor.getSessions() != null && !professor.getSessions().isEmpty()) {
            throw new BadRequestException(
                    "Cannot delete professor. They have " + professor.getSessions().size() + " session(s) scheduled."
            );
        }

        refreshTokenRepository.deleteByUser(professor);

        professorRepository.delete(professor);
        log.info("Professor deleted successfully with ID: {}", id);
    }

    @Override
    @Transactional
    public MessageResponse changeProfessorPassword(UUID id, ChangePasswordRequest request) {
        log.debug("Changing password for professor with ID: {}", id);

        Professor professor = professorRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Professor not found with ID: " + id));

        // Verify current password
        if (!passwordEncoder.matches(request.getCurrentPassword(), professor.getPasswordHash())) {
            throw new BadRequestException("Current password is incorrect");
        }

        // Verify new password and confirm password match
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new BadRequestException("New password and confirm password do not match");
        }

        // Update password
        professor.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        professorRepository.save(professor);

        log.info("Password changed successfully for professor ID: {}", id);
        return new MessageResponse("Password changed successfully", true);
    }
}