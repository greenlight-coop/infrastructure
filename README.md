# Ale Vat Software Infrastructure
Documents Ale Vat environment set up and configurations.

## MacBook

### Set Up

* Install Docker Desktop, no Kubernetes

* Install and configure Google Cloud Platform CLI

        cd ~/dev/tools
        wget -c https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-265.0.0-darwin-x86_64.tar.gz -O - | tar -xz
        gcloud init
        
    * Login as ...@alevat.com account
    * Choose alevat-development as project
    * Choose us-east4-a as the default zone

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
            --project alevat-development \
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

    * Fork https://github.com/jenkins-x/jenkins-x-boot-config.git to `alevat` and rename new 
      repository `environment-alevat-dev`
    
    
        cd ~/dev/git/alevat/jx
        git clone git@github.com:alevat/environment-alevat-dev.git
        cd environment-alevat-dev
        echo "*.iml" >> .gitignore
        cp ~/dev/git/alevat/infrastructure/jx-requirements.yml .
        git commit -a -m"Initial configuration" && git push
        jx boot
        
*  Configure via `jx boot`
    * Y to continue after TLS warning
    * Enter three times to create new buckets
    * Use default username (admin)
    * Generate, store and use admin password
    * `Pipeline bot Git username`: alevat-jenkins
    * `Pipeline bot Git email address`: jenkins@alevat.com
    * `Pipeline bot Git token`: generate via https://github.com/settings/tokens/new?scopes=repo,read:user,read:org,user:email,write:repo_hook,delete_repo
    * `HMAC token...`: save token and press enter to use generated token
    * `...external Docker Registry`: press enter for no
    
* Upgrade Ingress
    
    * Set *.dev.alevat.com A record to Ingress IP via domains.google.com
    * `jx upgrade ingress --cluster`
        * `Expose type:` Ingress
        * `Domain`: dev.alevat.com
        * `...enable cluster wide TLS`: Y
        * `Use LetsEncrypt staging or production`: production
        * `Email address...`: etavela@alevat.com
        * `UrlTemplate...`: enter for default
        * `Use config values...`: enter for Y
        * `CertManager deployment not found...`: enter for Y
        

### Tear Down

* Remove resources from Google Cloud Platform

        gcloud container clusters \
            delete alevat \
            --region us-east4 \
            --quiet
            
        gcloud compute disks delete \
            --zone us-east4-1 \
            $(gcloud compute disks list \
            --filter="zone:us-east1-b AND -users:*" \
            --format="value(id)") --quiet
        gcloud compute disks delete \
            --zone us-east4-b \
            $(gcloud compute disks list \
            --filter="zone:us-east1-c AND -users:*" \
            --format="value(id)") --quiet
        gcloud compute disks delete \
            --zone us-east4-c \
            $(gcloud compute disks list \
            --filter="zone:us-east1-d AND -users:*" \
            --format="value(id)") --quiet
            
    * Delete all buckets

* Remove tools from brew

        brew uninstall jx
        brew uninstall kail
        brew uninstall kubernetes-helm
        brew uninstall kubernetes-cli

* Remove gcloud-sdk

        rm -rf  ~/dev/tools/google-cloud-sdk

* Remove local configuration files

        rm -rf  ~/.gsutil
        rm -rf  ~/.helm
        rm -rf  ~/.kube
        rm -rf  ~/.config/gcloud
        
* Remove Jenkins X GitHub artifacts
    * Remove any alevat-jenkins environment repositories
    * Delete alevat-jenkins Jenkins X token
