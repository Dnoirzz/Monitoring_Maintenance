allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.set(File(rootProject.projectDir, "../build"))
subprojects {
    project.layout.buildDirectory.set(File(rootProject.layout.buildDirectory.asFile.get(), project.name))
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
