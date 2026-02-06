package ma.uiz.fsa.management_system.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.uiz.fsa.management_system.exception.ResourceNotFoundException;
import ma.uiz.fsa.management_system.model.entity.*;
import ma.uiz.fsa.management_system.model.entity.Module;
import ma.uiz.fsa.management_system.model.enums.DegreeType;
import ma.uiz.fsa.management_system.model.enums.RoleType;
import ma.uiz.fsa.management_system.model.enums.RoomType;
import ma.uiz.fsa.management_system.repository.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.*;

@Component
@RequiredArgsConstructor
@Slf4j
public class DatabaseInitializer implements CommandLineRunner {

    private final DepartmentRepository departmentRepository;
    private final LocationRepository locationRepository;
    private final FiliereRepository filiereRepository;
    private final SemesterRepository semesterRepository;
    private final ModuleRepository moduleRepository;
    private final ProfessorRepository professorRepository;
    private final StudentRepository studentRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final AdminRepository adminRepository;

    private final Random random = new Random();

    // Store created entities for relationships
    private List<Department> departments;
    private List<Location> locations;
    private List<Filiere> filieres;
    private List<Semester> semesters;
    private List<Module> modules;
    private List<Professor> professors;
    private List<Student> students;

    @Override
    public void run(String... args) {
        initializeRoles();

//        log.info("=== Starting development data seeding ===");
//
//        seedAdmins();
//        seedDepartments();
//        seedLocations();
//        seedFilieres();
//        seedSemesters();
//        seedModules();
//        seedProfessors();
//        seedStudents();
//
//        log.info("=== Development data seeding completed successfully ===");
    }

    private void initializeRoles() {
        if (roleRepository.count() == 0) {
            log.info("Initializing default roles...");

            Role superAdminRole = Role.builder()
                    .name(RoleType.ROLE_SUPER_ADMIN)
                    .description("Administrator role with full access")
                    .build();

            Role adminRole = Role.builder()
                    .name(RoleType.ROLE_ADMIN)
                    .description("Administrator role with full access")
                    .build();

            Role professorRole = Role.builder()
                    .name(RoleType.ROLE_PROFESSOR)
                    .description("Professor role with teaching privileges")
                    .build();

            Role studentRole = Role.builder()
                    .name(RoleType.ROLE_STUDENT)
                    .description("Student role with learning access")
                    .build();

            roleRepository.save(superAdminRole);
            roleRepository.save(adminRole);
            roleRepository.save(professorRole);
            roleRepository.save(studentRole);

            log.info("Default roles initialized successfully");
        } else {
            log.info("Roles already exist in database");
        }
    }

    private void seedAdmins() {
        if(adminRepository.count() == 0) {
            log.info("Seeding admins...");

            Role adminRole = roleRepository.findByName(RoleType.ROLE_ADMIN)
                    .orElseThrow(() -> new RuntimeException("Admin role not found"));

            Set<Role> roles = new HashSet<>();
            roles.add(adminRole);

            Admin admin1 = Admin.builder()
                    .username("admin")
                    .email("admin@fsa.uiz.ac.ma")
                    .passwordHash(passwordEncoder.encode("admin123"))
                    .firstName("Admin")
                    .lastName("Admin")
                    .phoneNumber("+212-600-000001")
                    .enabled(true)
                    .accountNonExpired(true)
                    .accountNonLocked(true)
                    .credentialsNonExpired(true)
                    .roles(roles)
                    .build();

            Admin admin2 = Admin.builder()
                    .username("admin2")
                    .email("admin2@fsa.uiz.ac.ma")
                    .passwordHash(passwordEncoder.encode("admin123"))
                    .roles(roles)
                    .enabled(true)
                    .accountNonExpired(true)
                    .accountNonLocked(true)
                    .credentialsNonExpired(true)
                    .firstName("admin2")
                    .lastName("admin2")
                    .build();

            adminRepository.save(admin1);
            adminRepository.save(admin2);

            log.info("Created {} admins", 2);
        } else {
            log.info("Admins already exist in database");
        }
    }

    private void seedDepartments() {
        if (departmentRepository.count() == 0) {
            log.info("Seeding departments...");

            departments = new ArrayList<>();

            Department informatique = Department.builder()
                    .name("Informatique")
                    .code("INFO")
                    .description("Département d'Informatique et Systèmes d'Information")
                    .build();

            Department mathematiques = Department.builder()
                    .name("Mathématiques")
                    .code("MATH")
                    .description("Département de Mathématiques et Applications")
                    .build();

            Department physique = Department.builder()
                    .name("Physique")
                    .code("PHYS")
                    .description("Département de Physique et Sciences de l'Ingénieur")
                    .build();

            Department chimie = Department.builder()
                    .name("Chimie")
                    .code("CHIM")
                    .description("Département de Chimie et Sciences des Matériaux")
                    .build();

            departments = departmentRepository.saveAll(
                    List.of(informatique, mathematiques, physique, chimie)
            );

            log.info("Created {} departments", departments.size());
        } else {
            log.info("Departments already exist in database");
            departments = departmentRepository.findAll();  // Add this line
            log.info("Loaded {} existing departments", departments.size());
        }
    }

    private void seedLocations() {
        if(locationRepository.count() == 0) {
            log.info("Seeding locations...");

            locations = new ArrayList<>();

            String[] buildings = {"A", "B", "C", "D"};
            RoomType[] roomTypes = RoomType.values();

            for (int i = 0; i < departments.size(); i++) {
                Department dept = departments.get(i);
                String building = buildings[i];

                // Create amphitheater
                locations.add(Location.builder()
                        .building(building)
                        .roomNumber("AMPHI-" + (i + 1))
                        .roomType(RoomType.AMPHITHEATER)
                        .capacity(200)
                        .equipment("Projector, Sound System, Whiteboard")
                        .isActive(true)
                        .department(dept)
                        .notes("Large amphitheater for lectures")
                        .build());

                // Create classrooms
                for (int j = 1; j <= 5; j++) {
                    locations.add(Location.builder()
                            .building(building)
                            .roomNumber(String.format("%d0%d", i + 1, j))
                            .roomType(RoomType.CLASSROOM)
                            .capacity(40)
                            .equipment("Projector, Whiteboard")
                            .isActive(true)
                            .department(dept)
                            .build());
                }

                // Create computer labs
                for (int j = 1; j <= 3; j++) {
                    locations.add(Location.builder()
                            .building(building)
                            .roomNumber(String.format("LAB-%d0%d", i + 1, j))
                            .roomType(RoomType.COMPUTER_LAB)
                            .capacity(30)
                            .equipment("30 Computers, Projector, Network Access")
                            .isActive(true)
                            .department(dept)
                            .build());
                }

                // Create laboratories
                locations.add(Location.builder()
                        .building(building)
                        .roomNumber(String.format("PLAB-%d", i + 1))
                        .roomType(RoomType.LABORATORY)
                        .capacity(25)
                        .equipment("Lab Equipment, Safety Equipment")
                        .isActive(true)
                        .department(dept)
                        .build());
            }

            locations = locationRepository.saveAll(locations);
            log.info("Created {} locations", locations.size());
        } else {
            log.info("Locations already exist in database");
        }
    }

    private void seedFilieres() {
        if(filiereRepository.count() == 0) {
            log.info("Seeding filières...");

            filieres = new ArrayList<>();

            // Informatique department programs
            Department info = departments.get(0);
            filieres.add(Filiere.builder()
                    .name("Licence en Informatique")
                    .code("LI")
                    .degreeType(DegreeType.LICENCE)
                    .department(info)
                    .durationYears(3)
                    .isActive(true)
                    .build());

            filieres.add(Filiere.builder()
                    .name("Master en Génie Logiciel")
                    .code("MGL")
                    .degreeType(DegreeType.MASTER)
                    .department(info)
                    .durationYears(2)
                    .isActive(true)
                    .build());

            filieres.add(Filiere.builder()
                    .name("Master en Sécurité des Systèmes d'Information")
                    .code("MSSI")
                    .degreeType(DegreeType.MASTER)
                    .department(info)
                    .durationYears(2)
                    .isActive(true)
                    .build());

            // Mathématiques department programs
            Department math = departments.get(1);
            filieres.add(Filiere.builder()
                    .name("Licence en Mathématiques Appliquées")
                    .code("LMA")
                    .degreeType(DegreeType.LICENCE)
                    .department(math)
                    .durationYears(3)
                    .isActive(true)
                    .build());

            filieres.add(Filiere.builder()
                    .name("Master en Mathématiques et Applications")
                    .code("MMA")
                    .degreeType(DegreeType.MASTER)
                    .department(math)
                    .durationYears(2)
                    .isActive(true)
                    .build());

            // Physique department programs
            Department phys = departments.get(2);
            filieres.add(Filiere.builder()
                    .name("Licence en Physique")
                    .code("LP")
                    .degreeType(DegreeType.LICENCE)
                    .department(phys)
                    .durationYears(3)
                    .isActive(true)
                    .build());

            filieres.add(Filiere.builder()
                    .name("Master en Physique des Matériaux")
                    .code("MPM")
                    .degreeType(DegreeType.MASTER)
                    .department(phys)
                    .durationYears(2)
                    .isActive(true)
                    .build());

            // Chimie department programs
            Department chim = departments.get(3);
            filieres.add(Filiere.builder()
                    .name("Licence en Chimie")
                    .code("LC")
                    .degreeType(DegreeType.LICENCE)
                    .department(chim)
                    .durationYears(3)
                    .isActive(true)
                    .build());

            filieres = filiereRepository.saveAll(filieres);
            log.info("Created {} filières", filieres.size());
        } else {
            log.info("Filiers already exist in database");
        }
    }

    private void seedSemesters() {
        if(semesterRepository.count() == 0) {
            log.info("Seeding semesters...");

            semesters = new ArrayList<>();
            String currentYear = "2024-2025";

            for (Filiere filiere : filieres) {
                int numSemesters = filiere.getDurationYears() * 2;

                for (int i = 1; i <= numSemesters; i++) {
                    semesters.add(Semester.builder()
                            .name("Semestre " + i)
                            .semesterNumber(i)
                            .academicYear(currentYear)
                            .filiere(filiere)
                            .isActive(true)
                            .build());
                }
            }

            semesters = semesterRepository.saveAll(semesters);
            log.info("Created {} semesters", semesters.size());
        } else {
            log.info("Semesters already exist in database");
        }
    }

    private void seedModules() {
        if(moduleRepository.count() == 0) {
            log.info("Seeding modules...");

            modules = new ArrayList<>();

            // Module templates by subject area
            Map<String, List<String[]>> modulesBySemester = new HashMap<>();

            // CS modules (name, code, credits)
            modulesBySemester.put("INFO", List.of(
                    new String[]{"Programmation Java", "JAVA", "6"},
                    new String[]{"Bases de Données", "BD", "6"},
                    new String[]{"Développement Web", "WEB", "5"},
                    new String[]{"Structures de Données", "SD", "6"},
                    new String[]{"Algorithmes Avancés", "ALGO", "6"},
                    new String[]{"Réseaux Informatiques", "RES", "5"},
                    new String[]{"Génie Logiciel", "GL", "6"},
                    new String[]{"Intelligence Artificielle", "IA", "6"},
                    new String[]{"Sécurité Informatique", "SEC", "5"},
                    new String[]{"Systèmes d'Exploitation", "SYS", "6"}
            ));

            // Math modules
            modulesBySemester.put("MATH", List.of(
                    new String[]{"Analyse Mathématique", "ANAL", "6"},
                    new String[]{"Algèbre Linéaire", "ALG", "6"},
                    new String[]{"Probabilités et Statistiques", "PROB", "6"},
                    new String[]{"Analyse Numérique", "ANUM", "5"},
                    new String[]{"Équations Différentielles", "EQD", "5"},
                    new String[]{"Optimisation", "OPT", "5"}
            ));

            // Physics modules
            modulesBySemester.put("PHYS", List.of(
                    new String[]{"Mécanique Quantique", "MQ", "6"},
                    new String[]{"Thermodynamique", "THERMO", "6"},
                    new String[]{"Électromagnétisme", "EM", "6"},
                    new String[]{"Optique", "OPT", "5"},
                    new String[]{"Physique des Matériaux", "PM", "6"}
            ));

            // Chemistry modules
            modulesBySemester.put("CHIM", List.of(
                    new String[]{"Chimie Organique", "CORG", "6"},
                    new String[]{"Chimie Inorganique", "CINORG", "6"},
                    new String[]{"Chimie Analytique", "CANAL", "5"},
                    new String[]{"Chimie Physique", "CPHYS", "6"}
            ));

            int moduleCounter = 1;
            for (Semester semester : semesters) {
                Filiere filiere = semester.getFiliere();
                String deptCode = filiere.getDepartment().getCode();

                List<String[]> availableModules = modulesBySemester.getOrDefault(deptCode, new ArrayList<>());

                // Add 4-6 modules per semester
                int numModules = 4 + random.nextInt(3);
                for (int i = 0; i < Math.min(numModules, availableModules.size()); i++) {
                    String[] moduleData = availableModules.get(i % availableModules.size());

                    modules.add(Module.builder()
                            .title(moduleData[0])
                            .code(filiere.getCode() + "-" + moduleData[1] + "-S" + semester.getSemesterNumber())
                            .credits(Integer.parseInt(moduleData[2]))
                            .semester(semester)
                            .isActive(true)
                            .passingGrade(10.0)
                            .build());
                }
            }

            modules = moduleRepository.saveAll(modules);
            log.info("Created {} modules", modules.size());
        } else {
            log.info("Modules already exist in database");
        }
    }

    private void seedProfessors() {
        if(professorRepository.count() == 0) {
            log.info("Seeding professors...");

            professors = new ArrayList<>();

            Role professorRole = roleRepository.findByName(RoleType.ROLE_PROFESSOR)
                    .orElseThrow(() -> new RuntimeException("Professor role not found"));

            Set<Role> roles = new HashSet<>();
            roles.add(professorRole);

            String[] firstNames = {
                    "Ahmed", "Mohammed", "Fatima", "Khadija", "Hassan",
                    "Amina", "Youssef", "Sara", "Omar", "Nadia",
                    "Rachid", "Laila", "Karim", "Samira", "Abdellah"
            };

            String[] lastNames = {
                    "Alami", "Benali", "Chakir", "Diouri", "El Amrani",
                    "Fassi", "Ghazali", "Hajji", "Idrissi", "Jabri",
                    "Kadiri", "Lahlou", "Mansouri", "Naciri", "Ouazzani"
            };

            String[] grades = {"Professeur", "Professeur Assistant", "Maître de Conférences"};
            String[] specializations = {
                    "Intelligence Artificielle", "Bases de Données", "Réseaux",
                    "Génie Logiciel", "Sécurité", "Algorithmique",
                    "Analyse Mathématique", "Algèbre", "Physique Quantique",
                    "Chimie Organique", "Thermodynamique"
            };

            for (int i = 0; i < 15; i++) {
                String firstName = firstNames[i % firstNames.length];
                String lastName = lastNames[i % lastNames.length];
                String username = (firstName + "." + lastName).toLowerCase();

                Department dept = departments.get(i % departments.size());

                Professor professor = Professor.builder()
                        .username(username)
                        .email(username + "@fsa.uiz.ac.ma")
                        .passwordHash(passwordEncoder.encode("prof123"))
                        .firstName(firstName)
                        .lastName(lastName)
                        .grade(grades[i % grades.length])
                        .specialization(specializations[i % specializations.length])
                        .department(dept)
                        .phoneNumber("+212-6" + String.format("%02d", i) + "-" + String.format("%06d", 100000 + i))
                        .officeLocation(dept.getCode() + "-" + (i % 5 + 1))
                        .enabled(true)
                        .accountNonExpired(true)
                        .accountNonLocked(true)
                        .credentialsNonExpired(true)
                        .roles(roles)
                        .build();

                professors.add(professor);
            }

            professors = professorRepository.saveAll(professors);
            log.info("Created {} professors", professors.size());

            // Assign professors to modules
            assignProfessorsToModules();
        } else {
            log.info("Professors already exist in database");
        }
    }

    private void assignProfessorsToModules() {
        log.info("Assigning professors to modules...");

        for (Module module : modules) {
            // Assign 1-2 professors per module
            int numProfs = 1 + random.nextInt(2);
            Set<Professor> moduleProfessors = new HashSet<>();

            // Get professors from the same department
            Department dept = module.getSemester().getFiliere().getDepartment();
            List<Professor> deptProfessors = professors.stream()
                    .filter(p -> p.getDepartment().equals(dept))
                    .toList();

            for (int i = 0; i < Math.min(numProfs, deptProfessors.size()); i++) {
                moduleProfessors.add(deptProfessors.get(random.nextInt(deptProfessors.size())));
            }

            module.setProfessors(moduleProfessors);
        }

        moduleRepository.saveAll(modules);
    }

    private void seedStudents() {
        if (studentRepository.count() == 0) {
            log.info("Seeding students...");

            students = new ArrayList<>();

            Role studentRole = roleRepository.findByName(RoleType.ROLE_STUDENT)
                    .orElseThrow(() -> new RuntimeException("Student role not found"));

            Set<Role> roles = new HashSet<>();
            roles.add(studentRole);

            String[] firstNames = {
                    "Ali", "Ayoub", "Boutaina", "Chaimaa", "Dounia",
                    "Elmehdi", "Fatiha", "Ghita", "Hamza", "Imane",
                    "Jalal", "Kawtar", "Loubna", "Mehdi", "Nour",
                    "Oumaima", "Rajae", "Salma", "Tarik", "Yasmine"
            };

            String[] lastNames = {
                    "Amrani", "Bennis", "Chraibi", "Drissi", "Ezzahri",
                    "Fahmi", "Guerraoui", "Hammoudi", "Ismaili", "Jaafari",
                    "Khalil", "Laaroussi", "Mahfoud", "Naji", "Ouali",
                    "Qadiri", "Rahmani", "Seddik", "Tazi", "Ziani"
            };

            int studentCount = 0;

            // Create students for each filière
            for (Filiere filiere : filieres) {
                // Number of students per filière: 15-25
                int numStudents = 15 + random.nextInt(11);

                for (int i = 0; i < numStudents; i++) {
                    String firstName = firstNames[random.nextInt(firstNames.length)];
                    String lastName = lastNames[random.nextInt(lastNames.length)];
                    String username = (firstName + "." + lastName + (studentCount + 1)).toLowerCase();

                    String cne = String.format("R%09d", 130000000 + studentCount);
                    String cin = String.format("%s%06d", "BK", 100000 + studentCount);

                    int birthYear = 1998 + random.nextInt(7); // 1998-2004
                    LocalDate dateOfBirth = LocalDate.of(birthYear,
                            1 + random.nextInt(12),
                            1 + random.nextInt(28));

                    Student student = Student.builder()
                            .username(username)
                            .email(username + "@etu.fsa.uiz.ac.ma")
                            .passwordHash(passwordEncoder.encode("student123"))
                            .firstName(firstName)
                            .lastName(lastName)
                            .cne(cne)
                            .cin(cin)
                            .dateOfBirth(dateOfBirth)
                            .filiere(filiere)
                            .enabled(true)
                            .accountNonExpired(true)
                            .accountNonLocked(true)
                            .credentialsNonExpired(true)
                            .roles(roles)
                            .build();

                    students.add(student);
                    studentCount++;
                }
            }

            students = studentRepository.saveAll(students);
            log.info("Created {} students", students.size());
        } else {
            log.info("Students already exist in database");
        }
    }
}