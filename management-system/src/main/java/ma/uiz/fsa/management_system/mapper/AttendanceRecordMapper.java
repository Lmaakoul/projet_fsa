package ma.uiz.fsa.management_system.mapper;

import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.dto.request.AttendanceRecordRequestDto;
import ma.uiz.fsa.management_system.dto.request.AttendanceRecordUpdateDto;
import ma.uiz.fsa.management_system.dto.response.AttendanceRecordResponseDto;
import ma.uiz.fsa.management_system.dto.response.AttendanceRecordSimpleResponseDto;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.model.entity.AttendanceRecord;
import ma.uiz.fsa.management_system.model.entity.Session;
import ma.uiz.fsa.management_system.model.entity.Student;
import ma.uiz.fsa.management_system.repository.SessionRepository;
import ma.uiz.fsa.management_system.repository.StudentRepository;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class AttendanceRecordMapper implements BaseMapper<AttendanceRecord, AttendanceRecordRequestDto, AttendanceRecordResponseDto> {

    private final StudentRepository studentRepository;
    private final SessionRepository sessionRepository;

    @Override
    public AttendanceRecord toEntity(AttendanceRecordRequestDto dto) {
        if (dto == null) return null;

        Student student = studentRepository.findById(dto.getStudentId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Student not found with ID: " + dto.getStudentId()));

        Session session = sessionRepository.findById(dto.getSessionId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Session not found with ID: " + dto.getSessionId()));

        return AttendanceRecord.builder()
                .student(student)
                .session(session)
                .date(dto.getDate())
                .status(dto.getStatus())
                .scannedAt(dto.getScannedAt())
                .isJustified(dto.getIsJustified() != null ? dto.getIsJustified() : false)
                .justificationNote(dto.getJustificationNote())
                .justificationDocumentUrl(dto.getJustificationDocumentUrl())
                .deviceInfo(dto.getDeviceInfo())
                .ipAddress(dto.getIpAddress())
                .markedBy("MANUAL")
                .build();
    }

    @Override
    public AttendanceRecordResponseDto toResponseDto(AttendanceRecord entity) {
        if (entity == null) return null;

        return AttendanceRecordResponseDto.builder()
                .id(entity.getId())
                .date(entity.getDate())
                .status(entity.getStatus())
                .scannedAt(entity.getScannedAt())
                .isJustified(entity.getIsJustified())
                .justificationNote(entity.getJustificationNote())
                .justificationDocumentUrl(entity.getJustificationDocumentUrl())
                .studentId(entity.getStudent() != null ? entity.getStudent().getId() : null)
                .studentName(entity.getStudent() != null
                        ? entity.getStudent().getFirstName() + " " + entity.getStudent().getLastName()
                        : null)
                .studentCne(entity.getStudent() != null ? entity.getStudent().getCne() : null)
                .studentEmail(entity.getStudent() != null ? entity.getStudent().getEmail() : null)
                .sessionId(entity.getSession() != null ? entity.getSession().getId() : null)
                .sessionType(entity.getSession() != null ? entity.getSession().getType().name() : null)
                .sessionSchedule(entity.getSession() != null ? entity.getSession().getSchedule() : null)
                .locationName(entity.getSession() != null && entity.getSession().getLocation() != null ? entity.getSession().getLocation().getFullName() : null)
                .locationBuilding(entity.getSession() != null && entity.getSession().getLocation() != null ? entity.getSession().getLocation().getBuilding() : null)
                .locationRoomNumber(entity.getSession() != null && entity.getSession().getLocation() != null ? entity.getSession().getLocation().getRoomNumber() : null)
                .moduleTitle(entity.getSession() != null && entity.getSession().getModule() != null
                        ? entity.getSession().getModule().getTitle() : null)
                .moduleCode(entity.getSession() != null && entity.getSession().getModule() != null
                        ? entity.getSession().getModule().getCode() : null)
                .deviceInfo(entity.getDeviceInfo())
                .ipAddress(entity.getIpAddress())
                .markedBy(entity.getMarkedBy())
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .createdBy(entity.getCreatedBy())
                .lastModifiedBy(entity.getLastModifiedBy())
                .build();
    }

    public AttendanceRecordSimpleResponseDto toSimpleResponseDto(AttendanceRecord entity) {
        if (entity == null) return null;

        return AttendanceRecordSimpleResponseDto.builder()
                .id(entity.getId())
                .date(entity.getDate())
                .status(entity.getStatus())
                .scannedAt(entity.getScannedAt())
                .studentName(entity.getStudent() != null
                        ? entity.getStudent().getFirstName() + " " + entity.getStudent().getLastName()
                        : null)
                .moduleTitle(entity.getSession() != null && entity.getSession().getModule() != null
                        ? entity.getSession().getModule().getTitle() : null)
                .isJustified(entity.getIsJustified())
                .build();
    }

    @Override
    public void updateEntityFromDto(AttendanceRecordRequestDto dto, AttendanceRecord entity) {
        if (dto == null || entity == null) return;

        if (dto.getDate() != null) {
            entity.setDate(dto.getDate());
        }
        if (dto.getStatus() != null) {
            entity.setStatus(dto.getStatus());
        }
        if (dto.getScannedAt() != null) {
            entity.setScannedAt(dto.getScannedAt());
        }
        if (dto.getIsJustified() != null) {
            entity.setIsJustified(dto.getIsJustified());
        }
        if (dto.getJustificationNote() != null) {
            entity.setJustificationNote(dto.getJustificationNote());
        }
        if (dto.getJustificationDocumentUrl() != null) {
            entity.setJustificationDocumentUrl(dto.getJustificationDocumentUrl());
        }
        if (dto.getDeviceInfo() != null) {
            entity.setDeviceInfo(dto.getDeviceInfo());
        }
        if (dto.getIpAddress() != null) {
            entity.setIpAddress(dto.getIpAddress());
        }
    }

    public void updateEntityFromUpdateDto(AttendanceRecordUpdateDto dto, AttendanceRecord entity) {
        if (dto == null || entity == null) return;

        if (dto.getStatus() != null) {
            entity.setStatus(dto.getStatus());
        }
        if (dto.getIsJustified() != null) {
            entity.setIsJustified(dto.getIsJustified());
        }
        if (dto.getJustificationNote() != null) {
            entity.setJustificationNote(dto.getJustificationNote());
        }
        if (dto.getJustificationDocumentUrl() != null) {
            entity.setJustificationDocumentUrl(dto.getJustificationDocumentUrl());
        }
    }
}