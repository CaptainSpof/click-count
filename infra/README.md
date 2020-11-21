This is where the infrastucture-as-code (IaC) for the `click-count` project lives.

# Workspaces

This project uses terraform's workspaces to deploy to separate environments, namely `staging` and `production`.

# Terraform States

Terraform states are saved using the s3 backend. A single bucket with all three stacks separated by environment hold the infrastructure states.

## Tips

To run terraform commands using the selected workspace, run:

``` bash
terraform <cmd> -var env=`terraform workspace show`
```
