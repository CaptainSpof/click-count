This is where the infrastucture-as-code (IaC) for the `click-count` project lives.

# Stacks

This project is separated in three stacks
- `tf-shared` - The stack responsible for creating everything shared between the stacks, mainly IAM roles and security groups
- `tf-db` - The stack responsible for creating everything related to databases (i.e Elasticache redis)
- `tf-app` - The stack responsible for creating everything related to the applications (i.e elastic Beanstalk)

# Workspaces

This project uses terraform's workspaces to deploy to separate environments, namely `staging` and `production`.

A `shared` workspace also exists (only for `tf-shared`) for holding shared resources between the environments.

# Terraform States

Terraform's states are saved using the s3 backend. A single bucket with all three stacks separated by environment holds the infrastructure states.

# How to deploy ?

To deploy the infrastructure, you need to select a workspace for each stacks. Navigate to the stack you want to deploy, then:

for `shared`:
``` bash
terraform workspace select shared
```
for `staging`:
``` bash
terraform workspace select staging
```
for `production`:
``` bash
terraform workspace select production
```

Then, your regular terraform commands are available to interact with the infrastucture. See bellow for tips on how to deploy.

## What order ?

Some stacks depends on other stacks in order to work, this is why you need to respect a specific order when first creating your environment.
Here's the order:

### Creation

1. `tg-shared`
2. `tg-db`
3. `tg-app`

### Destruction

For destructing your environment, the order is reversed:

1. `tg-app`
2. `tg-db`
3. `tg-shared`

> **_NOTE:_** Destroying can be done in parallel, resources will simply wait for their dependencies to be destroyed first, just be aware of the timeouts.

## Tips

To run terraform commands using the selected workspace, run:

``` bash
terraform <cmd> -var env=`terraform workspace show`
```

### Makefile

Additionally a Makefile can allow you to quickly apply or destroy the stacks.

To use it run:

#### Creation

for staging:
``` bash
ENV=staging make apply
```

for production:
``` bash
ENV=production make apply
```

#### Destruction

for staging:
``` bash
ENV=staging make destroy
```

for production:
``` bash
ENV=production make destroy
```

> **_NOTE:_** The destroy command won't destroy the tf-shared stack, as it could still be used by another environment

To destroy the shared stack, run:

``` bash
make destroy-shared
```
