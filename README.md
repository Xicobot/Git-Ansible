# Documentation of the Git Module in Ansible

## Introduction
The `git` module in Ansible allows you to clone, update, and manage Git repositories on remote systems. It is especially useful for deploying applications and keeping configurations updated on servers.

## Installing Ansible
To use the `git` module, first, ensure that Ansible is installed on your machine. If you don't have it installed, you can do so with:

```bash
sudo apt update
sudo apt install ansible -y
```

It is also necessary to install `git` on the target servers if it is not already present:

```yaml
- name: Install Git
  hosts: all
  become: yes
  tasks:
    - name: Install Git on Debian/Ubuntu
      ansible.builtin.apt:
        name: git
        state: present
        update_cache: yes
```

## Using the `git` Module
The `git` module allows you to clone and update repositories to a specified path. Its basic syntax is:

```yaml
- name: Clone a repository
  ansible.builtin.git:
    repo: "REPO_URL"
    dest: "DEST_PATH"
    version: "main"
    update: yes
```

### Main Options:
| Option | Description |
|---------|-------------|
| `repo` | Git repository URL (HTTPS or SSH) |
| `dest` | Destination path on the remote machine |
| `version` | Branch, tag, or commit to clone |
| `update` | If `yes`, updates the repository if it already exists |
| `force` | If `yes`, discards local changes |

## Authentication Methods
### 1️⃣ Public Repositories (No Authentication)
```yaml
- name: Clone a public repository
  ansible.builtin.git:
    repo: "https://github.com/user/public_project.git"
    dest: "/opt/project"
    version: "main"
    update: yes
```

### 2️⃣ Private Repositories with Personal Access Token
```yaml
- name: Clone a private repository with a token
  ansible.builtin.git:
    repo: "https://ghp_YOUR_TOKEN@github.com/user/private_project.git"
    dest: "/opt/project"
    version: "main"
    update: yes
```
🔹 *This method is more secure than using plain text passwords.*

### 3️⃣ Private Repositories with SSH (Recommended)
1. Generate an SSH key on the remote server:
   ```bash
   ssh-keygen -t rsa -b 4096 -C "ansible@server"
   ```
2. Add the public key to GitHub/GitLab under `Settings > SSH keys`.
3. Use the following playbook:

```yaml
- name: Clone a private repository with SSH
  ansible.builtin.git:
    repo: "git@github.com:user/private_project.git"
    dest: "/opt/project"
    version: "main"
    update: yes
    key_file: "~/.ssh/id_rsa"
```

✅ *This method is secure and avoids storing credentials in the playbook.*

## Full Example: Clone and Run an Application
This playbook installs Git, clones a private repository, and executes an installation script:

```yaml
- name: Deploy application from GitHub
  hosts: all
  become: yes
  tasks:
    - name: Install Git
      ansible.builtin.apt:
        name: git
        state: present
        update_cache: yes
    
    - name: Clone the repository
      ansible.builtin.git:
        repo: "git@github.com:user/private_project.git"
        dest: "/opt/project"
        version: "main"
        update: yes
        key_file: "~/.ssh/id_rsa"

    - name: Run installation script
      ansible.builtin.command:
        cmd: "bash /opt/project/install.sh"
      args:
        chdir: "/opt/project"
      register: install_output

    - name: Display installation output
      debug:
        var: install_output.stdout_lines
```

## Conclusion
The `git` module in Ansible allows you to automate repository management efficiently. Using SSH or Personal Access Tokens is the best way to securely handle credentials.

🔹 *Recommendation:* If working with private repositories, **use SSH keys or access tokens** instead of plain text passwords.
