# Ale Vat Software Infrastructure

Documents Ale Vat environment set up and configurations.

## Set Up

* Install Docker Desktop, no Kubernetes

* Install and configure Google Cloud Platform CLI

        cd ~/dev/tools
        wget -c https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-266.0.0-darwin-x86_64.tar.gz -O - | tar -xz
        ./google-cloud-sdk/install.sh
        gcloud init
        
    * Login as ...@alevat.com account
    * Choose any project
    * Choose us-east4-a as the default zone

* Create a new project named alevat in Google Cloud Platform and configure API permissions

        GCP_PROJECT=alevat
        gcloud projects create $GCP_PROJECT --name="Ale Vat Jenkins X" --organization=411469552668 --set-as-default
        gcloud beta billing projects link $GCP_PROJECT --billing-account=01FB2E-55F20C-819FB4
        gcloud services enable compute.googleapis.com
        gcloud services enable container.googleapis.com
        gcloud services enable containerregistry.googleapis.com
        gcloud services enable dns.googleapis.com
        
* Create a DNS managed zone for the cluster	

        ALEVAT_CLUSTER_DOMAIN=k8s
        gcloud dns managed-zones create "$ALEVAT_CLUSTER_DOMAIN-alevat-com" \
            --dns-name "$ALEVAT_CLUSTER_DOMAIN.alevat.com." \
            --description "Automatically managed zone by kubernetes.io/external-dns for Ale Vat Jenkins X cluster"

    * Add NS records for the managed zone via Google Domains
    
* Install various tools via brew

        brew install kubernetes-cli        
        brew install kubernetes-helm
        brew tap jenkins-x/jx
        brew install jx
        brew tap boz/repo
        brew install boz/repo/kail
        
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
            --scopes=gke-default,https://www.googleapis.com/auth/cloud-platform.read-only \
            --preemptible
        
        kubectl create clusterrolebinding \
            cluster-admin-binding \
            --clusterrole cluster-admin \
            --user $(gcloud config get-value account)
        
* Install Jenkins X via `jx boot`

        cd ~/dev/git/alevat/jx
        jx boot --end-step validate-git
        mv jenkins-x-boot-config environment-alevat-dev
        cd environment-alevat-dev
        cat ~/dev/git/alevat/infrastructure/jx-requirements.yml | \
            sed -e "s/GCP_PROJECT/$GCP_PROJECT/g" | \
            sed -e "s/ALEVAT_CLUSTER_DOMAIN/$ALEVAT_CLUSTER_DOMAIN/g" | \
            tee jx-requirements.yml
        jx boot
    
    *  Create GitHub token for alevat.jenkins
        * generate via https://github.com/settings/tokens/new?scopes=repo,read:user,read:org,user:email,write:repo_hook,delete_repo
        * `GITHUB_TOKEN=<generated value>`

    *  Configuration values:
        * `Jenkins X Admin Username`: Enter for admin
        * `Jenkins X Admin Password`: Generate, store and use password
        * `Pipeline bot Git username`: alevat-jenkins
        * `Pipeline bot Git email address`: jenkins@alevat.com
        * `Pipeline bot Git token`: generate via https://github.com/settings/tokens/new?scopes=repo,read:user,read:org,user:email,write:repo_hook,delete_repo
        * `HMAC token...`: save token and press enter to use generated token
        * `...external Docker Registry`: press enter for no
        
    * Grant Admin permissions to `administrators` team for alevat/environment-alevat-dev repository in GitHub
    * Edit `OWNERS` file to include `etavela` and `alevat-jenkins` 
    * Synchronize local repository with GitHub and wait for pipeline to complete
                
            git pull
            echo "*.iml" >> .gitignore
            git commit -a -m"Updated .gitignore and OWNERS" && git push
            jx get activities -w 
            
* Check and fix TLS secrets. 

    * Fix TLS secret replication annotation
    
            kubectl annotate secret tls-k8s-alevat-com-p -n jx \
                replicator.v1.mittwald.de/replication-allowed=true \
                replicator.v1.mittwald.de/replication-allowed-namespaces=jx-staging,jx-production 

    * Check secret content in jx-staging and jx-production checking for LetsEncrypt certificate info. If okay, skip 
    steps that follow.
    
            kubectl -n jx-staging get secret tls-k8s-alevat-com-p -o yaml 
            kubectl -n jx-production get secret tls-k8s-alevat-com-p -o yaml
           
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
    
            cd ~/dev/git/alevat/jx/builder-gradle-alevat
            git pull
            jx import \
                --pack docker \
                --git-username=alevat-jenkins \
                --git-api-token=$GITHUB_TOKEN

    * Wait for build to complete
    
            jx get activity -f builder-gradle-alevat -w

    * Update configuration to include new PodTemplate
    
        * Look up current builder version
    
                gcloud container images list-tags --limit=1 gcr.io/$GCP_PROJECT/builder-gradle-alevat --format="value(tags)"
                
        * Include PodTemplate configuration from builder README.md at `jenkins` key in `env/jenkins-x-platform/values.tmpl.yaml`.
                
                cd ~/dev/git/alevat/jx/environment-alevat-dev

        * Push changes and wait for build to complete
    
                git commit -a -m"Added custom builder" && git push
                jx get activity -f environment-alevat-dev -w

## Install Application

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
    
    * Import the project

            cd ~/dev/tmp
            jx import \
                --pack $JX_IMPORT_PACK \
                --git-username=alevat-jenkins \
                --url=https://github.com/alevat/$JX_IMPORT_PROJECT_NAME \
                --git-api-token=$GITHUB_TOKEN
            cd $JX_IMPORT_PROJECT_NAME
            jx get activity -f $JX_IMPORT_PROJECT_NAME -w
            
    * Fix any build issues
    
    * Promote to production
    
            JX_IMPORT_PROJECT_VERSION=$(gcloud container images list-tags --limit=1 gcr.io/$GCP_PROJECT/$JX_IMPORT_PROJECT_NAME --format="value(tags)")
            jx promote $JX_IMPORT_PROJECT_NAME --version $JX_IMPORT_PROJECT_VERSION --env production
            
    * Clean up temporary checkout 
            
            cd ~/dev/tmp
            rm -rf ~/dev/tmp/$JX_IMPORT_PROJECT_NAME
            
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
        
        gcloud projects delete $GCP_PROJECT --quiet
        
    * Remove DNS managed zone
    * Remove NS records for managed zone from Google Domains

* Remove Jenkins X GitHub artifacts
    * Remove any alevat environment repositories
    
          cd ~/dev/git/alevat/jx
          hub delete -y alevat/environment-alevat-staging
          hub delete -y alevat/environment-alevat-production
          hub delete -y alevat/environment-alevat-dev
          rm -rf ~/dev/git/alevat/jx/environment-alevat-dev
          
    * Delete alevat-jenkins Jenkins X token
    
* Remove tools from brew

        brew uninstall jx
        brew uninstall kail
        brew uninstall kubernetes-helm
        brew uninstall kubernetes-cli

* Remove local configuration files

        rm -rf  ~/.jx
        rm -rf  ~/.helm
        rm -rf  ~/.kube
        rm -rf  ~/.gsutil
        rm -rf  ~/.config/gcloud
        
* Remove gcloud-sdk

        rm -rf  ~/dev/tools/google-cloud-sdk
        
    * Remove gcloud-sdk from PATH in ~/.zshrc
        
