allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Force tous les plugins (dont le SDK Jitsi Meet) a compiler avec la
// meme version d Android que le module principal, meme si leur propre
// configuration interne demande une version plus ancienne. Ce bloc
// doit etre declare AVANT evaluationDependsOn ci-dessous, sinon Gradle
// refuse d y attacher un afterEvaluate (deja evalue trop tot).
subprojects {
    afterEvaluate {
        val androidExtension = project.extensions.findByType(com.android.build.gradle.BaseExtension::class.java)
        androidExtension?.compileSdkVersion(36)
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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
