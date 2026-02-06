package ma.uiz.fsa.management_system.service;

import ma.uiz.fsa.management_system.dto.request.FiliereRequestDto;
import ma.uiz.fsa.management_system.dto.response.FiliereResponseDto;
import ma.uiz.fsa.management_system.dto.response.FiliereSimpleResponseDto;
import ma.uiz.fsa.management_system.model.enums.DegreeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface FiliereService {

    FiliereResponseDto createFiliere(FiliereRequestDto requestDto);

    FiliereResponseDto updateFiliere(UUID id, FiliereRequestDto requestDto);

    FiliereResponseDto getFiliereById(UUID id);

    FiliereResponseDto getFiliereByCode(String code);

    Page<FiliereResponseDto> getAllFilieres(Pageable pageable);

    List<FiliereSimpleResponseDto> getAllFilieresSimple();

    Page<FiliereResponseDto> getFilieresByDepartment(UUID departmentId, Pageable pageable);

    Page<FiliereResponseDto> getFilieresByDegreeType(DegreeType degreeType, Pageable pageable);

    Page<FiliereResponseDto> getActiveFilieres(Pageable pageable);

    Page<FiliereResponseDto> searchFilieres(String searchTerm, Pageable pageable);

    void deleteFiliere(UUID id);

    FiliereResponseDto toggleFiliereStatus(UUID id);

    boolean existsByCode(String code);

    boolean existsByName(String name);
}