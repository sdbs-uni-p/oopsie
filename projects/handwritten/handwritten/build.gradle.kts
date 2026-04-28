import org.checkerframework.plugin.gradle.CheckerFrameworkExtension

plugins {
    id("java")
    id("org.checkerframework") version("1.0.2")
}

repositories {
    mavenCentral()
    mavenLocal()
}

checkerFramework {
    version = "dependencies"
}

dependencies {
    checkerQual("io.github.eisop:checker-qual:3.49.5-eisop1")
    checkerFramework("io.github.eisop:checker:3.49.5-eisop1")

    compileOnly("io.github.eisop:opsc:0.0.1-SNAPSHOT-java8")
    checkerFramework("io.github.eisop:opsc:0.0.1-SNAPSHOT-java8")

    implementation("org.hibernate:hibernate-core:3.6.10.Final")
    implementation("commons-codec:commons-codec:1.16.0")
}

configure<CheckerFrameworkExtension> {
    checkers = listOf("io.github.eisop.opsc.OpsChecker")
}

checkerFramework {
    extraJavacArgs = listOf(
        "-Awarns",
        "-AnonNullStringsConcatenation=true",
        "-AdbUrl=jdbc:postgresql://localhost:5432/handwritten",
        "-AdbUser=postgres",
        "-AdbPassword=postgres",
        "-Awarns",
        "-AopsLogDir={{{opslogdir}}}"
    )
}

tasks {
    compileJava {
        options.encoding = "UTF-8"
    }
}