## Naming Conventions

Caveat: Conventions are always wrong as soon as they are agreed, we shouldn't be relying on names to do anything critical.

### Environments

`<env use>-< Customer Name or Acronym>-<extra>`

#### Environment Use

| Code | Type             | Usage
|------|------------------|-------
| prod    | Production| Customer(s) production environments
| uat     | User Acceptance testing | Place for Developers/Customers to do any UAT required
| sbox   | Sandbox      | Somewhere we can break, in practice often the same place we do UAT
| test   | Testing | Used in automatic or load testing
| demo   | Demo | A demo environment

#### Identifier

A environment identifier such as a customer name, or another unique identifier for an internal environment.

| Code | Description             |
|------|------------------|
| snicket  | Snicket Labs |
| adsignal | AdSignal     |
| amcn     | AMC networks |
| paramount     | Paramount |
| prmt     | Paramount short version |

#### 2nd Identifier

An OPTIONAL 2nd identifier to be appended after the first Identifier - should mostly not be used.

| Code | Description             |
|------|------------------|
| poc  | A Proof of Concept |
| b | A simple 2nd ID for a customer/client that needs multiple env for any reason |

#### Region

A location id of the county/region the cloud region (or DC) the environment is in.

| Code | AWS         | Azure         | On Prem |
|------|-------------|---------------|---------|
| gb1   | eu-west-2   | UK South (London) | Lon1
| gb2   | n/a   | UK West (Cardiff) | n/a |
| gb2   | n/a   | n/a | man1 |
| ie1  | eu-west-1   | North Europe  | n/a|
| eu3  | eu-central-1| Germany West Central | n/a |
| us1   | us-east-1   | East US       | n/a |
| us2  | us-west-2   | West US       | n/a |

Examples:

Production Dedicated Single Tenancy AWS Hosted Environment for AMC Hosted on AWS in us-east-1.

```
prod-acmn-us1
```

A Small Snicket Validation environment on AWS in AWS eu-east-1.

```
test-snicket-small-us1
```

A Test large Snicket environment on AWS in AWS eu-east-1.

```
test-snicket-large-us1
```

A Snicket Validation environment on AWS in AWS eu-east-1.

```
test-snicket-us1
```
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_additional_id"></a> [env\_additional\_id](#input\_env\_additional\_id) | An OPTIONAL additional identifier to be appended after the first Identifier - should mostly not be used. Limited to 5 characters. | `string` | `""` | no |
| <a name="input_env_id"></a> [env\_id](#input\_env\_id) | The unique ID such as customer or use for an environment name, eg bigcorp, mediaorg, adsignal or snicket. Limited to 12 characters. | `string` | n/a | yes |
| <a name="input_env_region"></a> [env\_region](#input\_env\_region) | The region (e.g., us1, eu1, ap1) | `string` | n/a | yes |
| <a name="input_env_use"></a> [env\_use](#input\_env\_use) | The environment type (e.g., prod, test, uat, sbox) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_env_name"></a> [env\_name](#output\_env\_name) | Standardized name for resources |
| <a name="output_tags"></a> [tags](#output\_tags) | Standardized tags for resources |
<!-- END_TF_DOCS -->