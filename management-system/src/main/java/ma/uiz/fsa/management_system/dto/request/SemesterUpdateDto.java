package ma.uiz.fsa.management_system.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SemesterUpdateDto {

    @Size(min = 2, max = 50, message = "Semester name must be between 2 and 50 characters")
    private String name;

    @Size(max = 20, message = "Academic year must not exceed 20 characters")
    @Pattern(regexp = "^\\d{4}-\\d{4}$", message = "Academic year must be in format YYYY-YYYY")
    private String academicYear;

    @Min(value = 1, message = "Semester number must be at least 1")
    @Max(value = 10, message = "Semester number must not exceed 10")
    private Integer semesterNumber;

    private UUID filiereId;

    @Size(max = 500, message = "Description must not exceed 500 characters")
    private String description;

    private Boolean isActive;
}