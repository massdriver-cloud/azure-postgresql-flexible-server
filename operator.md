# Operator Guide

## TODO:

* [ ] Write a design doc / operator guide
* [x] Write bundle code
  * [x] Defing params & connections JSON schema
  * [x] Write 2-3 Guided Configs
  * [x] Define artifact schema, design new artifact definitions if necessary
  * [x] Test each guided config
  * [ ] View params schema in storybook, [write UI schema](https://react-jsonschema-form.readthedocs.io/en/latest/usage/widgets/) for sorting fields, etc
* [ ] Write user guide
* [ ] Remove this TODO block

Provisions Azure PostgreSQL Flexible Server, a private DNS zone for the PSQL server, a new subnet in the VNET artifact, and a network security group for the subnet.

## Use Cases

Common use case would be provisioning an Azure PostgreSQL Flexible Server in the environment that can integrate with an existing virtual network

### Guided Configs

Guided configs are set up for 3 targetted deployments:
- Development/testing
- Small organizations
- Large organizations

## Design

### How It Works

1. The bundle first generates a random password for the PSQL server
2. It then provisions a subnet in the target virtual network, dedicated to the PSQL server
3. Then it creates a network security group and associates it to the subnet
4. A private DNS zone is required for the PSQL server if integrated with a VNET, so that is created next, along with the VNET link
5. The PSQL server is finally provisioned based on the customer's inputted values

#### Best Practices

Per Azure documentation, best practice for naming the private DNS zone and private DNS zone VNET link are as follows:

Private DNS zone: "${local.psql_server_name}-pdz.private.postgres.database.azure.com"
Private DNS zone VNET link: "${local.psql_server_name}-pdzvnetlink.com"

#### Security 

#### Auditing

#### Compliance

#### Observability

### Trade-offs

Currently, the compute size is not dependent on the compute tier. This will be patched when possible.

### Permissions

Subscription contributor
