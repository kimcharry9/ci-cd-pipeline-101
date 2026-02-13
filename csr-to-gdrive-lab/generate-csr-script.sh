#!/bin/bash

source $1

echo ""
echo "CSR Generator Script is working!"
CURRENT_DIR_TIMESTAMP=`date +"%Y-%m-%d_%H:%M:%S"`
CURRENT_DIR_DATE=`date +"%Y-%m-%d"`
echo "Executing Date: ${CURRENT_DIR_TIMESTAMP}"
echo ""

echo "[1] Check previous 'Date' folder for key/csr quarter collection"
PREVIOUS_DIR_DATE=`/usr/bin/rclone lsf ${GDRIVE_REMOTE_NAME}:${JOB_NAME} --dirs-only --exclude "*_*/**" | tail -n 1 | sed 's#/$##g'`
echo "> previous key/csr generating date: ${PREVIOUS_DIR_DATE}"
echo "> list key/csr files:"
CSR_PREVIOUS_LIST=`/usr/bin/rclone lsl ${GDRIVE_REMOTE_NAME}:${JOB_NAME}/${PREVIOUS_DIR_DATE}`
echo "${CSR_PREVIOUS_LIST}"
CSR_PREVIOUS_MODIFIED_DATE=`echo ${CSR_PREVIOUS_LIST} | head -n 1 | awk '{print $2 "_" $3}' | cut -d '.' -f 1`
echo ""
if [ "${CURRENT_DIR_DATE}" == "${PREVIOUS_DIR_DATE}" ]
then
	/usr/bin/rclone move ${GDRIVE_REMOTE_NAME}:${JOB_NAME}/${PREVIOUS_DIR_DATE} ${GDRIVE_REMOTE_NAME}:${JOB_NAME}/${CSR_PREVIOUS_MODIFIED_DATE}
fi

echo "[2] Create current 'Date' folder for key/csr quarter collection"
echo "> date folder is: ${CURRENT_DIR_DATE}"
mkdir -p ${COLLECTION_DIR}/${CURRENT_DIR_DATE}
echo ""

echo "[3] Generate key/csr file for current quarter"

/usr/bin/openssl req -new -newkey rsa:${RSA_SIZE} -nodes \
	-keyout ${COLLECTION_DIR}/${CURRENT_DIR_DATE}/${COMMON_NAME}.key \
	-out ${COLLECTION_DIR}/${CURRENT_DIR_DATE}/${COMMON_NAME}.csr \
	-subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}/O=${ORG_NAME}/OU=${ORG_OU_NAME}/CN=${COMMON_NAME}/emailAddress=${EMAIL}"

echo ""

echo "[4] Display SOURCE csr file information for validation"
SUBJECT_LIST=`/usr/bin/openssl req -in ${COLLECTION_DIR}/${CURRENT_DIR_DATE}/${COMMON_NAME}.csr -noout -subject -nameopt multiline`
echo "> ${SUBJECT_LIST}"
RSA_SIZE_LIST=`/usr/bin/openssl req -in ${COLLECTION_DIR}/${CURRENT_DIR_DATE}/${COMMON_NAME}.csr -noout -text \
	| grep -i "public-key" \
	| sed 's/^[[:space:]]*//g'`
echo "> ${RSA_SIZE_LIST}"
SAN_LIST=`/usr/bin/openssl req -in ${COLLECTION_DIR}/${CURRENT_DIR_DATE}/${COMMON_NAME}.csr -noout -text \
	| grep -i -A 1 "Subject Alternative Name" \
	| sed 's/^[[:space:]]*//g'`
echo "> ${SAN_LIST}"
echo ""

echo "[5] Push csr file to google-drive"
/usr/bin/rclone copy ${COLLECTION_DIR}/${CURRENT_DIR_DATE} ${GDRIVE_REMOTE_NAME}:${JOB_NAME}/${CURRENT_DIR_DATE}
echo "> uploded file:`/usr/bin/rclone lsl ${GDRIVE_REMOTE_NAME}:${COMMON_NAME}/${CURRENT_DIR_DATE}`"
echo "> file diff/match:"
/usr/bin/rclone check ${COLLECTION_DIR}/${CURRENT_DIR_DATE} ${GDRIVE_REMOTE_NAME}:${JOB_NAME}/${CURRENT_DIR_DATE}
echo ""

echo "[6] Display DESTINATION csr file information for validation"
SUBJECT_LIST=`/usr/bin/rclone cat ${GDRIVE_REMOTE_NAME}:${JOB_NAME}/${CURRENT_DIR_DATE}/${COMMON_NAME}.csr \
	| /usr/bin/openssl req -noout -subject -nameopt multiline`
echo "> ${SUBJECT_LIST}"
RSA_SIZE_LIST=`/usr/bin/rclone cat ${GDRIVE_REMOTE_NAME}:${JOB_NAME}/${CURRENT_DIR_DATE}/${COMMON_NAME}.csr \
	| /usr/bin/openssl req -noout -text \
	| grep -i "public-key" \
	| sed 's/^[[:space:]]*//g'`
echo "> ${RSA_SIZE_LIST}"
SAN_LIST=`/usr/bin/rclone cat ${GDRIVE_REMOTE_NAME}:${JOB_NAME}/${CURRENT_DIR_DATE}/${COMMON_NAME}.csr \
	| /usr/bin/openssl req -noout -text \
	| grep -i -A 1 "Subject Alternative Name" \
	| sed 's/^[[:space:]]*//g'`
echo "> ${SAN_LIST}"
echo ""
echo "CSR Generator Script is succesfully worked!"
echo ""
