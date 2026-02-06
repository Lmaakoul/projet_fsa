package ma.uiz.fsa.management_system.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;
import ma.uiz.fsa.management_system.model.enums.DegreeType;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FiliereRequestDto {

    @NotBlank(message = "Filiere name is required")
    @Size(min = 2, max = 100, message = "Filiere name must be between 2 and 100 characters")
    private String name;

    @NotBlank(message = "Filiere code is required")
    @Size(min = 2, max = 10, message = "Filiere code must be between 2 and 10 characters")
    private String code;

    @NotNull(message = "Degree type is required")
    private DegreeType degreeType;

    @NotNull(message = "Department ID is required")
    private UUID departmentId;

    @Size(max = 1000, message = "Description must not exceed 1000 characters")
    private String description;

    @NotNull(message = "Duration in years is required")
    @Min(value = 1, message = "Duration must be at least 1 year")
    private Integer durationYears;

    @Builder.Default
    private Boolean isActive = true;
}