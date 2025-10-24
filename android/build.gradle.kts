allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Use default per-project build directories to avoid cross-drive issues on Windows.
// Overriding build directories for subprojects can cause errors when plugin
// sources are on a different drive (e.g., C:) than the app (e.g., Z:).
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
