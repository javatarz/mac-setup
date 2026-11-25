# Managing multiple signatures for git repositories

Github explains pretty well how to sign commits. You can make it automatic by globally setting `commit.gpgsign = true` by using

What if you have different signatures for your personal ID and your work ID?

First, you create multiple signatures. It is important that the email address in the signature is the same as the one for the user who has authored the commit. Run `gpg -K --keyid-format SHORT` to see all available keys. The output looks like

Fetch the ID for each of the signatures. The ID for the personal signature is 11111111 and that for the work signature is 33333333. To assign a signature to the repo, execute `git config user.signingkey <ID>`.

Personally, I have aliases for personal and work signatures and every time I checkout a project, run the alias once.

Run `git log --show-signature` to verify if a commit used the right signature. Happy commit-signing.
