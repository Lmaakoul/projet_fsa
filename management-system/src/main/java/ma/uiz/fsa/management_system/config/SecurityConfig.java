package ma.uiz.fsa.management_system.config;

import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.security.CustomAccessDeniedHandler;
import ma.uiz.fsa.management_system.security.UserDetailsServiceImpl;
import ma.uiz.fsa.management_system.security.jwt.JwtAuthenticationEntryPoint;
import ma.uiz.fsa.management_system.security.jwt.JwtAuthenticationFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfigurationSource;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final UserDetailsServiceImpl userDetailsService;
    private final JwtAuthenticationEntryPoint authenticationEntryPoint;
    private final CustomAccessDeniedHandler accessDeniedHandler;
    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final PasswordEncoder passwordEncoder;
    private final CorsConfigurationSource corsConfigurationSource;

    @Bean
    public AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder);
        return authProvider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(cors -> cors.configurationSource(corsConfigurationSource))
                .exceptionHandling(exception -> exception
                        .authenticationEntryPoint(authenticationEntryPoint)
                        .accessDeniedHandler(accessDeniedHandler)
                )
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )
                .authorizeHttpRequests(auth -> auth
                        // Swagger/OpenAPI endpoints - MUST BE FIRST
                        .requestMatchers(
                                "/v3/api-docs/**",
                                "/v3/api-docs.yaml",
                                "/swagger-ui/**",
                                "/swagger-ui.html",
                                "/swagger-resources/**",
                                "/configuration/**",
                                "/webjars/**"
                        ).permitAll()

                        // Public endpoints
                        .requestMatchers("/api/auth/**").permitAll()
                        .requestMatchers("/api/public/**").permitAll()

                        // Admin endpoints
                        .requestMatchers("/api/admin/**").hasRole("ADMIN")

                        // Professor endpoints
                        .requestMatchers("/api/professors/**").hasAnyRole("ADMIN", "PROFESSOR")

                        // Student endpoints
                        .requestMatchers("/api/students/**").hasAnyRole("ADMIN", "PROFESSOR", "STUDENT")

                        // Department & Filiere management (Admin only)
                        .requestMatchers("/api/departments/**").hasRole("ADMIN")
                        .requestMatchers("/api/filieres/**").hasRole("ADMIN")

                        // Module management (Admin & Professor)
                        .requestMatchers("/api/modules/**").hasAnyRole("ADMIN", "PROFESSOR")

                        // Session management (Professor)
                        .requestMatchers("/api/sessions/**").hasAnyRole("ADMIN", "PROFESSOR")

                        // Attendance (Professor can mark, Student can view)
                        .requestMatchers("/api/attendance/mark/**").hasAnyRole("ADMIN", "PROFESSOR")
                        .requestMatchers("/api/attendance/**").hasAnyRole("ADMIN", "PROFESSOR", "STUDENT")

                        // Evaluation (Professor can create, Student can view)
                        .requestMatchers("/api/evaluations/create/**").hasAnyRole("ADMIN", "PROFESSOR")
                        .requestMatchers("/api/evaluations/**").hasAnyRole("ADMIN", "PROFESSOR", "STUDENT")

                        // QR Code operations
                        .requestMatchers("/api/qrcode/**").hasAnyRole("ADMIN", "PROFESSOR", "STUDENT")

                        // All other requests require authentication
                        .anyRequest().authenticated()
                )
                .authenticationProvider(authenticationProvider())
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}