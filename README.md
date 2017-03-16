# Ansible Project Deploy

<p>These are the scripts and Anible playbooks that I use to deploy my projects to their proper AWS EC2 host using Jenkins. It was designed to be included as a `git submodule` for my projects and handle the basic build and deployment. This works well for my projects and could be used as a very basic deployment playbook for EC2. It has a few assumptions that are detailed below.</p>

### Requirements
* Python 2.7
* Ansible 2.2
* Git
* An EC2 LAMP Server
* A Private Key PEM file for the above server
* AWS Access Key ID
* AWS Secret Access Key

### How To Install
<p>In the root folder for your project, run the following:</p>

`git submodule add https://github.com/mcred/Ansible-Project-Deploy ./ansible/`

### How To Set Up
<p>Whether you are running this locally or on a remote server, Ansible assumes that your host has CLI access to AWS configured. This script will help set that up, but you will need two files: the PEM file that was used to create the EC2 host and a configuration file that contains the following:</p>

```
export AWS_ACCESS_KEY_ID='INSERT YOUR ACCESS KEY'
export AWS_SECRET_ACCESS_KEY='INSERT YOUR SECRET KEY'
export EC2_REGION='INSERT YOUR REGION'
```
<p><b>DO NOT commit these files to your project</b> and put them under version control, rather install these files outside of your project directory in a place where Jenkins can access them. During one of your CI build steps, the files should be copied into the proper place. An Ansible variable file is also needed. This can be stored inside of version control and copied into the proper place during runtime. Sample Ansible config:</p>

```
---
ec2_instance_name: "EC2 INSTANCE NAME TAG"
full_domain_path: "example: /var/www/vhosts/YOURDOMAIN.com"
```

### How To Use
<p>Prior to running the `deploy.sh` command, copy your configuration files into place:</p>

```
cp YOURANSIBLECONFIG.yaml ./ansible/inventory/group_vars/all.yaml
cp ~/.ssh/YOURKEYFILE.pem ./ansible/inventory/ansible-deploy-key.pem
cp ~/.ssh/YOURAWSKEYS ./ansible/inventory/aws_keys
```
<p>Once your configuration is in place, simply run `./deploy.sh`</p>

### Sample Jenkins Configuration
* <b>General:</b> Can be any Project setting. I've used both GitHub and BitBucket.
* <b>Source Code Management:</b> Git. Specify which branch to build.
* <b>Build Triggers:</b> Can be anything, I use When changes are made on the Source Branch.
* <b>Build Environment:</b> Delete workspace before build starts.
* <b>Build:</b> This is where the magic happens. This is done in two steps. First to get the submodule and then to run the build script. Set up two `Execute Shell` steps like below.

#### First Execute Shell Step
```
git submodule add https://github.com/mcred/Ansible-Project-Deploy ./ansible/
touch ./ansible/inventory/group_vars/all.yaml
echo '---' >> ./ansible/inventory/group_vars/all.yaml
echo 'ec2_instance_name: "HOST_BOX_NAME"' >> ./ansible/inventory/group_vars/all.yaml
echo 'full_domain_path: "/var/www/vhosts/YOURDOMAIN.com"' >> ./ansible/inventory/group_vars/all.yaml
echo 'composer_build: false' >> ./ansible/inventory/group_vars/all.yaml
```
#### Second Execute Shell Step
```
#!/bin/bash

set -u # Variables must be explicit
set -e # If any command fails, fail the whole thing
set -o pipefail

export PATH=$PATH:/usr/local/bin

cp ansible_config.yaml ./ansible/inventory/group_vars/all.yaml
cp ~/.ssh/mypemfile.pem ./ansible/inventory/ansible-deploy-key.pem
cp ~/.ssh/aws_keys ./ansible/inventory

cd ansible
bash deploy.sh
```
* <b>Post-build Actions:</b> Your preference. I like the Slack Notifier, personally.
