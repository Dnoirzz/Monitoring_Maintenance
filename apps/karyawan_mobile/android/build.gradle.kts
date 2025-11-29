allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Removed custom build directory configuration to fix plugin conflicts
// Build directory will use default location (android/build/)

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
