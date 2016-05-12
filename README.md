Kibana on AWS using Terraform
=============

## Requirements

* Terraform >= v0.6.15

## Installation

* install [Terraform](https://www.terraform.io/) and add it to your PATH.
* clone this repo.

## Configuration

### AWS Credentials

We rely on AWS credentials to have been set elsewhere, for example using environment variables. We also use [terraform_exec](https://github.com/nadnerb/terraform_exec) to execute terraform that
saves environment state to S3.

### Terraform configuration

Create a configuration file such as `~/.aws/default.tfvars` which can include mandatory and optional variables such as:

```
key_name="<key name>"

stream_tag="<used for aws resource groups>"
kibana_version="4.5"

aws_region="ap-southeast-2"
ami="ami-7ff38945"

vpc_id="xxx"
additional_security_groups=""

instances="1"
availability_zones="ap-southeast-2a,ap-southeast-2b"
subnets="subnet-xxxxx,subnet-yyyyy"

# consul variables
dns_server  = "172.100.0.2"
consul_dc   = "dc0"
atlas       = "atlas user"
atlas_token = "atlas token"
```

These variables can also be overriden when running terraform like so:

```
terraform (plan|apply|destroy) -var 'ami=foozie'
```

The variables.tf terraform file can be further modified, for example it defaults to `ap-southeast-2` for the AWS region.

## Using Terraform

Execute the plan to see if everything works as expected.

```
terraform plan -var-file ~/.aws/default.tfvars -state='environment/development.tfstate'
```

If all looks good, lets build our infrastructure!

```
terraform apply -var-file ~/.aws/default.tfvars -state='environment/development.tfstate'
```

### Multiple security groups

A security group is created using terraform that opens up kibana and ssh ports. We can also add extra pre-existing security groups to our kibana instances like so:

```
terraform plan -var-file '~/.aws/default.tfvars' -var 'additional_security_groups=sg-xxxx, sg-yyyy'
```

