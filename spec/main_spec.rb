require 'spec_helper'

describe "RabbitMQ server setup" do

  describe package('rabbitmq-server') do
    it { should be_installed }
  end

  describe file('/etc/rabbitmq/rabbitmq.conf') do
    it { should be_file }
    its(:content) { should include(
      "default_user = #{ANSIBLE_VARS.fetch('rabbitmq_default_user', 'FAIL')}"
    ) }
    its(:content) { should include(
      "default_pass = #{ANSIBLE_VARS.fetch('rabbitmq_default_pass', 'FAIL')}"
    ) }
    its(:content) { should include(
      "default_user_tags.#{ANSIBLE_VARS.fetch('rabbitmq_default_user_tags', ['FAIL']).first} = true"
    ) }
  end

  describe service('rabbitmq-server') do
    it { should be_enabled }
    it { should be_running } # has to run with sudo
  end

  if ANSIBLE_VARS.fetch('rabbitmq_manage', false)
    describe command('sudo rabbitmq-plugins list') do
      its(:stdout) { should include('[E*] rabbitmq_management') }
    end
  end

  ANSIBLE_VARS.fetch('rabbitmq_custom_plugins', []).each do |plugin|
    describe command('sudo rabbitmq-plugins list') do
      its(:stdout) { should include("[E*] #{plugin}") }
    end
  end

  if ANSIBLE_VARS.fetch('rabbitmq_cluster', false)
    describe file('/root/library/ec2_search.yml') do
      it { should be_file }
    end

    describe file('/root/rabbit_boot.yml') do
      it { should be_file }
      its(:content) { should include("name \"{{ ansible_hostname }}#{ANSIBLE_VARS.fetch('rabbitmq_nodename_suffix', 'FAIL')}\"") }
    end

    describe file('/etc/rc.local') do
      its(:content) { should include('cd /root/ && /usr/local/bin/ansible-playbook rabbit_bootup.yml') }
    end
  end
end
