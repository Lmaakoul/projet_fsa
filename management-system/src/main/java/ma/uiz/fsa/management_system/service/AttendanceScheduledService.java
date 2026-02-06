package ma.uiz.fsa.management_system.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.uiz.fsa.management_system.model.entity.AttendanceRecord;
import ma.uiz.fsa.management_system.model.entity.Group;
import ma.uiz.fsa.management_system.model.entity.Session;
import ma.uiz.fsa.management_system.model.entity.Student;
import ma.uiz.fsa.management_system.model.enums.AttendanceStatus;
import ma.uiz.fsa.management_system.repository.AttendanceRecordRepository;
import ma.uiz.fsa.management_system.repository.SessionRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
@Slf4j
public class AttendanceScheduledService {

    private final SessionRepository sessionRepository;
    private final AttendanceRecordRepository attendanceRecordRepository;

    @Value("${attendance.grace-period-minutes}")
    private Integer gracePeriodMinutes;

    /**
     * Scheduled task that runs twice daily at 13:00 and 19:00 to automatically mark
     * students as absent if they didn't mark their attendance within the grace period.
     *
     * This only processes sessions from the current day to avoid affecting historical data.
     */
    @Scheduled(cron = "0 0 13,19 * * *")
    @Transactional
    public void autoMarkAbsentStudents() {
        log.info("Starting automatic absent-marking job...");

        LocalDateTime now = LocalDateTime.now();
        LocalDate today = now.toLocalDate();

        // Get start and end of today
        LocalDateTime startOfDay = today.atStartOfDay();
        LocalDateTime endOfDay = today.atTime(LocalTime.MAX);

        log.info("Processing sessions for date: {}", today);

        // Find all sessions from today that have passed their grace period
        List<Session> sessionsToProcess = findSessionsPastGracePeriod(now, startOfDay, endOfDay);

        log.info("Found {} sessions past grace period", sessionsToProcess.size());

        int totalSessionsProcessed = 0;
        int totalStudentsMarkedAbsent = 0;

        for (Session session : sessionsToProcess) {
            try {
                int studentsMarked = processSession(session, now);
                totalStudentsMarkedAbsent += studentsMarked;
                totalSessionsProcessed++;

                log.info("Session '{}' (ID: {}): Marked {} students as ABSENT",
                        session.getName(), session.getId(), studentsMarked);

            } catch (Exception e) {
                log.error("Error processing session {} ({}): {}",
                        session.getId(), session.getName(), e.getMessage(), e);
            }
        }

        log.info("Auto-absence job completed. Processed {} sessions, marked {} students as ABSENT",
                totalSessionsProcessed, totalStudentsMarkedAbsent);
    }

    /**
     * Find sessions from today that have passed their grace period and haven't been marked as completed
     */
    private List<Session> findSessionsPastGracePeriod(LocalDateTime now, LocalDateTime startOfDay, LocalDateTime endOfDay) {
        // Get all sessions scheduled for today
        List<Session> todaySessions = sessionRepository.findByModuleIdAndScheduleBetween(null, startOfDay, endOfDay)
                .stream()
                .filter(session -> session.getSchedule().toLocalDate().equals(now.toLocalDate()))
                .toList();

        // Alternative: use custom query to get all sessions for today
        // We need a more general query, so let's get all past incomplete sessions and filter for today
        List<Session> allPastSessions = sessionRepository.findPastIncompleteSessions(now);

        // Filter for sessions from today that passed grace period
        return allPastSessions.stream()
                .filter(session -> {
                    LocalDate sessionDate = session.getSchedule().toLocalDate();
                    LocalDateTime gracePeriodEnd = session.getSchedule()
                            .plusMinutes(session.getDuration())
                            .plusMinutes(gracePeriodMinutes);

                    // Only process today's sessions that have passed grace period
                    return sessionDate.equals(now.toLocalDate()) && now.isAfter(gracePeriodEnd);
                })
                .toList();
    }

    /**
     * Process a single session: find students without attendance and mark them absent
     *
     * @return number of students marked absent
     */
    private int processSession(Session session, LocalDateTime now) {
        // Get all enrolled students for this session (from all groups)
        Set<Student> enrolledStudents = getAllEnrolledStudents(session);

        if (enrolledStudents.isEmpty()) {
            log.warn("Session {} has no enrolled students", session.getId());
            return 0;
        }

        // Find students who don't have attendance records
        Set<Student> studentsWithoutAttendance = new HashSet<>();

        for (Student student : enrolledStudents) {
            boolean hasAttendance = attendanceRecordRepository
                    .existsByStudentIdAndSessionId(student.getId(), session.getId());

            if (!hasAttendance) {
                studentsWithoutAttendance.add(student);
            }
        }

        // Create ABSENT records for students without attendance
        for (Student student : studentsWithoutAttendance) {
            AttendanceRecord absentRecord = AttendanceRecord.builder()
                    .student(student)
                    .session(session)
                    .status(AttendanceStatus.ABSENT)
                    .date(session.getSchedule().toLocalDate())
                    .scannedAt(now)
                    .isJustified(false)
                    .markedBy("SYSTEM")
                    .build();

            attendanceRecordRepository.save(absentRecord);
        }

        // Mark session attendance as taken
        session.setAttendanceTaken(true);
        sessionRepository.save(session);

        return studentsWithoutAttendance.size();
    }

    /**
     * Get all students enrolled in the session through its groups
     */
    private Set<Student> getAllEnrolledStudents(Session session) {
        Set<Student> allStudents = new HashSet<>();

        for (Group group : session.getGroups()) {
            allStudents.addAll(group.getStudents());
        }

        return allStudents;
    }
}
