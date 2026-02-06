package ma.uiz.fsa.management_system.service;

import ma.uiz.fsa.management_system.dto.request.SessionRequestDto;
import ma.uiz.fsa.management_system.dto.request.SessionUpdateDto;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.dto.response.SessionResponseDto;
import ma.uiz.fsa.management_system.dto.response.SessionSimpleResponseDto;
import ma.uiz.fsa.management_system.model.enums.AttendanceMode;
import ma.uiz.fsa.management_system.model.enums.SessionType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface SessionService {

    SessionResponseDto createSession(SessionRequestDto requestDto);

    SessionResponseDto updateSession(UUID id, SessionUpdateDto requestDto);

    SessionResponseDto getSessionById(UUID id);

    Page<SessionResponseDto> getAllSessions(Pageable pageable);

    List<SessionSimpleResponseDto> getAllSessionsSimple();

    Page<SessionResponseDto> getSessionsByModule(UUID moduleId, Pageable pageable);

    Page<SessionResponseDto> getSessionsByProfessor(UUID professorId, Pageable pageable);

    List<SessionSimpleResponseDto> getUpcomingSessionsByProfessor(UUID professorId);

    Page<SessionResponseDto> getSessionsByGroup(UUID groupId, Pageable pageable);

    Page<SessionResponseDto> getSessionsByType(SessionType type, Pageable pageable);

    Page<SessionResponseDto> getSessionsByDateRange(LocalDateTime startDate, LocalDateTime endDate, Pageable pageable);

    Page<SessionResponseDto> getCompletedSessions(Pageable pageable);

    Page<SessionResponseDto> getIncompleteSessions(Pageable pageable);

    Page<SessionResponseDto> getUpcomingSessions(Pageable pageable);

    Page<SessionResponseDto> searchSessions(String searchTerm, Pageable pageable);

    SessionResponseDto markSessionAsCompleted(UUID id);

    SessionResponseDto markAttendanceTaken(UUID id);

    MessageResponse addGroupsToSession(UUID sessionId, List<UUID> groupIds);

    MessageResponse removeGroupFromSession(UUID sessionId, UUID groupId);

    void deleteSession(UUID id);

    List<SessionSimpleResponseDto> getSessionsForToday(UUID professorId);

    String generateSessionQrCode(UUID sessionId);

    String regenerateSessionQrCode(UUID sessionId);

    void activateSessionQrCode(UUID sessionId, Integer validityMinutes);

    void deactivateSessionQrCode(UUID sessionId);

    SessionResponseDto setAttendanceMode(UUID sessionId, AttendanceMode mode);
}