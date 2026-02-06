package ma.uiz.fsa.management_system.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;

import java.util.Set;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ModuleRequestDto {

    @NotBlank(message = "Module title is required")
    @Size(min = 2, max = 150, message = "Module title must be between 2 and 150 characters")
    private String title;

    @NotBlank(message = "Module code is required")
    @Size(min = 2, max = 20, message = "Module code must be between 2 and 20 characters")
    private String code;

    @NotNull(message = "Credits is required")
    @Min(value = 1, message = "Credits must be at least 1")
    @Max(value = 30, message = "Credits must not exceed 30")
    private Integer credits;

    @NotNull(message = "Semester ID is required")
    private UUID semesterId;

    @Size(max = 1000, message = "Description must not exceed 1000 characters")
    private String description;

    @NotNull(message = "Passing grade is required")
    @DecimalMin(value = "0.0", message = "Passing grade must be at least 0")
    @DecimalMax(value = "20.0", message = "Passing grade must not exceed 20")
    private Double passingGrade;

    private Set<UUID> professorIds;

    @Builder.Default
    private Boolean isActive = true;
}