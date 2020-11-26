The table bellow describe the choices made for `click-count` technical stacks.

| Stack           | Option used      | Comment                                         |
|-----------------|------------------|-------------------------------------------------|
| Cloud Provider  | AWS              | Because why not                                 |
| CI/CD           | Github Actions   | To its merit, it's not Jenkins                  |
| Redis           | Elasticache      | AWS managed service                             |
| App Server      | Beanstalk Docker | Also managed service, KISS from AWS             |
| Docker Registry | DockerHub        | DockerHub instead of ECR to keep it "agnostish" |
| Provisioner     | Terraform        | Another "agnostic" choice                       |
