buildscript {
    // ════════════════════════════════════════════════════════════
    // 🔧 Extra Properties (Versions)
    // ════════════════════════════════════════════════════════════
    extra.apply {
        set("kotlinVersion", "2.1.0")
    }

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // ✅ Android Gradle Plugin
        classpath("com.android.tools.build:gradle:8.7.3")

        // ✅ Kotlin Gradle Plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")

        // ✅ Google Services Plugin (محدّث!)
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ════════════════════════════════════════════════════════════
// 🔧 Custom Build Directory Configuration
// ════════════════════════════════════════════════════════════
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ════════════════════════════════════════════════════════════
// 🔧 Subproject Configuration
// ════════════════════════════════════════════════════════════
subprojects {
    project.evaluationDependsOn(":app")
}

// ════════════════════════════════════════════════════════════
// 🔧 Suppress Java obsolete options warnings for all plugins
// Uses -Xlint:-options as Gradle itself recommends
// ════════════════════════════════════════════════════════════
subprojects {
    tasks.withType<JavaCompile>().configureEach {
        options.compilerArgs.addAll(listOf("-Xlint:-options"))
    }
}

// ════════════════════════════════════════════════════════════
// 🧹 Clean Task
// ════════════════════════════════════════════════════════════
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}