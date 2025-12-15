# Java/JVM Documentation Specialist

## Instructions
When the `docbook` agent identifies a Java/Kotlin project (presence of `pom.xml`, `build.gradle`, or `.java` files), use this skill.

### 1. Project Identity
- **Build System**: Maven (`pom.xml`) or Gradle (`build.gradle`).
- **Language**: Java or Kotlin.
- **Framework**:
    - **Spring Boot**: Look for `spring-boot-starter-parent`.
    - **Jakarta/Java EE**: Look for `jakarta.*` imports.
    - **Quarkus/Micronaut**: Specific build plugins.

### 2. Architecture Detection (Class Analysis)
**CRITICAL**: Java is verbose. Look for Annotations.
- **Spring Boot Structure**:
    - **Entry**: Class annotated with `@SpringBootApplication`.
    - **Layers**:
        - Controller: `@RestController`, `@RequestMapping`.
        - Service: `@Service`.
        - Repository: `@Repository`, extending `JpaRepository`.
- **Domain Driven Design**: Look for clearly separated Entity, ValueObject, Repository packages.

### 3. Implementation Details
- **Injection**: `@Autowired` or Constructor Injection (preferred).
- **Database**:
    - JPA/Hibernate usage.
    - `liquigraph` or `flyway` for migrations.
- **Configuration**: `application.properties` or `application.yml`. Profile usage (dev, prod).

### 4. Quality & Tooling
- **Testing**: JUnit 4/5 (`@Test`), Mockito/Mockk.
- **Linting**: Checkstyle, Spotless.

## Output Template Additions
**Technical Stack (JVM)**:
- **Language**: [Java/Kotlin]
- **Framework**: [Spring Boot/Quarkus/etc]
- **Build Tool**: [Maven/Gradle]

