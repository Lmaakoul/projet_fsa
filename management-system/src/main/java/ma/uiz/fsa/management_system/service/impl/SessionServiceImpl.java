package ma.uiz.fsa.management_system.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.uiz.fsa.management_system.dto.request.SessionRequestDto;
import ma.uiz.fsa.management_system.dto.request.SessionUpdateDto;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.dto.response.SessionResponseDto;
import ma.uiz.fsa.management_system.dto.response.SessionSimpleResponseDto;
import ma.uiz.fsa.management_system.exception.BadRequestException;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.mapper.SessionMapper;
import ma.uiz.fsa.management_system.model.entity.*;
import ma.uiz.fsa.management_system.model.entity.Module;
import ma.uiz.fsa.management_system.model.enums.AttendanceMode;
import ma.uiz.fsa.management_system.model.enums.SessionType;
import ma.uiz.fsa.management_system.repository.*;
import ma.uiz.fsa.management_system.service.QrCodeService;
import ma.uiz.fsa.management_system.service.SessionService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class SessionServiceImpl implements SessionService {

    private final SessionRepository sessionRepository;
    private final ModuleRepository moduleRepository;
    private final ProfessorRepository professorRepository;
    private final GroupRepository groupRepository;
    private final LocationRepository locationRepository;
    private final SessionMapper sessionMapper;
    private final QrCodeService qrCodeService;

    @Value("${attendance.grace-period-minutes:30}")
    private long gracePeriodMinutes;

    @Override
    @Transactional
    public SessionResponseDto createSession(SessionRequestDto requestDto) {
        log.debug("Creating new session for module ID: {} at {}",
                requestDto.getModuleId(), requestDto.getSchedule());

        // Validate schedule is in the future
        if (requestDto.getSchedule().isBefore(LocalDateTime.now())) {
            throw new BadRequestException("Session schedule must be in the future");
        }

        // Validate module exists
        Module module = moduleRepository.findById(requestDto.getModuleId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Module not found with ID: " + requestDto.getModuleId()));

        // Validate professor exists
        Professor professor = professorRepository.findById(requestDto.getProfessorId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Professor not found with ID: " + requestDto.getProfessorId()));

        // Validate location exists and is available
        Location location = locationRepository.findById(requestDto.getLocationId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Location not found with ID: " + requestDto.getLocationId()));

        // Check if location is active
        if (!location.getIsActive()) {
            throw new BadRequestException("Location is not active: " + location.getFullName());
        }

        // Check if location is available for this time slot
        LocalDateTime endTime = requestDto.getSchedule().plusMinutes(requestDto.getDuration());
        boolean isAvailable = locationRepository.isLocationAvailable(
                location.getId(),
                requestDto.getSchedule(),
                endTime
        );

        if (!isAvailable) {
            throw new BadRequestException(
                    "Location " + location.getFullName() + " is not available at " +
                            requestDto.getSchedule() + " for " + requestDto.getDuration() + " minutes"
            );
        }

        // Map DTO to entity
        Session session = sessionMapper.toEntity(requestDto);
        session.setModule(module);
        session.setProfessor(professor);

        // Set default attendance mode if not provided
        if (session.getAttendanceMode() == null) {
            session.setAttendanceMode(AttendanceMode.PROFESSOR_SCAN);
        }

        // Handle groups if provided
        if (requestDto.getGroupIds() != null && !requestDto.getGroupIds().isEmpty()) {
            Set<Group> groups = new HashSet<>(groupRepository.findAllById(requestDto.getGroupIds()));
            if (groups.size() != requestDto.getGroupIds().size()) {
                throw new ResourceNotFoundException("One or more groups not found");
            }

            // Validate location capacity vs total students in groups
            int totalStudents = groups.stream()
                    .mapToInt(group -> group.getStudents().size())
                    .sum();

            if (totalStudents > location.getCapacity()) {
                throw new BadRequestException(
                        "Total students (" + totalStudents + ") exceeds location capacity (" +
                                location.getCapacity() + ") at " + location.getFullName()
                );
            }

            session.setGroups(groups);
        }

        // Save session first to get the ID
        Session savedSession = sessionRepository.save(session);

        // Always generate session QR code on creation
        log.debug("Generating QR code for newly created session {}", savedSession.getId());
        generateSessionQrCodeForNewSession(savedSession);

        log.info("Session created successfully with ID: {} and attendance mode: {}",
                savedSession.getId(), savedSession.getAttendanceMode());

        return sessionMapper.toResponseDto(savedSession);
    }

    /**
     * Generate QR code for a newly created session
     */
    private void generateSessionQrCodeForNewSession(Session session) {
        // Generate QR code content
        String qrCodeContent = String.format("SESSION:%s:%s",
                session.getId(),
                LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)
        );

        // Generate QR code image as Base64
        String qrCodeImageBase64 = qrCodeService.generateQrCodeBase64(qrCodeContent);

        // Set expiry time (session end + grace period)
        LocalDateTime expiryTime = session.getSchedule()
                .plusMinutes(session.getDuration())
                .plusMinutes(gracePeriodMinutes);

        // Update session with QR code data
        session.setQrCode(qrCodeContent);
        session.setQrCodeImage(qrCodeImageBase64);
        session.setQrCodeExpiry(expiryTime);

        // No need to save again, as this is called within the same transaction
        sessionRepository.save(session);

        log.info("QR code generated for session {}. Expires at: {}", session.getId(), expiryTime);
    }

    @Override
    @Transactional
    public SessionResponseDto updateSession(UUID id, SessionUpdateDto requestDto) {
        log.debug("Updating session with ID: {}", id);

        Session session = sessionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with ID: " + id));

        // Prevent updating completed sessions
        if (session.getIsCompleted() && requestDto.getIsCompleted() != null && !requestDto.getIsCompleted()) {
            throw new BadRequestException("Cannot un-complete a session");
        }

        // Prevent updating past sessions unless marking as completed
        if (session.getSchedule().isBefore(LocalDateTime.now()) &&
                requestDto.getSchedule() != null &&
                !session.getIsCompleted()) {
            throw new BadRequestException("Cannot reschedule past sessions");
        }

        sessionMapper.updateEntityFromUpdateDto(requestDto, session);
        Session updatedSession = sessionRepository.save(session);

        log.info("Session updated successfully with ID: {}", updatedSession.getId());
        return sessionMapper.toResponseDto(updatedSession);
    }

    @Override
    @Transactional(readOnly = true)
    public SessionResponseDto getSessionById(UUID id) {
        log.debug("Fetching session with ID: {}", id);

        Session session = sessionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with ID: " + id));

        return sessionMapper.toResponseDto(session);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SessionResponseDto> getAllSessions(Pageable pageable) {
        log.debug("Fetching all sessions with pagination");

        Page<Session> sessions = sessionRepository.findAll(pageable);
        return sessions.map(sessionMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SessionSimpleResponseDto> getAllSessionsSimple() {
        log.debug("Fetching all sessions (simple)");

        List<Session> sessions = sessionRepository.findAll();
        return sessions.stream()
                .map(sessionMapper::toSimpleResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SessionResponseDto> getSessionsByModule(UUID moduleId, Pageable pageable) {
        log.debug("Fetching sessions for module ID: {}", moduleId);

        Page<Session> sessions = sessionRepository.findByModuleId(moduleId, pageable);
        return sessions.map(sessionMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SessionResponseDto> getSessionsByProfessor(UUID professorId, Pageable pageable) {
        log.debug("Fetching sessions for professor ID: {}", professorId);

        Page<Session> sessions = sessionRepository.findByProfessorId(professorId, pageable);
        return sessions.map(sessionMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SessionSimpleResponseDto> getUpcomingSessionsByProfessor(UUID professorId) {
        log.debug("Fetching upcoming sessions for professor ID: {}", professorId);

        List<Session> sessions = sessionRepository.findUpcomingSessionsByProfessorOrderBySchedule(
                professorId, LocalDateTime.now());

        return sessions.stream()
                .map(sessionMapper::toSimpleResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SessionResponseDto> getSessionsByGroup(UUID groupId, Pageable pageable) {
        log.debug("Fetching sessions for group ID: {}", groupId);

        Page<Session> sessions = sessionRepository.findByGroupId(groupId, pageable);
        return sessions.map(sessionMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SessionResponseDto> getSessionsByType(SessionType type, Pageable pageable) {
        log.debug("Fetching sessions of type: {}", type);

        Page<Session> sessions = sessionRepository.findByType(type, pageable);
        return sessions.map(sessionMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SessionResponseDto> getSessionsByDateRange(
            LocalDateTime startDate, LocalDateTime endDate, Pageable pageable) {
        log.debug("Fetching sessions between {} and {}", startDate, endDate);

        if (startDate.isAfter(endDate)) {
            throw new BadRequestException("Start date must be before end date");
        }

        Page<Session> sessions = sessionRepository.findByScheduleBetween(startDate, endDate, pageable);
        return sessions.map(sessionMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SessionResponseDto> getCompletedSessions(Pageable pageable) {
        log.debug("Fetching completed sessions");

        Page<Session> sessions = sessionRepository.findByIsCompleted(true, pageable);
        return sessions.map(sessionMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SessionResponseDto> getIncompleteSessions(Pageable pageable) {
        log.debug("Fetching incomplete sessions");

        Page<Session> sessions = sessionRepository.findByIsCompleted(false, pageable);
        return sessions.map(sessionMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SessionResponseDto> getUpcomingSessions(Pageable pageable) {
        log.debug("Fetching upcoming sessions");

        Page<Session> sessions = sessionRepository.findUpcomingSessions(LocalDateTime.now(), pageable);
        return sessions.map(sessionMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SessionResponseDto> searchSessions(String searchTerm, Pageable pageable) {
        log.debug("Searching sessions with term: {}", searchTerm);

        Page<Session> sessions = sessionRepository.searchSessions(searchTerm, pageable);
        return sessions.map(sessionMapper::toResponseDto);
    }

    @Override
    @Transactional
    public SessionResponseDto markSessionAsCompleted(UUID id) {
        log.debug("Marking session as completed: {}", id);

        Session session = sessionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with ID: " + id));

        if (session.getIsCompleted()) {
            throw new BadRequestException("Session is already marked as completed");
        }

        // Check if session is in the past or currently happening
        if (session.getSchedule().isAfter(LocalDateTime.now())) {
            throw new BadRequestException("Cannot complete a future session");
        }

        session.setIsCompleted(true);
        Session updatedSession = sessionRepository.save(session);

        log.info("Session marked as completed: {}", id);
        return sessionMapper.toResponseDto(updatedSession);
    }

    @Override
    @Transactional
    public SessionResponseDto markAttendanceTaken(UUID id) {
        log.debug("Marking attendance as taken for session: {}", id);

        Session session = sessionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with ID: " + id));

        if (session.getAttendanceTaken()) {
            throw new BadRequestException("Attendance has already been taken for this session");
        }

        session.setAttendanceTaken(true);
        Session updatedSession = sessionRepository.save(session);

        log.info("Attendance marked as taken for session: {}", id);
        return sessionMapper.toResponseDto(updatedSession);
    }

    @Override
    @Transactional
    public MessageResponse addGroupsToSession(UUID sessionId, List<UUID> groupIds) {
        log.debug("Adding groups to session ID: {}", sessionId);

        Session session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with ID: " + sessionId));

        if (session.getIsCompleted()) {
            throw new BadRequestException("Cannot modify groups for a completed session");
        }

        Set<Group> currentGroups = session.getGroups();
        if (currentGroups == null) {
            currentGroups = new HashSet<>();
        }

        for (UUID groupId : groupIds) {
            Group group = groupRepository.findById(groupId)
                    .orElseThrow(() -> new ResourceNotFoundException("Group not found with ID: " + groupId));
            currentGroups.add(group);
        }

        session.setGroups(currentGroups);
        sessionRepository.save(session);

        log.info("Groups added successfully to session ID: {}", sessionId);
        return new MessageResponse("Groups added to session successfully", true);
    }

    @Override
    @Transactional
    public MessageResponse removeGroupFromSession(UUID sessionId, UUID groupId) {
        log.debug("Removing group ID: {} from session ID: {}", groupId, sessionId);

        Session session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with ID: " + sessionId));

        if (session.getIsCompleted()) {
            throw new BadRequestException("Cannot modify groups for a completed session");
        }

        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new ResourceNotFoundException("Group not found with ID: " + groupId));

        if (!session.getGroups().contains(group)) {
            throw new BadRequestException("Group is not assigned to this session");
        }

        session.getGroups().remove(group);
        sessionRepository.save(session);

        log.info("Group removed successfully from session ID: {}", sessionId);
        return new MessageResponse("Group removed from session successfully", true);
    }

    @Override
    @Transactional
    public void deleteSession(UUID id) {
        log.debug("Deleting session with ID: {}", id);

        Session session = sessionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with ID: " + id));

        // Check if session has attendance records
        if (session.getAttendanceRecords() != null && !session.getAttendanceRecords().isEmpty()) {
            throw new BadRequestException(
                    "Cannot delete session. It has " + session.getAttendanceRecords().size() +
                            " attendance record(s) associated with it."
            );
        }

        // Prevent deleting past sessions
        if (session.getSchedule().isBefore(LocalDateTime.now()) && session.getIsCompleted()) {
            throw new BadRequestException("Cannot delete a completed past session");
        }

        sessionRepository.delete(session);
        log.info("Session deleted successfully with ID: {}", id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SessionSimpleResponseDto> getSessionsForToday(UUID professorId) {
        log.debug("Fetching today's sessions for professor ID: {}", professorId);

        LocalDateTime startOfDay = LocalDateTime.of(LocalDate.now(), LocalTime.MIN);
        LocalDateTime endOfDay = LocalDateTime.of(LocalDate.now(), LocalTime.MAX);

        List<Session> sessions = sessionRepository.findByModuleIdAndScheduleBetween(
                professorId, startOfDay, endOfDay);

        return sessions.stream()
                .map(sessionMapper::toSimpleResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public SessionResponseDto setAttendanceMode(UUID sessionId, AttendanceMode mode) {
        log.debug("Setting attendance mode for session {} to {}", sessionId, mode);

        Session session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with ID: " + sessionId));

        // Validate that session is not completed
        if (session.getIsCompleted()) {
            throw new BadRequestException("Cannot change attendance mode for completed sessions");
        }

        // Validate that attendance has not been taken yet
        if (session.getAttendanceTaken() && mode != session.getAttendanceMode()) {
            log.warn("Changing attendance mode after attendance has been taken for session {}", sessionId);
        }

        // Set the new mode
        session.setAttendanceMode(mode);

        // If switching to STUDENT_SCAN mode, generate QR code if not exists
        if (mode == AttendanceMode.STUDENT_SCAN) {
            if (session.getQrCode() == null || !session.isQrCodeValid()) {
                log.info("Generating QR code for session {} as mode is set to STUDENT_SCAN", sessionId);
                generateSessionQrCodeInternal(session);
            }
        }

        // If switching away from STUDENT_SCAN, optionally deactivate QR code
        if (mode != AttendanceMode.STUDENT_SCAN && session.getQrCode() != null) {
            log.info("Deactivating QR code for session {} as mode changed from STUDENT_SCAN", sessionId);
            session.setQrCodeExpiry(LocalDateTime.now().minusMinutes(1)); // Expire immediately
        }

        Session savedSession = sessionRepository.save(session);
        log.info("Attendance mode set to {} for session {}", mode, sessionId);

        return sessionMapper.toResponseDto(savedSession);
    }

    @Override
    @Transactional
    public String generateSessionQrCode(UUID sessionId) {
        log.debug("Generating QR code for session: {}", sessionId);

        Session session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with ID: " + sessionId));

        return generateSessionQrCodeInternal(session);
    }

    @Override
    @Transactional
    public String regenerateSessionQrCode(UUID sessionId) {
        log.debug("Regenerating QR code for session: {}", sessionId);

        Session session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with ID: " + sessionId));

        // Generate new QR code with new timestamp
        String qrCodeContent = String.format("SESSION:%s:%s",
                session.getId(),
                LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)
        );

        String qrCodeImageBase64 = qrCodeService.generateQrCodeBase64(qrCodeContent);

        session.setQrCode(qrCodeContent);
        session.setQrCodeImage(qrCodeImageBase64);

        sessionRepository.save(session);

        log.info("QR code regenerated for session {}", sessionId);
        return qrCodeContent;
    }

    @Override
    @Transactional
    public void activateSessionQrCode(UUID sessionId, Integer validityMinutes) {
        log.debug("Activating QR code for session: {} with validity {} minutes", sessionId, validityMinutes);

        Session session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with ID: " + sessionId));

        if (session.getQrCode() == null) {
            // Generate QR code if it doesn't exist
            generateSessionQrCodeInternal(session);
        }

        // Set or extend expiry
        LocalDateTime newExpiry = LocalDateTime.now().plusMinutes(validityMinutes);
        session.setQrCodeExpiry(newExpiry);
        session.setAttendanceMode(AttendanceMode.STUDENT_SCAN);

        sessionRepository.save(session);

        log.info("QR code activated for session {}. Valid until: {}", sessionId, newExpiry);
    }

    @Override
    @Transactional
    public void deactivateSessionQrCode(UUID sessionId) {
        log.debug("Deactivating QR code for session: {}", sessionId);

        Session session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with ID: " + sessionId));

        // Expire QR code immediately
        if (session.getQrCode() != null) {
            session.setQrCodeExpiry(LocalDateTime.now().minusMinutes(1));
            sessionRepository.save(session);
            log.info("QR code deactivated for session {}", sessionId);
        } else {
            log.warn("No QR code to deactivate for session {}", sessionId);
        }
    }

    /**
     * Internal method to generate QR code for a session
     * @param session The session entity
     * @return The generated QR code content
     */
    private String generateSessionQrCodeInternal(Session session) {
        // Generate QR code content with timestamp for uniqueness
        String qrCodeContent = String.format("SESSION:%s:%s",
                session.getId(),
                LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)
        );

        // Generate QR code image as Base64
        String qrCodeImageBase64 = qrCodeService.generateQrCodeBase64(qrCodeContent);

        // Set expiry time (session end + grace period)
        LocalDateTime expiryTime = session.getSchedule()
                .plusMinutes(session.getDuration())
                .plusMinutes(gracePeriodMinutes);

        // Save to session
        session.setQrCode(qrCodeContent);
        session.setQrCodeImage(qrCodeImageBase64);
        session.setQrCodeExpiry(expiryTime);

        sessionRepository.save(session);

        log.info("QR code generated for session {}. Expires at: {}", session.getId(), expiryTime);
        return qrCodeContent;
    }
}