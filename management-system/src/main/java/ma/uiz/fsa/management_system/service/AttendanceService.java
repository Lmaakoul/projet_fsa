package ma.uiz.fsa.management_system.service;

import ma.uiz.fsa.management_system.dto.request.*;
import ma.uiz.fsa.management_system.dto.response.AttendanceRecordResponseDto;
import ma.uiz.fsa.management_system.dto.response.AttendanceRecordSimpleResponseDto;
import ma.uiz.fsa.management_system.dto.response.AttendanceStatisticsDto;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.model.enums.AttendanceStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface AttendanceService {

    AttendanceRecordResponseDto recordAttendance(AttendanceRecordRequestDto requestDto);

    AttendanceRecordResponseDto markAttendanceByCne(AttendanceByCneRequestDto requestDto);

    AttendanceRecordResponseDto scanQrCode(ScanQrRequestDto scanQrRequestDto);

    MessageResponse recordBulkAttendance(BulkAttendanceDto bulkDto);

    AttendanceRecordResponseDto updateAttendanceRecord(UUID id, AttendanceRecordUpdateDto requestDto);

    AttendanceRecordResponseDto justifyAbsence(UUID id, JustifyAbsenceDto justifyDto);

    AttendanceRecordResponseDto getAttendanceRecordById(UUID id);

    Page<AttendanceRecordResponseDto> getAllAttendanceRecords(Pageable pageable);

    List<AttendanceRecordSimpleResponseDto> getAllAttendanceRecordsSimple();

    Page<AttendanceRecordResponseDto> getAttendanceByStudent(UUID studentId, Pageable pageable);

    Page<AttendanceRecordResponseDto> getAttendanceBySession(UUID sessionId, Pageable pageable);

    Page<AttendanceRecordResponseDto> getAttendanceByModule(UUID moduleId, Pageable pageable);

    List<AttendanceRecordResponseDto> getAttendanceByModuleAndStudent(UUID moduleId, UUID studentId);

    Page<AttendanceRecordResponseDto> getAttendanceByStatus(AttendanceStatus status, Pageable pageable);

    Page<AttendanceRecordResponseDto> getAttendanceByDateRange(LocalDate startDate, LocalDate endDate, Pageable pageable);

    List<AttendanceRecordResponseDto> getStudentAttendanceByDateRange(UUID studentId, LocalDate startDate, LocalDate endDate);

    Page<AttendanceRecordResponseDto> getUnjustifiedAbsences(Pageable pageable);

    List<AttendanceRecordSimpleResponseDto> getUnjustifiedAbsencesByStudent(UUID studentId);

    Page<AttendanceRecordResponseDto> searchAttendanceRecords(String searchTerm, Pageable pageable);

    AttendanceStatisticsDto getStudentAttendanceStatistics(UUID studentId);

    AttendanceStatisticsDto getModuleAttendanceStatistics(UUID moduleId);

    AttendanceStatisticsDto getSessionAttendanceStatistics(UUID sessionId);

    void deleteAttendanceRecord(UUID id);

    boolean hasAttendanceForSession(UUID studentId, UUID sessionId);

    AttendanceRecordResponseDto scanSessionQrCode(StudentScanSessionQrRequestDto requestDto);
}