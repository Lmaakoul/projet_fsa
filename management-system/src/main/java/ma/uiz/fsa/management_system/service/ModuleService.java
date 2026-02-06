package ma.uiz.fsa.management_system.service;

import ma.uiz.fsa.management_system.dto.request.AssignProfessorsDto;
import ma.uiz.fsa.management_system.dto.request.ModuleRequestDto;
import ma.uiz.fsa.management_system.dto.request.ModuleUpdateDto;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.dto.response.ModuleResponseDto;
import ma.uiz.fsa.management_system.dto.response.ModuleSimpleResponseDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface ModuleService {

    ModuleResponseDto createModule(ModuleRequestDto requestDto);

    ModuleResponseDto updateModule(UUID id, ModuleUpdateDto requestDto);

    ModuleResponseDto getModuleById(UUID id);

    ModuleResponseDto getModuleByCode(String code);

    Page<ModuleResponseDto> getAllModules(Pageable pageable);

    List<ModuleSimpleResponseDto> getAllModulesSimple();

    Page<ModuleResponseDto> getModulesBySemester(UUID semesterId, Pageable pageable);

    List<ModuleSimpleResponseDto> getActiveModulesBySemester(UUID semesterId);

    Page<ModuleResponseDto> getModulesByFiliere(UUID filiereId, Pageable pageable);

    Page<ModuleResponseDto> getModulesByProfessor(UUID professorId, Pageable pageable);

    List<ModuleSimpleResponseDto> getActiveModulesByProfessor(UUID professorId);

    Page<ModuleResponseDto> getModulesByAcademicYear(String academicYear, Pageable pageable);

    Page<ModuleResponseDto> getActiveModules(Pageable pageable);

    Page<ModuleResponseDto> searchModules(String searchTerm, Pageable pageable);

    ModuleResponseDto assignProfessors(UUID moduleId, AssignProfessorsDto assignDto);

    MessageResponse removeProfessorFromModule(UUID moduleId, UUID professorId);

    ModuleResponseDto toggleModuleStatus(UUID id);

    void deleteModule(UUID id);

    boolean existsByCode(String code);
}