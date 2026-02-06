package ma.uiz.fsa.management_system.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.uiz.fsa.management_system.exception.BadRequestException;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.model.entity.PasswordResetToken;
import ma.uiz.fsa.management_system.model.entity.User;
import ma.uiz.fsa.management_system.repository.PasswordResetTokenRepository;
import ma.uiz.fsa.management_system.service.PasswordResetService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class PasswordResetServiceImpl implements PasswordResetService {

    private final PasswordResetTokenRepository passwordResetTokenRepository;

    @Value("${password-reset.token-expiration:3600000}") // Default 1 hour
    private Long tokenExpirationMs;

    @Override
    @Transactional
    public PasswordResetToken createPasswordResetToken(User user) {
        PasswordResetToken resetToken = PasswordResetToken.builder()
                .user(user)
                .token(UUID.randomUUID().toString())
                .expiryDate(LocalDateTime.now().plusSeconds(tokenExpirationMs / 1000))
                .used(false)
                .createdAt(LocalDateTime.now())
                .build();

        return passwordResetTokenRepository.save(resetToken);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<PasswordResetToken> findByToken(String token) {
        return passwordResetTokenRepository.findByToken(token);
    }

    @Override
    public PasswordResetToken verifyToken(String token) {
        PasswordResetToken resetToken = findByToken(token)
                .orElseThrow(() -> new ResourceNotFoundException("Invalid password reset token"));

        if (resetToken.isExpired()) {
            throw new BadRequestException("Password reset token has expired");
        }

        if (resetToken.getUsed()) {
            throw new BadRequestException("Password reset token has already been used");
        }

        return resetToken;
    }

    @Override
    @Transactional
    public void markTokenAsUsed(PasswordResetToken token) {
        token.setUsed(true);
        passwordResetTokenRepository.save(token);
    }

    @Override
    @Transactional
    public void deleteExpiredTokens() {
        passwordResetTokenRepository.deleteExpiredTokens(LocalDateTime.now());
    }
}