package ma.uiz.fsa.management_system.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.uiz.fsa.management_system.dto.request.DepartmentRequestDto;
import ma.uiz.fsa.management_system.dto.response.DepartmentResponseDto;
import ma.uiz.fsa.management_system.exception.BadRequestException;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.mapper.DepartmentMapper;
import ma.uiz.fsa.management_system.model.entity.Department;
import ma.uiz.fsa.management_system.repository.DepartmentRepository;
import ma.uiz.fsa.management_system.service.DepartmentService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class DepartmentServiceImpl implements DepartmentService {

    private final DepartmentRepository departmentRepository;
    private final DepartmentMapper departmentMapper;

    @Override
    @Transactional
    public DepartmentResponseDto createDepartment(DepartmentRequestDto requestDto) {
        log.debug("Creating new department with code: {}", requestDto.getCode());

        // Validate unique code
        if (departmentRepository.existsByCodeIgnoreCase(requestDto.getCode())) {
            throw new BadRequestException("Department with code '" + requestDto.getCode() + "' already exists");
        }

        // Validate unique name
        if (departmentRepository.existsByNameIgnoreCase(requestDto.getName())) {
            throw new BadRequestException("Department with name '" + requestDto.getName() + "' already exists");
        }

        Department department = departmentMapper.toEntity(requestDto);
        Department savedDepartment = departmentRepository.save(department);

        log.info("Department created successfully with ID: {}", savedDepartment.getId());
        return departmentMapper.toResponseDto(savedDepartment);
    }

    @Override
    @Transactional
    public DepartmentResponseDto updateDepartment(UUID id, DepartmentRequestDto requestDto) {
        log.debug("Updating department with ID: {}", id);

        Department department = departmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Department not found with ID: " + id));

        // Validate unique code (if changed)
        if (requestDto.getCode() != null &&
                !department.getCode().equalsIgnoreCase(requestDto.getCode()) &&
                departmentRepository.existsByCodeIgnoreCase(requestDto.getCode())) {
            throw new BadRequestException("Department with code '" + requestDto.getCode() + "' already exists");
        }

        // Validate unique name (if changed)
        if (requestDto.getName() != null &&
                !department.getName().equalsIgnoreCase(requestDto.getName()) &&
                departmentRepository.existsByNameIgnoreCase(requestDto.getName())) {
            throw new BadRequestException("Department with name '" + requestDto.getName() + "' already exists");
        }

        departmentMapper.updateEntityFromDto(requestDto, department);
        Department updatedDepartment = departmentRepository.save(department);

        log.info("Department updated successfully with ID: {}", updatedDepartment.getId());
        return departmentMapper.toResponseDto(updatedDepartment);
    }

    @Override
    @Transactional(readOnly = true)
    public DepartmentResponseDto getDepartmentById(UUID id) {
        log.debug("Fetching department with ID: {}", id);

        Department department = departmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Department not found with ID: " + id));

        return departmentMapper.toResponseDto(department);
    }

    @Override
    @Transactional(readOnly = true)
    public DepartmentResponseDto getDepartmentByCode(String code) {
        log.debug("Fetching department with code: {}", code);

        Department department = departmentRepository.findByCodeIgnoreCase(code)
                .orElseThrow(() -> new ResourceNotFoundException("Department not found with code: " + code));

        return departmentMapper.toResponseDto(department);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<DepartmentResponseDto> getAllDepartments(Pageable pageable) {
        log.debug("Fetching all departments with pagination");

        Page<Department> departments = departmentRepository.findAll(pageable);
        return departments.map(departmentMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<DepartmentResponseDto> getAllDepartments() {
        log.debug("Fetching all departments");

        List<Department> departments = departmentRepository.findAll();
        return departments.stream()
                .map(departmentMapper::toResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void deleteDepartment(UUID id) {
        log.debug("Deleting department with ID: {}", id);

        Department department = departmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Department not found with ID: " + id));

        // Check if department has filieres
        if (department.getFilieres() != null && !department.getFilieres().isEmpty()) {
            throw new BadRequestException(
                    "Cannot delete department. It has " + department.getFilieres().size() + " filiere(s) associated with it."
            );
        }

        // Check if department has professors
        if (department.getProfessors() != null && !department.getProfessors().isEmpty()) {
            throw new BadRequestException(
                    "Cannot delete department. It has " + department.getProfessors().size() + " professor(s) associated with it."
            );
        }

        departmentRepository.delete(department);
        log.info("Department deleted successfully with ID: {}", id);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean existsByCode(String code) {
        return departmentRepository.existsByCodeIgnoreCase(code);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean existsByName(String name) {
        return departmentRepository.existsByNameIgnoreCase(name);
    }
}