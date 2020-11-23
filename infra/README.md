This is where the infrastucture-as-code (IaC) for the `click-count` project lives.

# Stacks

This project is separated in three stacks
- `tf-shared` - The stack responsible to create everything shared between the stacks, main iam roles and security groups
- `tf-db` - The stack responsible to create everything related to databases (i.e Elasticache redis)
- `tf-app` - The stack responsible to create everything related to the applications (i.e elastic Beanstalk)

# Workspaces

This project uses terraform's workspaces to deploy to separate environments, namely `shared`, `staging` and `production`.

# Terraform States

Terraform states are saved using the s3 backend. A single bucket with all three stacks separated by environment hold the infrastructure states.

# How to deploy ?

To deploy the infrastructure, you need to select a workspace for each stacks, navigate to the stack you want to deploy, then:

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

## Tips

To run terraform commands using the selected workspace, run:

``` bash
terraform <cmd> -var env=`terraform workspace show`
```
