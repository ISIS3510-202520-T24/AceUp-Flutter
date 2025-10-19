// Top-level build file

// ❌ Sin 'plugins { id("com.android.application") version "..."}' aquí.
// Flutter ya inyecta los plugins/versions desde settings.gradle.

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// (Opcional) Mover el directorio build a la raíz del repo
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
