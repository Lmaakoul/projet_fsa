package ma.uiz.fsa.management_system.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.uiz.fsa.management_system.dto.request.BulkStudentRequestDto;
import ma.uiz.fsa.management_system.dto.request.ChangePasswordRequest;
import ma.uiz.fsa.management_system.dto.request.StudentRequestDto;
import ma.uiz.fsa.management_system.dto.request.StudentUpdateDto;
import ma.uiz.fsa.management_system.dto.response.*;
import ma.uiz.fsa.management_system.exception.BadRequestException;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.mapper.StudentMapper;
import ma.uiz.fsa.management_system.model.entity.Group;
import ma.uiz.fsa.management_system.model.entity.Student;
import ma.uiz.fsa.management_system.repository.RefreshTokenRepository;
import ma.uiz.fsa.management_system.repository.StudentRepository;
import ma.uiz.fsa.management_system.service.QrCodeService;
import ma.uiz.fsa.management_system.service.StudentService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentServiceImpl implements StudentService {

    private final StudentRepository studentRepository;
    private final StudentMapper studentMapper;
    private final PasswordEncoder passwordEncoder;
    private final RefreshTokenRepository refreshTokenRepository;
    private final QrCodeService qrCodeService;

    @Override
    @Transactional
    public BulkStudentResponseDto createBulkStudents(BulkStudentRequestDto requestDto) {
        log.info("Starting bulk student creation for {} students in filiere: {}",
                requestDto.getStudents().size(), requestDto.getFiliereId());

        List<StudentResponseDto> createdStudents = new ArrayList<>();
        List<BulkStudentResponseDto.BulkOperationError> errors = new ArrayList<>();

        for (int i = 0; i < requestDto.getStudents().size(); i++) {
            var studentItem = requestDto.getStudents().get(i);
            try {
                // Validate unique email
                if (studentRepository.existsByEmail(studentItem.getEmail())) {
                    throw new BadRequestException("Student with email '" + studentItem.getEmail() + "' already exists");
                }

                // Validate unique username
                if (studentRepository.existsByUsername(studentItem.getUsername())) {
                    throw new BadRequestException("Username '" + studentItem.getUsername() + "' is already taken");
                }

                // Validate unique CNE
                if (studentRepository.existsByCne(studentItem.getCne().toUpperCase())) {
                    throw new BadRequestException("Student with CNE '" + studentItem.getCne() + "' already exists");
                }

                // Validate unique CIN
                if (studentRepository.existsByCin(studentItem.getCin().toUpperCase())) {
                    throw new BadRequestException("Student with CIN '" + studentItem.getCin() + "' already exists");
                }

                // Create StudentRequestDto with filiere from bulk request
                StudentRequestDto studentRequest = StudentRequestDto.builder()
                        .email(studentItem.getEmail())
                        .password(studentItem.getPassword())
                        .username(studentItem.getUsername())
                        .cne(studentItem.getCne())
                        .cin(studentItem.getCin())
                        .firstName(studentItem.getFirstName())
                        .lastName(studentItem.getLastName())
                        .dateOfBirth(studentItem.getDateOfBirth())
                        .filiereId(requestDto.getFiliereId())
                        .phoneNumber(studentItem.getPhoneNumber())
                        .address(studentItem.getAddress())
                        .photoUrl(studentItem.getPhotoUrl())
                        .build();

                // Create student
                Student student = studentMapper.toEntity(studentRequest);
                Student savedStudent = studentRepository.save(student);

                // Generate QR code
                generateAndSaveQrCode(savedStudent);

                // Add to successful list
                createdStudents.add(studentMapper.toResponseDto(savedStudent));
                log.debug("Successfully created student at index {} with CNE: {}", i, studentItem.getCne());

            } catch (Exception e) {
                // Log error and add to error list
                log.error("Failed to create student at index {} with CNE: {}. Error: {}",
                        i, studentItem.getCne(), e.getMessage());

                BulkStudentResponseDto.BulkOperationError error = BulkStudentResponseDto.BulkOperationError.builder()
                        .index(i)
                        .email(studentItem.getEmail())
                        .cne(studentItem.getCne())
                        .errorMessage(e.getMessage())
                        .build();
                errors.add(error);
            }
        }

        int totalRequested = requestDto.getStudents().size();
        int successCount = createdStudents.size();
        int failureCount = errors.size();

        log.info("Bulk student creation completed. Total: {}, Success: {}, Failures: {}",
                totalRequested, successCount, failureCount);

        return BulkStudentResponseDto.builder()
                .totalRequested(totalRequested)
                .successCount(successCount)
                .failureCount(failureCount)
                .createdStudents(createdStudents)
                .errors(errors)
                .build();
    }

    @Override
    @Transactional
    public StudentResponseDto createStudent(StudentRequestDto requestDto) {
        log.debug("Creating new student with CNE: {}", requestDto.getCne());

        // Validate unique email
        if (studentRepository.existsByEmail(requestDto.getEmail())) {
            throw new BadRequestException("Student with email '" + requestDto.getEmail() + "' already exists");
        }

        // Validate unique username
        if (studentRepository.existsByUsername(requestDto.getUsername())) {
            throw new BadRequestException("Username '" + requestDto.getUsername() + "' is already taken");
        }

        // Validate unique CNE
        if (studentRepository.existsByCne(requestDto.getCne().toUpperCase())) {
            throw new BadRequestException("Student with CNE '" + requestDto.getCne() + "' already exists");
        }

        // Validate unique CIN
        if (studentRepository.existsByCin(requestDto.getCin().toUpperCase())) {
            throw new BadRequestException("Student with CIN '" + requestDto.getCin() + "' already exists");
        }

        Student student = studentMapper.toEntity(requestDto);
        Student savedStudent = studentRepository.save(student);

        // ✅ Generate QR code automatically after saving
        generateAndSaveQrCode(savedStudent);

        log.info("Student created successfully with ID: {}", savedStudent.getId());
        return studentMapper.toResponseDto(savedStudent);
    }

    @Override
    @Transactional
    public StudentResponseDto updateStudent(UUID id, StudentUpdateDto requestDto) {
        log.debug("Updating student with ID: {}", id);

        Student student = studentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with ID: " + id));

        // Validate unique username (if changed)
        if (requestDto.getUsername() != null &&
                !student.getUsername().equals(requestDto.getUsername()) &&
                studentRepository.existsByUsername(requestDto.getUsername())) {
            throw new BadRequestException("Username '" + requestDto.getUsername() + "' is already taken");
        }

        studentMapper.updateEntityFromDto(requestDto, student);
        Student updatedStudent = studentRepository.save(student);

        log.info("Student updated successfully with ID: {}", updatedStudent.getId());
        return studentMapper.toResponseDto(updatedStudent);
    }

    @Override
    @Transactional(readOnly = true)
    public StudentResponseDto getStudentById(UUID id) {
        log.debug("Fetching student with ID: {}", id);

        Student student = studentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with ID: " + id));

        return studentMapper.toResponseDto(student);
    }

    @Override
    @Transactional(readOnly = true)
    public StudentResponseDto getStudentByEmail(String email) {
        log.debug("Fetching student with email: {}", email);

        Student student = studentRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with email: " + email));

        return studentMapper.toResponseDto(student);
    }

    @Override
    @Transactional(readOnly = true)
    public StudentResponseDto getStudentByCne(String cne) {
        log.debug("Fetching student with CNE: {}", cne);

        Student student = studentRepository.findByCne(cne.toUpperCase())
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with CNE: " + cne));

        return studentMapper.toResponseDto(student);
    }

    @Override
    @Transactional(readOnly = true)
    public StudentResponseDto getStudentByCin(String cin) {
        log.debug("Fetching student with CIN: {}", cin);

        Student student = studentRepository.findByCin(cin.toUpperCase())
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with CIN: " + cin));

        return studentMapper.toResponseDto(student);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<StudentResponseDto> getAllStudents(Pageable pageable) {
        log.debug("Fetching all students with pagination");

        Page<Student> students = studentRepository.findAll(pageable);
        return students.map(studentMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public List<StudentSimpleResponseDto> getAllStudentsSimple() {
        log.debug("Fetching all students (simple)");

        List<Student> students = studentRepository.findAll();
        return students.stream()
                .map(studentMapper::toSimpleResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<StudentResponseDto> getStudentsByFiliere(UUID filiereId, Pageable pageable) {
        log.debug("Fetching students for filiere ID: {}", filiereId);

        Page<Student> students = studentRepository.findByFiliereId(filiereId, pageable);
        return students.map(studentMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<StudentResponseDto> getStudentsByGroup(UUID groupId, Pageable pageable) {
        log.debug("Fetching students for group ID: {}", groupId);

        Page<Student> students = studentRepository.findByGroupId(groupId, pageable);
        return students.map(studentMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<StudentResponseDto> searchStudents(String searchTerm, Pageable pageable) {
        log.debug("Searching students with term: {}", searchTerm);

        Page<Student> students = studentRepository.searchStudents(searchTerm, pageable);
        return students.map(studentMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<StudentResponseDto> getActiveStudents(Pageable pageable) {
        log.debug("Fetching active students");

        Page<Student> students = studentRepository.findByEnabled(true, pageable);
        return students.map(studentMapper::toResponseDto);
    }

    @Override
    @Transactional
    public MessageResponse toggleStudentStatus(UUID id) {
        log.debug("Toggling status for student with ID: {}", id);

        Student student = studentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with ID: " + id));

        student.setEnabled(!student.getEnabled());
        studentRepository.save(student);

        String status = student.getEnabled() ? "enabled" : "disabled";
        log.info("Student status toggled to {} for ID: {}", status, id);

        return new MessageResponse("Student account " + status + " successfully", true);
    }

    @Override
    @Transactional
    public void deleteStudent(UUID id) {
        log.debug("Deleting student with ID: {}", id);

        Student student = studentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with ID: " + id));

        // Validate business rules
        validateCanDeleteStudent(student);

        // Remove from groups
        removeStudentFromGroups(student);

        // Delete refresh tokens
        refreshTokenRepository.deleteByUser(student);

        studentRepository.delete(student);
        log.info("Student deleted successfully with ID: {}", id);
    }

    private void validateCanDeleteStudent(Student student) {
        if (student.getEvaluations() != null && !student.getEvaluations().isEmpty()) {
            throw new BadRequestException(
                    "Cannot delete student. They have " + student.getEvaluations().size() + " evaluation(s). " +
                            "Please delete evaluations first."
            );
        }

        if (student.getAttendanceRecords() != null && !student.getAttendanceRecords().isEmpty()) {
            throw new BadRequestException(
                    "Cannot delete student. They have " + student.getAttendanceRecords().size() + " attendance record(s). " +
                            "Please delete attendance records first."
            );
        }
    }

    private void removeStudentFromGroups(Student student) {
        if (student.getGroups() != null && !student.getGroups().isEmpty()) {
            log.debug("Removing student from {} group(s)", student.getGroups().size());

            Set<Group> groupsCopy = new HashSet<>(student.getGroups());
            for (Group group : groupsCopy) {
                group.getStudents().remove(student);
            }
            student.getGroups().clear();
            studentRepository.flush();
        }
    }

    @Override
    @Transactional
    public MessageResponse changeStudentPassword(UUID id, ChangePasswordRequest request) {
        log.debug("Changing password for student with ID: {}", id);

        Student student = studentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with ID: " + id));

        // Verify current password
        if (!passwordEncoder.matches(request.getCurrentPassword(), student.getPasswordHash())) {
            throw new BadRequestException("Current password is incorrect");
        }

        // Verify new password and confirm password match
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new BadRequestException("New password and confirm password do not match");
        }

        // Update password
        student.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        studentRepository.save(student);

        log.info("Password changed successfully for student ID: {}", id);
        return new MessageResponse("Password changed successfully", true);
    }

    @Override
    @Transactional
    public String generateQrCodeForStudent(UUID id) {
        log.debug("Generating QR code for student with ID: {}", id);

        Student student = studentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with ID: " + id));

        generateAndSaveQrCode(student);

        log.info("QR code generated for student ID: {}", id);
        return student.getQrCode();
    }

    private void generateAndSaveQrCode(Student student) {
        // Generate QR code content
        String qrCodeContent = "STUDENT:" + student.getId() + ":" + student.getCne();

        // Generate QR code image as Base64
        String qrCodeImageBase64 = qrCodeService.generateQrCodeBase64(qrCodeContent);

        // Save to student
        student.setQrCode(qrCodeContent);
        student.setQrCodeImage(qrCodeImageBase64);

        studentRepository.save(student);
    }

    @Override
    @Transactional(readOnly = true)
    public QrCodeResponseDto getStudentQrCodeData(UUID studentId, UUID currentUserId) {
        log.debug("Retrieving QR code for student ID: {}", studentId);

        // Get student
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Student not found with ID: " + studentId));

        // Authorization: If current user is a student, they can only access their own QR
        if (currentUserId != null && !currentUserId.equals(studentId)) {
            Student currentStudent = studentRepository.findById(currentUserId).orElse(null);
            if (currentStudent != null) {
                throw new AccessDeniedException("Students can only access their own QR code");
            }
        }

        // Validate QR code exists
        if (student.getQrCodeImage() == null || student.getQrCodeImage().isEmpty()) {
            throw new ResourceNotFoundException("QR code not found for student: " + student.getCne());
        }

        // Decode Base64 to bytes
        byte[] imageBytes = Base64.getDecoder().decode(student.getQrCodeImage());

        return QrCodeResponseDto.builder()
                .imageBytes(imageBytes)
                .filename(student.getCne() + "_qrcode.png")
                .cne(student.getCne())
                .build();
    }
}