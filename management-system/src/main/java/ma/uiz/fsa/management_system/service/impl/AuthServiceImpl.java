package ma.uiz.fsa.management_system.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.uiz.fsa.management_system.dto.request.*;
import ma.uiz.fsa.management_system.dto.response.JwtResponse;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.dto.response.RefreshTokenResponse;
import ma.uiz.fsa.management_system.dto.response.UserInfoResponse;
import ma.uiz.fsa.management_system.exception.BadRequestException;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.model.entity.*;
import ma.uiz.fsa.management_system.model.enums.RoleType;
import ma.uiz.fsa.management_system.repository.*;
import ma.uiz.fsa.management_system.security.jwt.JwtTokenProvider;
import ma.uiz.fsa.management_system.service.AuthService;
import ma.uiz.fsa.management_system.service.PasswordResetService;
import ma.uiz.fsa.management_system.service.RefreshTokenService;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final StudentRepository studentRepository;
    private final ProfessorRepository professorRepository;
    private final RoleRepository roleRepository;
    private final FiliereRepository filiereRepository;
    private final DepartmentRepository departmentRepository;
    private final AdminRepository adminRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final RefreshTokenService refreshTokenService;
    private final PasswordResetService passwordResetService;

    @Override
    @Transactional
    public JwtResponse login(LoginRequest loginRequest) {
        // Authenticate using email
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        loginRequest.getEmail(),
                        loginRequest.getPassword()
                )
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);

        // Get user details
        User user = userRepository.findByEmail(loginRequest.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // Generate tokens
        String accessToken = jwtTokenProvider.generateAccessToken(authentication);
        RefreshToken refreshToken = refreshTokenService.createRefreshToken(user);

        // Build response
        Set<String> roles = user.getRoles().stream()
                .map(role -> role.getName().name())
                .collect(Collectors.toSet());

        return JwtResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken.getToken())
                .tokenType("Bearer")
                .userId(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .roles(roles)
                .expiresIn(jwtTokenProvider.getExpirationDateFromToken(accessToken).getTime())
                .build();
    }

    @Override
    @Transactional
    public MessageResponse registerSuperAdmin(AdminRegistrationRequest request) {
        // Validate username
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new BadRequestException("Username is already taken");
        }

        // Validate email
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email is already in use");
        }

        // Get super admin role
        Role superAdminRole = roleRepository.findByName(RoleType.ROLE_SUPER_ADMIN)
                .orElseThrow(() -> new ResourceNotFoundException("Super Admin role not found"));

        Set<Role> roles = new HashSet<>();
        roles.add(superAdminRole);

        // Create admin
        Admin admin = Admin.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .roles(roles)
                .enabled(true)
                .accountNonExpired(true)
                .accountNonLocked(true)
                .credentialsNonExpired(true)
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .build();

        adminRepository.save(admin);

        log.info("Super admin registered successfully: {}", admin.getUsername());

        return new MessageResponse("Super admin registered successfully", true);
    }

    @Override
    @Transactional
    public MessageResponse registerAdmin(AdminRegistrationRequest request) {
        // Validate username
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new BadRequestException("Username is already taken");
        }

        // Validate email
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email is already in use");
        }

        // Get admin role
        Role adminRole = roleRepository.findByName(RoleType.ROLE_ADMIN)
                .orElseThrow(() -> new ResourceNotFoundException("Admin role not found"));

        Set<Role> roles = new HashSet<>();
        roles.add(adminRole);

        // Create admin
        Admin admin = Admin.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .roles(roles)
                .enabled(true)
                .accountNonExpired(true)
                .accountNonLocked(true)
                .credentialsNonExpired(true)
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .build();

        adminRepository.save(admin);

        log.info("Admin registered successfully: {}", admin.getUsername());

        return new MessageResponse("Admin registered successfully", true);
    }

    @Override
    @Transactional
    public MessageResponse registerStudent(StudentRegistrationRequest request) {
        // Validate username
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new BadRequestException("Username is already taken");
        }

        // Validate email
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email is already in use");
        }

        // Validate CNE
        if (studentRepository.existsByCne(request.getCne())) {
            throw new BadRequestException("CNE is already registered");
        }

        // Validate CIN
        if (studentRepository.existsByCin(request.getCin())) {
            throw new BadRequestException("CIN is already registered");
        }

        // Get filiere
        Filiere filiere = filiereRepository.findById(request.getFiliereId())
                .orElseThrow(() -> new ResourceNotFoundException("Filiere not found"));

        // Get student role
        Role studentRole = roleRepository.findByName(RoleType.ROLE_STUDENT)
                .orElseThrow(() -> new ResourceNotFoundException("Student role not found"));

        Set<Role> roles = new HashSet<>();
        roles.add(studentRole);

        // Create student
        Student student = Student.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .roles(roles)
                .enabled(true)
                .accountNonExpired(true)
                .accountNonLocked(true)
                .credentialsNonExpired(true)
                .cne(request.getCne())
                .cin(request.getCin())
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .dateOfBirth(request.getDateOfBirth())
                .filiere(filiere)
                .phoneNumber(request.getPhoneNumber())
                .address(request.getAddress())
                .build();

        studentRepository.save(student);

        log.info("Student registered successfully: {}", student.getUsername());

        return new MessageResponse("Student registered successfully", true);
    }

    @Override
    @Transactional
    public MessageResponse registerProfessor(ProfessorRegistrationRequest request) {
        // Validate username
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new BadRequestException("Username is already taken");
        }

        // Validate email
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email is already in use");
        }

        // Get department
        Department department = departmentRepository.findById(request.getDepartmentId())
                .orElseThrow(() -> new ResourceNotFoundException("Department not found"));

        // Get professor role
        Role professorRole = roleRepository.findByName(RoleType.ROLE_PROFESSOR)
                .orElseThrow(() -> new ResourceNotFoundException("Professor role not found"));

        Set<Role> roles = new HashSet<>();
        roles.add(professorRole);

        // Create professor
        Professor professor = Professor.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .roles(roles)
                .enabled(true)
                .accountNonExpired(true)
                .accountNonLocked(true)
                .credentialsNonExpired(true)
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .grade(request.getGrade())
                .department(department)
                .phoneNumber(request.getPhoneNumber())
                .officeLocation(request.getOfficeLocation())
                .specialization(request.getSpecialization())
                .build();

        professorRepository.save(professor);

        log.info("Professor registered successfully: {}", professor.getUsername());

        return new MessageResponse("Professor registered successfully", true);
    }

    @Override
    @Transactional
    public RefreshTokenResponse refreshToken(RefreshTokenRequest refreshTokenRequest) {
        String requestRefreshToken = refreshTokenRequest.getRefreshToken();

        return refreshTokenService.findByToken(requestRefreshToken)
                .map(refreshTokenService::verifyExpiration)
                .map(RefreshToken::getUser)
                .map(user -> {
                    String newAccessToken = jwtTokenProvider.generateAccessTokenFromUsername(user.getUsername());

                    return RefreshTokenResponse.builder()
                            .accessToken(newAccessToken)
                            .refreshToken(requestRefreshToken)
                            .tokenType("Bearer")
                            .expiresIn(jwtTokenProvider.getExpirationDateFromToken(newAccessToken).getTime())
                            .build();
                })
                .orElseThrow(() -> new ResourceNotFoundException("Refresh token not found"));
    }

    @Override
    @Transactional
    public MessageResponse logout(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        refreshTokenService.revokeAllUserTokens(user);

        return new MessageResponse("Logged out successfully", true);
    }

    @Override
    @Transactional
    public MessageResponse requestPasswordReset(PasswordResetRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("User not found with this email"));

        PasswordResetToken resetToken = passwordResetService.createPasswordResetToken(user);

        // TODO: Send email with reset token
        // For now, we'll just log it (in production, use an email service)
        log.info("Password reset token for user {}: {}", user.getEmail(), resetToken.getToken());
        log.info("Reset link: http://localhost:8080/api/auth/reset-password?token={}", resetToken.getToken());

        return new MessageResponse(
                "Password reset instructions have been sent to your email",
                true
        );
    }

    @Override
    @Transactional
    public MessageResponse resetPassword(PasswordResetConfirmRequest request) {
        PasswordResetToken resetToken = passwordResetService.verifyToken(request.getToken());

        User user = resetToken.getUser();
        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        passwordResetService.markTokenAsUsed(resetToken);

        // Revoke all refresh tokens for security
        refreshTokenService.revokeAllUserTokens(user);

        return new MessageResponse("Password has been reset successfully", true);
    }

    @Override
    @Transactional
    public MessageResponse changePassword(String email, ChangePasswordRequest request) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // Verify current password
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPasswordHash())) {
            throw new BadRequestException("Current password is incorrect");
        }

        // Verify new password and confirm password match
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new BadRequestException("New password and confirm password do not match");
        }

        // Update password
        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        // Revoke all refresh tokens for security
        refreshTokenService.revokeAllUserTokens(user);

        return new MessageResponse("Password changed successfully", true);
    }

    @Override
    @Transactional(readOnly = true)
    public UserInfoResponse getCurrentUser(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        Set<String> roles = user.getRoles().stream()
                .map(role -> role.getName().name())
                .collect(Collectors.toSet());

        return UserInfoResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .roles(roles)
                .enabled(user.getEnabled())
                .accountNonExpired(user.getAccountNonExpired())
                .accountNonLocked(user.getAccountNonLocked())
                .credentialsNonExpired(user.getCredentialsNonExpired())
                .build();
    }
}