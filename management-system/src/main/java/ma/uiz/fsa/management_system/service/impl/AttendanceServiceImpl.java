package ma.uiz.fsa.management_system.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.uiz.fsa.management_system.dto.request.*;
import ma.uiz.fsa.management_system.dto.response.AttendanceRecordResponseDto;
import ma.uiz.fsa.management_system.dto.response.AttendanceRecordSimpleResponseDto;
import ma.uiz.fsa.management_system.dto.response.AttendanceStatisticsDto;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.exception.BadRequestException;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.mapper.AttendanceRecordMapper;
import ma.uiz.fsa.management_system.model.entity.AttendanceRecord;
import ma.uiz.fsa.management_system.model.entity.Module;
import ma.uiz.fsa.management_system.model.entity.Session;
import ma.uiz.fsa.management_system.model.entity.Student;
import ma.uiz.fsa.management_system.model.enums.AttendanceMode;
import ma.uiz.fsa.management_system.model.enums.AttendanceStatus;
import ma.uiz.fsa.management_system.repository.AttendanceRecordRepository;
import ma.uiz.fsa.management_system.repository.ModuleRepository;
import ma.uiz.fsa.management_system.repository.SessionRepository;
import ma.uiz.fsa.management_system.repository.StudentRepository;
import ma.uiz.fsa.management_system.service.AttendanceService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AttendanceServiceImpl implements AttendanceService {

    private final AttendanceRecordRepository attendanceRecordRepository;
    private final StudentRepository studentRepository;
    private final SessionRepository sessionRepository;
    private final ModuleRepository moduleRepository;
    private final AttendanceRecordMapper attendanceRecordMapper;

    // Configuration: How long after session ends can attendance be taken (in minutes)
    private static final long ATTENDANCE_GRACE_PERIOD_MINUTES = 30;

    // Configuration: How early before session can attendance be taken (in minutes)
    private static final long ATTENDANCE_EARLY_PERIOD_MINUTES = 15;

    @Override
    @Transactional
    public AttendanceRecordResponseDto recordAttendance(AttendanceRecordRequestDto requestDto) {
        log.debug("Recording attendance for student ID: {} and session ID: {}",
                requestDto.getStudentId(), requestDto.getSessionId());

        // Check if attendance already exists
        if (attendanceRecordRepository.existsByStudentIdAndSessionId(
                requestDto.getStudentId(), requestDto.getSessionId())) {
            throw new BadRequestException("Attendance already recorded for this student and session");
        }

        // Validate session exists and is not completed
        Session session = sessionRepository.findById(requestDto.getSessionId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Session not found with ID: " + requestDto.getSessionId()));

        if (session.getIsCompleted()) {
            throw new BadRequestException("Cannot record attendance for a completed session");
        }

        AttendanceRecord attendance = attendanceRecordMapper.toEntity(requestDto);
        AttendanceRecord savedAttendance = attendanceRecordRepository.save(attendance);

        log.info("Attendance recorded successfully with ID: {}", savedAttendance.getId());
        return attendanceRecordMapper.toResponseDto(savedAttendance);
    }

    @Override
    @Transactional
    public AttendanceRecordResponseDto markAttendanceByCne(AttendanceByCneRequestDto requestDto) {
        log.debug("Marking attendance by CNE: {} for session ID: {}",
                requestDto.getCne(), requestDto.getSessionId());

        // 1. Find student by CNE
        Student student = studentRepository.findByCne(requestDto.getCne())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Student not found with CNE: " + requestDto.getCne()));

        // 2. Validate session exists
        Session session = sessionRepository.findById(requestDto.getSessionId())
                .orElseThrow(() -> new ResourceNotFoundException("Session not found"));

        // 3. VALIDATE SESSION TIMING
        validateSessionTiming(session);

        // 4. VALIDATE SESSION STATUS
        validateSessionStatus(session);

        // 5. Check if student is enrolled in session's groups
        validateStudentEnrollment(student, session);

        // 6. Check for duplicate attendance
        Optional<AttendanceRecord> existingRecord = attendanceRecordRepository
                .findByStudentIdAndSessionId(student.getId(), session.getId());

        if (existingRecord.isPresent()) {
            throw new BadRequestException(
                    "Attendance already recorded for this student in this session. Status: "
                            + existingRecord.get().getStatus()
            );
        }

        // 7. Determine attendance status based on timing
        AttendanceStatus status = determineAttendanceStatus(session, LocalDateTime.now());

        // 8. Create attendance record
        AttendanceRecord attendanceRecord = AttendanceRecord.builder()
                .student(student)
                .session(session)
                .date(LocalDate.now())
                .status(status)
                .scannedAt(LocalDateTime.now())
                .deviceInfo(requestDto.getDeviceInfo())
                .ipAddress(requestDto.getIpAddress())
                .isJustified(false)
                .markedBy("PROFESSOR")
                .build();

        AttendanceRecord savedRecord = attendanceRecordRepository.save(attendanceRecord);

        log.info("Attendance recorded for student {} in session {} with status: {}",
                student.getCne(), session.getId(), status);

        return attendanceRecordMapper.toResponseDto(savedRecord);
    }

    @Override
    @Transactional
    public AttendanceRecordResponseDto scanQrCode(ScanQrRequestDto requestDto) {
        log.debug("Scanning QR code for session: {}", requestDto.getSessionId());

        // 1. Parse and validate QR code format
        String[] qrParts = requestDto.getStudentQrCode().split(":");
        if (qrParts.length != 3 || !"STUDENT".equals(qrParts[0])) {
            throw new BadRequestException("Invalid QR code format");
        }

        UUID studentId;
        String cne;
        try {
            studentId = UUID.fromString(qrParts[1]);
            cne = qrParts[2];
        } catch (IllegalArgumentException e) {
            throw new BadRequestException("Invalid QR code data");
        }

        // 2. Validate student exists
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found"));

        // Verify CNE matches
        if (!student.getCne().equals(cne)) {
            throw new BadRequestException("QR code data mismatch");
        }

        // 3. Validate session exists
        Session session = sessionRepository.findById(requestDto.getSessionId())
                .orElseThrow(() -> new ResourceNotFoundException("Session not found"));

        // 4. VALIDATE SESSION TIMING
        validateSessionTiming(session);

        // 5. VALIDATE SESSION STATUS
        validateSessionStatus(session);

        // 6. Check if student is enrolled in session's groups
        validateStudentEnrollment(student, session);

        // 7. Check for duplicate attendance
        Optional<AttendanceRecord> existingRecord = attendanceRecordRepository
                .findByStudentIdAndSessionId(student.getId(), session.getId());

        if (existingRecord.isPresent()) {
            throw new BadRequestException(
                    "Attendance already recorded for this student in this session. Status: "
                            + existingRecord.get().getStatus()
            );
        }

        // 8. Determine attendance status based on timing
        AttendanceStatus status = determineAttendanceStatus(session, LocalDateTime.now());

        // 9. Create attendance record
        AttendanceRecord attendanceRecord = AttendanceRecord.builder()
                .student(student)
                .session(session)
                .date(LocalDate.now())
                .status(status)
                .scannedAt(LocalDateTime.now())
                .deviceInfo(requestDto.getDeviceInfo())
                .ipAddress(requestDto.getIpAddress())
                .isJustified(false)
                .markedBy("PROFESSOR")
                .build();

        AttendanceRecord savedRecord = attendanceRecordRepository.save(attendanceRecord);

        log.info("Attendance recorded for student {} in session {} with status: {}",
                student.getCne(), session.getId(), status);

        return attendanceRecordMapper.toResponseDto(savedRecord);
    }

    /**
     * Validates that the session timing is appropriate for taking attendance
     */
    private void validateSessionTiming(Session session) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime sessionStart = session.getSchedule();
        LocalDateTime sessionEnd = sessionStart.plusMinutes(session.getDuration());
        LocalDateTime allowedStartTime = sessionStart.minusMinutes(ATTENDANCE_EARLY_PERIOD_MINUTES);
        LocalDateTime allowedEndTime = sessionEnd.plusMinutes(ATTENDANCE_GRACE_PERIOD_MINUTES);

        // Check if session is too far in the future
        if (now.isBefore(allowedStartTime)) {
            long hoursUntil = ChronoUnit.HOURS.between(now, sessionStart);
            long minutesUntil = ChronoUnit.MINUTES.between(now, sessionStart) % 60;

            throw new BadRequestException(
                    String.format("Cannot take attendance for future sessions. " +
                                    "This session starts in %d hours and %d minutes (at %s). " +
                                    "Attendance can be taken starting %d minutes before the session.",
                            hoursUntil, minutesUntil,
                            sessionStart.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")),
                            ATTENDANCE_EARLY_PERIOD_MINUTES)
            );
        }

        // Check if session ended too long ago
        if (now.isAfter(allowedEndTime)) {
            long hoursAgo = ChronoUnit.HOURS.between(sessionEnd, now);
            long minutesAgo = ChronoUnit.MINUTES.between(sessionEnd, now) % 60;

            throw new BadRequestException(
                    String.format("Cannot take attendance for old sessions. " +
                                    "This session ended %d hours and %d minutes ago (at %s). " +
                                    "Attendance window closed %d minutes after session end.",
                            hoursAgo, minutesAgo,
                            sessionEnd.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")),
                            ATTENDANCE_GRACE_PERIOD_MINUTES)
            );
        }

        log.debug("Session timing validated. Session: {}, Now: {}, Allowed window: {} to {}",
                sessionStart, now, allowedStartTime, allowedEndTime);
    }

    /**
     * Validates that the session status allows attendance recording
     */
    private void validateSessionStatus(Session session) {
        if (session.getIsCompleted()) {
            throw new BadRequestException(
                    "Cannot take attendance for completed sessions. " +
                            "This session was marked as completed on " +
                            session.getUpdatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"))
            );
        }

        if (session.getAttendanceTaken()) {
            log.warn("Attendance already taken for session {}, but allowing QR scans", session.getId());
            // Note: We log but don't block, as professor might still be accepting late arrivals
        }
    }

    /**
     * Validates that the student is enrolled in at least one of the session's groups
     */
    private void validateStudentEnrollment(Student student, Session session) {
        boolean isEnrolled = session.getGroups().stream()
                .anyMatch(group -> group.getStudents().contains(student));

        if (!isEnrolled) {
            throw new BadRequestException(
                    "Student is not enrolled in any group assigned to this session"
            );
        }
    }

    /**
     * Determines attendance status based on scan time relative to session schedule
     */
    private AttendanceStatus determineAttendanceStatus(Session session, LocalDateTime scanTime) {
        LocalDateTime sessionStart = session.getSchedule();
        LocalDateTime lateThreshold = sessionStart.plusMinutes(15); // 15 minutes late threshold

        if (scanTime.isBefore(lateThreshold) || scanTime.isEqual(lateThreshold)) {
            return AttendanceStatus.PRESENT;
        } else {
            return AttendanceStatus.LATE;
        }
    }

    @Override
    @Transactional
    public MessageResponse recordBulkAttendance(BulkAttendanceDto bulkDto) {
        log.debug("Recording bulk attendance for session ID: {}", bulkDto.getSessionId());

        Session session = sessionRepository.findById(bulkDto.getSessionId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Session not found with ID: " + bulkDto.getSessionId()));

        if (session.getIsCompleted()) {
            throw new BadRequestException("Cannot record attendance for a completed session");
        }

        int recordedCount = 0;
        int skippedCount = 0;

        for (UUID studentId : bulkDto.getStudentIds()) {
            // Check if attendance already exists
            if (attendanceRecordRepository.existsByStudentIdAndSessionId(studentId, bulkDto.getSessionId())) {
                skippedCount++;
                log.warn("Attendance already exists for student ID: {} and session ID: {}",
                        studentId, bulkDto.getSessionId());
                continue;
            }

            Student student = studentRepository.findById(studentId)
                    .orElseThrow(() -> new ResourceNotFoundException("Student not found with ID: " + studentId));

            AttendanceRecord attendance = AttendanceRecord.builder()
                    .student(student)
                    .session(session)
                    .date(LocalDate.now())
                    .status(bulkDto.getStatus())
                    .scannedAt(LocalDateTime.now())
                    .isJustified(false)
                    .markedBy("PROFESSOR")
                    .build();

            attendanceRecordRepository.save(attendance);
            recordedCount++;
        }

        String message = String.format("Bulk attendance recorded: %d successful, %d skipped",
                recordedCount, skippedCount);
        log.info(message);

        return new MessageResponse(message, true);
    }

    @Override
    @Transactional
    public AttendanceRecordResponseDto updateAttendanceRecord(UUID id, AttendanceRecordUpdateDto requestDto) {
        log.debug("Updating attendance record with ID: {}", id);

        AttendanceRecord attendance = attendanceRecordRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Attendance record not found with ID: " + id));

        attendanceRecordMapper.updateEntityFromUpdateDto(requestDto, attendance);
        AttendanceRecord updatedAttendance = attendanceRecordRepository.save(attendance);

        log.info("Attendance record updated successfully with ID: {}", updatedAttendance.getId());
        return attendanceRecordMapper.toResponseDto(updatedAttendance);
    }

    @Override
    @Transactional
    public AttendanceRecordResponseDto justifyAbsence(UUID id, JustifyAbsenceDto justifyDto) {
        log.debug("Justifying absence for attendance record ID: {}", id);

        AttendanceRecord attendance = attendanceRecordRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Attendance record not found with ID: " + id));

        if (attendance.getStatus() != AttendanceStatus.ABSENT) {
            throw new BadRequestException("Can only justify absences. Current status: " + attendance.getStatus());
        }

        attendance.setIsJustified(true);
        attendance.setJustificationNote(justifyDto.getJustificationNote());
        attendance.setJustificationDocumentUrl(justifyDto.getJustificationDocumentUrl());
        attendance.setStatus(AttendanceStatus.EXCUSED);

        AttendanceRecord updatedAttendance = attendanceRecordRepository.save(attendance);

        log.info("Absence justified successfully for attendance record ID: {}", id);
        return attendanceRecordMapper.toResponseDto(updatedAttendance);
    }

    @Override
    @Transactional(readOnly = true)
    public AttendanceRecordResponseDto getAttendanceRecordById(UUID id) {
        log.debug("Fetching attendance record with ID: {}", id);

        AttendanceRecord attendance = attendanceRecordRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Attendance record not found with ID: " + id));

        return attendanceRecordMapper.toResponseDto(attendance);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AttendanceRecordResponseDto> getAllAttendanceRecords(Pageable pageable) {
        log.debug("Fetching all attendance records with pagination");

        Page<AttendanceRecord> records = attendanceRecordRepository.findAll(pageable);
        return records.map(attendanceRecordMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AttendanceRecordSimpleResponseDto> getAllAttendanceRecordsSimple() {
        log.debug("Fetching all attendance records (simple)");

        List<AttendanceRecord> records = attendanceRecordRepository.findAll();
        return records.stream()
                .map(attendanceRecordMapper::toSimpleResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AttendanceRecordResponseDto> getAttendanceByStudent(UUID studentId, Pageable pageable) {
        log.debug("Fetching attendance records for student ID: {}", studentId);

        Page<AttendanceRecord> records = attendanceRecordRepository.findByStudentId(studentId, pageable);
        return records.map(attendanceRecordMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AttendanceRecordResponseDto> getAttendanceBySession(UUID sessionId, Pageable pageable) {
        log.debug("Fetching attendance records for session ID: {}", sessionId);

        Page<AttendanceRecord> records = attendanceRecordRepository.findBySessionId(sessionId, pageable);
        return records.map(attendanceRecordMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AttendanceRecordResponseDto> getAttendanceByModule(UUID moduleId, Pageable pageable) {
        log.debug("Fetching attendance records for module ID: {}", moduleId);

        Page<AttendanceRecord> records = attendanceRecordRepository.findByModuleId(moduleId, pageable);
        return records.map(attendanceRecordMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AttendanceRecordResponseDto> getAttendanceByModuleAndStudent(UUID moduleId, UUID studentId) {
        log.debug("Fetching attendance records for module ID: {} and student ID: {}", moduleId, studentId);

        List<AttendanceRecord> records = attendanceRecordRepository.findByModuleIdAndStudentId(moduleId, studentId);
        return records.stream()
                .map(attendanceRecordMapper::toResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AttendanceRecordResponseDto> getAttendanceByStatus(AttendanceStatus status, Pageable pageable) {
        log.debug("Fetching attendance records with status: {}", status);

        Page<AttendanceRecord> records = attendanceRecordRepository.findByStatus(status, pageable);
        return records.map(attendanceRecordMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AttendanceRecordResponseDto> getAttendanceByDateRange(
            LocalDate startDate, LocalDate endDate, Pageable pageable) {
        log.debug("Fetching attendance records between {} and {}", startDate, endDate);

        if (startDate.isAfter(endDate)) {
            throw new BadRequestException("Start date must be before end date");
        }

        Page<AttendanceRecord> records = attendanceRecordRepository.findByDateBetween(startDate, endDate, pageable);
        return records.map(attendanceRecordMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AttendanceRecordResponseDto> getStudentAttendanceByDateRange(
            UUID studentId, LocalDate startDate, LocalDate endDate) {
        log.debug("Fetching attendance records for student ID: {} between {} and {}",
                studentId, startDate, endDate);

        if (startDate.isAfter(endDate)) {
            throw new BadRequestException("Start date must be before end date");
        }

        List<AttendanceRecord> records = attendanceRecordRepository.findByStudentIdAndDateBetween(
                studentId, startDate, endDate);
        return records.stream()
                .map(attendanceRecordMapper::toResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AttendanceRecordResponseDto> getUnjustifiedAbsences(Pageable pageable) {
        log.debug("Fetching unjustified absences");

        Page<AttendanceRecord> records = attendanceRecordRepository.findUnjustifiedAbsences(pageable);
        return records.map(attendanceRecordMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AttendanceRecordSimpleResponseDto> getUnjustifiedAbsencesByStudent(UUID studentId) {
        log.debug("Fetching unjustified absences for student ID: {}", studentId);

        List<AttendanceRecord> records = attendanceRecordRepository.findUnjustifiedAbsencesByStudent(studentId);
        return records.stream()
                .map(attendanceRecordMapper::toSimpleResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AttendanceRecordResponseDto> searchAttendanceRecords(String searchTerm, Pageable pageable) {
        log.debug("Searching attendance records with term: {}", searchTerm);

        Page<AttendanceRecord> records = attendanceRecordRepository.searchAttendanceRecords(searchTerm, pageable);
        return records.map(attendanceRecordMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public AttendanceStatisticsDto getStudentAttendanceStatistics(UUID studentId) {
        log.debug("Calculating attendance statistics for student ID: {}", studentId);

        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with ID: " + studentId));

        Long totalSessions = attendanceRecordRepository.countByStudentId(studentId);
        Long presentCount = attendanceRecordRepository.countByStudentIdAndStatus(studentId, AttendanceStatus.PRESENT);
        Long absentCount = attendanceRecordRepository.countByStudentIdAndStatus(studentId, AttendanceStatus.ABSENT);
        Long lateCount = attendanceRecordRepository.countByStudentIdAndStatus(studentId, AttendanceStatus.LATE);
        Long excusedCount = attendanceRecordRepository.countByStudentIdAndStatus(studentId, AttendanceStatus.EXCUSED);

        Double attendanceRate = totalSessions > 0
                ? ((presentCount + lateCount + excusedCount) * 100.0) / totalSessions
                : 0.0;
        Double absenteeismRate = totalSessions > 0
                ? (absentCount * 100.0) / totalSessions
                : 0.0;

        return AttendanceStatisticsDto.builder()
                .entityId(studentId)
                .entityName(student.getFirstName() + " " + student.getLastName())
                .totalSessions(totalSessions.intValue())
                .presentCount(presentCount.intValue())
                .absentCount(absentCount.intValue())
                .lateCount(lateCount.intValue())
                .excusedCount(excusedCount.intValue())
                .attendanceRate(attendanceRate)
                .absenteeismRate(absenteeismRate)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public AttendanceStatisticsDto getModuleAttendanceStatistics(UUID moduleId) {
        log.debug("Calculating attendance statistics for module ID: {}", moduleId);

        // Validate module exists
        Module module = moduleRepository.findById(moduleId)
                .orElseThrow(() -> new ResourceNotFoundException("Module not found with ID: " + moduleId));

        // Count total attendance records for this module
        Long totalRecords = attendanceRecordRepository.countByModuleId(moduleId);

        // Count by status
        Long presentCount = attendanceRecordRepository.countByModuleIdAndStatus(moduleId, AttendanceStatus.PRESENT);
        Long absentCount = attendanceRecordRepository.countByModuleIdAndStatus(moduleId, AttendanceStatus.ABSENT);
        Long lateCount = attendanceRecordRepository.countByModuleIdAndStatus(moduleId, AttendanceStatus.LATE);
        Long excusedCount = attendanceRecordRepository.countByModuleIdAndStatus(moduleId, AttendanceStatus.EXCUSED);

        // Calculate rates
        Double attendanceRate = totalRecords > 0
                ? ((presentCount + lateCount + excusedCount) * 100.0) / totalRecords
                : 0.0;
        Double absenteeismRate = totalRecords > 0
                ? (absentCount * 100.0) / totalRecords
                : 0.0;

        // Count total sessions for this module
        int totalSessions = module.getSessions() != null ? module.getSessions().size() : 0;

        return AttendanceStatisticsDto.builder()
                .entityId(moduleId)
                .entityName(module.getTitle())
                .totalSessions(totalSessions)
                .presentCount(presentCount.intValue())
                .absentCount(absentCount.intValue())
                .lateCount(lateCount.intValue())
                .excusedCount(excusedCount.intValue())
                .attendanceRate(attendanceRate)
                .absenteeismRate(absenteeismRate)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public AttendanceStatisticsDto getSessionAttendanceStatistics(UUID sessionId) {
        log.debug("Calculating attendance statistics for session ID: {}", sessionId);

        Session session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found with ID: " + sessionId));

        Long presentCount = attendanceRecordRepository.countBySessionIdAndStatus(sessionId, AttendanceStatus.PRESENT);
        Long absentCount = attendanceRecordRepository.countBySessionIdAndStatus(sessionId, AttendanceStatus.ABSENT);
        Long lateCount = attendanceRecordRepository.countBySessionIdAndStatus(sessionId, AttendanceStatus.LATE);
        Long excusedCount = attendanceRecordRepository.countBySessionIdAndStatus(sessionId, AttendanceStatus.EXCUSED);

        Long totalRecords = presentCount + absentCount + lateCount + excusedCount;

        Double attendanceRate = totalRecords > 0
                ? ((presentCount + lateCount + excusedCount) * 100.0) / totalRecords
                : 0.0;
        Double absenteeismRate = totalRecords > 0
                ? (absentCount * 100.0) / totalRecords
                : 0.0;

        return AttendanceStatisticsDto.builder()
                .entityId(sessionId)
                .entityName(session.getModule().getTitle() + " - " + session.getType())
                .totalSessions(1)
                .presentCount(presentCount.intValue())
                .absentCount(absentCount.intValue())
                .lateCount(lateCount.intValue())
                .excusedCount(excusedCount.intValue())
                .attendanceRate(attendanceRate)
                .absenteeismRate(absenteeismRate)
                .build();
    }

    @Override
    @Transactional
    public void deleteAttendanceRecord(UUID id) {
        log.debug("Deleting attendance record with ID: {}", id);

        AttendanceRecord attendance = attendanceRecordRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Attendance record not found with ID: " + id));

        attendanceRecordRepository.delete(attendance);
        log.info("Attendance record deleted successfully with ID: {}", id);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean hasAttendanceForSession(UUID studentId, UUID sessionId) {
        return attendanceRecordRepository.existsByStudentIdAndSessionId(studentId, sessionId);
    }

    @Override
    @Transactional
    public AttendanceRecordResponseDto scanSessionQrCode(StudentScanSessionQrRequestDto requestDto) {
        log.debug("Student {} scanning session QR code", requestDto.getStudentId());

        // 1. Parse and validate QR code format
        String[] qrParts = requestDto.getSessionQrCode().split(":");
        if (qrParts.length < 2 || !"SESSION".equals(qrParts[0])) {
            throw new BadRequestException("Invalid session QR code format");
        }

        UUID sessionId;
        try {
            sessionId = UUID.fromString(qrParts[1]);
        } catch (IllegalArgumentException e) {
            throw new BadRequestException("Invalid session QR code data");
        }

        // 2. Validate student exists
        Student student = studentRepository.findById(requestDto.getStudentId())
                .orElseThrow(() -> new ResourceNotFoundException("Student not found"));

        // 3. Validate session exists
        Session session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found"));

        // 4. Validate session is in STUDENT_SCAN mode
        if (session.getAttendanceMode() != AttendanceMode.STUDENT_SCAN) {
            throw new BadRequestException(
                    "This session is not configured for student QR code scanning. " +
                            "Current mode: " + session.getAttendanceMode()
            );
        }

        // 5. Validate QR code matches session's current QR code
        if (!requestDto.getSessionQrCode().equals(session.getQrCode())) {
            throw new BadRequestException("QR code does not match the current session QR code");
        }

        // 6. Validate QR code is not expired
        if (!session.isQrCodeValid()) {
            throw new BadRequestException(
                    "Session QR code has expired. Expired at: " +
                            session.getQrCodeExpiry().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"))
            );
        }

        // 7. Validate session timing
        validateSessionTiming(session);

        // 8. Validate session status
        validateSessionStatus(session);

        // 9. Check if student is enrolled in session's groups
        validateStudentEnrollment(student, session);

        // 10. Check for duplicate attendance
        Optional<AttendanceRecord> existingRecord = attendanceRecordRepository
                .findByStudentIdAndSessionId(student.getId(), session.getId());

        if (existingRecord.isPresent()) {
            throw new BadRequestException(
                    "You have already scanned for this session. Status: " +
                            existingRecord.get().getStatus()
            );
        }

        // 11. Optional: Validate location if provided
        if (requestDto.getLatitude() != null && requestDto.getLongitude() != null) {
            validateStudentLocation(requestDto.getLatitude(), requestDto.getLongitude(), session);
        }

        // 12. Determine attendance status based on timing
        AttendanceStatus status = determineAttendanceStatus(session, LocalDateTime.now());

        // 13. Create attendance record
        AttendanceRecord attendanceRecord = AttendanceRecord.builder()
                .student(student)
                .session(session)
                .date(LocalDate.now())
                .status(status)
                .scannedAt(LocalDateTime.now())
                .deviceInfo(requestDto.getDeviceInfo())
                .ipAddress(requestDto.getIpAddress())
                .isJustified(false)
                .markedBy("STUDENT")
                .build();

        AttendanceRecord savedRecord = attendanceRecordRepository.save(attendanceRecord);

        log.info("Attendance recorded via session QR scan for student {} in session {} with status: {}",
                student.getCne(), session.getId(), status);

        return attendanceRecordMapper.toResponseDto(savedRecord);
    }

    /**
     * Optional: Validate student is physically near the session location
     */
    private void validateStudentLocation(Double latitude, Double longitude, Session session) {
        // Example: University coordinates
        final double UNIVERSITY_LATITUDE = 30.4278;  // Agadir, Morocco example
        final double UNIVERSITY_LONGITUDE = -9.5981;
        final double MAX_DISTANCE_KM = 0.5; // 500 meters radius

        double distance = calculateDistance(
                latitude, longitude,
                UNIVERSITY_LATITUDE, UNIVERSITY_LONGITUDE
        );

        if (distance > MAX_DISTANCE_KM) {
            throw new BadRequestException(
                    String.format("You must be on campus to mark attendance. " +
                            "You are %.2f km away from the university.", distance)
            );
        }

        log.debug("Location validated. Student is {} km from campus", distance);
    }

    /**
     * Calculate distance between two coordinates using Haversine formula
     */
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int EARTH_RADIUS_KM = 6371;

        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);

        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return EARTH_RADIUS_KM * c;
    }
}