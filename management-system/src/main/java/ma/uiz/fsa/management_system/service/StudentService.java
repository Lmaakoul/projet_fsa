package ma.uiz.fsa.management_system.service;

import ma.uiz.fsa.management_system.dto.request.BulkStudentRequestDto;
import ma.uiz.fsa.management_system.dto.request.ChangePasswordRequest;
import ma.uiz.fsa.management_system.dto.request.StudentRequestDto;
import ma.uiz.fsa.management_system.dto.request.StudentUpdateDto;
import ma.uiz.fsa.management_system.dto.response.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface StudentService {

    BulkStudentResponseDto createBulkStudents(BulkStudentRequestDto requestDto);

    StudentResponseDto createStudent(StudentRequestDto requestDto);

    StudentResponseDto updateStudent(UUID id, StudentUpdateDto requestDto);

    StudentResponseDto getStudentById(UUID id);

    StudentResponseDto getStudentByEmail(String email);

    StudentResponseDto getStudentByCne(String cne);

    StudentResponseDto getStudentByCin(String cin);

    Page<StudentResponseDto> getAllStudents(Pageable pageable);

    List<StudentSimpleResponseDto> getAllStudentsSimple();

    Page<StudentResponseDto> getStudentsByFiliere(UUID filiereId, Pageable pageable);

    Page<StudentResponseDto> getStudentsByGroup(UUID groupId, Pageable pageable);

    Page<StudentResponseDto> searchStudents(String searchTerm, Pageable pageable);

    Page<StudentResponseDto> getActiveStudents(Pageable pageable);

    MessageResponse toggleStudentStatus(UUID id);

    void deleteStudent(UUID id);

    MessageResponse changeStudentPassword(UUID id, ChangePasswordRequest request);

    String generateQrCodeForStudent(UUID id);

    QrCodeResponseDto getStudentQrCodeData(UUID studentId, UUID currentUserId);
}