# Gitlab-CI-101
-  This document will be writen based on "CSR File Generator" laboratory tasks.

---
[Table Of Contents] - [Gitlab-CI-101](#gitlab-ci-101)
- [Gitlab-CI-101](#gitlab-ci-101)
  - [1. Install gitlab](#1-install-gitlab)
  - [2. Add public key for git connection via SSH method on gitlab UI](#2-add-public-key-for-git-connection-via-ssh-method-on-gitlab-ui)
  - [3. Set credential for git local repository usage](#3-set-credential-for-git-local-repository-usage)
    - [3.1) Create user detail](#31-create-user-detail)
    - [3.2) Check current user config](#32-check-current-user-config)
  - [4. \[Optional\] Set credential for git global repository usage (one credential, many connections)](#4-optional-set-credential-for-git-global-repository-usage-one-credential-many-connections)
    - [4.1) Create global user detail](#41-create-global-user-detail)
    - [4.2) Check current global user config](#42-check-current-global-user-config)
  - [5. Create your first project](#5-create-your-first-project)
    - [5.1) Clone target repository or link your current program to repository](#51-clone-target-repository-or-link-your-current-program-to-repository)
    - [5.2) Create your first gitlab-ci pipeline via .gitlab-ci.yaml](#52-create-your-first-gitlab-ci-pipeline-via-gitlab-ciyaml)


## 1. Install gitlab

## 2. Add public key for git connection via SSH method on gitlab UI
```shell
- Go to your gitlab website
- Click your profile picture > "Edit Profile" > "SSH Keys"
- Add your "id_rsa.pub" or any public key file from your local laptop, then click "Save".
```

## 3. Set credential for git local repository usage
### 3.1) Create user detail
```shell
cd <your-gitlab-repo>

# Add user detail via command below
git config user.name "<your-gitlab-username>"
git config user.email "<your-gitlab-email>"

# Or add user detail directly via .gitconfig file
vi .git/config
[user]
  name = <your-gitlab-username>
  email = <your-gitlab-email>
```
### 3.2) Check current user config
```shell
git config -l
```

## 4. [Optional] Set credential for git global repository usage (one credential, many connections)
### 4.1) Create global user detail
```shell
cd ~

# Add user detail via command below
git config --global user.name "<your-gitlab-username>"
git config --global user.email "<your-gitlab-email>"

# Or add user detail directly via .gitconfig file
vi .gitconfig
# This is Git's per-user configuration file.
[user]
# Please adapt and uncomment the following lines:
#       name = wongsatorn.pu
#       email = wongsatorn.pu@gmail.com
```
### 4.2) Check current global user config
```shell
git config --global -l
```

## 5. Create your first project
### 5.1) Clone target repository or link your current program to repository
```shell
# Clone via SSH method.
ssh://git@<your-git-server>:<your-git-port>/<project>/<your-git-repository>.git

# Clone via HTTPS method. REQUIRE username/password or access-token
git clone https://<your-git-server>/<project>/<your-git-repository>.git

# Link your current program to repository with 'git remote' command
git remote add origin https://<your-git-server>/<project>/<your-git-repository>.git
git branch -M master
# Force-push (-f) current local program to repository. those files in previous commit will be replaced. add --set-upstream (-u) for define what remote_name and branch_name that will permanently use such as 'origin (remote_name) master (branch_name)'.
git push -uf origin master
```
### 5.2) Create your first gitlab-ci pipeline via .gitlab-ci.yaml
```shell
# Prefilled-variable section: define any config detail via "New Pipeline" on Gitlab UI
spec:
  inputs:
    KEY_NAME:
      description: "CSR Key Name:"
      type: string
      default: "nine_test"
    COUNTRY:
      description: "Country (C); e.g. 'TH'"
      type: string
      default: "TH"
    STATE:
      description: "State (ST); e.g. 'Bangkok'"
      type: string
      default: "Bangkok"
    LOCATION:
      description: "Location (L); e.g. 'Sathorn'"
      type: string
      default: "Bangrak"
    ORG_NAME:
      description: "Organization Name (O); e.g. 'Your Company'"
      type: string
      default: "anineda"
    ORG_OU_NAME:
      description: "Organization Unit Name (OU); e.g. 'DevOps'"
      type: string
      default: "devops"
    COMMON_NAME:
      description: "Common Name (CN); e.g. 'example.com'"
      type: string
      default: "<your-domain>.com"
    EMAIL:
      description: "Email Address (emailAddress); e.g. support@gmail.com"
      type: string
      default: "noreply@gmail.com"
    RSA_SIZE:
      description: "RSA Key Size; choose only one in [2048, 4096]"
      type: string
      options: ["2048", "4096"]
      default: "2048"
    HAS_EXT:
      description: "Add other extension such as SAN; 'yes' for applying, 'no' for skipping"
      type: string
      options: ["yes", "no"]
      default: "no"
    SAN:
      description: "[Optional] Subject Alternative Name (SAN); e.g. www.example2.com"
      type: string
      default: ""

---

image: docker:29.1.5

services:
  - docker:29.1.5-dind

stages:
  - prepare
  - build
  - run

prepare-config:
  stage: prepare
  rules:
    - if: '$CI_PIPELINE_SOURCE == "push" || $CI_PIPELINE_SOURCE == "web"'
      when: manual
  image: ubuntu:24.04
  variables:
    KEY_NAME: $[[ inputs.KEY_NAME ]]
    COUNTRY: $[[ inputs.COUNTRY ]]
    STATE: $[[ inputs.STATE ]]
    LOCATION: $[[ inputs.LOCATION ]]
    ORG_NAME: $[[ inputs.ORG_NAME ]]
    ORG_OU_NAME: $[[ inputs.ORG_OU_NAME ]]
    COMMON_NAME: $[[ inputs.COMMON_NAME ]]
    EMAIL: $[[ inputs.EMAIL ]]
    RSA_SIZE: $[[ inputs.RSA_SIZE ]]
    HAS_EXT: $[[ inputs.HAS_EXT ]]
    SAN: $[[ inputs.SAN ]]
  script:
    - apt-get update && apt-get install -y gettext-base
    - mkdir -p replaced_conf
    # Replace prefilled-variable to template file. then, write those detail in new file
    - envsubst < templates/generate-csr-config.conf > replaced_conf/generate-csr-config.conf
    - echo "==== Information of CSR file===="
    - cat replaced_conf/generate-csr-config.conf
  artifacts:
    paths:
      - replaced_conf/generate-csr-config.conf

build-image:
  stage: build
  rules:
    - if: '$CI_PIPELINE_SOURCE == "web"'
      when: never
    - if: '$CI_PIPELINE_SOURCE == "push"'
      when: on_success
  variables:
    IMAGE_TAG: "$CI_COMMIT_SHORT_SHA-$CI_PIPELINE_IID"
    IMAGE_TAG_LATEST: "$CI_COMMIT_SHORT_SHA-latest"
  before_script:
    - SWR_USER="${SWR_PROJECT_NAME}@${SWR_AK}"
    - SWR_PASS="$(printf "%s" "${SWR_AK}" | openssl dgst -binary -sha256 -hmac "${SWR_SK}" | od -An -vtx1 | sed 's/[ \n]//g' | sed 'N;s/\n//')"
    - echo "${SWR_PASS}" | docker login -u "${SWR_USER}" --password-stdin "https://${SWR_REGISTRY}"
  script:
    - |
      docker build \
      -f ${CUSTOM_DOCKERFILE:-Dockerfile} \
      -t "${IMAGE_NAME}:${IMAGE_TAG}" \
      -t "${IMAGE_NAME}:${IMAGE_TAG_LATEST}" \
      .
    - docker push "${IMAGE_NAME}:${IMAGE_TAG}"
    - docker push "${IMAGE_NAME}:${IMAGE_TAG_LATEST}"

run-image:
  stage: run
  needs:
    - job: prepare-config
    - job: build-image
      optional: true
  rules:
    - if: '$CI_PIPELINE_SOURCE == "web"'
      variables:
        IMAGE_TAG: "$CI_COMMIT_SHORT_SHA-latest"
    - if: '$CI_PIPELINE_SOURCE == "push"'
      variables:
        IMAGE_TAG: "$CI_COMMIT_SHORT_SHA-$CI_PIPELINE_IID"
  image: "${IMAGE_NAME}:${IMAGE_TAG}"
  variables:
    SCRIPT_PATH: "/etc/docker/my-image/generate-csr-to-gdrive"
  script:
    - mkdir -p /root/.config/rclone
    - cp "${RCLONE_CRED}" /root/.config/rclone/rclone.conf
    - cp replaced_conf/generate-csr-config.conf ${SCRIPT_PATH}/replaced_conf/
    - ${SCRIPT_PATH}/generate-csr-script.sh ${SCRIPT_PATH}/replaced_conf/generate-csr-config.conf
```