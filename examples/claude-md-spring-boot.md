# Example CLAUDE.md — Java/Spring Boot Project

This example shows a CLAUDE.md for a Java backend service using Spring Boot 3, Spring Data JPA, and Gradle. It covers Java-specific conventions for package structure, dependency injection, and testing patterns that keep Claude Code generating production-quality Java.

## The CLAUDE.md File

```markdown
# Project: Acme Customer API

Java 21 + Spring Boot 3.3 REST API. Gradle build system. PostgreSQL database with Spring Data JPA.

## Commands

- `./gradlew bootRun` — start the server (port 8080)
- `./gradlew test` — run all tests
- `./gradlew test --tests "com.acme.customer.service.CustomerServiceTest"` — run a single test class
- `./gradlew test --tests "*.CustomerServiceTest.shouldCreateCustomer"` — run a single test method
- `./gradlew spotlessCheck` — check code formatting
- `./gradlew spotlessApply` — auto-format code
- `./gradlew check` — run all checks (tests + spotless + checkstyle)
- `docker compose up -d` — start PostgreSQL and Redis locally

Run `./gradlew check` before committing.

## Architecture

Standard layered Spring Boot architecture:

- `src/main/java/com/acme/customer/`
  - `controller/` — REST controllers, one per resource
  - `service/` — business logic, interfaces + implementations
  - `repository/` — Spring Data JPA repositories
  - `model/` — JPA entity classes
  - `dto/` — request/response DTOs (records)
  - `mapper/` — MapStruct mappers for entity-DTO conversion
  - `config/` — Spring configuration classes
  - `exception/` — custom exceptions and global exception handler
  - `security/` — Spring Security configuration and filters
- `src/main/resources/`
  - `application.yml` — main config
  - `application-local.yml` — local dev overrides
  - `db/migration/` — Flyway migration scripts
- `src/test/java/` — mirrors main structure

## Coding Conventions

- Java 21 features: use records for DTOs, pattern matching, sealed interfaces where appropriate
- Constructor injection only — no field injection with `@Autowired`
- Use `final` on all fields, parameters, and local variables where possible
- DTOs are Java records, not classes:

```java
public record CreateCustomerRequest(
    @NotBlank String name,
    @Email String email,
    @NotNull CustomerType type
) {}
```

- Service interfaces with single implementation: `CustomerService` interface + `CustomerServiceImpl`
- All public methods in services have Javadoc
- Use `Optional<T>` return types for single-entity lookups — never return null
- Use `lombok` only for `@Slf4j` — do not use `@Data`, `@Getter`, `@Setter` on new code (use records)

## Database

- Flyway for migrations — files in `src/main/resources/db/migration/`
- Naming: `V001__create_customers_table.sql`, `V002__add_email_index.sql`
- JPA entities use `@Entity` with explicit `@Table(name = "...")` and `@Column(name = "...")`
- Always specify column lengths and constraints in the entity
- Use `@Version` for optimistic locking on frequently updated entities
- Repositories extend `JpaRepository<T, ID>` — add custom query methods with `@Query` or derived queries

```java
@Entity
@Table(name = "customers")
public class Customer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false, length = 255)
    private String name;

    @Column(name = "email", nullable = false, unique = true)
    private String email;

    @Version
    private Long version;
}
```

## REST Controllers

```java
@RestController
@RequestMapping("/api/v1/customers")
@RequiredArgsConstructor
public class CustomerController {
    private final CustomerService customerService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CustomerResponse create(@Valid @RequestBody CreateCustomerRequest request) {
        return customerService.create(request);
    }

    @GetMapping("/{id}")
    public CustomerResponse getById(@PathVariable Long id) {
        return customerService.getById(id);
    }
}
```

- Use `@Valid` on all request body parameters
- Return DTOs, never entities
- Use `@ResponseStatus` for non-200 success codes
- Paginated endpoints return `Page<T>` with Spring's `Pageable` parameter

## Exception Handling

Global exception handler in `exception/GlobalExceptionHandler.java`:

- `@RestControllerAdvice` with `@ExceptionHandler` methods
- Custom exceptions: `ResourceNotFoundException`, `BusinessValidationException`, `ConflictException`
- Return structured error responses: `{ "error": "...", "code": "...", "timestamp": "..." }`
- Never expose stack traces or internal details in error responses

## Testing

- Unit tests: JUnit 5 + Mockito for service layer
- Integration tests: `@SpringBootTest` with Testcontainers for PostgreSQL
- Controller tests: `@WebMvcTest` with `MockMvc`
- Use `@Sql` annotation to load test data from SQL files
- Test naming: `should_[expected]_when_[condition]` — e.g., `should_throw_not_found_when_customer_missing`
- Test data builders in `src/test/java/.../fixture/`

## Git

- Conventional commits: feat:, fix:, chore:, refactor:
- One feature per PR, squash merge to main
- Run `./gradlew check` before pushing

## Do NOT

- Do not use field injection (`@Autowired` on fields)
- Do not return JPA entities from controllers — always map to DTOs
- Do not use `@Data` or `@Getter`/`@Setter` on new code — use records or write accessors
- Do not catch `Exception` or `RuntimeException` in service code — let the global handler deal with it
- Do not use `System.out.println` — use SLF4J logging (`@Slf4j`)
- Do not write business logic in controllers — delegate to the service layer
```

## Key Sections Explained

**Architecture** — Spring Boot projects have a well-defined package structure. Spelling it out prevents Claude from putting code in the wrong layer.

**Coding Conventions** — Java 21 records, constructor injection, and the `final` preference are deliberate choices. Without this section, Claude defaults to older Java patterns with Lombok and field injection.

**Database** — Flyway migration naming and explicit JPA column annotations prevent the common issue of Claude generating entities that do not match the database schema.

**Do NOT** — The field injection and entity-in-controller rules catch the two most common Spring Boot mistakes Claude makes. Being explicit about these prevents code review friction.

## See Also

- [CLAUDE.md Setup Guide](../guides/claude-md-guide.md) — how to structure your own CLAUDE.md
- [Minimal Example](./claude-md-minimal.md) — a simpler starting point
- [Python Example](./claude-md-python.md) — for Python backend projects
- [Go Example](./claude-md-go.md) — for Go microservices
