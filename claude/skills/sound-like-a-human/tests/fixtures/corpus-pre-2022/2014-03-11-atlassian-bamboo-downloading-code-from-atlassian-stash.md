# Atlassian Bamboo: Downloading Code from Atlassian Stash

The Atlassian suite of tools are a good way to have your organization’s workflow administered. If you’re using Atlassian Stash to manage your source code and are attempting to get Atlassian Bamboo to download code off Stash’s copy of git, the answer isn’t quite straight forward.

Having experience with Atlassian’s tools for over a year, one gets used to excellent integration wrapped up with beautiful UI but when it comes to setting up flawless CI with Bamboo, you’re let down (either that or my integration is non-standard; don’t see how).

Here forth, I’m assuming users have necessary rights to perform these actions. If not, contact your Bamboo/Stash admin

## Setting up Stash

### Creating keys

Atlassian’s documentation on creating SSH keys does a fine job at explaining things. A few deviations I recommend are listed below:

I’d name this file something like “stash_access_stashServerName” instead of “id_rsa”.

I recommend you using “bamboo_access_bambooServerName” instead of your e-mail when generating the key (replacing “[email protected]” with said value)

I highly recommend you using a passphrase. I hope I don’t need to explain why. :)

### Enable SSH

An admin needs to enable SSH access and SSH access keys from Stash > Administration > Settings > Server settings > SSH access

Ensure “SSH enabled” and “SSH access keys enabled” are checked (yes, it’s important enough to be said twice). If your enterprise wants to restrict access to the source code, they probably have the network set up to ensure that the http based checkout currently being used by users is behind a firewall. In such a case, similar restrictions need to be made to secure the port mentioned there on the machine which runs stash. Please make a note of the SSH port for stash. Default port for this option is 7999.

[caption id=”” align=”alignnone” width=”300”] Stash: SSH Enable Config[/caption]

### Add Access Keys

Go to Stash > Your Repository > Settings > Access Keys and click the Add key button. The same can be done at project level instead of repository level based on what kind of setup you have.

Paste the public key into the text box and add it.

If you have the key on your machine use

If you have the key on a remote machine, on terminal you can use the following command to output the public key and copy it from terminal yourself (cmd+c for macs, ctrl+shift+c for most linux based terminals)

## Setting up Bamboo

### Create a Plan

[caption id=”” align=”alignright” width=”300”] Bamboo: Create Plan Menu Option[/caption]

This can be done by using the create button on the top of the screen. If you already have a plan, skip this step. If required, create a new project on the next screen.

### Configure Plan

[caption id=”” align=”alignright” width=”195”] Bamboo: Configure Plan Option[/caption]

Click the “Actions” button on the top right corner and the “Configure plan” option.

### Repositories

Under “Plan Configuration” on the left, go to the “Repositories” tab. Either add a repository or edit an existing one that you have.

### Repository Configuration

The following settings have to be used. Any fields not mentioned are to be filled based on the user’s discretion.

Source repository: Git

Repository URL: SSH URL for the repository; probably ssh://git@stash_host:stash_ssh_port/project_key/repo_key.git; Open repository in Stash and click the clone button. If the repository has a SSH key added (or the user has a SSH key added for himself; this is NOT REQUIRED) you should be able to see the SSH URL

[caption id=”attachment_499” align=”alignright” width=”300”] Stash: SSH Clone URL[/caption]

Authentication Type: SSH private key

SSH Key:

SSH Passphrase:

Advanced Options (optional; recommended; for Stash-Bamboo integration for build and defect stats)

Web repository: Stash

Stash URL: <Your Stash URL; if you’re using an internal hostname setup in the host file for your machine, ensure the server has the same setting>

Stash Project Key: Reference “project_key” from repository url mentioned earlier for the Bamboo repository configuration

Repository Name: Reference “repo_key” from repository url mentioned earlier for the Bamboo repository configuration

## Misc

If any of these steps aren’t clear, leave a comment for clarification.

This tutorial has been written for Atlassian Bamboo 5.4.2 build 4208. If any instructions above do not map the version you have, feel free to ask below.
