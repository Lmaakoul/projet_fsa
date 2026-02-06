package ma.uiz.fsa.management_system.service;

import ma.uiz.fsa.management_system.model.entity.RefreshToken;
import ma.uiz.fsa.management_system.model.entity.User;

import java.util.Optional;

public interface RefreshTokenService {

    RefreshToken createRefreshToken(User user);

    Optional<RefreshToken> findByToken(String token);

    RefreshToken verifyExpiration(RefreshToken token);

    void deleteByUser(User user);

    void revokeAllUserTokens(User user);
}