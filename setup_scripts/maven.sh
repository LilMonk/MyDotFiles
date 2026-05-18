# MAVEN
# https://linuxize.com/post/how-to-install-apache-maven-on-ubuntu-20-04/
sudo apt install maven

# Alternate way
MAVEN_VERSION=3.9.9
sudo mkdir -p /usr/local/apache-maven/

# Download and extract Maven in one step
wget -c https://dlcdn.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz -O - | sudo tar -xz -C /usr/local/apache-maven/ --strip-components=1

# Download the .zip or .tar.gz file from official site.
# Extract it into /usr/local/apache-maven/apache-maven-<version>
# Add this to the .zshrc or .bashrc
export M2_HOME=/usr/local/apache-maven/apache-maven-$MAVEN_VERSION
export M2=$M2_HOME/bin
export PATH=$M2:$PATH