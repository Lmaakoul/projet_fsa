package ma.uiz.fsa.management_system.repository;

import ma.uiz.fsa.management_system.model.entity.Evaluation;
import ma.uiz.fsa.management_system.model.enums.EvaluationType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface EvaluationRepository extends JpaRepository<Evaluation, UUID> {

    Page<Evaluation> findByStudentId(UUID studentId, Pageable pageable);

    Page<Evaluation> findByModuleId(UUID moduleId, Pageable pageable);

    List<Evaluation> findByStudentIdAndModuleId(UUID studentId, UUID moduleId);

    Page<Evaluation> findByType(EvaluationType type, Pageable pageable);

    Page<Evaluation> findByIsValidated(Boolean isValidated, Pageable pageable);

    @Query("SELECT e FROM Evaluation e WHERE e.date BETWEEN :startDate AND :endDate")
    Page<Evaluation> findByDateBetween(
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate,
            Pageable pageable);

    @Query("SELECT e FROM Evaluation e WHERE e.student.id = :studentId AND e.date BETWEEN :startDate AND :endDate")
    List<Evaluation> findByStudentIdAndDateBetween(
            @Param("studentId") UUID studentId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    @Query("SELECT AVG((e.grade / e.maxGrade) * 20.0) FROM Evaluation e WHERE e.student.id = :studentId")
    Double calculateAverageGradeByStudent(@Param("studentId") UUID studentId);

    @Query("SELECT AVG((e.grade / e.maxGrade) * 20.0) FROM Evaluation e WHERE e.module.id = :moduleId")
    Double calculateAverageGradeByModule(@Param("moduleId") UUID moduleId);

    @Query("SELECT AVG((e.grade / e.maxGrade) * 20.0) FROM Evaluation e WHERE e.student.id = :studentId AND e.module.id = :moduleId")
    Double calculateAverageGradeByStudentAndModule(
            @Param("studentId") UUID studentId,
            @Param("moduleId") UUID moduleId);

    @Query("SELECT COUNT(e) FROM Evaluation e WHERE e.student.id = :studentId")
    Long countByStudentId(@Param("studentId") UUID studentId);

    @Query("SELECT COUNT(e) FROM Evaluation e WHERE e.module.id = :moduleId")
    Long countByModuleId(@Param("moduleId") UUID moduleId);

    @Query("SELECT e FROM Evaluation e WHERE " +
            "LOWER(e.student.firstName) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(e.student.lastName) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(e.student.cne) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(e.module.title) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    Page<Evaluation> searchEvaluations(@Param("searchTerm") String searchTerm, Pageable pageable);

    @Query("SELECT e FROM Evaluation e WHERE e.module.semester.id = :semesterId")
    Page<Evaluation> findBySemesterId(@Param("semesterId") UUID semesterId, Pageable pageable);

    @Query("SELECT e FROM Evaluation e WHERE (e.grade / e.maxGrade) * 20.0 < e.module.passingGrade")
    Page<Evaluation> findFailingGrades(Pageable pageable);

    @Query("SELECT e FROM Evaluation e WHERE e.student.id = :studentId AND (e.grade / e.maxGrade) * 20.0 < e.module.passingGrade")
    List<Evaluation> findFailingGradesByStudent(@Param("studentId") UUID studentId);
}