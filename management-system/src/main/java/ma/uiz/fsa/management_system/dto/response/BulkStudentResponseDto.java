package ma.uiz.fsa.management_system.dto.response;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BulkStudentResponseDto {

    private int totalRequested;
    private int successCount;
    private int failureCount;
    private List<StudentResponseDto> createdStudents;
    private List<BulkOperationError> errors;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class BulkOperationError {
        private int index;
        private String email;
        private String cne;
        private String errorMessage;
    }
}