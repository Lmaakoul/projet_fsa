package ma.uiz.fsa.management_system.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.uiz.fsa.management_system.dto.request.SemesterRequestDto;
import ma.uiz.fsa.management_system.dto.request.SemesterUpdateDto;
import ma.uiz.fsa.management_system.dto.response.SemesterResponseDto;
import ma.uiz.fsa.management_system.dto.response.SemesterSimpleResponseDto;
import ma.uiz.fsa.management_system.exception.BadRequestException;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.mapper.SemesterMapper;
import ma.uiz.fsa.management_system.model.entity.Semester;
import ma.uiz.fsa.management_system.repository.SemesterRepository;
import ma.uiz.fsa.management_system.service.SemesterService;
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
public class SemesterServiceImpl implements SemesterService {

    private final SemesterRepository semesterRepository;
    private final SemesterMapper semesterMapper;

    @Override
    @Transactional
    public SemesterResponseDto createSemester(SemesterRequestDto requestDto) {
        log.debug("Creating new semester: {} for filiere ID: {}",
                requestDto.getName(), requestDto.getFiliereId());

        // Validate unique semester number within filiere
        if (semesterRepository.existsByFiliereIdAndSemesterNumber(
                requestDto.getFiliereId(), requestDto.getSemesterNumber())) {
            throw new BadRequestException(
                    "Semester number " + requestDto.getSemesterNumber() +
                            " already exists for this filiere");
        }

        Semester semester = semesterMapper.toEntity(requestDto);
        Semester savedSemester = semesterRepository.save(semester);

        log.info("Semester created successfully with ID: {}", savedSemester.getId());
        return semesterMapper.toResponseDto(savedSemester);
    }

    @Override
    @Transactional
    public SemesterResponseDto updateSemester(UUID id, SemesterUpdateDto requestDto) {
        log.debug("Updating semester with ID: {}", id);

        Semester semester = semesterRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Semester not found with ID: " + id));

        // Validate unique semester number within filiere (if changed)
        if (requestDto.getSemesterNumber() != null &&
                !semester.getSemesterNumber().equals(requestDto.getSemesterNumber())) {

            UUID filiereId = requestDto.getFiliereId() != null ?
                    requestDto.getFiliereId() : semester.getFiliere().getId();

            if (semesterRepository.existsByFiliereIdAndSemesterNumber(
                    filiereId, requestDto.getSemesterNumber())) {
                throw new BadRequestException(
                        "Semester number " + requestDto.getSemesterNumber() +
                                " already exists for this filiere");
            }
        }

        semesterMapper.updateEntityFromUpdateDto(requestDto, semester);
        Semester updatedSemester = semesterRepository.save(semester);

        log.info("Semester updated successfully with ID: {}", updatedSemester.getId());
        return semesterMapper.toResponseDto(updatedSemester);
    }

    @Override
    @Transactional(readOnly = true)
    public SemesterResponseDto getSemesterById(UUID id) {
        log.debug("Fetching semester with ID: {}", id);

        Semester semester = semesterRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Semester not found with ID: " + id));

        return semesterMapper.toResponseDto(semester);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SemesterResponseDto> getAllSemesters(Pageable pageable) {
        log.debug("Fetching all semesters with pagination");

        Page<Semester> semesters = semesterRepository.findAll(pageable);
        return semesters.map(semesterMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SemesterSimpleResponseDto> getAllSemestersSimple() {
        log.debug("Fetching all semesters (simple)");

        List<Semester> semesters = semesterRepository.findAll();
        return semesters.stream()
                .map(semesterMapper::toSimpleResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SemesterResponseDto> getSemestersByFiliere(UUID filiereId, Pageable pageable) {
        log.debug("Fetching semesters for filiere ID: {}", filiereId);

        Page<Semester> semesters = semesterRepository.findByFiliereId(filiereId, pageable);
        return semesters.map(semesterMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SemesterSimpleResponseDto> getActiveSemestersByFiliere(UUID filiereId) {
        log.debug("Fetching active semesters for filiere ID: {}", filiereId);

        List<Semester> semesters = semesterRepository.findActiveSemestersByFiliere(filiereId);
        return semesters.stream()
                .map(semesterMapper::toSimpleResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SemesterResponseDto> getSemestersByAcademicYear(String academicYear, Pageable pageable) {
        log.debug("Fetching semesters for academic year: {}", academicYear);

        Page<Semester> semesters = semesterRepository.findByAcademicYear(academicYear, pageable);
        return semesters.map(semesterMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SemesterResponseDto> getActiveSemesters(Pageable pageable) {
        log.debug("Fetching active semesters");

        Page<Semester> semesters = semesterRepository.findByIsActive(true, pageable);
        return semesters.map(semesterMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SemesterResponseDto> searchSemesters(String searchTerm, Pageable pageable) {
        log.debug("Searching semesters with term: {}", searchTerm);

        Page<Semester> semesters = semesterRepository.searchSemesters(searchTerm, pageable);
        return semesters.map(semesterMapper::toResponseDto);
    }

    @Override
    @Transactional
    public SemesterResponseDto toggleSemesterStatus(UUID id) {
        log.debug("Toggling status for semester with ID: {}", id);

        Semester semester = semesterRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Semester not found with ID: " + id));

        semester.setIsActive(!semester.getIsActive());
        Semester updatedSemester = semesterRepository.save(semester);

        log.info("Semester status toggled to {} for ID: {}", updatedSemester.getIsActive(), id);
        return semesterMapper.toResponseDto(updatedSemester);
    }

    @Override
    @Transactional
    public void deleteSemester(UUID id) {
        log.debug("Deleting semester with ID: {}", id);

        Semester semester = semesterRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Semester not found with ID: " + id));

        // Check if semester has modules
        if (semester.getModules() != null && !semester.getModules().isEmpty()) {
            throw new BadRequestException(
                    "Cannot delete semester. It has " + semester.getModules().size() + " module(s) associated with it."
            );
        }

        semesterRepository.delete(semester);
        log.info("Semester deleted successfully with ID: {}", id);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean existsByFiliereAndSemesterNumber(UUID filiereId, Integer semesterNumber) {
        return semesterRepository.existsByFiliereIdAndSemesterNumber(filiereId, semesterNumber);
    }
}