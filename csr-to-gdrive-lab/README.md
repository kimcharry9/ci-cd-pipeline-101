# CSR Certificate Generator Pipeline (csr-to-gdrive)


## Description

To generate CSR certificate file and push to google drive for renewing the sooner expired certificate file with new one.

## Certificate Information

For standard information–most usage. please validate or change the information with any purposed below.

| **Topic List** | **Description** | **Example Info** |
|:-----:|-----|:-----:|
|Country Name|2 letter code of your country|TH|
|State/Province Name|Full name of State|Bangkok|
|Locality Name|Full name of City|Sathorn|
|Organization Name|Your company name|Happy|
|Organizational Unit Name|Your section name|DevOps|
|Common Name|Your domain name|example.com|
|Email Address|Your email usage|noreply@gmail.com|

## How to use the pipeline
### for any program/yaml changed
- please push your latest version of source code to this repository.
- then, Gitlab CI/CD will track the .gitlab-ci.yaml for any change and create the new pipeline immediately.
- to run pipeline, click the **engine icon** on the right near the commit code to proceed. or follow steps below.
  - go to **"Build" > "Pipelines"**
  - select the **latest commit pipeline**
  - click **"Run manual or delayed jobs"**
- this method will do 3 jobs respectively: **prepare-config, build-image and run-image**
### for pipeline rerun
- to run piepline, follow steps below.
  - go to **"Build" > "Pipelines"**
  - click **"New Pipeline"**
  - click **"master"** for "Run for branch name or tag" selecting and verify the CSR detail on current UI
  - click **"New pipeline"** to proceed
- this method will do 2 jobs respectively: **prepare-config and run-image**. NO **build-image** for avoiding multiple image building unnecessarily.