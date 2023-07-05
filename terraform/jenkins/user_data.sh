#!/bin/bash

apt-get update -y
apt-get install -y openjdk-11-jdk

# Debian/Ubuntu LTS release
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Docker
apt-get update
apt-get install ca-certificates curl gnupg unzip -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

export JENKINS_HOME=/var/lib/jenkins/
export REF=/usr/share/jenkins/ref

mkdir -p $JENKINS_HOME

apt-get update -y
apt-get install -y jenkins docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

wget https://raw.githubusercontent.com/jenkinsci/docker/master/jenkins-plugin-cli.sh -O /var/lib/jenkins/jenkins-plugin-cli.sh
chmod +x /var/lib/jenkins/jenkins-plugin-cli.sh

usermod -aG docker jenkins

# export PLUGIN_CLI_VERSION=2.12.11
export PLUGIN_CLI_URL=https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/${PLUGIN_CLI_VERSION}/jenkins-plugin-manager-${PLUGIN_CLI_VERSION}.jar
curl -fsSL $${PLUGIN_CLI_URL} -o /opt/jenkins-plugin-manager.jar

# Create knownhost for github
mkdir -p /var/lib/jenkins/.ssh
ssh-keyscan github.com >> /var/lib/jenkins/.ssh/known_hosts

# Create plugin.txt
cat << EOF > /var/lib/jenkins/plugins.txt
configuration-as-code
job-dsl

blueocean
workflow-job
workflow-cps

matrix-auth

github:1.37.1
junit:1214.va_2f9db_3e6de0
pipeline-groovy-lib:656.va_a_ceeb_6ffb_f7
EOF

# Install plugins
/var/lib/jenkins/jenkins-plugin-cli.sh \
    --plugin-download-directory /var/lib/jenkins/plugins/ \
    --war /usr/share/java/jenkins.war \
    --plugin-file /var/lib/jenkins/plugins.txt  

# Set Jenkins config
export CASC_JENKINS_DIR=/var/lib/jenkins/casc_configs
export CASC_JENKINS_CONFIG=/var/lib/jenkins/casc_configs/jenkins.yaml
mkdir -p /var/lib/jenkins/casc_configs

# Create /tmp/gitlab_private file from base64 encoded string
echo ${GITLAB_PRIVATE_KEY} | base64 -d > /tmp/gitlab_private

cat << EOF > $CASC_JENKINS_CONFIG
jenkins:
  systemMessage: "Example of configuring credentials in Jenkins"
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: "admin"
          password: "admin"
        - id: "dev"
          password: "dev"
  # authorizationStrategy: loggedInUsersCanDoAnything
  authorizationStrategy:
    globalMatrix:
      permissions:
        - "Job/Build:dev"
        - "Job/Cancel:dev"
        - "Job/Read:dev"
        - "Job/Workspace:dev"
        - "Overall/Administer:admin"
        - "Overall/Read:authenticated"
        - "Run/Replay:dev"
        - "Run/Update:dev"

  # make sure our jenkins master has 1 executor so that we can run our pipelines
  numExecutors: 1

#   gitHubPluginConfig:
#     hookUrl: "http://${LB_URL}:8080/github-webhook/"
#   junitTestResultStorage:
#     storage: "file"
#   location:
#     adminAddress: "address not configured yet <nobody@nowhere>"
#     url: "http://${LB_URL}:8080/"

credentials:
  system:
    domainCredentials:
      - credentials:
          - basicSSHUserPrivateKey:
              scope: GLOBAL
              id: github
              username: ${SSH_USERNAME}
              passphrase: "${SSH_KEY_PASSWORD}"
              description: "Created by Terraform"
              privateKeySource:
                directEntry:
                  privateKey: "{readFile:/tmp/gitlab_private}" # Path to file loaded from Environment Variable
          - string:
              scope: GLOBAL
              id: "docker-repository-name"
              secret: "${DRNAME}"
              description: "Created by Terraform"
          - string:
              scope: GLOBAL
              id: "aws-account-id"
              secret: "${AWSACCOUNTID}"
              description: "Created by Terraform"
          - string:
              scope: GLOBAL
              id: "aws-vpc-id"
              secret: "${AWSVPCID}"
              description: "Created by Terraform"
jobs:
  - file: $CASC_JENKINS_DIR/example-job.groovy
tool:
  git:
    installations:
      - name: git
        home: /bin/git
      - name: another_git
        home: /usr/local/bin/git
EOF

# add dollar sign to front of readFile in jenkins.yaml
sed -i 's/{readFile/${"$"}{readFile/g' $CASC_JENKINS_CONFIG

# create example job
cat << EOF > $CASC_JENKINS_DIR/example-job.groovy
pipelineJob("example-job") {
	description("Example PipelineJob")
	displayName("Example Pipeline")
	keepDependencies(false)
	definition {
		cpsScm {
      lightweight(true)
			scm {
				git {
					remote {
						github("sknight80/cyware-sre-coding-challenge", "ssh")
						credentials("github")
					}
					branch("*/main")
          extensions {
            cleanBeforeCheckout()
          }
				}
			}
			scriptPath("pipeline/Jenkinsfile")
		}
	}
  logRotator {
    numToKeep(-1)
    daysToKeep(30)
    artifactDaysToKeep(-1)
    artifactNumToKeep(-1)
  }

	quietPeriod(5)
	disabled(false)
	configure {
		it / 'properties' / 'jenkins.model.BuildDiscarderProperty' {
			strategy {
				'daysToKeep'('31')
				'numToKeep'('30')
				'artifactDaysToKeep'('-1')
				'artifactNumToKeep'('-1')
			}
		}
		it / 'properties' / 'com.coravy.hudson.plugins.github.GithubProjectProperty' {
			'projectUrl'('https://github.com/sknight80/cyware-sre-coding-challenge/')
			displayName("Git Repo")
		}
	}
  properties {
    pipelineTriggers {
      triggers {
        githubPush()
      }
    }
  }
}
listView("Example View") {
	jobs {
		name("example-job")
	}
	columns {
		status()
		weather()
		name()
		lastSuccess()
		lastFailure()
		lastDuration()
		buildButton()
	}
}
EOF

# Extend Environment Variable with "-Dcasc.jenkins.config=/var/lib/jenkins/casc_configs -Djenkins.install.runSetupWizard=false" to /etc/systemd/system/multi-user.target.wants/jenkins.service
sed -i "s#Environment=\"JAVA_OPTS=-Djava.awt.headless=true\"#Environment=\"JAVA_OPTS=-Djava.awt.headless=true -Dcasc.jenkins.config=$CASC_JENKINS_DIR -Djenkins.install.runSetupWizard=false\"#g" /lib/systemd/system/jenkins.service
# Enable logging to file in /lib/systemd/system/jenkins.service
sed -i 's/#Environment="JENKINS_LOG=/Environment="JENKINS_LOG=/g' /lib/systemd/system/jenkins.service
systemctl daemon-reload

echo "Example variable: ${example_var}"
systemctl restart jenkins.service