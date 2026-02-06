package ma.uiz.fsa.management_system.service;

import jakarta.validation.Valid;
import ma.uiz.fsa.management_system.dto.request.*;
import ma.uiz.fsa.management_system.dto.response.JwtResponse;
import ma.uiz.fsa.management_system.dto.response.MessageResponse;
import ma.uiz.fsa.management_system.dto.response.RefreshTokenResponse;
import ma.uiz.fsa.management_system.dto.response.UserInfoResponse;

public interface AuthService {

    JwtResponse login(LoginRequest loginRequest);

    MessageResponse registerStudent(StudentRegistrationRequest request);

    MessageResponse registerProfessor(ProfessorRegistrationRequest request);

    RefreshTokenResponse refreshToken(RefreshTokenRequest refreshTokenRequest);

    MessageResponse logout(String username);

    MessageResponse requestPasswordReset(PasswordResetRequest request);

    MessageResponse resetPassword(PasswordResetConfirmRequest request);

    MessageResponse changePassword(String username, ChangePasswordRequest request);

    UserInfoResponse getCurrentUser(String username);

    MessageResponse registerAdmin(AdminRegistrationRequest request);

    MessageResponse registerSuperAdmin(@Valid AdminRegistrationRequest request);
}