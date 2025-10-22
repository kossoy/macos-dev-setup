# Java Development Environment

Complete Java setup with SDKMAN for version management, Maven, Gradle, and Spring Boot.

## Prerequisites

- [System Setup](01-system-setup.md) completed
- Homebrew installed
- Xcode Command Line Tools installed

## 1. SDKMAN (Java Version Manager)

SDKMAN is the recommended way to manage Java versions and build tools on macOS.

```bash
# Install SDKMAN
curl -s "https://get.sdkman.io" | bash

# Reload shell to activate SDKMAN
source ~/.zshrc

# Verify installation
sdk version
```

## 2. Install Java

### Install Multiple Java Versions

```bash
# List available Java versions
sdk list java

# Install SAP Machine JDK (recommended for SAP/enterprise work)
sdk install java 21.0.8-sapmchn
sdk install java 23.0.2-sapmchn
sdk install java 24.0.2-sapmchn
sdk install java 25-sapmchn

# Or install other distributions
sdk install java 21.0.1-oracle      # Oracle JDK
sdk install java 21.0.1-tem         # Eclipse Temurin
sdk install java 21.0.1-amzn        # Amazon Corretto

# Set default Java version
sdk default java 21.0.8-sapmchn

# Verify installation
java --version
javac --version
```

### Switch Between Java Versions

```bash
# Use specific version in current shell
sdk use java 23.0.2-sapmchn

# Check current version
sdk current java

# List installed versions
sdk list java | grep installed

# Set default for new shells
sdk default java 21.0.8-sapmchn
```

## 3. Build Tools

### Maven

```bash
# Install Maven
sdk install maven

# Verify installation
mvn --version

# Install specific version (if needed)
sdk install maven 3.9.5

# List available versions
sdk list maven
```

### Gradle

```bash
# Install Gradle
sdk install gradle

# Verify installation
gradle --version

# Install specific version (if needed)
sdk install gradle 8.5

# List available versions
sdk list gradle
```

## 4. Spring Boot CLI

```bash
# Install Spring Boot CLI via Homebrew
brew tap spring-io/tap
brew install spring-boot

# Verify installation
spring --version

# Get help
spring help

# Create new Spring Boot project
spring init --dependencies=web,data-jpa my-spring-app
cd my-spring-app
```

### Spring Initializr (Alternative)

```bash
# Create project with Spring Initializr
spring init \
  --dependencies=web,data-jpa,postgresql \
  --build=maven \
  --java-version=21 \
  --packaging=jar \
  my-app

# Or use the web interface
# https://start.spring.io
```

## 5. Java Project Templates

### Basic Maven Project

```bash
# Create new Maven project
mkdir -p ~/work/projects/personal/my-java-app
cd ~/work/projects/personal/my-java-app

# Create pom.xml
cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>my-java-app</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <maven.compiler.source>21</maven.compiler.source>
        <maven.compiler.target>21</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencies>
        <!-- JUnit 5 for testing -->
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>5.10.0</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.1.2</version>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# Create source directories
mkdir -p src/main/java/com/example
mkdir -p src/test/java/com/example

# Create main class
cat > src/main/java/com/example/Main.java << 'EOF'
package com.example;

public class Main {
    public static void main(String[] args) {
        System.out.println("Hello, Java!");
    }
}
EOF

# Build and run
mvn clean package
java -jar target/my-java-app-1.0-SNAPSHOT.jar
```

### Basic Gradle Project

```bash
# Create new Gradle project
mkdir -p ~/work/projects/personal/my-gradle-app
cd ~/work/projects/personal/my-gradle-app

# Initialize Gradle project
gradle init --type java-application --dsl groovy --test-framework junit-jupiter

# Or create build.gradle manually
cat > build.gradle << 'EOF'
plugins {
    id 'java'
    id 'application'
}

group = 'com.example'
version = '1.0-SNAPSHOT'
sourceCompatibility = '21'

repositories {
    mavenCentral()
}

dependencies {
    testImplementation 'org.junit.jupiter:junit-jupiter:5.10.0'
}

application {
    mainClass = 'com.example.Main'
}

test {
    useJUnitPlatform()
}
EOF

# Create source directories
mkdir -p src/main/java/com/example
mkdir -p src/test/java/com/example

# Build and run
gradle build
gradle run
```

### Spring Boot Project

```bash
# Create Spring Boot project
spring init \
  --dependencies=web,data-jpa,postgresql,lombok \
  --build=maven \
  --java-version=21 \
  --packaging=jar \
  --group-id=com.example \
  --artifact-id=my-spring-app \
  my-spring-app

cd my-spring-app

# Create application.properties
cat > src/main/resources/application.properties << 'EOF'
# Server Configuration
server.port=8080

# Database Configuration
spring.datasource.url=jdbc:postgresql://localhost:5432/myapp_dev
spring.datasource.username=myapp
spring.datasource.password=myapp123
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# Logging
logging.level.root=INFO
logging.level.com.example=DEBUG
EOF

# Run the application
./mvnw spring-boot:run

# Or with Gradle
./gradlew bootRun
```

## 6. Common Commands

### Maven Commands

```bash
# Clean and build
mvn clean install

# Run tests
mvn test

# Package (create JAR)
mvn package

# Skip tests
mvn install -DskipTests

# Run specific test
mvn test -Dtest=MyTestClass

# Generate project from archetype
mvn archetype:generate \
  -DgroupId=com.example \
  -DartifactId=my-app \
  -DarchetypeArtifactId=maven-archetype-quickstart \
  -DinteractiveMode=false

# Show dependency tree
mvn dependency:tree

# Update dependencies
mvn versions:display-dependency-updates
```

### Gradle Commands

```bash
# Build project
gradle build

# Run tests
gradle test

# Run application
gradle run

# Clean build
gradle clean build

# Show dependencies
gradle dependencies

# Show tasks
gradle tasks

# Build without tests
gradle build -x test

# Generate wrapper
gradle wrapper

# Use wrapper (recommended)
./gradlew build
```

### SDKMAN Commands

```bash
# List candidates (installable tools)
sdk list

# List versions of specific tool
sdk list java
sdk list maven
sdk list gradle

# Install specific version
sdk install java 21.0.1-tem

# Use version in current shell
sdk use java 21.0.1-tem

# Set default version
sdk default java 21.0.1-tem

# Show current versions
sdk current

# Upgrade SDKMAN
sdk selfupdate

# Update candidate lists
sdk update
```

## 7. Java in IntelliJ IDEA

IntelliJ IDEA provides the best Java IDE experience:

```bash
# Open project in IntelliJ IDEA (if installed via JetBrains Toolbox)
idea ~/work/projects/personal/my-java-app
```

**Key IntelliJ Features:**
- Intelligent code completion
- Built-in Maven/Gradle support
- Advanced debugging
- Spring framework support
- Database tools integration
- Docker and Kubernetes support
- Git integration
- Code refactoring tools

## 8. Environment Configuration

### Project-Specific Java Version

Create `.sdkmanrc` in your project root:

```bash
# Create .sdkmanrc
cat > .sdkmanrc << 'EOF'
java=21.0.8-sapmchn
maven=3.9.5
gradle=8.5
EOF

# SDKMAN will auto-switch when you cd into the directory
cd ~/work/projects/my-java-app
# Java version automatically switches!
```

### IntelliJ Project SDK

1. Open project in IntelliJ IDEA
2. File → Project Structure → Project
3. Set SDK to desired Java version
4. Apply changes

## 9. Troubleshooting

### JAVA_HOME Not Set

```bash
# Check if JAVA_HOME is set
echo $JAVA_HOME

# SDKMAN sets this automatically, but if needed:
export JAVA_HOME="$HOME/.sdkman/candidates/java/current"

# Add to ~/.zshrc for persistence
echo 'export JAVA_HOME="$HOME/.sdkman/candidates/java/current"' >> ~/.zshrc
```

### Maven/Gradle Not Found

```bash
# Verify SDKMAN is loaded
sdk version

# If not loaded, source it
source ~/.zshrc

# Reinstall if needed
sdk install maven
sdk install gradle
```

### Version Conflicts

```bash
# Check which Java is being used
which java
java --version

# Check SDKMAN current versions
sdk current

# Reset to default
sdk default java 21.0.8-sapmchn

# Or use specific version
sdk use java 21.0.8-sapmchn
```

### M1 Mac Compatibility

```bash
# Most Java distributions now support M1 natively
# Prefer native ARM builds:
sdk list java | grep aarch64

# SAP Machine has native M1 support
sdk install java 21.0.8-sapmchn

# Verify architecture
java -XshowSettings:properties -version 2>&1 | grep "os.arch"
# Should show: aarch64
```

## 10. Best Practices

### 1. Use SDKMAN for All Java Tools

```bash
# Don't use Homebrew for Java/Maven/Gradle
# Use SDKMAN instead for better version management
sdk install java
sdk install maven
sdk install gradle
```

### 2. Pin Project Versions

```bash
# Always create .sdkmanrc in project root
echo "java=21.0.8-sapmchn" > .sdkmanrc
echo "maven=3.9.5" >> .sdkmanrc
```

### 3. Use Maven Wrapper or Gradle Wrapper

```bash
# Maven Wrapper (commit mvnw to repo)
mvn -N io.takari:maven:wrapper

# Gradle Wrapper (commit gradlew to repo)
gradle wrapper

# Team members don't need Maven/Gradle installed
./mvnw clean install
./gradlew build
```

### 4. Separate Work and Personal Projects

```bash
# Work projects (Company)
~/work/projects/work/my-enterprise-app/

# Personal projects (PersonalOrg)
~/work/projects/personal/my-side-project/

# Use context switching
work    # Sets Git to work email
personal  # Sets Git to personal email
```

## 11. Common Dependencies

### Spring Boot Starters

```xml
<!-- Web applications -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<!-- Data JPA -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<!-- Security -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>

<!-- Testing -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
```

### Useful Libraries

```xml
<!-- Lombok -->
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <optional>true</optional>
</dependency>

<!-- MapStruct -->
<dependency>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct</artifactId>
    <version>1.5.5.Final</version>
</dependency>

<!-- Database Drivers -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
</dependency>
```

## Next Steps

Continue with:
- **[Docker & Kubernetes](05-docker-kubernetes.md)** - Containerization
- **[Databases](06-databases.md)** - Database setup
- **[IDEs & Editors](09-ides-editors.md)** - IntelliJ IDEA configuration

---

**Estimated Time**: 20 minutes  
**Difficulty**: Beginner  
**Last Updated**: October 5, 2025
