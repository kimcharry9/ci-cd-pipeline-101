# Docker-101 with rclone setup

[Table Of Contents] - [Docker-101 with rclone setup](#docker-101-with-rclone-setup)
- [Docker-101 with rclone setup](#docker-101-with-rclone-setup)
  - [1. Install Docker](#1-install-docker)
    - [1.1) Setup docker's `apt` repository](#11-setup-dockers-apt-repository)
    - [1.2) Install docker package and dependencies](#12-install-docker-package-and-dependencies)
  - [2. Install rclone](#2-install-rclone)
    - [2.1) Install packages](#21-install-packages)
    - [2.2) Setup credential for first-time config](#22-setup-credential-for-first-time-config)
    - [2.3) Setup credential for first-time config](#23-setup-credential-for-first-time-config)
    - [2.4) Backup rclone.conf for future usage](#24-backup-rcloneconf-for-future-usage)
  - [3. Create program/script for image usage](#3-create-programscript-for-image-usage)
    - [3.1) Create config file for variable updating](#31-create-config-file-for-variable-updating)
    - [3.2) Create script](#32-create-script)
  - [4. Create Dockerfile](#4-create-dockerfile)
  - [5. Deploy program into image file](#5-deploy-program-into-image-file)
  - [6. Run your first image](#6-run-your-first-image)
  - [7. Docker general command](#7-docker-general-command)


## 1. Install Docker
- ref: https://docs.docker.com/engine/install/ubuntu/
### 1.1) Setup docker's `apt` repository
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
```
### 1.2) Install docker package and dependencies
```shell
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 2. Install rclone
- ref: https://rclone.org/install/
### 2.1) Install packages
```shell
curl https://rclone.org/install.sh | sudo bash
```

### 2.2) Setup credential for first-time config
- **Google Application Client Id:** 
  - please follow the official guideline link: https://rclone.org/drive/#making-your-own-client-id
  - then, collect the credential file in .json format for further step reference. see `credential-collection/rclone-google-app-client-id.json` for reference.
- [optional] **Service Accounts:** 
  - if you want to skip interactive login. please use 'Service Accounts' instead. please follow the official guideline link: https://docs.cloud.google.com/iam/docs/service-accounts-create
  - then, collect the credential file in .json format for further step reference. see `credential-collection/rclone-google-service-accounts.json` for reference.


### 2.3) Setup credential for first-time config
```shell
rclone config

2026/01/20 10:37:50 NOTICE: Config file "/root/.config/rclone/rclone.conf" not found - using defaults
No remotes found, make a new one?
n) New remote
s) Set configuration password
q) Quit config
n/s/q> n

Enter name for new remote.
name> csr-to-gdrive

Option Storage.
Type of storage to configure.
Choose a number from below, or type in your own value.
Storage> 22

Option client_id.
Google Application Client Id
Setting your own is recommended.
See https://rclone.org/drive/#making-your-own-client-id for how to create your own.
If you leave this blank, it will use an internal key which is low performance.
Enter a value. Press Enter to leave empty.
client_id> <your_client_id>

Option client_secret.
OAuth Client Secret.
Leave blank normally.
Enter a value. Press Enter to leave empty.
client_secret> <your_client_secret>

Option scope.
Comma separated list of scopes that rclone should use when requesting access from drive.
Choose a number from below, or type in your own value.
Press Enter to leave empty.
 1 / Full access all files, excluding Application Data Folder.
   \ (drive)
 2 / Read-only access to file metadata and file contents.
   \ (drive.readonly)
   / Access to files created by rclone only.
 3 | These are visible in the drive website.
   | File authorization is revoked when the user deauthorizes the app.
   \ (drive.file)
   / Allows read and write access to the Application Data folder.
 4 | This is not visible in the drive website.
   \ (drive.appfolder)
   / Allows read-only access to file metadata but
 5 | does not allow any access to read or download file content.
   \ (drive.metadata.readonly)
scope> 1

Option service_account_file.
Service Account Credentials JSON file path.
Leave blank normally.
Needed only if you want use SA instead of interactive login.
Leading `~` will be expanded in the file name as will environment variables such as `${RCLONE_CONFIG_DIR}`.
Enter a value. Press Enter to leave empty.
service_account_file> 

Edit advanced config?
y) Yes
n) No (default)
y/n> n

Use web browser to automatically authenticate rclone with remote?
 * Say Y if the machine running rclone has a web browser you can use
 * Say N if running rclone on a (remote) machine without web browser access
If not sure try Y. If Y failed, try N.

y) Yes (default)
n) No
y/n> n

Option config_token.
For this to work, you will need rclone available on a machine that has
a web browser available.
For more help and alternate methods see: https://rclone.org/remote_setup/
Execute the following on the machine with the web browser (same rclone
version recommended):
        # run this command on vm that possible access web browser
        rclone authorize "drive" "xxxxx"
        # expected output
        # 2026/01/20 11:28:45 NOTICE: Config file "/Users/kimcharry9/.config/rclone/rclone.conf" not found - using defaults
        # 2026/01/20 11:28:45 NOTICE: Make sure your Redirect URL is set to "http://127.0.0.1:53682/" in your custom config.
        # 2026/01/20 11:28:45 NOTICE: If your browser doesn't open automatically go to the following link: http://127.0.0.1:53682/auth?state=xxxxx>
        # 2026/01/20 11:28:45 NOTICE: Log in and authorize rclone for access
        # 2026/01/20 11:28:45 NOTICE: Waiting for code...
        # 2026/01/20 11:29:09 NOTICE: Got code
        # Paste the following into your remote machine --->
        # <your_code>
        # <---End paste

Then paste the result.
Enter a value.
config_token> <your-tokens-from-your-browser-link>

Configure this as a Shared Drive (Team Drive)?

y) Yes
n) No (default)
y/n> n

Configuration complete.
Options:
- type: drive
- client_id: <client-id>
- client_secret: <client-secret>
- scope: drive
- token: <token>
- team_drive: 
Keep this "csr-to-gdrive" remote?
y) Yes this is OK (default)
e) Edit this remote
d) Delete this remote
y

Current remotes:

Name                 Type
====                 ====
csr-to-gdrive        drive

e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q> q
```

### 2.4) Backup rclone.conf for future usage
- see `credential-collection/rclone.conf` for reference.

## 3. Create program/script for image usage
### 3.1) Create config file for variable updating
```shell
# Add general option
WORK_DIR="/etc/docker/my-image/generate-csr-to-gdrive"
COLLECTION_DIR="${WORK_DIR}/collection"
GDRIVE_REMOTE_NAME="csr-to-gdrive"
GDRIVE_DIR="csr-to-gdrive"
RSA_SIZE=${RSA_SIZE}
KEY_NAME=${KEY_NAME}

# Add subject session
# -subj "/C=COUNTRY/ST=STATE/L=LOCATION/O=ORG_NAME/CN=COMMON_NAME/emailAddress=EMAIL" \
COUNTRY=${COUNTRY}
STATE=${STATE}
LOCATION=${LOCATION}
ORG_NAME=${ORG_NAME}
ORG_OU_NAME=${ORG_OU_NAME}
COMMON_NAME=${COMMON_NAME}
EMAIL=${EMAIL}

# Add "Subject Alternative Name" extension
# -addext "subjectAltName=SAN_01,SAN_02"
# Please fill "yes" to add SAN with "," between SANs definition. fill "no" to skip this config
# e.g. "DNS:www.example.com,DNS:www.example2.com"
HAS_EXT=${HAS_EXT}
SAN=${SAN}
```
### 3.2) Create script
```shell
#!/bin/bash

source $1 

echo ""
echo "CSR Generator Script is working!"
CURRENT_DIR_DATE=`date +"%Y%m%d-%H%M%S"`
echo "Executing Date: ${CURRENT_DIR_DATE}"
echo ""

echo "[1] Check previous 'Date' folder for key/csr quarter collection"
PREVIOUS_DIR_DATE=`/usr/bin/rclone lsf ${GDRIVE_REMOTE_NAME}:${GDRIVE_DIR} --dirs-only | tail -n 1 | sed 's#/$##g'`
echo "> previous key/csr generating date: ${PREVIOUS_DIR_DATE}"
echo "> list key/csr files:"
/usr/bin/rclone lsl ${GDRIVE_REMOTE_NAME}:${GDRIVE_DIR}/${PREVIOUS_DIR_DATE} | tail -n 1 | sed 's#/$##g'
echo ""

echo "[2] Create current 'Date' folder for key/csr quarter collection"
echo "> date folder is: ${CURRENT_DIR_DATE}"
mkdir -p ${COLLECTION_DIR}/${CURRENT_DIR_DATE}
echo ""

echo "[3] Generate key/csr file for current quarter"
if [ ${HAS_EXT} == "yes" ]
then
        /usr/bin/openssl req -new -newkey rsa:${RSA_SIZE} -nodes \
                -keyout ${COLLECTION_DIR}/${CURRENT_DIR_DATE}/${KEY_NAME}.key \
                -out ${COLLECTION_DIR}/${CURRENT_DIR_DATE}/${KEY_NAME}.csr \
                -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}/O=${ORG_NAME}/OU=${ORG_OU_NAME}/CN=${COMMON_NAME}/emailAddress=${EMAIL}" \
                -addext "subjectAltName=${SAN}"
else
        /usr/bin/openssl req -new -newkey rsa:${RSA_SIZE} -nodes \
                -keyout ${COLLECTION_DIR}/${CURRENT_DIR_DATE}/${KEY_NAME}.key \
                -out ${COLLECTION_DIR}/${CURRENT_DIR_DATE}/${KEY_NAME}.csr \
                -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}/O=${ORG_NAME}/OU=${ORG_OU_NAME}/CN=${COMMON_NAME}/emailAddress=${EMAIL}"
fi
echo ""

echo "[4] Display SOURCE csr file information for validation"
SUBJECT_LIST=`/usr/bin/openssl req -in ${COLLECTION_DIR}/${CURRENT_DIR_DATE}/${KEY_NAME}.csr -noout -subject -nameopt multiline`
echo "> ${SUBJECT_LIST}"
RSA_SIZE_LIST=`/usr/bin/openssl req -in ${COLLECTION_DIR}/${CURRENT_DIR_DATE}/${KEY_NAME}.csr -noout -text \
        | grep -i "public-key" \
        | sed 's/^[[:space:]]*//g'`
echo "> ${RSA_SIZE_LIST}"
SAN_LIST=`/usr/bin/openssl req -in ${COLLECTION_DIR}/${CURRENT_DIR_DATE}/${KEY_NAME}.csr -noout -text \
        | grep -i -A 1 "Subject Alternative Name" \
        | sed 's/^[[:space:]]*//g'`
echo "> ${SAN_LIST}"
echo ""

echo "[5] Push csr file to google-drive"
/usr/bin/rclone copy ${COLLECTION_DIR}/${CURRENT_DIR_DATE}/${KEY_NAME}.csr ${GDRIVE_REMOTE_NAME}:${GDRIVE_DIR}/${CURRENT_DIR_DATE}
echo "> uploded file:`/usr/bin/rclone lsl csr-to-gdrive:/csr-to-gdrive/${CURRENT_DIR_DATE}`"
echo "> file diff/match:"
/usr/bin/rclone check ${COLLECTION_DIR}/${CURRENT_DIR_DATE}/${KEY_NAME}.csr ${GDRIVE_REMOTE_NAME}:${GDRIVE_DIR}/${CURRENT_DIR_DATE}
echo ""

echo "[6] Display DESTINATION csr file information for validation"
SUBJECT_LIST=`/usr/bin/rclone cat ${GDRIVE_REMOTE_NAME}:${GDRIVE_DIR}/${CURRENT_DIR_DATE}/${KEY_NAME}.csr \
        | /usr/bin/openssl req -noout -subject -nameopt multiline`
echo "> ${SUBJECT_LIST}"
RSA_SIZE_LIST=`/usr/bin/rclone cat ${GDRIVE_REMOTE_NAME}:${GDRIVE_DIR}/${CURRENT_DIR_DATE}/${KEY_NAME}.csr \
        | /usr/bin/openssl req -noout -text \
        | grep -i "public-key" \
        | sed 's/^[[:space:]]*//g'`
echo "> ${RSA_SIZE_LIST}"
SAN_LIST=`/usr/bin/rclone cat ${GDRIVE_REMOTE_NAME}:${GDRIVE_DIR}/${CURRENT_DIR_DATE}/${KEY_NAME}.csr \
        | /usr/bin/openssl req -noout -text \
        | grep -i -A 1 "Subject Alternative Name" \
        | sed 's/^[[:space:]]*//g'`
echo "> ${SAN_LIST}"
echo ""
echo "CSR Generator Script is succesfully worked!"
echo ""
```

## 4. Create Dockerfile
```shell
FROM ubuntu:24.04

ENV TZ=Asia/Bangkok

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
	tzdata	\
      	openssl \
      	ca-certificates \
      	bash \
  && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
  && echo $TZ > /etc/timezone \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /

COPY rclone /usr/bin/rclone
RUN chmod +x /usr/bin/rclone

RUN mkdir -p /etc/docker/my-image/generate-csr-to-gdrive/collection
RUN mkdir -p /etc/docker/my-image/generate-csr-to-gdrive/replaced_conf
COPY generate-csr-script.sh /etc/docker/my-image/generate-csr-to-gdrive/
COPY replaced_conf/generate-csr-config.conf /etc/docker/my-image/generate-csr-to-gdrive/replaced_conf/
COPY replaced_conf/rclone.conf /root/.config/rclone/

CMD ["/etc/docker/my-image/generate-csr-to-gdrive/generate-csr-script.sh"]
```

## 5. Deploy program into image file
```shell
docker build \
      -f ${CUSTOM_DOCKERFILE:-Dockerfile} \
      -t "${IMAGE_NAME}:${IMAGE_TAG}" \
      -t "${IMAGE_NAME}:${IMAGE_TAG_LATEST}" \

docker push "${IMAGE_NAME}:${IMAGE_TAG}"
docker push "${IMAGE_NAME}:${IMAGE_TAG_LATEST}"
```

## 6. Run your first image
```shell
docker run --rm ${IMAGE_NAME}:${IMAGE_TAG}

# For interactive mode or container discovering.
docker run --rm -it --entrypoint /bin/bash ${IMAGE_NAME}:${IMAGE_TAG}
```

## 7. Docker general command
- list current images
```shell
docker images

i Info →   U  In Use
IMAGE                                                             ID             DISK USAGE   CONTENT SIZE   EXTRA
generate-csr-to-gdrive:0.0.2                                      4b3daa2477f1        225MB         56.6MB        
gitlab/gitlab-runner:latest                                       d90b8dddf621        452MB          104MB    U   
registry.gitlab.com/wongsatorn.pu-group/csr-to-gdrive-lab:0.0.1   4a2b0e21d7bb        225MB         56.6MB          
```
- list current running container
```shell
docker ps -a

CONTAINER ID   IMAGE                         COMMAND                  CREATED      STATUS                          PORTS     NAMES
a3b570e2a4cf   gitlab/gitlab-runner:latest   "/usr/bin/dumb-init …"   6 days ago   Restarting (1) 32 seconds ago             gitlab-runner
```
- remove container
```shell
docker rm <container-id/container-name>
```
- remove image. REQUIRE remove container first.
```shell
docker rmi <image-id/image-name>
```