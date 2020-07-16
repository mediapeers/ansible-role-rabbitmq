**Moved to https://github.com/mediafellows/ansible-role-rabbitmq**

[![Build Status](https://travis-ci.com/mediapeers/ansible-role-rabbitmq.svg?branch=master)](https://travis-ci.com/mediapeers/ansible-role-rabbitmq)

# RabbitMQ
RabbitMQ playbook that enables you to spin up a simple server or cluster them together. Currently only clustering on EC2 is supported.
If you are integrating this into another repo make sure that rabbitmq goes in the roles folder.

Configuration only works for RabbitMQ 3.7 and newer as this role already uses newer config format, see https://www.rabbitmq.com/configure.html#config-file
This shouldn't be a problem though, as this role anyway installs the latest RabbitMQ version which is 3.7.4 already (on Apr. 2018).

Also note that this role has to be run on bootup of new instances to hook them into the cluster!
Hence in cluster.yml ansible & boto gets installed.

**Note:** this is a fork of https://github.com/nowait-tools/ansible-rabbitmq.

## Requirements
Ubuntu/Debian base image.

## Dependencies
This role depends on no other roles.

## Role Variables
Variables you can set for this role:

```yaml
# Enable management plugin:
rabbitmq_manage: true
# Setup clustering:
rabbitmq_cluster: false
# Create your own RabbitMQ user as specified on rabbitmq_default_user etc.
make_rabbitmq_user: true

# Cluster information
# RabbitMQ (erlang.cookie)
rabbitmq_cookie: XPVTRGPZHAQYKQHKEBUF # replace with your own!
rabbitmq_nodename: "rabbit"
rabbitmq_nodename_suffix: .ec2.internal
rabbitmq_ec2_tag_key: Name
rabbitmq_ec2_tag_value: RabbitMQ

# RabbitMQ user premissions
rabbitmq_configure_priv: .*
rabbitmq_read_priv: .*
rabbitmq_write_priv: .*
rabbitmq_user_state: present

# RabbitMQ (rabbitmq.config)
rabbitmq_amqp_port: 5672
rabbitmq_loopback_users:
 - guest # leave it empty to allow guest login from anywhere
rabbitmq_default_vhost: /
rabbitmq_default_user: ansible
rabbitmq_default_pass: ansible
rabbitmq_default_user_tags: administrator
rabbitmq_disk_free_limit: 0.7
rabbitmq_high_watermark: 0.4
rabbitmq_high_watermark_paging: 0.5

# AWS Key config (add your AWS AMI keys for a user that can read EC2 information)
rabbitmq_cluster_aws_access_key_id: not-a-real-key
rabbitmq_cluster_aws_secret_access_key: not-a-real-key
```

## Example Playbook
Simple playbook that is enabled for use of clustering. If you are using rabbitmq_clustering you must gather facts.
Never use the default key in production:

```yaml
- name: Install Rabbit MQ
  hosts: localhost
  become: true
  vars:
    rabbitmq_cluster: true
    rabbitmq_ec2_tag_values: 'My RabbitMQ Instance Name'
    # AWS user needs ec2:Describe* permissions
    rabbitmq_cluster_aws_access_key_id: ABC123
    rabbitmq_cluster_aws_secret_access_key: 123456
  roles:
    - rabbitmq
```

## Auto Clustering (EC2)
This playbook has auto clustering support built in with the exception that you need to configure a few things.

The easiest way is to creat an autoscaling group that boots instances from a pre generated AMI, which you can configure 
using this role.

You have to ensure that your servers are in the same security group and have the proper ports open to
each other as well as being in the same VPC.
The ports that need to be open can be found in the rabbitmq documentation. You will likely only need 4369, 25672, 15672, and 5672. 
If you are having issues open up all ports to everything for testing to ensure the security group is not the issue.

Add the LC you have made to an Auto Scale Group (ASG) and set the number of servers to spin up.

### IAM role for instance discovery on EC2
IAM user should have this policy to read necessary information from EC2:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInstances",
        "ec2:DescribeRegions",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeTags"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
```

## License
BSD

## Author Information
Created by NoWait, modified by Stefan Horning
