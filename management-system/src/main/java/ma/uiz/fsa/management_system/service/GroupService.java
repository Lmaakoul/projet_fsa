package ma.uiz.fsa.management_system.service;

import ma.uiz.fsa.management_system.dto.request.EnrollStudentsDto;
import ma.uiz.fsa.management_system.dto.request.GroupRequestDto;
import ma.uiz.fsa.management_system.dto.request.GroupUpdateDto;
import ma.uiz.fsa.management_system.dto.response.GroupResponseDto;
import ma.uiz.fsa.management_system.dto.response.GroupSimpleResponseDto;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface GroupService {

    GroupResponseDto createGroup(GroupRequestDto requestDto);

    GroupResponseDto updateGroup(UUID id, GroupUpdateDto requestDto);

    GroupResponseDto getGroupById(UUID id);

    GroupResponseDto getGroupByCode(String code);

    Page<GroupResponseDto> getAllGroups(Pageable pageable);

    List<GroupSimpleResponseDto> getAllGroupsSimple();

    Page<GroupResponseDto> getGroupsByModule(UUID moduleId, Pageable pageable);

    List<GroupSimpleResponseDto> getActiveGroupsByModule(UUID moduleId);

    Page<GroupResponseDto> getGroupsByStudent(UUID studentId, Pageable pageable);

    Page<GroupResponseDto> getGroupsBySemester(UUID semesterId, Pageable pageable);

    Page<GroupResponseDto> getActiveGroups(Pageable pageable);

    Page<GroupResponseDto> getAvailableGroups(Pageable pageable);

    List<GroupSimpleResponseDto> getAvailableGroupsByModule(UUID moduleId);

    Page<GroupResponseDto> getFullGroups(Pageable pageable);

    Page<GroupResponseDto> searchGroups(String searchTerm, Pageable pageable);

    GroupResponseDto enrollStudents(UUID groupId, EnrollStudentsDto enrollDto);

    MessageResponse removeStudentFromGroup(UUID groupId, UUID studentId);

    GroupResponseDto toggleGroupStatus(UUID id);

    void deleteGroup(UUID id);

    boolean existsByCode(String code);

    boolean isGroupFull(UUID id);
}