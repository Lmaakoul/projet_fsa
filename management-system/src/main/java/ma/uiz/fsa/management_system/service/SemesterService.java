package ma.uiz.fsa.management_system.service;

import ma.uiz.fsa.management_system.dto.request.SemesterRequestDto;
import ma.uiz.fsa.management_system.dto.request.SemesterUpdateDto;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.dto.response.SemesterResponseDto;
import ma.uiz.fsa.management_system.dto.response.SemesterSimpleResponseDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface SemesterService {

    SemesterResponseDto createSemester(SemesterRequestDto requestDto);

    SemesterResponseDto updateSemester(UUID id, SemesterUpdateDto requestDto);

    SemesterResponseDto getSemesterById(UUID id);

    Page<SemesterResponseDto> getAllSemesters(Pageable pageable);

    List<SemesterSimpleResponseDto> getAllSemestersSimple();

    Page<SemesterResponseDto> getSemestersByFiliere(UUID filiereId, Pageable pageable);

    List<SemesterSimpleResponseDto> getActiveSemestersByFiliere(UUID filiereId);

    Page<SemesterResponseDto> getSemestersByAcademicYear(String academicYear, Pageable pageable);

    Page<SemesterResponseDto> getActiveSemesters(Pageable pageable);

    Page<SemesterResponseDto> searchSemesters(String searchTerm, Pageable pageable);

    SemesterResponseDto toggleSemesterStatus(UUID id);

    void deleteSemester(UUID id);

    boolean existsByFiliereAndSemesterNumber(UUID filiereId, Integer semesterNumber);
}