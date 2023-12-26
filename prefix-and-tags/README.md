# prefix-and-tags

Simple Terraform module used for enforcing resource naming and tag convention.
The module requires users to provide the company name, team and environment and will return prefixes in the format:
1. kebab-case: `<company-name>-<team-id>-<environment-id>`
2. snake-case: `<company-name>_<team-id>_<environment-id>`

Additionally, the module will return a `tags` map with the previous information.
