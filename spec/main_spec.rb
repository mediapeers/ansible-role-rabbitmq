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
#    it { should be_running } # has to run with sudo
  end

  if ANSIBLE_VARS.fetch('rabbitmq_manage', 'false') == 'true'
    describe command('sudo rabbitmq-plugins list') do
      its(:stdout) { should include('[E*] rabbitmq_management') }
    end
  end

  ANSIBLE_VARS.fetch('rabbitmq_custom_plugins', []).each do |plugin|
    describe command('sudo rabbitmq-plugins list') do
      its(:stdout) { should include("[E*] #{plugin}") }
    end
  end

end
