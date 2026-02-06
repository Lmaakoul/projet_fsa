package ma.uiz.fsa.management_system.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.uiz.fsa.management_system.dto.request.AssignProfessorsDto;
import ma.uiz.fsa.management_system.dto.request.ModuleRequestDto;
import ma.uiz.fsa.management_system.dto.request.ModuleUpdateDto;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.dto.response.ModuleResponseDto;
import ma.uiz.fsa.management_system.dto.response.ModuleSimpleResponseDto;
import ma.uiz.fsa.management_system.exception.BadRequestException;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.mapper.ModuleMapper;
import ma.uiz.fsa.management_system.model.entity.Module;
import ma.uiz.fsa.management_system.model.entity.Professor;
import ma.uiz.fsa.management_system.repository.ModuleRepository;
import ma.uiz.fsa.management_system.repository.ProfessorRepository;
import ma.uiz.fsa.management_system.service.ModuleService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ModuleServiceImpl implements ModuleService {

    private final ModuleRepository moduleRepository;
    private final ProfessorRepository professorRepository;
    private final ModuleMapper moduleMapper;

    @Override
    @Transactional
    public ModuleResponseDto createModule(ModuleRequestDto requestDto) {
        log.debug("Creating new module with code: {}", requestDto.getCode());

        // Validate unique code
        if (moduleRepository.existsByCodeIgnoreCase(requestDto.getCode())) {
            throw new BadRequestException("Module with code '" + requestDto.getCode() + "' already exists");
        }

        Module module = moduleMapper.toEntity(requestDto);
        Module savedModule = moduleRepository.save(module);

        log.info("Module created successfully with ID: {}", savedModule.getId());
        return moduleMapper.toResponseDto(savedModule);
    }

    @Override
    @Transactional
    public ModuleResponseDto updateModule(UUID id, ModuleUpdateDto requestDto) {
        log.debug("Updating module with ID: {}", id);

        Module module = moduleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Module not found with ID: " + id));

        // Validate unique code (if changed)
        if (requestDto.getCode() != null &&
                !module.getCode().equalsIgnoreCase(requestDto.getCode()) &&
                moduleRepository.existsByCodeIgnoreCase(requestDto.getCode())) {
            throw new BadRequestException("Module with code '" + requestDto.getCode() + "' already exists");
        }

        moduleMapper.updateEntityFromUpdateDto(requestDto, module);
        Module updatedModule = moduleRepository.save(module);

        log.info("Module updated successfully with ID: {}", updatedModule.getId());
        return moduleMapper.toResponseDto(updatedModule);
    }

    @Override
    @Transactional(readOnly = true)
    public ModuleResponseDto getModuleById(UUID id) {
        log.debug("Fetching module with ID: {}", id);

        Module module = moduleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Module not found with ID: " + id));

        return moduleMapper.toResponseDto(module);
    }

    @Override
    @Transactional(readOnly = true)
    public ModuleResponseDto getModuleByCode(String code) {
        log.debug("Fetching module with code: {}", code);

        Module module = moduleRepository.findByCodeIgnoreCase(code)
                .orElseThrow(() -> new ResourceNotFoundException("Module not found with code: " + code));

        return moduleMapper.toResponseDto(module);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ModuleResponseDto> getAllModules(Pageable pageable) {
        log.debug("Fetching all modules with pagination");

        Page<Module> modules = moduleRepository.findAll(pageable);
        return modules.map(moduleMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ModuleSimpleResponseDto> getAllModulesSimple() {
        log.debug("Fetching all modules (simple)");

        List<Module> modules = moduleRepository.findAll();
        return modules.stream()
                .map(moduleMapper::toSimpleResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ModuleResponseDto> getModulesBySemester(UUID semesterId, Pageable pageable) {
        log.debug("Fetching modules for semester ID: {}", semesterId);

        Page<Module> modules = moduleRepository.findBySemesterId(semesterId, pageable);
        return modules.map(moduleMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ModuleSimpleResponseDto> getActiveModulesBySemester(UUID semesterId) {
        log.debug("Fetching active modules for semester ID: {}", semesterId);

        List<Module> modules = moduleRepository.findActiveModulesBySemester(semesterId);
        return modules.stream()
                .map(moduleMapper::toSimpleResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ModuleResponseDto> getModulesByFiliere(UUID filiereId, Pageable pageable) {
        log.debug("Fetching modules for filiere ID: {}", filiereId);

        Page<Module> modules = moduleRepository.findByFiliereId(filiereId, pageable);
        return modules.map(moduleMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ModuleResponseDto> getModulesByProfessor(UUID professorId, Pageable pageable) {
        log.debug("Fetching modules for professor ID: {}", professorId);

        Page<Module> modules = moduleRepository.findByProfessorId(professorId, pageable);
        return modules.map(moduleMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ModuleSimpleResponseDto> getActiveModulesByProfessor(UUID professorId) {
        log.debug("Fetching active modules for professor ID: {}", professorId);

        List<Module> modules = moduleRepository.findActiveModulesByProfessor(professorId);
        return modules.stream()
                .map(moduleMapper::toSimpleResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ModuleResponseDto> getModulesByAcademicYear(String academicYear, Pageable pageable) {
        log.debug("Fetching modules for academic year: {}", academicYear);

        Page<Module> modules = moduleRepository.findByAcademicYear(academicYear, pageable);
        return modules.map(moduleMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ModuleResponseDto> getActiveModules(Pageable pageable) {
        log.debug("Fetching active modules");

        Page<Module> modules = moduleRepository.findByIsActive(true, pageable);
        return modules.map(moduleMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ModuleResponseDto> searchModules(String searchTerm, Pageable pageable) {
        log.debug("Searching modules with term: {}", searchTerm);

        Page<Module> modules = moduleRepository.searchModules(searchTerm, pageable);
        return modules.map(moduleMapper::toResponseDto);
    }

    @Override
    @Transactional
    public ModuleResponseDto assignProfessors(UUID moduleId, AssignProfessorsDto assignDto) {
        log.debug("Assigning professors to module ID: {}", moduleId);

        Module module = moduleRepository.findById(moduleId)
                .orElseThrow(() -> new ResourceNotFoundException("Module not found with ID: " + moduleId));

        Set<Professor> professors = assignDto.getProfessorIds().stream()
                .map(id -> professorRepository.findById(id)
                        .orElseThrow(() -> new ResourceNotFoundException("Professor not found with ID: " + id)))
                .collect(Collectors.toSet());

        module.setProfessors(professors);
        Module updatedModule = moduleRepository.save(module);

        log.info("Professors assigned successfully to module ID: {}", moduleId);
        return moduleMapper.toResponseDto(updatedModule);
    }

    @Override
    @Transactional
    public MessageResponse removeProfessorFromModule(UUID moduleId, UUID professorId) {
        log.debug("Removing professor ID: {} from module ID: {}", professorId, moduleId);

        Module module = moduleRepository.findById(moduleId)
                .orElseThrow(() -> new ResourceNotFoundException("Module not found with ID: " + moduleId));

        Professor professor = professorRepository.findById(professorId)
                .orElseThrow(() -> new ResourceNotFoundException("Professor not found with ID: " + professorId));

        if (!module.getProfessors().contains(professor)) {
            throw new BadRequestException("Professor is not assigned to this module");
        }

        module.getProfessors().remove(professor);
        moduleRepository.save(module);

        log.info("Professor removed successfully from module ID: {}", moduleId);
        return new MessageResponse("Professor removed from module successfully", true);
    }

    @Override
    @Transactional
    public ModuleResponseDto toggleModuleStatus(UUID id) {
        log.debug("Toggling status for module with ID: {}", id);

        Module module = moduleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Module not found with ID: " + id));

        module.setIsActive(!module.getIsActive());
        Module updatedModule = moduleRepository.save(module);

        log.info("Module status toggled to {} for ID: {}", updatedModule.getIsActive(), id);
        return moduleMapper.toResponseDto(updatedModule);
    }

    @Override
    @Transactional
    public void deleteModule(UUID id) {
        log.debug("Deleting module with ID: {}", id);

        Module module = moduleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Module not found with ID: " + id));

        // Check if module has sessions
        if (module.getSessions() != null && !module.getSessions().isEmpty()) {
            throw new BadRequestException(
                    "Cannot delete module. It has " + module.getSessions().size() + " session(s) associated with it."
            );
        }

        // Check if module has evaluations
        if (module.getEvaluations() != null && !module.getEvaluations().isEmpty()) {
            throw new BadRequestException(
                    "Cannot delete module. It has " + module.getEvaluations().size() + " evaluation(s) associated with it."
            );
        }

        // Check if module has groups
        if (module.getGroups() != null && !module.getGroups().isEmpty()) {
            throw new BadRequestException(
                    "Cannot delete module. It has " + module.getGroups().size() + " group(s) associated with it."
            );
        }

        moduleRepository.delete(module);
        log.info("Module deleted successfully with ID: {}", id);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean existsByCode(String code) {
        return moduleRepository.existsByCodeIgnoreCase(code);
    }
}