# aws-cloudwatch-alarms-terraform

*Pre-requisites:*

```
Terraform v1.1
Python3.8 (not tested with older versions)
```


In order to run the code:

1. you need to install the python requirements with below commands:

```bash
pip install -r ./python_slack_client/requirements.txt -t ./python_slack_client
```

2. set the terraform variables (see `variables.tf`).

3. you should be able to deploy this code as is with below commands:

```
terraform init
terraform plan
terraform apply
```
