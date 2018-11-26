title 'Test Jenkins GCP compute network'

gcp_project_id = attribute('gcp_project_id')
gcp_network_name = attribute('gcp_network_name')

control 'gcp-jenkins-network-1.0' do

  impact 1.0
  title 'Ensure GCP Jenkins network has the correct properties.'

  describe google_compute_network(project: gcp_project_id, name: gcp_network_name) do
    it { should exist }
    its ('name') { should eq gcp_network_name }
    its ('subnetworks.count') { should be >= 18 }
    its ('subnetworks.first') { should match gcp_network_name }
    its ('creation_timestamp_date') { should be > Time.now - 365*60*60*24*10 }
    its ('routing_config.routing_mode') { should eq "REGIONAL" }
    its ('auto_create_subnetworks'){ should be true }
  end
end