# Ale Vat Software Infrastructure

Documents Ale Vat environment set up and configurations.

## MacBook

### Set Up

* Install Docker Desktop, no Kubernetes

* Install and configure Google Cloud Platform CLI

        cd ~/dev/tools
        wget -c https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-266.0.0-darwin-x86_64.tar.gz -O - | tar -xz
        ./google-cloud-sdk/install.sh
        gcloud init
        
    * Login as ...@alevat.com account
    * Choose any project
    * Choose us-east4-a as the default zone

* Create a new project named alevat-jx-<n> in Google Cloud Platform and configure API permissions

        GCP_PROJECT=alevat-jx-$(date +%Y%m%d%H%M%S)
        gcloud projects create $GCP_PROJECT --name="Ale Vat Jenkins X" --organization=411469552668 --set-as-default
        gcloud beta billing projects link $GCP_PROJECT --billing-account=01FB2E-55F20C-819FB4
        gcloud services enable compute.googleapis.com
        gcloud services enable container.googleapis.com
        gcloud services enable containerregistry.googleapis.com
        gcloud services enable dns.googleapis.com
        
* Create a DNS managed zone for the cluster

        gcloud dns managed-zones create "jx-test2-alevat-com" \
            --dns-name "jx-test2.alevat.com." \
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
            --preemptible
        
        kubectl create clusterrolebinding \
            cluster-admin-binding \
            --clusterrole cluster-admin \
            --user $(gcloud config get-value account)
        
* Install Jenkins X to cluster

    *  `cd ~/dev/git/alevat/jx`
    * `jx boot --end-step validate-git`
        * `Do you want to clone the Jenkins X Boot Git repository?`: Enter for Y
    * `mv jenkins-x-boot-config environment-alevat-dev`
    * `cd environment-alevat-dev`
    * `cat ~/dev/git/alevat/infrastructure/jx-requirements-step-1.yml | sed -e "s/GCP_PROJECT/$GCP_PROJECT/g" | tee jx-requirements.yml`
    
    *  Configure via `jx boot`
        * `WARNING: TLS is not enabled`: Y
        * `Jenkins X Admin Username`: Enter for admin
        * `Jenkins X Admin Password`: Generate, store and use password
        * `Pipeline bot Git username`: alevat-jenkins
        * `Pipeline bot Git email address`: jenkins@alevat.com
        * `Pipeline bot Git token`: generate via https://github.com/settings/tokens/new?scopes=repo,read:user,read:org,user:email,write:repo_hook,delete_repo
        * `HMAC token...`: save token and press enter to use generated token
        * `...external Docker Registry`: press enter for no
        
    * `git pull`
    * `echo "*.iml" >> .gitignore`
    * Grant Admin permissions to `administrators` team for alevat/environment-alevat-dev repository in GitHub
    
    * TBD - FIX for external DNS! Update *.dev A record for alevat.com in Google Domains to use new Ingress IP.
    * `git commit -a -m"Updated .gitignore" && git push`
        * Wait for any jobs to complete        

    *  TBD: copy / revise jx-requirements.yml (vault, storage, TLS, etc.)
    
* Configure dev.alevat.com domain and TLS (OLD)
    
    * Modify jx-requirements.yml
    
            ingress:
              domain: dev.alevat.com
              externalDNS: true ??????
              namespaceSubDomain: -jx.
              tls:
                email: etavela@alevat.com
                enabled: true
                production: true
        
    * `jx boot`
    
* Configure custom builder(s) ???????

        cp ~/dev/git/alevat/infrastructure/myvalues.yaml ~/.jx/
        jx upgrade platform --always-upgrade

### Tear Down

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
        
