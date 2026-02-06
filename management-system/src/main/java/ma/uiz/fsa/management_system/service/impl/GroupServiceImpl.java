package ma.uiz.fsa.management_system.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.uiz.fsa.management_system.dto.request.EnrollStudentsDto;
import ma.uiz.fsa.management_system.dto.request.GroupRequestDto;
import ma.uiz.fsa.management_system.dto.request.GroupUpdateDto;
import ma.uiz.fsa.management_system.dto.response.GroupResponseDto;
import ma.uiz.fsa.management_system.dto.response.GroupSimpleResponseDto;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.exception.BadRequestException;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.mapper.GroupMapper;
import ma.uiz.fsa.management_system.model.entity.Group;
import ma.uiz.fsa.management_system.model.entity.Student;
import ma.uiz.fsa.management_system.repository.GroupRepository;
import ma.uiz.fsa.management_system.repository.StudentRepository;
import ma.uiz.fsa.management_system.service.GroupService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class GroupServiceImpl implements GroupService {

    private final GroupRepository groupRepository;
    private final StudentRepository studentRepository;
    private final GroupMapper groupMapper;

    @Override
    @Transactional
    public GroupResponseDto createGroup(GroupRequestDto requestDto) {
        log.debug("Creating new group with code: {}", requestDto.getCode());

        // Validate unique code
        if (groupRepository.existsByCodeIgnoreCase(requestDto.getCode())) {
            throw new BadRequestException("Group with code '" + requestDto.getCode() + "' already exists");
        }

        // Validate student count doesn't exceed capacity
        if (requestDto.getStudentIds() != null &&
                requestDto.getStudentIds().size() > requestDto.getMaxCapacity()) {
            throw new BadRequestException(
                    "Number of students (" + requestDto.getStudentIds().size() +
                            ") exceeds max capacity (" + requestDto.getMaxCapacity() + ")"
            );
        }

        Group group = groupMapper.toEntity(requestDto);
        Group savedGroup = groupRepository.save(group);

        log.info("Group created successfully with ID: {}", savedGroup.getId());
        return groupMapper.toResponseDto(savedGroup);
    }

    @Override
    @Transactional
    public GroupResponseDto updateGroup(UUID id, GroupUpdateDto requestDto) {
        log.debug("Updating group with ID: {}", id);

        Group group = groupRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Group not found with ID: " + id));

        // Validate unique code (if changed)
        if (requestDto.getCode() != null &&
                !group.getCode().equalsIgnoreCase(requestDto.getCode()) &&
                groupRepository.existsByCodeIgnoreCase(requestDto.getCode())) {
            throw new BadRequestException("Group with code '" + requestDto.getCode() + "' already exists");
        }

        // Validate capacity change doesn't conflict with current enrollment
        if (requestDto.getMaxCapacity() != null) {
            int currentStudentCount = group.getStudents() != null ? group.getStudents().size() : 0;
            if (requestDto.getMaxCapacity() < currentStudentCount) {
                throw new BadRequestException(
                        "Cannot set max capacity to " + requestDto.getMaxCapacity() +
                                " when " + currentStudentCount + " students are already enrolled"
                );
            }
        }

        groupMapper.updateEntityFromUpdateDto(requestDto, group);
        Group updatedGroup = groupRepository.save(group);

        log.info("Group updated successfully with ID: {}", updatedGroup.getId());
        return groupMapper.toResponseDto(updatedGroup);
    }

    @Override
    @Transactional(readOnly = true)
    public GroupResponseDto getGroupById(UUID id) {
        log.debug("Fetching group with ID: {}", id);

        Group group = groupRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Group not found with ID: " + id));

        return groupMapper.toResponseDto(group);
    }

    @Override
    @Transactional(readOnly = true)
    public GroupResponseDto getGroupByCode(String code) {
        log.debug("Fetching group with code: {}", code);

        Group group = groupRepository.findByCodeIgnoreCase(code)
                .orElseThrow(() -> new ResourceNotFoundException("Group not found with code: " + code));

        return groupMapper.toResponseDto(group);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<GroupResponseDto> getAllGroups(Pageable pageable) {
        log.debug("Fetching all groups with pagination");

        Page<Group> groups = groupRepository.findAll(pageable);
        return groups.map(groupMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<GroupSimpleResponseDto> getAllGroupsSimple() {
        log.debug("Fetching all groups (simple)");

        List<Group> groups = groupRepository.findAll();
        return groups.stream()
                .map(groupMapper::toSimpleResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<GroupResponseDto> getGroupsByModule(UUID moduleId, Pageable pageable) {
        log.debug("Fetching groups for module ID: {}", moduleId);

        Page<Group> groups = groupRepository.findByModuleId(moduleId, pageable);
        return groups.map(groupMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<GroupSimpleResponseDto> getActiveGroupsByModule(UUID moduleId) {
        log.debug("Fetching active groups for module ID: {}", moduleId);

        List<Group> groups = groupRepository.findActiveGroupsByModule(moduleId);
        return groups.stream()
                .map(groupMapper::toSimpleResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<GroupResponseDto> getGroupsByStudent(UUID studentId, Pageable pageable) {
        log.debug("Fetching groups for student ID: {}", studentId);

        Page<Group> groups = groupRepository.findByStudentId(studentId, pageable);
        return groups.map(groupMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<GroupResponseDto> getGroupsBySemester(UUID semesterId, Pageable pageable) {
        log.debug("Fetching groups for semester ID: {}", semesterId);

        Page<Group> groups = groupRepository.findBySemesterId(semesterId, pageable);
        return groups.map(groupMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<GroupResponseDto> getActiveGroups(Pageable pageable) {
        log.debug("Fetching active groups");

        Page<Group> groups = groupRepository.findByIsActive(true, pageable);
        return groups.map(groupMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<GroupResponseDto> getAvailableGroups(Pageable pageable) {
        log.debug("Fetching available groups (not full)");

        Page<Group> groups = groupRepository.findAvailableGroups(pageable);
        return groups.map(groupMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<GroupSimpleResponseDto> getAvailableGroupsByModule(UUID moduleId) {
        log.debug("Fetching available groups for module ID: {}", moduleId);

        List<Group> groups = groupRepository.findAvailableGroupsByModule(moduleId);
        return groups.stream()
                .map(groupMapper::toSimpleResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<GroupResponseDto> getFullGroups(Pageable pageable) {
        log.debug("Fetching full groups");

        Page<Group> groups = groupRepository.findFullGroups(pageable);
        return groups.map(groupMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<GroupResponseDto> searchGroups(String searchTerm, Pageable pageable) {
        log.debug("Searching groups with term: {}", searchTerm);

        Page<Group> groups = groupRepository.searchGroups(searchTerm, pageable);
        return groups.map(groupMapper::toResponseDto);
    }

    @Override
    @Transactional
    public GroupResponseDto enrollStudents(UUID groupId, EnrollStudentsDto enrollDto) {
        log.debug("Enrolling students to group ID: {}", groupId);

        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new ResourceNotFoundException("Group not found with ID: " + groupId));

        if (!group.getIsActive()) {
            throw new BadRequestException("Cannot enroll students in an inactive group");
        }

        Set<Student> currentStudents = group.getStudents();
        if (currentStudents == null) {
            currentStudents = new HashSet<>();
        }

        // Check capacity
        int newTotalCount = currentStudents.size() + enrollDto.getStudentIds().size();
        if (newTotalCount > group.getMaxCapacity()) {
            throw new BadRequestException(
                    "Cannot enroll " + enrollDto.getStudentIds().size() + " students. " +
                            "Group capacity: " + group.getMaxCapacity() + ", " +
                            "Current enrollment: " + currentStudents.size() + ", " +
                            "Available slots: " + (group.getMaxCapacity() - currentStudents.size())
            );
        }

        for (UUID studentId : enrollDto.getStudentIds()) {
            Student student = studentRepository.findById(studentId)
                    .orElseThrow(() -> new ResourceNotFoundException("Student not found with ID: " + studentId));

            if (currentStudents.contains(student)) {
                log.warn("Student ID {} is already enrolled in group ID {}", studentId, groupId);
                continue;
            }

            currentStudents.add(student);
        }

        group.setStudents(currentStudents);
        Group updatedGroup = groupRepository.save(group);

        log.info("Students enrolled successfully to group ID: {}", groupId);
        return groupMapper.toResponseDto(updatedGroup);
    }

    @Override
    @Transactional
    public MessageResponse removeStudentFromGroup(UUID groupId, UUID studentId) {
        log.debug("Removing student ID: {} from group ID: {}", studentId, groupId);

        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new ResourceNotFoundException("Group not found with ID: " + groupId));

        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with ID: " + studentId));

        if (!group.getStudents().contains(student)) {
            throw new BadRequestException("Student is not enrolled in this group");
        }

        group.getStudents().remove(student);
        groupRepository.save(group);

        log.info("Student removed successfully from group ID: {}", groupId);
        return new MessageResponse("Student removed from group successfully", true);
    }

    @Override
    @Transactional
    public GroupResponseDto toggleGroupStatus(UUID id) {
        log.debug("Toggling status for group with ID: {}", id);

        Group group = groupRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Group not found with ID: " + id));

        group.setIsActive(!group.getIsActive());
        Group updatedGroup = groupRepository.save(group);

        log.info("Group status toggled to {} for ID: {}", updatedGroup.getIsActive(), id);
        return groupMapper.toResponseDto(updatedGroup);
    }

    @Override
    @Transactional
    public void deleteGroup(UUID id) {
        log.debug("Deleting group with ID: {}", id);

        Group group = groupRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Group not found with ID: " + id));

        // Check if group has students
        if (group.getStudents() != null && !group.getStudents().isEmpty()) {
            throw new BadRequestException(
                    "Cannot delete group. It has " + group.getStudents().size() + " student(s) enrolled."
            );
        }

        // Check if group has sessions
        if (group.getSessions() != null && !group.getSessions().isEmpty()) {
            throw new BadRequestException(
                    "Cannot delete group. It has " + group.getSessions().size() + " session(s) associated with it."
            );
        }

        groupRepository.delete(group);
        log.info("Group deleted successfully with ID: {}", id);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean existsByCode(String code) {
        return groupRepository.existsByCodeIgnoreCase(code);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isGroupFull(UUID id) {
        Group group = groupRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Group not found with ID: " + id));

        int currentStudentCount = group.getStudents() != null ? group.getStudents().size() : 0;
        return currentStudentCount >= group.getMaxCapacity();
    }
}