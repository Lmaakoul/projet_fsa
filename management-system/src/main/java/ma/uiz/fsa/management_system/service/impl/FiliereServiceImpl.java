package ma.uiz.fsa.management_system.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.uiz.fsa.management_system.dto.request.FiliereRequestDto;
import ma.uiz.fsa.management_system.dto.response.FiliereResponseDto;
import ma.uiz.fsa.management_system.dto.response.FiliereSimpleResponseDto;
import ma.uiz.fsa.management_system.exception.BadRequestException;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.mapper.FiliereMapper;
import ma.uiz.fsa.management_system.model.entity.Filiere;
import ma.uiz.fsa.management_system.model.enums.DegreeType;
import ma.uiz.fsa.management_system.repository.FiliereRepository;
import ma.uiz.fsa.management_system.service.FiliereService;
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
public class FiliereServiceImpl implements FiliereService {

    private final FiliereRepository filiereRepository;
    private final FiliereMapper filiereMapper;

    @Override
    @Transactional
    public FiliereResponseDto createFiliere(FiliereRequestDto requestDto) {
        log.debug("Creating new filiere with code: {}", requestDto.getCode());

        // Validate unique code
        if (filiereRepository.existsByCodeIgnoreCase(requestDto.getCode())) {
            throw new BadRequestException("Filiere with code '" + requestDto.getCode() + "' already exists");
        }

        // Validate unique name
        if (filiereRepository.existsByNameIgnoreCase(requestDto.getName())) {
            throw new BadRequestException("Filiere with name '" + requestDto.getName() + "' already exists");
        }

        Filiere filiere = filiereMapper.toEntity(requestDto);
        Filiere savedFiliere = filiereRepository.save(filiere);

        log.info("Filiere created successfully with ID: {}", savedFiliere.getId());
        return filiereMapper.toResponseDto(savedFiliere);
    }

    @Override
    @Transactional
    public FiliereResponseDto updateFiliere(UUID id, FiliereRequestDto requestDto) {
        log.debug("Updating filiere with ID: {}", id);

        Filiere filiere = filiereRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Filiere not found with ID: " + id));

        // Validate unique code (if changed)
        if (requestDto.getCode() != null &&
                !filiere.getCode().equalsIgnoreCase(requestDto.getCode()) &&
                filiereRepository.existsByCodeIgnoreCase(requestDto.getCode())) {
            throw new BadRequestException("Filiere with code '" + requestDto.getCode() + "' already exists");
        }

        // Validate unique name (if changed)
        if (requestDto.getName() != null &&
                !filiere.getName().equalsIgnoreCase(requestDto.getName()) &&
                filiereRepository.existsByNameIgnoreCase(requestDto.getName())) {
            throw new BadRequestException("Filiere with name '" + requestDto.getName() + "' already exists");
        }

        filiereMapper.updateEntityFromDto(requestDto, filiere);
        Filiere updatedFiliere = filiereRepository.save(filiere);

        log.info("Filiere updated successfully with ID: {}", updatedFiliere.getId());
        return filiereMapper.toResponseDto(updatedFiliere);
    }

    @Override
    @Transactional(readOnly = true)
    public FiliereResponseDto getFiliereById(UUID id) {
        log.debug("Fetching filiere with ID: {}", id);

        Filiere filiere = filiereRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Filiere not found with ID: " + id));

        return filiereMapper.toResponseDto(filiere);
    }

    @Override
    @Transactional(readOnly = true)
    public FiliereResponseDto getFiliereByCode(String code) {
        log.debug("Fetching filiere with code: {}", code);

        Filiere filiere = filiereRepository.findByCodeIgnoreCase(code)
                .orElseThrow(() -> new ResourceNotFoundException("Filiere not found with code: " + code));

        return filiereMapper.toResponseDto(filiere);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<FiliereResponseDto> getAllFilieres(Pageable pageable) {
        log.debug("Fetching all filieres with pagination");

        Page<Filiere> filieres = filiereRepository.findAll(pageable);
        return filieres.map(filiereMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<FiliereSimpleResponseDto> getAllFilieresSimple() {
        log.debug("Fetching all filieres (simple)");

        List<Filiere> filieres = filiereRepository.findAll();
        return filieres.stream()
                .map(filiereMapper::toSimpleResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<FiliereResponseDto> getFilieresByDepartment(UUID departmentId, Pageable pageable) {
        log.debug("Fetching filieres for department ID: {}", departmentId);

        Page<Filiere> filieres = filiereRepository.findByDepartmentId(departmentId, pageable);
        return filieres.map(filiereMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<FiliereResponseDto> getFilieresByDegreeType(DegreeType degreeType, Pageable pageable) {
        log.debug("Fetching filieres with degree type: {}", degreeType);

        Page<Filiere> filieres = filiereRepository.findByDegreeType(degreeType, pageable);
        return filieres.map(filiereMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<FiliereResponseDto> getActiveFilieres(Pageable pageable) {
        log.debug("Fetching active filieres");

        Page<Filiere> filieres = filiereRepository.findByIsActive(true, pageable);
        return filieres.map(filiereMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<FiliereResponseDto> searchFilieres(String searchTerm, Pageable pageable) {
        log.debug("Searching filieres with term: {}", searchTerm);

        Page<Filiere> filieres = filiereRepository.searchFilieres(searchTerm, pageable);
        return filieres.map(filiereMapper::toResponseDto);
    }

    @Override
    @Transactional
    public void deleteFiliere(UUID id) {
        log.debug("Deleting filiere with ID: {}", id);

        Filiere filiere = filiereRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Filiere not found with ID: " + id));

        // Check if filiere has students
        if (filiere.getStudents() != null && !filiere.getStudents().isEmpty()) {
            throw new BadRequestException(
                    "Cannot delete filiere. It has " + filiere.getStudents().size() + " student(s) enrolled."
            );
        }

        // Check if filiere has semesters
        if (filiere.getSemesters() != null && !filiere.getSemesters().isEmpty()) {
            throw new BadRequestException(
                    "Cannot delete filiere. It has " + filiere.getSemesters().size() + " semester(s) configured."
            );
        }

        filiereRepository.delete(filiere);
        log.info("Filiere deleted successfully with ID: {}", id);
    }

    @Override
    @Transactional
    public FiliereResponseDto toggleFiliereStatus(UUID id) {
        log.debug("Toggling status for filiere with ID: {}", id);

        Filiere filiere = filiereRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Filiere not found with ID: " + id));

        filiere.setIsActive(!filiere.getIsActive());
        Filiere updatedFiliere = filiereRepository.save(filiere);

        log.info("Filiere status toggled to {} for ID: {}", updatedFiliere.getIsActive(), id);
        return filiereMapper.toResponseDto(updatedFiliere);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean existsByCode(String code) {
        return filiereRepository.existsByCodeIgnoreCase(code);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean existsByName(String name) {
        return filiereRepository.existsByNameIgnoreCase(name);
    }
}