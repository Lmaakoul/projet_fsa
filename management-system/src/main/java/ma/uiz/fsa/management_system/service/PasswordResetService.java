package ma.uiz.fsa.management_system.service;

import ma.uiz.fsa.management_system.model.entity.PasswordResetToken;
import ma.uiz.fsa.management_system.model.entity.User;

import java.util.Optional;

public interface PasswordResetService {

    PasswordResetToken createPasswordResetToken(User user);

    Optional<PasswordResetToken> findByToken(String token);

    PasswordResetToken verifyToken(String token);

    void markTokenAsUsed(PasswordResetToken token);

    void deleteExpiredTokens();
}