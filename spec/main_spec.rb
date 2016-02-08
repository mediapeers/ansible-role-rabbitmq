require 'spec_helper'

describe "RabbitMQ server setup" do

  describe package('rabbitmq-server') do
    it { should be_installed }
  end

  describe file('/etc/rabbitmq/rabbitmq.config') do
    it { should be_file }
    its(:content) { should include(
      "{default_user,        <<\"#{ANSIBLE_VARS.fetch('rabbitmq_default_user', 'FAIL')}\">>}"
    ) }
    its(:content) { should include(
      "{default_pass,        <<\"#{ANSIBLE_VARS.fetch('rabbitmq_default_pass', 'FAIL')}\">>}"
    ) }
  end

  describe service('rabbitmq-server') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/rabbitmq/enabled_plugins') do
    it { should be_file }
#    if ANSIBLE_VARS.fetch('rabbitmq_manage', 'false').to_bool
#      its(:content) { should include('rabbitmq_managements') }
#    end
  end
end
