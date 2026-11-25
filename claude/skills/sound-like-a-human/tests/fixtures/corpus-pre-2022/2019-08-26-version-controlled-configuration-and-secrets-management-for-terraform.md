# Version controlled configuration and secrets management for Terraform

Terraform is a tool to build your infrastructure as code. We’ve been having a few challenges while trying to figure out how to how to manage configuration and secrets when integrating terraform with our CD pipeline.

### Life before version control

Before we can do that, it’s important to understand build process before we began on this journey.

Our build model for this project was branch based. Each environment maps to a branch (`main -> dev`, `uat -> uat` and `production -> production`). All other (feature) branches only ran the plan stage against the `dev` environment.

As you can notice, the configurations, secrets and keys are all maintained on the build agent. This means, every developer wanting to run plan and test their changes needs to replicate the `terraform_variables` directory. Any mistakes in doing so masks actual issues that your pipeline might face leading to delayed feedback.

Next, let’s look at what our codebase looked like

The provisioning scripts help us consistently run different stages across modules. Each module is an independent area of our infrastructure (such as core networking, HTTP services etc.)

Each of the provisioning scripts accepted a `WORKSPACE_NAME` (branch for execution that maps to the environment terraform is running for) and `MODULE_NAME` (module being executed).

`init.sh` ran the `terraform init` stage of the pipeline downloading the necessary plugins and initializing the backend

`plan.sh` ran the `terraform plan` stage allowing users to review their changes before applying them.

`apply.sh` applied the changes onto an environment. Developers do not run this command from local to ensure consistency on the environment

### Version controlling configuration

We moved the variables into the `config` directory by making a directory for every branch for each of the 3 environments we had.

According to terraform’s documentation, you can export a variable that your terraform codes need with a prefix of `TF_VAR`.

`functions.sh` provides convenience functions to read the configuration and secrets.

`fetch_variables` read the `tfvars` file, removes empty lines (that were added for readability), prefixed the name with `TF_VAR` and joined all entries into a single line. The string this method returns can be used as a prefix to the `terraform` command while running `plan` and `apply` making them environment variables.

Updated plan and apply scripts are placed in the secrets management section for brevity

#### Testing configuration files

The only limitation is that none of these variables can have a hyphen in the name because of shell variable naming rules. As with any potential mistake, a test providing feedback helps protect you from run time failures. `test_variable_names.sh` does this check for us.

### Version controlling secrets

Secrets like passwords can be version controlled in a similar way though they require encryption to keep them safe. We’re using OpenSSL with a symmetric key to encrypt our secrets. Each secret is put into a `tfsecrets` file (internally a property file just like `tfvars` files for configuration). When encrypted, the file will have an extension of `.tfsecrets.enc`. When the `plan` or `apply` stages are executed, files are decrypted in memory (and not on disk, for security reasons) and used the same way.

`functions.sh` gets a new addition to support reading all secrets

The astute amongst you probably noticed that we’re using OpenSSL v1.0.2s because v1.1.x changes the syntax on encryption/decryption of files. Also, you might have noticed the use of environment variables like `SECRET_KEY_main`, `SECRET_KEY_uat` and `SECRET_KEY_production` as the encryption keys. These values are stored on our CI server (in our case GitLab) which makes these values available to our CI agent during execution.

For local development, we have scripts to encrypt and decrypt configuration files either one at a time or in bulk per environment. It’s worth noting that re-encryption of the same file will show up on your `git diff` since the encrypted file’s metadata changes. Only check in encrypted files when their contents have changed (helping you debug future issues)

`encrypt.sh` takes `SECRET_KEY` as an environment variable for making local usage easier.

`decrypt.sh` also takes the same `SECRET_KEY` as an environment variable for making local usage easier.

#### Testing secret files

If all files for an environment aren’t checked with the same key, you’ll face a runtime error. Since files can be encrypted individually, you must test if all files have been encrypted correctly. This test is also useful when you’re rotating the `SECRET_KEY` for an environment.

`test_encryption.sh` needs `SECRET_KEY_<env>` values set so it can be executed locally.

#### End result

Our final project structure contains the following files

`plan.sh` uses `functions.sh` to load configuration and secrets

`apply.sh` uses `functions.sh` in a similar fashion

And thus, our terraform project requires no data from the CI agent and can be executed perfectly from any box as long as it has the latest code checked out and the correct version of terraform.
