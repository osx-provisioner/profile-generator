# {{cookiecutter.project_slug}}

(Powered by [CICD-Tools](https://github.com/cicd-tools-org/cicd-tools).)

### {{ cookiecutter._BRANCH_NAME_BASE | capitalize }} Branch CI
- [![{{cookiecutter.project_slug}}](https://github.com/{{cookiecutter.github_handle}}/{{cookiecutter.project_slug}}/actions/workflows/workflow-push.yml/badge.svg?branch={{ cookiecutter._BRANCH_NAME_BASE }})](https://github.com/{{cookiecutter.github_handle}}/{{cookiecutter.project_slug}}/actions/workflows/workflow-push.yml)

### {{ cookiecutter._BRANCH_NAME_DEVELOPMENT | capitalize }} Branch CI
- [![{{cookiecutter.project_slug}}](https://github.com/{{cookiecutter.github_handle}}/{{cookiecutter.project_slug}}/actions/workflows/workflow-push.yml/badge.svg?branch={{ cookiecutter._BRANCH_NAME_DEVELOPMENT }})](https://github.com/{{cookiecutter.github_handle}}/{{cookiecutter.project_slug}}/actions/workflows/workflow-push.yml)

## Mac Maker Profile

{{ cookiecutter.description }}

Use [Mac Maker](https://github.com/osx-provisioner/mac_maker) to apply this profile to a Mac that is ready to setup.

## About The Default Configuration

The template has generated you a development environment for a [Mac Maker](https://github.com/osx-provisioner/mac_maker.git) machine profile, with [functional CI](.github/workflows/workflow-push.yml).

The default configuration has some excellent functionality out of the box:
- Installs the [Homebrew](https://brew.sh/) cli tools and the content of the centralized package manifest in the [profile/vars/main.yml](./profile/vars/main.yml) file.
- A functional [ClamAV](https://github.com/Cisco-Talos/clamav) install to protect you against malicious downloads.
- Node.js and Python, managed by [asdf](https://asdf-vm.com/#/).
  - Activate these language installs by following [these](https://asdf-vm.com/#/core-manage-asdf) instructions for your shell.

Extend this further by mixing and matching Ansible roles in the [profile/install.yml](./profile/install.yml) file.

#### Am Important Note about ClamAV on Catalina and Later

- To get the most out of your ClamAV install, make sure you grant it "Full Disk Access".
- Please take a quick look at the documentation [here](https://github.com/osx-provisioner/role-clamav).

## Development Requirements

An OSX machine is of course the best platform to development your profile on, although you could probably use a Linux or BSD machine in a pinch.

You'll need [Python](https://www.python.org/) **3.9** or later, and a container runtime environment such as [Docker](https://www.docker.com/) or [Colima](https://github.com/abiosoft/colima) is strongly recommended.

Please see the complete template guide [here](https://github.com/osx-provisioner/profile-generator/blob/main/README.md#requirements).

## This Looks Complicated, How Can I Customize It?

Start [here](./profile/vars/main.yml), it's really much simpler than you might think.

## Making the Default Profile your Own

To start branching out, and really customizing things, get familiar with the following files:

 - [install.yml](profile/install.yml)
   - This is the main [ansible](https://ansible.com) playbook that will be run when you "Apply" this profile.
 - [requirements.yml](profile/requirements.yml)
   - This is configuration for [ansible-galaxy](https://galaxy.ansible.com/docs/using/installing.html#installing-multiple-roles-from-a-file) dependencies.
   - If you add additional roles, include them here, so your Profile includes everything it needs.
   - Make sure to read the documentation any new roles and add the required variables to your [main vars file](./profile/vars/main.yml).

The more customized your want your profile to become, the more you'll benefit from reading up on [ansible](https://ansible.com).

## Configuration Files (More Complex Knob Tweaking)

There some configuration files you can fine tune as you see fit:

 - [.ansible-lint](profile/.ansible-lint)
   - This is configuration for [ansible-lint](https://ansible-lint.readthedocs.io/), which is used in the included GitHub CI pipeline.
 - [.yamllint.yml](profile/.yamllint.yml)
   - This is configuration for [yamllint](https://yamllint.readthedocs.io/), which is used in the included GitHub CI pipeline.

## Profile Precheck Folder

The `profile` folder contains a special [\_\_precheck\_\_](profile/__precheck__) sub-folder with configuration used by [Mac Maker](https://github.com/osx-provisioner/mac_maker) to help end users apply the Profile to their machines.

Please read the [Mac Maker Profile](https://mac-maker.readthedocs.io/en/latest/project/4.profiles.html) documentation for details on this. (It's a quick read.)

## Developing Your Profile

[Mac Maker](https://github.com/osx-provisioner/mac_maker) can work with _public_ GitHub repositories, or with privately maintained `spec.json` files.

The Profile has a specific directory structure, but the `spec.json` file lets you mix and match where the directories and files are. It's a bit inflexible in certain ways, because it requires absolute paths, but this makes it ideal to work off a USB stick or any portable media.
When developing your profile locally, it's handy to setup a `spec.json` file that points to all the locations you need, so you can run Mac Maker to test.

(A common use case for `spec.json` files, is to clone a _private_ git repository to a USB key, and configure the `spec.json` to point to the USB key locations.)

Please read the [Mac Maker Job Spec](https://mac-maker.readthedocs.io/en/latest/project/5.spec_files.html) documentation for details on this. (It's a quick read.)

## Securing Your Profile

Take care not to check in any privileged content such as passwords, or api keys to your profile.  This is especially true if you're working with a _public_ GitHub repository.

### Environment Variables

- The recommended best practice to work around this is to use environment variables.  These are easily loaded into your shell before your run Mac Maker.  
- This gives you the ability to parameterize certain aspects of your profile that may differ from machine to machine.
- Use Mac Maker's [precheck](./profile/__precheck__/env.yml) functionality to document your profile's environment variables.

#### Using Environment Variables in Practice

In practice this might mean keeping a small shell script that sets variables somewhere safe (such as an encrypted USB key):

```shell
#!/bin/bash
export MY_SECRET_VALUE="very secret"
```

Before applying your profile, you would insert your USB key and source your shell script:

```shell
$ source /Volumes/USB/my_secret_script.sh
$ ./mac_maker
```

Your environment variables will then be accessible inside Ansible configuration:

```yaml
---
- name: Read My Secret
  ansible.builtin.set_fact:
    ansible_variable: {% raw %}"{{ lookup('env', 'MY_SECRET_VALUE') }}"{% endraw %}
```

You can find simple examples of this in the example profile [here](./profile/vars/main.yml).

### Ansible Vault

- Ansible also has an encryption system called [vault](https://docs.ansible.com/ansible/latest/vault_guide) which is used to encrypt files containing sensitive data.
- This would allow you to encrypt and decrypt yaml files containing sensitive material- but I would still recommend NOT making these files public.
- If you're working with securely stored vault files, you can use the `ANSIBLE_VAULT_PASSWORD_FILE` environment variable documented [here](https://docs.ansible.com/ansible/latest/vault_guide/vault_using_encrypted_content.html#setting-a-default-password-source) to decrypt your data during installation.

## Poetry

Poetry is leveraged to manage the Python dependencies:
- [Adding Python Packages with Poetry](https://python-poetry.org/docs/cli/#add)
- [Removing Python Packages With Poetry](https://python-poetry.org/docs/cli/#remove)

You can also conveniently execute commands inside the Python virtual environment by using: `poetry run [my command here]`

## Pre-Commit Git Hooks

The python library [pre-commit](https://pre-commit.com/) is installed during templating with a few useful initial hooks.

**This hooks depend on the presence of a container runtime such as [Docker](https://www.docker.com/) or [Colima](https://github.com/abiosoft/colima) on your development machine.**

Complete documentation on these hooks can be found [here](https://github.com/osx-provisioner/profile-generator/blob/main/README.md#pre-commit-git-hooks).

## Restricted Paths

Certain versions of the Ansible tool chain _may_ use these folders, which you would be best to avoid:
- .ansible/
- .cache/
- profile/.ansible/
- profile/.cache/

Mac Maker itself also writes some data overtop of the role (ephemerally at run time) in order to process it, this means there are a few paths that you should shy away from using:
- spec.json _\*_
- profile/.mac_maker/
- profile/collections/ _\*_
- profile/env/ _\*_
- profile/inventory/ _\*_
- profile/roles/ _\*_
  
_\*_ _(these paths are marked for deprecation, soon freeing them up for use)_

## Default License

An [MIT](LICENSE) license has been generated for you by default, feel free to discard/change as you see fit.
