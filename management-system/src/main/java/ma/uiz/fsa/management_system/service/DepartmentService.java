package ma.uiz.fsa.management_system.service;

import ma.uiz.fsa.management_system.dto.request.DepartmentRequestDto;
import ma.uiz.fsa.management_system.dto.response.DepartmentResponseDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface DepartmentService {

    DepartmentResponseDto createDepartment(DepartmentRequestDto requestDto);

    DepartmentResponseDto updateDepartment(UUID id, DepartmentRequestDto requestDto);

    DepartmentResponseDto getDepartmentById(UUID id);

    DepartmentResponseDto getDepartmentByCode(String code);

    Page<DepartmentResponseDto> getAllDepartments(Pageable pageable);

    List<DepartmentResponseDto> getAllDepartments();

    void deleteDepartment(UUID id);

    boolean existsByCode(String code);

    boolean existsByName(String name);
}
