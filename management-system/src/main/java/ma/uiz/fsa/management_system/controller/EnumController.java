package ma.uiz.fsa.management_system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import ma.uiz.fsa.management_system.model.enums.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/enums")
@RequiredArgsConstructor
@Tag(name = "Enums", description = "Enum values for dropdowns and forms")
@SecurityRequirement(name = "bearerAuth")
public class EnumController {

    @GetMapping("/attendance-mode")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get attendance modes values", description = "Get all possible attendance modes values")
    public ResponseEntity<List<EnumResponse>> getAttendanceModes() {
        return ResponseEntity.ok(
                Arrays.stream(AttendanceStatus.values())
                        .map(mode -> new EnumResponse(mode.name(), formatEnumName(mode.name())))
                        .collect(Collectors.toList())
        );
    }

    @GetMapping("/attendance-status")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSOR')")
    @Operation(summary = "Get attendance status values", description = "Get all possible attendance status values")
    public ResponseEntity<List<EnumResponse>> getAttendanceStatuses() {
        return ResponseEntity.ok(
                Arrays.stream(AttendanceStatus.values())
                        .map(status -> new EnumResponse(status.name(), formatEnumName(status.name())))
                        .collect(Collectors.toList())
        );
    }

    @GetMapping("/degree-types")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get degree type values", description = "Get all possible degree types")
    public ResponseEntity<List<EnumResponse>> getDegreeTypes() {
        return ResponseEntity.ok(
                Arrays.stream(DegreeType.values())
                        .map(type -> new EnumResponse(type.name(), formatEnumName(type.name())))
                        .collect(Collectors.toList())
        );
    }

    @GetMapping("/evaluation-types")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get evaluation type values", description = "Get all possible evaluation types")
    public ResponseEntity<List<EnumResponse>> getEvaluationTypes() {
        return ResponseEntity.ok(
                Arrays.stream(EvaluationType.values())
                        .map(type -> new EnumResponse(type.name(), formatEnumName(type.name())))
                        .collect(Collectors.toList())
        );
    }

    @GetMapping("/role-types")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Get role type values", description = "Get all possible role types")
    public ResponseEntity<List<EnumResponse>> getRoleTypes() {
        return ResponseEntity.ok(
                Arrays.stream(RoleType.values())
                        .map(type -> new EnumResponse(type.name(), formatEnumName(type.name())))
                        .collect(Collectors.toList())
        );
    }

    @GetMapping("/room-types")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get room type values", description = "Get all possible room types")
    public ResponseEntity<List<EnumResponse>> getRoomTypes() {
        return ResponseEntity.ok(
                Arrays.stream(RoomType.values())
                        .map(type -> new EnumResponse(type.name(), formatEnumName(type.name())))
                        .collect(Collectors.toList())
        );
    }

    @GetMapping("/session-types")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get session type values", description = "Get all possible session types")
    public ResponseEntity<List<EnumResponse>> getSessionTypes() {
        return ResponseEntity.ok(
                Arrays.stream(SessionType.values())
                        .map(type -> new EnumResponse(type.name(), formatEnumName(type.name())))
                        .collect(Collectors.toList())
        );
    }

    private String formatEnumName(String enumName) {
        return Arrays.stream(enumName.split("_"))
                .map(word -> word.charAt(0) + word.substring(1).toLowerCase())
                .collect(Collectors.joining(" "));
    }

    // Inner class for response
    public record EnumResponse(String value, String label) {}
}