import hudson.model.*;
import jenkins.model.*;
import hudson.tools.*;
import hudson.plugins.gradle.*;

def env = System.getenv();
def gradleVersion = env['GRADLE_VERSION']
def gradleVersionList = gradleVersion.split(',')

def instance = Jenkins.getInstance()

Thread.start {
 sleep 10000

 println "--> Configuring Gradle"
 def gradleDescriptor = instance.getDescriptor("hudson.plugins.gradle.GradleInstallation")
 def gradleInstallations = gradleDescriptor.getInstallations()

 gradleVersionList.eachWithIndex {
  version,
  index ->
  def installer = new GradleInstaller(version)
  def installSourceProperty = new InstallSourceProperty([installer])

  def name = "ADOP Gradle_" + version

  if (index == 0) {
   name = "ADOP Gradle"
  }

  def installation = new GradleInstallation(
   name,
   "", [installSourceProperty]
  )

  def gradleIntExists = false
  gradleInstallations.each {
   currentInstallation = (GradleInstallation) it
   if (installation.getName() == currentInstallation.getName()) {
    gradleIntExists = true
    println("Found existing installation: " + installation.getName())
   }
  }

  if (!gradleIntExists) {
   gradleInstallations += installation
  }
 }

 gradleDescriptor.setInstallations((GradleInstallation[]) gradleInstallations)

 instance.save()
}
