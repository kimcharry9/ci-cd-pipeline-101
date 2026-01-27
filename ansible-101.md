# Ansible-101

[Table Of Contents] - [Ansible-101](#cicd-pipeline-101)
- [Ansible-101](#ansible-101)
  - [1. ECS (VM) Setup](#1-ecs-vm-setup)
    - [1.1) Create User](#11-create-user)
    - [1.2) Set Timezone](#12-set-timezone)
    - [1.3) Config SSH on SSH port and "root" user login disabled](#13-config-ssh-on-ssh-port-and-root-user-login-disabled)
    - [1.4) Test SSH](#14-test-ssh)
  - [2. Ansible and Mandatory Package Preparation](#2-ansible-and-mandatory-package-preparation)
    - [2.1) Update Repository for latest version of any packages](#21-update-repository-for-latest-version-of-any-packages)
    - [2.2) Update Ansible repository with add-repo method](#22-update-ansible-repository-with-add-repo-method)
    - [2.3) Install Ansible and Python3 (Mandatory)](#23-install-ansible-and-python3-mandatory)
    - [2.4) Setting Docker repository and install Docker](#24-setting-docker-repository-and-install-docker)
  - [3. Key Pair Management](#3-key-pair-management)
    - [3.1) Generate key pair for automation ssh between control-node and managed-nodes](#31-generate-key-pair-for-automation-ssh-between-control-node-and-managed-nodes)
    - [3.2) Transfer control-node's key to managed-nodes](#32-transfer-control-nodes-key-to-managed-nodes)
  - [4. Ansible Playground Preparation](#4-ansible-playground-preparation)
    - [4.1) Create ansible directory for working and change permission to "ansibleuser"](#41-create-ansible-directory-for-working-and-change-permission-to-ansibleuser)
    - [4.2) Create default ansible.cfg (if not be created after package installation)](#42-create-default-ansiblecfg-if-not-be-created-after-package-installation)
    - [4.3) Create inventory file for connecting to managed-nodes](#43-create-inventory-file-for-connecting-to-managed-nodes)
    - [4.4) Create playbook for command testing](#44-create-playbook-for-command-testing)
    - [4.5) Run playbook](#45-run-playbook)
  - [5. Ansible Standard Structure Implementation](#5-ansible-standard-structure-implementation)
    - [5.1) Create "roles" directory for automated configuration management](#51-create-roles-directory-for-automated-configuration-management)
    - [5.2) Create "tasks" for automated task specification](#52-create-tasks-for-automated-task-specification)
    - [5.3) Create "templates" for automated configuration file management](#53-create-templates-for-automated-configuration-file-management)
    - [5.4) Create "vars" for variable replacing on templates](#54-create-vars-for-variable-replacing-on-templates)
    - [5.5) Create main playbook for automated task execution](#55-create-main-playbook-for-automated-task-execution)
    - [5.6) Run playbook](#56-run-playbook)
  - [6. "ansible-playbook" often option usage lists](#6-ansible-playbook-often-option-usage-lists)
  - [7. Ad-hoc "ansible" command pattern](#7-ad-hoc-ansible-command-pattern)


## 1. ECS (VM) Setup

### 1.1) Create User

```shell
# for acl setting in the future
apt install acl

# create user, group
groupadd ansibleuser
useradd -m -d /home/ansibleuser -s /bin/bash -g ansibleuser ansibleuser
echo -e "ansibleuser\nansibleuser" | passwd ansibleuser
chage -M 99999 ansibleuser
```

### 1.2) Set Timezone

```shell
# set Bangkok timezone
timedatectl set-timezone Asia/Bangkok
```

### 1.3) Config SSH on SSH port and "root" user login disabled

```shell
# add sudoers user
vi /etc/sudoers
ansibleuser   ALL=(ALL:ALL) ALL

# disable "root" ssh and change SSH port
vi /etc/ssh/sshd_config
Port 8022
PermitRootLogin no

systemctl daemon-reload
systemctl restart sshd
systemctl restart ssh
```

### 1.4) Test SSH

```shell
# test ssh with root and port 22, 8022 -> cannot access due to user login permission
ssh root@<ip> -p 8022

# test ssh with root and port 22 -> cannot access due to mismatch port
ssh ansibleuser@<ip> -p 22


# test ssh with root and port 8022 -> can must access normally 
ssh ansibleuser@<ip> -p 8022
```

## 2. Ansible and Mandatory Package Preparation
### 2.1) Update Repository for latest version of any packages
```shell
sudo apt-get update
sudo apt update
```

### 2.2) Update Ansible repository with add-repo method
```shell
sudo apt-add-repository --yes --update ppa:ansible/ansible
Repository: 'Types: deb
URIs: https://ppa.launchpadcontent.net/ansible/ansible/ubuntu/
Suites: noble
Components: main
'
Description:
Ansible is a radically simple IT automation platform that makes your applications and systems easier to deploy. Avoid writing scripts or custom code to deploy and update your applications— automate in a language that approaches plain English, using SSH, with no agents to install on remote systems.

http://ansible.com/

If you face any issues while installing Ansible PPA, file an issue here:
https://github.com/ansible-community/ppa/issues
More info: https://launchpad.net/~ansible/+archive/ubuntu/ansible
Adding repository.
Hit:1 http://repo.huaweicloud.com/ubuntu noble InRelease
Hit:2 http://repo.huaweicloud.com/ubuntu noble-updates InRelease 
Hit:3 http://repo.huaweicloud.com/ubuntu noble-backports InRelease
Hit:4 http://repo.huaweicloud.com/ubuntu noble-security InRelease
Get:5 https://ppa.launchpadcontent.net/ansible/ansible/ubuntu noble InRelease [17.8 kB]
Get:6 https://ppa.launchpadcontent.net/ansible/ansible/ubuntu noble/main amd64 Packages [772 B]
Get:7 https://ppa.launchpadcontent.net/ansible/ansible/ubuntu noble/main Translation-en [472 B]
Fetched 19.0 kB in 2s (12.5 kB/s)  
Reading package lists... Done
```

### 2.3) Install Ansible and Python3 (Mandatory)
```shell
sudo apt install -y ansible python3
```

### 2.4) Setting Docker repository and install Docker
```shell
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 3. Key Pair Management
### 3.1) Generate key pair for automation ssh between control-node and managed-nodes
```shell
ssh-keygen
```

### 3.2) Transfer control-node's key to managed-nodes
```shell
ssh-copy-id -i /home/ansibleuser/.ssh/id_ed25519.pub -p 8022 ansibleuser@<manage-node-ip>

# expected result
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/ansibleuser/.ssh/id_ed25519.pub"
The authenticity of host '[<manage-node-ip>]:8022 ([<manage-node-ip>]:8022)' can't be established.
ED25519 key fingerprint is SHA256:Or/ke6GJd02/wHSpne9epHZ3GvUsAREjzRJuwT9MGdc.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
ansibleuser@<manage-node-ip>'s password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh -p 8022 'ansibleuser@<manage-node-ip>'"
and check to make sure that only the key(s) you wanted were added.
```

## 4. Ansible Playground Preparation
### 4.1) Create ansible directory for working and change permission to "ansibleuser"
```shell
# inventory (hosts)
sudo mkdir -p /etc/ansible/inventory 

# playbook (command tasks center)
sudo mkdir -p /etc/ansible/playbook/webserver /etc/ansible/playbook/database /etc/ansible/playbook/load-balancer

# targeted service config file
sudo mkdir -p /etc/ansible/service-setup-config/webserver /etc/ansible/service-setup-config/database /etc/ansible/service-setup-config/load-balancer

sudo chown -R ansibleuser. /etc/ansible
```

### 4.2) Create default ansible.cfg (if not be created after package installation)
```shell
# use default config file
sudo ansible-config init --disabled > /etc/ansible/ansible.cfg
```
```shell
# create new config file
sudo mv ansible.cfg ansible.cfg.org
vi ansible.cfg

[default]
inventory = /etc/ansible/inventory/hosts
remote_user = ansibleuser
remote_port=8022
private_key_file = /home/ansibleuser/.ssh/id_ed25519
host_key_checking = False
```

### 4.3) Create inventory file for connecting to managed-nodes
```shell
vi /etc/ansible/inventory/hosts

[service:children]
webserver
database

[webserver]
web01 ansible_ssh_host=<web01-IP>
web02 ansible_ssh_host=<web02-IP>

[database]
db01 ansible_ssh_host=<db01-IP>
db02 ansible_ssh_host=<db02-IP>
```

### 4.4) Create playbook for command testing
```shell
vi /etc/ansible/playbook/webserver/test-command.yaml

- name: Test Command on Managed Nodes
  hosts: webserver
  tasks:
    - name: list files/folders in /tmp command and capture output to myoutputvar
      command: "ls -lrt /tmp"
      register: myoutputvar
    - debug: var=myoutputvar
```

### 4.5) Run playbook
```shell
ansible-playbook /etc/ansible/playbook/webserver/test-command.yaml
```

## 5. Ansible Standard Structure Implementation

```shell
/etc/ansible
├── ansible.cfg
├── ansible.cfg.org
├── inventory
│   └── hosts
├── playbooks
│   ├── load-balancer
│   ├── database
│   └── webserver
│       ├── setup-webserver.yaml
│       ├── uninstall-webserver.yaml
│       └── test-command.yaml
└── roles
    ├── load-balancer
    ├── database
    └── webserver
        ├── tasks
        │   ├── main.yaml
        │   ├── 01-install-service.yaml
        │   └── 02-setup-config.yaml
        ├── templates
        │   ├── apache2
        │   │   ├── readme
        │   │   └── nine-test.conf.j2
        │   ├── php-fpm
        │   │   ├── readme
        │   │   └── nine-test.conf.j2
        │   └── var-www
        │       ├── home
        │       │   └── index.html.j2
        │       └── function
        │           └── mariadb-config.php.j2
        ├── vars
        │   ├── apache2.yaml
        │   ├── php-fpm.yaml
        │   ├── mariadb-conn-web01.yaml
        │   └── mariadb-conn-web02.yaml
        ├── handlers
        │   └── main.yaml
        ├── files
        │   └── var-www
        │       └── function
        │           ├── insert.php
        │           ├── update.php
        │           ├── query.php
        │           └── delete.php
        ├── meta
        └── defaults
```

### 5.1) Create "roles" directory for automated configuration management

```shell
mkdir -p /etc/ansible/roles/webserver/{tasks,templates,vars,handlers,files,meta,defaults}
mkdir -p /etc/ansible/roles/webserver/templates/{apache2,php-fpm,var-www/home,var-www/function}
mkdir -p /etc/ansible/roles/webserver/files/var-www/function}
```

### 5.2) Create "tasks" for automated task specification
- for many .yaml files usage, please specify those files in "main.yaml" with "import_tasks" module
```shell
vi /etc/ansible/roles/webserver/tasks/main.yaml

- import_tasks: 01-install-service.yaml
  tags: install

- import_tasks: 02-setup-config.yaml
  tags: config
```
- task 01:
```shell
vi /etc/ansible/roles/webserver/tasks/01-install-service.yaml

- name: 1.1 update current repository to latest version
  apt:
    update_cache: yes

- name: 1.2 install apache2 and php8.3 packages
  apt: 
    name:
      - apache2
      - apache2-utils
      - apache2-bin
      - php8.3
      - php8.3-cli
      - php8.3-bz2
      - php8.3-curl
      - php8.3-mbstring
      - php8.3-intl
      - php8.3-fpm
      - php8.3-mysqli 
    state: present

- name: 1.3 collect current status of installation
  service_facts: 

- name: 1.4 display service status
  debug:
    msg:
      - "Apache2 status: {{ ansible_facts.services['apache2.service'] }}"
      - "PHP-FPM status: {{ ansible_facts.services['php8.3-fpm.service'] }}"
```
- task 02:
```shell
- name: 2.1 create dependent directories with directory exist checking
  file:
    path: "{{ item }}"
    state: directory
    owner: root
    group: root
    mode: '0755'
  loop:
    - /var/www/nine-test
    - /var/www/nine-test/home
    - /var/www/nine-test/function
    - /etc/apache2/sites-available
    - /etc/php/8.3/fpm/pool.d

- name: 2.2 copy index.html to host
  template:
    src: var-www/home/index.html.j2
    dest: /var/www/nine-test/home/index.html

- name: 2.3 load apache2 sites vars
  include_vars:
    file: "apache2.yaml"

- name: 2.4 copy apache2 sites config to host
  template:
    src: apache2/nine-test.conf.j2
    dest: /etc/apache2/sites-available/nine-test.conf

- name: 2.5 load php-fpm vars
  include_vars:
    file: "php-fpm.yaml"

- name: 2.6 copy php-fpm pool config to host
  template:
    src: php-fpm/nine-test.conf.j2
    dest: /etc/php/8.3/fpm/pool.d/nine-test.conf

- name: 2.7 load mariadb vars per host
  include_vars:
    file: "mariadb-conn-{{ inventory_hostname }}.yaml"

- name: 2.8 copy php mariadb connection config to host
  template:
    src: var-www/function/mariadb-config.php.j2
    dest: /var/www/nine-test/function/mariadb-config.php

- name: 2.9 copy php script to host
  copy:
    src: "{{ item }}"
    dest: "/var/www/nine-test/function/{{ item | basename }}"
    owner: root
    group: root
    mode: '0644'
  with_fileglob:
    - "var-www/function/*.php"

- name: 2.10 enable dependent apache2 modules
  community.general.apache2_module:
    name: proxy_fcgi
    state: present

- name: 2.11 enable apache2 php-fpm config
  command: a2enconf php8.3-fpm
  notify:
    - restart php-fpm config
    
- name: 2.12 enable apache2 sites (my_webserver_config)
  command: a2ensite nine-test.conf
  notify:
    - restart apache2
```
### 5.3) Create "templates" for automated configuration file management
- apache2
```shell
vi /etc/ansible/roles/webserver/templates/apache2/nine-test.conf.j2

<VirtualHost *:80>
        # The ServerName directive sets the request scheme, hostname and port that
        # the server uses to identify itself. This is used when creating
        # redirection URLs. In the context of virtual hosts, the ServerName
        # specifies what hostname must appear in the request's Host: header to
        # match this virtual host. For the default virtual host (this file) this
        # value is not decisive as it is used as a last resort host regardless.
        # However, you must set it for any further virtual host explicitly.
        ServerName www.hwc-nine-{{ inventory_hostname }}.com

        ServerAdmin webmaster@localhost
        DocumentRoot {{ webserver.nine_test.root_dir }}

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

        LogFormat "%v %{X-Forwarded-For}i %a %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" my_combined
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log my_combined

        <IfModule mod_proxy_fcgi.c>
                <Directory {{ webserver.nine_test.root_dir }}>
                        Options -Indexes +FollowSymLinks -MultiViews +ExecCGI
                        <FilesMatch \.php$>
                                #<If "-f %{REQUEST_FILENAME}">
                                SetHandler "proxy:unix:{{ webserver.nine_test.listen_proc }}|fcgi://php-fpm"
                                #</If>
                        </FilesMatch>
                        Require all granted
                </Directory>
        </IfModule>

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with "a2disconf".
        #Include conf-available/serve-cgi-bin.conf
</VirtualHost>
```
- php-fpm
```shell
vi /etc/ansible/roles/webserver/templates/php-fpm/nine-test.conf.j2

[nine-test]
user = {{ pool.nine_test.user }}
group = {{ pool.nine_test.group }}

listen = {{ pool.nine_test.listen_proc }}

listen.owner = {{ pool.nine_test.listen_owner }}
listen.group = {{ pool.nine_test.listen_group }}

pm = {{ pool.nine_test.pm.type }}
pm.max_children = {{ pool.nine_test.pm.max_children }}
pm.start_servers = {{ pool.nine_test.pm.start_servers }}
pm.min_spare_servers = {{ pool.nine_test.pm.min_spare_servers }}
pm.max_spare_servers = {{ pool.nine_test.pm.max_spare_servers }}
pm.max_requests = {{ pool.nine_test.pm.max_requests }}
pm.status_path = {{ pool.nine_test.pm.status_path }}

rlimit_files = {{ rlimit_files }}

;php_admin_value[memory_limit] = 128M
;php_admin_value[max_execution_time] = 30
;php_admin_value[max_input_vars] = 5000
```
- php database connection
```shell
vi /etc/ansible/roles/webserver/templates/var-www/function/mariadb-config.php.j2

<?php
// Basic connection settings
$databaseHost = '{{ web_to_db.nine_test.db_host }}';
$databaseUsername = '{{ web_to_db.nine_test.db_usr }}';
$databasePassword = '{{ web_to_db.nine_test.db_passwd }}';
$databaseName = '{{ web_to_db.nine_test.db_name }}';

// Connect to the database
$mysqli = mysqli_connect($databaseHost, $databaseUsername, $databasePassword, $databaseName);
?>
```

### 5.4) Create "vars" for variable replacing on templates
- apache2
```shell
vi /etc/ansible/roles/webserver/vars/apache2.yaml

webserver:
  nine_test:
    root_dir: /var/www/nine-test 
    listen_proc: /run/php/php8.3-fpm-webtest.sock
```
- php-fpm
```shell
vi /etc/ansible/roles/webserver/vars/php-fpm.yaml

pool:
  nine_test:
    user: www-data
    group: www-data
    listen_proc: /run/php/php8.3-fpm-webtest.sock
    listen_owner: www-data
    listen_group: www-data
    pm:
      type: dynamic
      max_children: 5
      start_servers: 2
      min_spare_servers: 1
      max_spare_servers: 3
      max_requests: 0
      status_path: /nine-status

rlimit_files: 1024
```
- php database connection (to db01)
```shell
web_to_db:
  nine_test:
    db_host: hwc-nine-db01
    db_usr: users_table
    db_passwd: users_table
    db_name: nine_db
```
- php database connection (to db02)
```shell
web_to_db:
  nine_test:
    db_host: hwc-nine-db02
    db_usr: users_table
    db_passwd: users_table
    db_name: nine_db
```

### 5.5) Create main playbook for automated task execution
```shell
vi /etc/ansible/playbooks/webserver/setup-webserver.yaml

# Setup Webserver Service (Apache2 + PHP-FPM) Automation Script
# - 01-install-service.yaml
# - 02-setup-config.yaml

- hosts: webserver
  become: yes   # Run as sudo
  roles: 
    - webserver
```

### 5.6) Run playbook
```shell
ansible-playbook /etc/ansible/playbooks/webserver/setup-webserver.yaml
```

## 6. "ansible-playbook" often option usage lists
- `--list-hosts` display managed node(s) that will be executed
```shell
ansible-playbook playbooks/webserver/test-command.yaml --list-hosts

# expected output
playbook: playbooks/webserver/test-command.yaml

  play #1 (service): Test Command on Managed Nodes      TAGS: []
    pattern: ['service']
    hosts (4):
      db01
      web01
      web02
      db02
```
- `--limit` select only specified managed node(s) to execute. can be possible to except some managed node(s) by adding "!" in front of {{ inventory_hostname }}
```shell
ansible-playbook playbooks/webserver/test-command.yaml --limit 'web01' --list-hosts

# expected output
playbook: playbooks/webserver/test-command.yaml

  play #1 (service): Test Command on Managed Nodes      TAGS: []
    pattern: ['service']
    hosts (1):
      web01
```
```shell
ansible-playbook playbooks/webserver/test-command.yaml --limit '!web01' --list-hosts

# expected output
playbook: playbooks/webserver/test-command.yaml

  play #1 (service): Test Command on Managed Nodes      TAGS: []
    pattern: ['service']
    hosts (3):
      db01
      db02
      web02
```
- `--check` verify playbook by dry-run step. some of modules did not support for dry-run step such as apt. with `-K` to ask ansible require become user password. otherwise please set `NOPASSWD` to these become user in `/etc/sudoers` to execute without authentication via password.
```shell
ansible-playbook playbooks/webserver/setup-webserver.yaml --check -K
BECOME password: <your_become_user_password>

PLAY [webserver] **************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************
ok: [web02]
ok: [web01]

TASK [webserver : 2.10 disable apache2 default sites] *************************************************************************************************************************************************************
skipping: [web02]
skipping: [web01]

TASK [webserver : 2.11 enable dependent apache2 modules] **********************************************************************************************************************************************************
ok: [web02]
ok: [web01]

TASK [webserver : 2.12 enable apache2 php-fpm config] *************************************************************************************************************************************************************
skipping: [web01]
skipping: [web02]

TASK [webserver : 2.13 enable apache2 sites (my_webserver_config)] ************************************************************************************************************************************************
skipping: [web02]
skipping: [web01]

PLAY RECAP ********************************************************************************************************************************************************************************************************
web01                      : ok=15   changed=1    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0   
web02                      : ok=15   changed=1    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
```
- `--syntax-check` verify .yaml syntax of playbook. no error display meaning correct syntax.
```shell
ansible-playbook playbooks/webserver/setup-webserver.yaml --syntax-check

playbook: playbooks/webserver/setup-webserver.yaml
```
- `--tags, -t` select only tasks that define tag to execute.
```shell
ansible-playbook /etc/ansible/playbooks/webserver/setup-webserver.yaml -K -t install
BECOME password: <your_become_user_password>

PLAY [webserver] **************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************
ok: [web01]
ok: [web02]

TASK [webserver : 1.1 update current repository to latest version] ************************************************************************************************************************************************
changed: [web02]
changed: [web01]

TASK [webserver : 1.2 install apache2 and php8.3 packages] ********************************************************************************************************************************************************
ok: [web02]
ok: [web01]

TASK [webserver : 1.3 collect current status of installation] *****************************************************************************************************************************************************
ok: [web02]
ok: [web01]

TASK [webserver : 1.4 display service status] *********************************************************************************************************************************************************************
ok: [web01] => {
    "msg": [
        "Apache2 status: {'name': 'apache2.service', 'state': 'running', 'status': 'enabled', 'source': 'systemd'}",
        "PHP-FPM status: {'name': 'php8.3-fpm.service', 'state': 'running', 'status': 'enabled', 'source': 'systemd'}"
    ]
}
ok: [web02] => {
    "msg": [
        "Apache2 status: {'name': 'apache2.service', 'state': 'running', 'status': 'enabled', 'source': 'systemd'}",
        "PHP-FPM status: {'name': 'php8.3-fpm.service', 'state': 'running', 'status': 'enabled', 'source': 'systemd'}"
    ]
}

PLAY RECAP ********************************************************************************************************************************************************************************************************
web01                      : ok=5    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
web02                      : ok=5    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```
- `--start-at-task` define the first start of task.
```shell
ansible-playbook /etc/ansible/playbooks/webserver/setup-webserver.yaml -K -t install --start-at-task "1.3 collect current status of installation
"
BECOME password: <your_become_user_password>

PLAY [webserver] **************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************
ok: [web02]
ok: [web01]

TASK [webserver : 1.3 collect current status of installation] *****************************************************************************************************************************************************
ok: [web01]
ok: [web02]

TASK [webserver : 1.4 display service status] *********************************************************************************************************************************************************************
ok: [web01] => {
    "msg": [
        "Apache2 status: {'name': 'apache2.service', 'state': 'running', 'status': 'enabled', 'source': 'systemd'}",
        "PHP-FPM status: {'name': 'php8.3-fpm.service', 'state': 'running', 'status': 'enabled', 'source': 'systemd'}"
    ]
}
ok: [web02] => {
    "msg": [
        "Apache2 status: {'name': 'apache2.service', 'state': 'running', 'status': 'enabled', 'source': 'systemd'}",
        "PHP-FPM status: {'name': 'php8.3-fpm.service', 'state': 'running', 'status': 'enabled', 'source': 'systemd'}"
    ]
}

PLAY RECAP ********************************************************************************************************************************************************************************************************
web01                      : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
web02                      : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## 7. Ad-hoc "ansible" command pattern
```shell
# command pattern
ansible [pattern] -m [module] -a "[module options]"

# where:
# [pattern] = specified inventory  
# - m [module] = selected module such as "command", "yum", etc.
# - a [module options] = tasks to execute
```
- `ansible.builtin.command` module: general execution with command line.
```shell
ansible webserver -m ansible.builtin.command -a "ls -lrt /tmp"
ansible db01 -m command -a "cat /tmp/dump_file.txt"
```
- `ansible.builtin.shell` module: general execution with shell script on managed nodes including multiple command line and wildcard.
```shell
ansible service -m shell -a "hostname; ls -lrt /tmp"
ansible service -m shell -a "/opt/scripts/cleanup.sh"
ansible service -m shell -a "systemctl is-active nginx && echo OK || echo FAIL"
```
- `file` module: files/folders handling. for example, create new file/directory, change permission and delete file/folder. **NO** wildcard acceptance for this module.
```shell
ansible webserver -m file -a "dest=/tmp/a.txt mode=640 state=touch"
ansible webserver -m file -a "dest=/tmp/test_folder mode=750 state=directory"
ansible webserver -m file -a "dest=/tmp/a.txt state=absent"
```
- `copy` module: files and unempty folders transferring from control node
```shell
ansible webserver -m copy -a "src=/tmp/h.txt dest=/tmp/"
ansible webserver -m copy -a "src=/tmp/copy_folder dest=/tmp/"
```
- `user` and `group` module: user/group handling
```shell
# create group
ansible webserver -m group -a "name=foo gid=3501" -l 'web02' -K -b

# create user
ansible webserver -m user -a "name=foo password=foo uid=3501 group=foo shell=/bin/bash home=/home/foo create_home=yes" -l 'web02' -K -b

# delete user
ansible webserver -m user -a "name=foo state=absent remove=yes" -l 'web02' -K -b
```
- `apt`, `yum` module: service installation via OS repository provided
```shell
# install
ansible webservers -m apt -a "name=acme state=present"

# uninstall
ansible webservers -m apt -a "name=acme state=absent"
```
- `service` module: service handling via service module. could be great if use `systemd_service` instead due to newest module than service module.
```shell
ansible webservers -m ansible.builtin.service -a "name=httpd state=started"
ansible webservers -m ansible.builtin.service -a "name=httpd state=restarted"
ansible webservers -m ansible.builtin.service -a "name=httpd state=stopped"
```