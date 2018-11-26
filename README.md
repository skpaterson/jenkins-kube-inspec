# Jenkins on Kubernetes with InSpec 

Steps from the following tutorial [GoogleCloudPlatform/continuous-deployment-on-kubernetes](https://github.com/GoogleCloudPlatform/continuous-deployment-on-kubernetes) are condensed into a single bash script to quickly set up Jenkins on Kubernetes (GKE) on GCP.  InSpec is used to subsequently test the infrastructure and Jenkins setup.

## Prerequisites

* Google Cloud Platform account
* [Google Compute Engine and Google Container Engine APIs Enabled](https://console.cloud.google.com/flows/enableapi?apiid=compute_component,container)
* [gcloud installed](https://cloud.google.com/sdk/docs/) and configured for your project
* OpenSSL  
* InSpec 
* Git
* Kubectl

Ensure that your target GCP project is correct by running:
```
$ gcloud config set project my-project-id
```

InSpec and dependencies can be installed via the [Gemfile](Gemfile) in this repository e.g.

```bash
$ gem install bundler
$ bundle install 
```

## Set Desired Configuration

Sensible defaults are in place for the installation script as shown below.  However, the following can be customized through environment variables.  Below shows the default values if nothing is set:

```
export GCP_REGION=europe-west2
export GCP_ZONE=europe-west2-a
```

## Run the Installation Script

The installation script uses the following default values that can be overridden as environment variables e.g.

```
export GCP_CLUSTER_NAME='jenkins-ci'
export GCP_ZONE='europe-west2-a'
export GCP_MACHINE_TYPE='n1-standard-2'
export GCP_CLUSTER_NODES=2
export GCP_NETWORK='jenkins'
export GCP_SCOPES='projecthosting,storage-rw'
```

Run the script via:

```
$ ./scripts/install_jenkins_gcp.sh
```

If all goes well, the Jenkins initial admin password will be printed towards the end of the output.


## Testing the Infrastructure 

An InSpec profile is provided in this repository to test the Jenkins cluster.   Variables can be passed to InSpec to test the infrastructure using the `attributes.yml` file.  Default values are provided in the `inspec.yml` and the only mandatory parameter is the GCP project identifier.  Run the tests using the following command:

```
$ cd jenkins-kube-inspec/
$ bundle exec inspec exec . -t gcp:// --attrs attributes.yml

Profile: InSpec GCP Jenkins Profile (inspec-gcp-jenkins-profile)
Version: 1.0.0
Target:  gcp://service-account@spaterson-project.iam.gserviceaccount.com

  ✔  gcp-gke-jenkins-cluster-1.0: Ensure the GKE Container Cluster was built correctly.
     ✔  Cluster jenkins-ci should exist
     ✔  Cluster jenkins-ci name should eq "jenkins-ci"
     ✔  Cluster jenkins-ci zone should match "europe-west2-a"
     ✔  Cluster jenkins-ci status should eq "RUNNING"
     ✔  Cluster jenkins-ci locations should include "europe-west2-a"
     ✔  Cluster jenkins-ci network should eq "jenkins"
     ✔  Cluster jenkins-ci subnetwork should eq "jenkins"
     ✔  Cluster jenkins-ci node_config.disk_size_gb should eq 100
     ✔  Cluster jenkins-ci node_config.image_type should eq "COS"
     ✔  Cluster jenkins-ci node_config.machine_type should eq "n1-standard-2"
     ✔  Cluster jenkins-ci node_ipv4_cidr_size should eq 24
     ✔  Cluster jenkins-ci node_pools.count should eq 1
  ✔  gcp-jenkins-network-1.0: Ensure GCP Jenkins network has the correct properties.
     ✔  Network jenkins should exist
     ✔  Network jenkins name should eq "jenkins"
     ✔  Network jenkins subnetworks.count should be >= 18
     ✔  Network jenkins subnetworks.first should match "jenkins"
     ✔  Network jenkins creation_timestamp_date should be > 2008-11-28 11:56:26 +0000
     ✔  Network jenkins routing_config.routing_mode should eq "REGIONAL"
     ✔  Network jenkins auto_create_subnetworks should equal true


Profile: Google Cloud Platform Resource Pack (inspec-gcp)
Version: 0.7.0
Target:  gcp://service-account@spaterson-project.iam.gserviceaccount.com

     No tests executed.

Profile Summary: 2 successful controls, 0 control failures, 0 controls skipped
Test Summary: 19 successful, 0 failures, 0 skipped
```

Add variables to the `attributes.yml` if values other than the defaults were used to run the `install_jenkins_gcp.sh` script.

## Building Images for your Builds

Sample docker files are included for information.  These can be built and pushed to GCR to be referenced in repository `Jenkinsfile` pod templates.  Example of building an image:

```
docker build -t gcr.io/my-gcp-project/image-name -f images/Dockerfile.name
docker push gcr.io/my-gcp-project/image-name:latest
```