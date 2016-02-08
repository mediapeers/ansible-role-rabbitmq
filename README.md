[![Build Status](https://travis-ci.org/mediapeers/ansible-role-rabbitmq.svg?branch=master)](https://travis-ci.org/mediapeers/ansible-role-rabbitmq)


# RabbitMQ
RabbitMQ playbook that enables you to spin up a simple server or cluster them together.
If you are integrating this into another repo make sure that rabbitmq goes in the roles folder and that you have a
top level folder called lookup_plugins with find_by_tag.py in it or this play will not be able to auto cluster.
Currently only EC2 is supported but feel free to request support for other services you may want to use this with.

**Note:** this is a fork of https://github.com/nowait-tools/ansible-rabbitmq.

## Requirements
Ubuntu/Debian base image.

## Dependencies
This role depends on no other roles.

## Role Variables
Variables you can set for this role:

```yaml
# defaults file for rabbitmq
rabbitmq_manage: true
rabbitmq_cluster: false
make_rabbitmq_user: true

# Cluster information
# RabbitMQ (erlang.cookie)
rabbitmq_cookie: XPVTRGPZHAQYKQHKEBUF
rabbitmq_nodename: "rabbit"
rabbitmq_hostname: "{{ ansible_hostname }}.ec2.internal"
rabbitmq_nodename_suffix: .ec2.internal
rabbitmq_ec2_tag_key: Name
rabbitmq_ec2_tag_value: rabbitmq
# Must be set to true for clustering to work
rabbitmq_use_longname: "false"

# RabbitMQ user premissions
rabbitmq_configure_priv: .*
rabbitmq_read_priv: .*
rabbitmq_write_priv: .*
rabbitmq_user_state: present

# RabbitMQ (rabbitmq.config)
rabbitmq_amqp_port: 5672
rabbitmq_loopback_users:
 - guest # leave it empty to allow guest loging from anywhere
rabbitmq_default_vhost: /
rabbitmq_default_user: ansible
rabbitmq_default_pass: ansible
rabbitmq_default_user_tags: administrator
rabbitmq_disk_free_limit: 0.7
rabbitmq_high_watermark: 0.4
rabbitmq_high_watermark_paging: 0.5

# User ansible is running as home dir
user_home_folder: /root

# AWS Key config
app_settings:
rabbitmq:
  aws_access_key_id: not-a-real-key
  aws_secret_access_key: not-a-real-key
```


## Example Playbook
Simple playbook that is enabled for use of clustering. If you are using rabbitmq_clustering you must gather facts. Never use the default key in production:

```yaml
- name: Install Rabbit MQ
  hosts: localhost
  become: true
  vars:
    rabbitmq_cluster: true
    rabbitmq_use_longname: true
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

## License
BSD

## Author Information
Produced by NoWait
