# Ale Vat Software Infrastructure

Documents Ale Vat environment set up and configurations.

## Global

* Set environment variables

       GCP_PROJECT=alevat-k8s # Revise if necessary to create in a new space
       ALEVAT_CLUSTER_DOMAIN=k8s

    *  Generate or reuse GitHub token for alevat.jenkins
        * generate via https://github.com/settings/tokens/new?scopes=repo,read:user,read:org,user:email,write:repo_hook,delete_repo
        * `GITHUB_TOKEN=<generated value>`

## Initial Set Up (One Time)

* Install Docker Desktop, no Kubernetes

* Install and configure Google Cloud Platform CLI

        cd ~/dev/tools
        wget -c https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-270.0.0-darwin-x86_64.tar.gz -O - | tar -xz
        ./google-cloud-sdk/install.sh
        gcloud init
        
    * Login as ...@alevat.com account
    * Choose any project
    * Choose us-east4-a as the default zone

* Create a new project in Google Cloud Platform and configure API permissions

        gcloud projects create $GCP_PROJECT --name="Ale Vat Kubernetes Project" --organization=411469552668 --set-as-default
        gcloud beta billing projects link $GCP_PROJECT --billing-account=01FB2E-55F20C-819FB4
        gcloud services enable compute.googleapis.com
        gcloud services enable container.googleapis.com
        gcloud services enable containerregistry.googleapis.com
        gcloud services enable dns.googleapis.com
        
* Create a DNS managed zone for the cluster	

        gcloud dns managed-zones create "$ALEVAT_CLUSTER_DOMAIN-alevat-com" \
            --dns-name "$ALEVAT_CLUSTER_DOMAIN.alevat.com." \
            --description "Automatically managed zone by kubernetes.io/external-dns for Ale Vat Jenkins X cluster"

    * Add NS records for the managed zone via Google Domains
    
* Create a GCP Storage bucket for build report output via GCP Console

    * Name: build-reports.k8s.alevat.com
    * Location type: Region, us-east4
    * Storage class: standard
    * Access control: uniform
    * Encryption: Google-managed key
    * Grant Storage Admin role to default compute service account (e.g. 472501189628-compute@developer.gserviceaccount.com)
    * Grant Storage Object Viewer to allUsers
    
* Set web configuration properties for the bucket

        gsutil web set -m index.html -e 404.html gs://build-reports.k8s.alevat.com

* Configure a CNAME to point to the report bucket
    
    * DNS Name: build-reports (.k8s.alevat.com)
    * Resource Record Type: CNAME
    * Canonical Name: c.storage.googleapis.com.

# Cluster Set Up
    
* Install various tools via brew (note Helm version may be an issue)

        brew install kubernetes-cli        
        brew tap jenkins-x/jx
        brew install jx
        brew tap boz/repo
        brew install boz/repo/kail
        brew install mongodb/brew/mongodb-community-shell
        brew tap starkandwayne/cf
        brew install starkandwayne/cf/safe
        
* Install Helm

        cd ~/dev/tmp
        wget -c https://get.helm.sh/helm-v2.14.3-darwin-amd64.tar.gz -O - | tar -xz
        sudo mv darwin-amd64/helm /usr/local/bin/helm
        rm -rf darwin-amd64
        helm version

* Create GCP Kubernetes cluster

        gcloud container clusters \
            create alevat \
            --project $GCP_PROJECT \
            --region us-east4 \
            --machine-type n1-standard-2 \
            --enable-autoscaling \
            --num-nodes 1 \
            --max-nodes 2 \
            --min-nodes 1 \
            --scopes=gke-default,storage-full,https://www.googleapis.com/auth/cloud-platform.read-only \
            --preemptible
        
        kubectl create clusterrolebinding \
            cluster-admin-binding \
            --clusterrole cluster-admin \
            --user $(gcloud config get-value account)
        
* Install Jenkins X via `jx boot`

        cd ~/dev/git/alevat/jx
        jx boot
           
    *  Configuration values:
        * `Do you want to clone the Jenkins X Boot Git repository?`: Enter for Y
        * `Do you want to jx boot the alevat cluster?`: Enter for Y
        * `Git Owner name for environment repositories`: alevat
        * `If 'alevat' is an GitHub organisation`: Y
        * (TLS warning) `Do you wish to continue?`: Y
        * `Jenkins X Admin Username`: Enter for admin
        * `Jenkins X Admin Password`: Generate, store and use password
        * `Pipeline bot Git username`: alevat-jenkins
        * `Pipeline bot Git email address`: jenkins@alevat.com
        * `Pipeline bot Git token`: Use value of GITHUB_TOKEN
        * `HMAC token...`: save token and press enter to use generated token
        * `...external Docker Registry`: press enter for no
        
    * Note - may encounter git conflicts, if necessary resolve and re-run `jx boot' in project.
            
    * Edit `OWNERS` file to include `etavela` and `alevat-jenkins`
    
    * Review any changes necessary to jx-requirements.yml template
        * `versionStream.ref`
        * Any others

    * Update the configuration
    
            mv jenkins-x-boot-config environment-alevat-dev
            cd environment-alevat-dev
            cat ~/dev/git/alevat/infrastructure/jx-requirements.yml | \
                sed -e "s/GCP_PROJECT/$GCP_PROJECT/g" | \
                sed -e "s/ALEVAT_CLUSTER_DOMAIN/$ALEVAT_CLUSTER_DOMAIN/g" | \
                tee jx-requirements.yml
            git pull
            echo "*.iml" >> .gitignore
            git commit -a -m"Updated configuration"
            jx boot
            
* Configure Jenkins X resources

    * Make JCenter available via `nexus`
    
        * Login to https://nexus-jx.k8s.alevat.com with admin username and password
        * Click Administration link
        * Click Repositories
        * Click Create Repository
        * Select `maven2 (proxy)` recipe
        * Configuration:
            * `Name`: jcenter
            * `Remote storage`: https://jcenter.bintray.com
        * Click Create Repository

* Configure custom builders

    * Import custom builder projects
    
        * Use project import steps with the following values:
        
                JX_IMPORT_PROJECT_NAME=builder-gradle-alevat
                JX_IMPORT_PACK=docker

    * Wait for build to complete

    * Update configuration to include new PodTemplate
    
        * Look up current builder version
    
                gcloud container images list-tags --limit=1 gcr.io/$GCP_PROJECT/builder-gradle-alevat --format="value(tags)"
                
        * Include PodTemplate configuration from builder README.md at `jenkins` key in `env/jenkins-x-platform/values.tmpl.yaml`.
                
                cd ~/dev/git/alevat/jx/environment-alevat-dev
                git commit -a -m"Added custom builder" && git push
                jx get activity -f environment-alevat-dev -w

* Install existing applications (required to create staging and production namespaces - see below
  for steps)
            
* Check and fix TLS secrets. (Note: annotating for kubernetes-replicator but this is not used)

    * Delete `env/templates/wildcardcert-secret.yaml` from environment-alevat-staging and 
      environment-alevat-staging.
      
        * Commit and push changes for environments.
      
    * Fix TLS secret replication annotation
    
            kubectl annotate secret tls-k8s-alevat-com-p -n jx \
                replicator.v1.mittwald.de/replication-allowed=true \
                replicator.v1.mittwald.de/replication-allowed-namespaces=jx-staging,jx-production 
           
    * Export secret data from `jx` namespace
    
            cd ~/dev/tmp
            kubectl -n jx get secret tls-k8s-alevat-com-p -o yaml > tls-secret-staging.yaml
            
    * Edit staging secret content
       
        * Delete replicator annotations
        * Add replicate from annotation
        
                replicator.v1.mittwald.de/replicate-from: jx/tls-k8s-alevat-com-p
        
        * Change `namespace` to jx-staging
        * Remove keys for selfLink, uid resourceVersion and creationTimestamp
        
    * Replace staging secret
    
            kubectl delete secret -n jx-staging tls-k8s-alevat-com-p
            kubectl apply -f tls-secret-staging.yaml
            
    * Fix secret in production
    
            cat tls-secret-staging.yaml | \
                sed -e "s/jx-staging/jx-production/g" | \
                tee tls-secret-production.yaml
            kubectl delete secret -n jx-production tls-k8s-alevat-com-p
            kubectl apply -f tls-secret-production.yaml

## Install Applications

### Quickstart

* Initialize quickstart and configure

        jx create quickstart \
            --git-username=alevat-jenkins \
            --git-api-token=$GITHUB_TOKEN
    
    * `select the quickstart you wish to create`: Select project type
    * `Who should be the owner of the repository?`: alevat
    * `Enter the new repository name:` Enter project name
    * `Would you like to initialise git now?`: Enter for Y
    * `Commit message:` Enter for default

### Import

* Import the project and configure

    * Set parameters
            
            JX_IMPORT_PROJECT_NAME=<name>
            JX_IMPORT_PACK=<pack>
            JX_IMPORT_NO_DRAFT=<true to suppress generation>
    
    * Import the project

            cd ~/dev/tmp
            jx import \
                --pack $JX_IMPORT_PACK \
                --git-username=alevat-jenkins \
                --url=https://github.com/alevat/$JX_IMPORT_PROJECT_NAME \
                --git-api-token=$GITHUB_TOKEN \
                --no-draft=$JX_IMPORT_NO_DRAFT
            cd $JX_IMPORT_PROJECT_NAME
            jx get activity -f $JX_IMPORT_PROJECT_NAME -w
            
    * Fix any build issues
    
    * Promote to production
    
            JX_IMPORT_PROJECT_VERSION=$(gcloud container images list-tags --limit=1 gcr.io/$GCP_PROJECT/$JX_IMPORT_PROJECT_NAME --format="value(tags)")
            jx promote $JX_IMPORT_PROJECT_NAME --version $JX_IMPORT_PROJECT_VERSION --env production

    * Test PR and preview environment
        * Note that updating project references in artifacts may be necessary
            
    * Clean up temporary checkout 
            
            cd ~/dev/tmp
            rm -rf ~/dev/tmp/$JX_IMPORT_PROJECT_NAME

    * Add any environment specific configuration to staging and production environments, e.g.:
    
            green-ui:
              env:
                JX_NAMESPACE: jx-staging

    * Add BDD tests to staging configuration, e.g.:
    
            env:
            - name: DEPLOY_NAMESPACE
              value: jx-staging
            pipelineConfig:
              env:
              - name: DEPLOY_NAMESPACE
                value: jx-staging
              pipelines:
                release:
                  postBuild:
                    steps:
                      - sh: ./run-tests.sh
                        name: green-bdd-test
                        dir: /home/bdd
                        agent:
                          image: gcr.io/alevat-k8s/green-bdd:0.0.5

            
## Revise Cluster Node Pool

* Create new node pool

        gcloud container node-pools create alevat-pool \
            --cluster alevat \
            --machine-type n1-standard-2 \
            --region us-east4 \
            --num-nodes 1 \
            --max-nodes 2 \
            --min-nodes 1 \
            --enable-autoscaling \
            --scopes=gke-default,storage-full,https://www.googleapis.com/auth/cloud-platform.read-only \
            --preemptible    


* Drain each node

        kubectl drain [node]
        
* Delete old pool

        gcloud container node-pools delete default-pool \
            --cluster alevat

## Tear Down

* Remove resources from Google Cloud Platform

        gcloud container clusters \
            delete alevat \
            --region us-east4 \
            --quiet
            
        gcloud compute disks delete \
            --zone us-east4-a \
            $(gcloud compute disks list \
            --filter="zone:us-east4-a AND -users:*" \
            --format="value(id)") --quiet
        gcloud compute disks delete \
            --zone us-east4-b \
            $(gcloud compute disks list \
            --filter="zone:us-east4-b AND -users:*" \
            --format="value(id)") --quiet
        gcloud compute disks delete \
            --zone us-east4-c \
            $(gcloud compute disks list \
            --filter="zone:us-east4-c AND -users:*" \
            --format="value(id)") --quiet    
            
        gsutil -m rm -r gs://alevat-jx-backup
        gsutil -m rm -r gs://alevat-jx-logs
        gsutil -m rm -r gs://alevat-jx-reports
        gsutil -m rm -r gs://alevat-jx-repository
        gsutil -m rm -r gs://jx-vault-alevat-bucket

* Remove DNS managed zone record sets

* Remove Jenkins X GitHub artifacts
    * Remove any alevat environment repositories
    
          cd ~/dev/git/alevat/jx
          hub delete -y alevat/environment-alevat-staging
          hub delete -y alevat/environment-alevat-production
          hub delete -y alevat/environment-alevat-dev
          rm -rf ~/dev/git/alevat/jx/environment-alevat-dev
          rm -rf ~/dev/git/alevat/jx/environment-alevat-staging
          rm -rf ~/dev/git/alevat/jx/environment-alevat-production
          
    * Delete alevat-jenkins Jenkins X token
    
* Uninstall manuall installed tools

        sudo rm /usr/local/bin/helm
    
* Remove tools from brew

        brew uninstall jx
        brew uninstall kail
        brew uninstall kubernetes-cli
        brew uninstall mongodb-community-shell
        brew uninstall safe

* Remove local configuration files

        rm -rf  ~/.jx
        rm -rf  ~/.helm
        rm -rf  ~/.kube
    
# Tear Down Project (optional)

* Remove DNS managed zone
    * Remove record sets for managed zone from Google Domains
    * Remove zone

* Remove project

        gcloud projects delete $GCP_PROJECT --quiet

* Remove local configuration files

        rm -rf  ~/.gsutil
        rm -rf  ~/.config/gcloud
        
* Remove gcloud-sdk

        rm -rf  ~/dev/tools/google-cloud-sdk
        
    * Remove gcloud-sdk from PATH in ~/.zshrc