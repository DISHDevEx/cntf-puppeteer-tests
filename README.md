# CNTF - Puppeteer Tests

## Purpose

This source code repository houses the configurations necessary to execute typical user actions, (e.g.  watching YouTube videos, browsing websites, etc.) on a User Equipment (UE) connected to a 5G network. This repository serves as a valuable resource for assessing the performance of a 5G core network in supporting these everyday user activities.

## Overview
This app combines [UERANSIM](https://github.com/aligungr/UERANSIM), [Puppeteer](https://github.com/puppeteer), and [Node.js](https://github.com/nodejs) in a Dockerfile to enable the simulation of typical UE (User Equipment) activities like web browsing and video streaming. Developers can easily create custom tests using Puppeteer and run them on UEs via UERANSIM. The application automates the creation of a Docker image with this functionality and includes an out-of-the-box test (youtube-search.js), which is then pushed to AWS ECR with a single build. Beef up UERANSIM with ease! 

## Deployment
Prerequisites:

* *Please ensure that you have configured the AWS CLI to authenticate to an AWS environment where you have adequate permissions to create an EKS cluster, security groups and IAM roles*: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html
* *Please ensure that the pipeline in the "CNTF-Main" repository has been successfully deployed, as this ensures that all necessary components are available to support the execution of scripts in this repository.*  


Steps:
1. [Mirror](https://docs.gitlab.com/ee/user/project/repository/mirror/) this repository OR connect it [externally](https://docs.gitlab.com/ee/ci/ci_cd_for_external_repos/) to Gitlab
2. Perform a "Git clone" of this repository on your local machine 
3. Set up a private Gitlab runner on the CNTF EKS cluster (***Note:*** *You only need to do this process once, this runner can be used by the other CNTF repositories you execute*):
    * In Gitlab, on the left side of the screen, hover over "settings" and select "CI/CD"
    * Next to "Runners" select "expand"
    * Unselect "Enable shared runners for this project"
    * Click "New project runner"
    * Under "Operating systems" select "Linux"
    * Fill out the "Tags" section and select "Run untagged jobs"
    * Scroll to the bottom and select "Create runner"
    * Copy and save the "runner token" listed under "Step 1"
    * Select "Go to runners page", you should now see your runner listed with a warning sign next to it under "Assigned project runners"
    * On your local terminal:
        * Install the helm gitlab repository: `helm repo add gitlab https://charts.gitlab.io`
        * intialize helm (for helm version 2): `helm init` 
        * create a namespace for your gitlab runner(s) in the cntf cluster: `kubectl create namespace <NAMESPACE (e.g. "gitlab-runners")>`
        * Install your created runner via helm: 
        `helm upgrade --install <RUNNER_NAME> -n <NAMESPACE> --set runnerRegistrationToken=<RUNNER_TOKEN> gitlabUrl=http://www.gitlab.com gitlab/gitlab-runner`
        * Check to see if your runner is working: `kubectl get pods -n <NAMESPACE>` (you should see "1/1" under "READY" and "Running" under "STATUS")
        * Give your runner cluster-wide permissions: `kubectl apply -f gitlab-runner-rbac.yaml`
    * In Gitlab, Under "Assigned project runners" you should now see that your runner has a green circle next to it, signaling a "ready" status
    * **How to re-use this runner for other CNTF repositories:**
        * Hover over "Settings" and select "CI/CD"
        * Under "Other available runners", find the runner you have created and select "Enable for this project"
        
4. Authenticate [Gitlab with AWS](https://docs.gitlab.com/ee/ci/cloud_deployment/)
5. Run the CI/CD pipeline:
    * On the left side of the screen click the drop-down arrow next to "Build" and select "Pipelines"
    * In the top right hand corner select "Run Pipeline"
    * In the drop-down under "Run for branch name or tag" select the appropriate branch name and click "Run Pipeline"
    * Once again, click the drop-down arrow next to "Build" and select "Pipelines", you should now see the pipeline being executed

## Coralogix Dashboards
To view parsed & visualized data resulting from tests run by various CNTF repositories, please visit CNTF's dedicated Coralogix tenant: https://dish-wireless-network.atlassian.net/wiki/spaces/MSS/pages/509509825/Coralogix+CNTF+Dashboards
* Note: *You must have an individual account created by Coralogix to gain access to this tenant.*
    
Steps to view dashboards:
1. At the top of the page select the dropdown next to "Dashboards"
2. Select "Custom Dashboards" (All dashboards should have the tag "CNTF")

Raw data: To view raw data resulting from test runs, please look at the data stored in AWS S3 buckets dedicated to CNTF.

## Project Structure
```
├── open5gs
|   ├── infrastructure                 contains infrastructure-as-code and helm configurations for open5gs & ueransim
|      	├── eks
|           └── fluentd-override.yaml  configures fluentd daemonset within the cluster
|           └── otel-override.yaml     configures opentelemtry daemonset within the cluster
|           └── provider.tf
|           └── main.tf                    
|           └── variables.tf                
|           └── outputs.tf 
|           └── versions.tf
|
└── .gitlab-ci.yml                     contains configurations to run CI/CD pipeline
|
|
└── README.md  
|
|
└── youtube-network-requests.txt       stores general data for youtube video running over 5g network locally
└── youtube-pupeteer-load-time.txt     stores download time for youtube video running over 5g network locally
└── youtube-pupeteer-screenshot.png    stores screenshot of youtube video running over 5g network locally
|
|
└── s3_test_results_coralogix.py       converts local files into s3 objects 
|  
|
└── update_test_results.sh             updates test result data from custom pupeteer pod(s) both locally and in aws                                           
```
## Gitlab CI
**Pipeline Stages:**
* test - creates a ueransim pod with the custom youtube script installed and performs the test while connected to the 5g network
* update_tests - update test results locally and in AWS
* cleanup - removes the youtube pod from the eks cluster 

**Note:** *In the "test" stage of the pipeline, you have the option to either run the puppeteer test using the public docker image (default setup) or specify an image stored in an AWS ECR repository. If you wish to use the image stored in your private AWS ECR repository, please look at the comments given in the ".gitabl-ci.yml" file.*

## Installation Guide 

 **Prerequisites**

  - Basic knowladge of AWS, Open5Gs and UERANSIM
  - AWS account with Open5Gs & UERANSIM deployed 
  -  S3 buckets as targets for test results 
  - Gitlab account connected to AWS

**Steps**
1. Set up 5gs and ueransim See: [NAPP](https://github.com/DISHDevEx/napp)
2. Deploy our CI script with custom varibles
   - Required: gitlab.yml Varibles section 
   - Optional: Test result paths in youtube-search.js
       - screenshotPath
       - loadTimePath
       - networkRequestsPath
4. Schedule tests 

## File Docs 

### Puppeteer Tests 
**Overview** This app has 3 puppeteer tests, (1) youtube-search.js, (2)amazon-search.js, (3) dev-tools.js. Currently, only youtube-search.js is functional, the other tests require developers to contribute to. 


**Routing traffic through UEs**

UERANSIM uses network interfaces to route traffic through a UE rather than over the internet. This is typically done using UESIMTUN.
When performing a Ping using a UE connected to the 5G core the command would look like this 
```
ping -I uesimtun6 google.com
```
We have developed a work-a-round to this while using puppeteer to run tests on UEs. You can see this in the youtube-search.js on line 17, with the function called getInterfaceIp. This function finds the default network interface of an EC2, **eth0**, and tells the puppeteer test to ignore it while accessing the internet. Eth0 should be the only public network interface in your AWS enviroment. By ignoring **eth0**, the puppeteer test will use an interface created by UERANSIM for a UE connected to your 5G core.

**Telemetry collection**

We create logs and write them to external files for monitoring the youtube-search.js test. 
(1) Load time
  - this log tells us how long it took to run the entire test, measured in ms
(2) Network Requests
  - This logs give us more verbose feedback on network requests made in this test. It gives us:
      - Response status
      - URL
      - single response time

## CI Script

**Overview of CI/CD script:** this script leverages Kaniko to build a Docker image from a provided Dockerfile, using the specified context and configuration for ECR, and then pushes the image to the specified ECR repository with the defined tag.

1. **build-and-push-to-ecr**: This is the name of the GitLab CI job. It is descriptive and suggests that the job will build and push a Docker image to ECR.

2. **Stage**: build: This specifies that the job belongs to the "build" stage in the CI/CD pipeline. Jobs in the same stage are executed together.

3. **Variables**:: This section defines environment variables used within the job.

   1. **AWS\_DEFAULT\_REGION**: us-east-1: 

      1. This sets the AWS region to "us-east-1" for the AWS CLI and SDK operations.

   2. **CI\_REGISTRY\_IMAGE**: “image\_destination”  

      1. This variable holds the ECR repository's full image URI.

   3. **IMAGE\_TAG**: 3.2.6: 

      1. This variable stores the tag that will be applied to the Docker image being built.

4. **image**: This section specifies the Docker image to be used for the job's execution.

   1. **name**: gcr.io/kaniko-project/executor:debug: 

      1. This sets the Docker image that GitLab CI will use as the job's execution environment. It's using the Kaniko executor image, which is designed for building container images inside Kubernetes or other containerized environments.

   2. **entrypoint**: \[""]: 

      1. This clears the default entrypoint for the image, allowing custom commands to be executed.

5. **Script**: This section contains the actual commands to be executed within the job.

   1. **mkdir -p /kaniko/.docker**: 
1. This command creates a directory where the Kaniko executor will store Docker configuration files.

   2. **echo "{\\"credsStore\\":\\"ecr-login\\"}" > /kaniko/.docker/config.json**: 

      1. This command generates a Docker configuration JSON file that specifies ECR credentials should be stored using the ecr-login credential helper.

   3. **/kaniko/executor**: 

      1. This is the main command for building the Docker image using Kaniko.

      2. **--context "${CI\_PROJECT\_DIR}"**: 

         1. This specifies the context (source directory) for the build. ${CI\_PROJECT\_DIR} is an environment variable pointing to the root of the GitLab repository.

      3. **--dockerfile "${CI\_PROJECT\_DIR}/Dockerfile"**:

         1.  This points to the Dockerfile within the repository that should be used for building the image.

      4. **--destination "${CI\_REGISTRY\_IMAGE}:${IMAGE\_TAG}"**: 

         1. This specifies the destination ECR repository and tag for the built image.





