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
$ cloud config set project my-project-id
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

```
$ ./scripts/install_jenkins_gcp.sh
```


## Testing the Infrastructure

The installation script automatically creates an attributes file in the root directory of the repository.  These variables are passed to InSpec to test the infrastructure.  Run the tests using the following command:
```
$ cd gcp-profile/
$ inspec exec . -t gcp:// --attrs inspec-attributes.yml
```

