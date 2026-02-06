package ma.uiz.fsa.management_system.service;

import ma.uiz.fsa.management_system.dto.request.ChangePasswordRequest;
import ma.uiz.fsa.management_system.dto.request.ProfessorRequestDto;
import ma.uiz.fsa.management_system.dto.request.ProfessorUpdateDto;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.dto.response.ProfessorResponseDto;
import ma.uiz.fsa.management_system.dto.response.ProfessorSimpleResponseDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface ProfessorService {

    ProfessorResponseDto createProfessor(ProfessorRequestDto requestDto);

    ProfessorResponseDto updateProfessor(UUID id, ProfessorUpdateDto requestDto);

    ProfessorResponseDto getProfessorById(UUID id);

    ProfessorResponseDto getProfessorByEmail(String email);

    Page<ProfessorResponseDto> getAllProfessors(Pageable pageable);

    List<ProfessorSimpleResponseDto> getAllProfessorsSimple();

    Page<ProfessorResponseDto> getProfessorsByDepartment(UUID departmentId, Pageable pageable);

    Page<ProfessorResponseDto> getProfessorsByGrade(String grade, Pageable pageable);

    Page<ProfessorResponseDto> searchProfessors(String searchTerm, Pageable pageable);

    Page<ProfessorResponseDto> getActiveProfessors(Pageable pageable);

    MessageResponse toggleProfessorStatus(UUID id);

    void deleteProfessor(UUID id);

    MessageResponse changeProfessorPassword(UUID id, ChangePasswordRequest request);
}