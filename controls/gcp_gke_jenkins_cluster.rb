title 'Jenkins Kubernetes InSpec Test'

gcp_project_id = attribute('gcp_project_id')
gcp_kube_cluster_name = attribute('gcp_kube_cluster_name')
gcp_kube_cluster_zone = attribute('gcp_kube_cluster_zone')
gcp_network_name = attribute('gcp_network_name')
gcp_machine_type = attribute('gcp_machine_type')

control 'gcp-gke-jenkins-cluster-1.0' do

  impact 1.0
  title 'Ensure the GKE Container Cluster was built correctly.'
  desc 'Test properties of the GKE cluster created for Jenkins.'

  describe google_container_cluster(project: gcp_project_id, zone: gcp_kube_cluster_zone, name: gcp_kube_cluster_name) do
    it { should exist }
    its('name') { should eq gcp_kube_cluster_name }
    its('zone') { should match gcp_kube_cluster_zone }

    # the cluster should be in running state
    its('status') { should eq 'RUNNING' }
    its('locations'){ should include gcp_kube_cluster_zone }
    its('network'){ should eq gcp_network_name }
    its('subnetwork'){ should eq gcp_network_name }

    # check node configuration settings
    its('node_config.disk_size_gb'){ should eq 100 }
    its('node_config.image_type'){ should eq 'COS' }
    its('node_config.machine_type'){ should eq gcp_machine_type}

    # check ipv4 cidr size
    its('node_ipv4_cidr_size'){should eq 24}

    # check there is one node pool in the cluster
    its('node_pools.count'){should eq 1}

  end
end
