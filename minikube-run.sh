#!/bin/bash

## Quick shell script that should let you run the golftv project quickly.
## Clones all of the repositories, sets up npm modules, and initializes
## a minikube setup that you would run locally.

### DEFINE SOME VARIABLES 
# Set the project root. This assumes all directories are in this project root dir.
PROJECT_ROOT=$(pwd)

# Pull all the defined repositories from this git url
GIT_URL="https://github.com/ppragides"

# The version of node that we'll be using for all of our nodejs containers
NODE_VERSION=latest

# Define our minikube namespace
KUBE_NAMESPACE=golftv

# We'll be tagging our docker images with this version
GOLFTV_VERSION=kubelocal

# Set the directories of the services for the various repositories we'll be cloning
STATIC_DIR=golftv-static
CONFIG_DIR=golftv-config
HARPER_DIR=harperdb-client

# Function tht builds and tags our docker images into minikube's docker instance
build_and_tag() {
    local name=$1
    # Build the image
    docker build -t $name:$GOLFTV_VERSION $PROJECT_ROOT/$name/.
}

# Array of services (aka containers) that we'll have to up and running to use the app
SERVICES=(
	"golftv-static"
	"harperdb-client"
)

# Function to print out some help info about using this script
usage() {
	echo "Usage: $0 [-nspc]" 1>&2;
	echo -e "-n \t Reinstall of NPM modules" 1>&2;
	echo -e "-p \t Pull latest changes from git repo" 1>&2;
	echo -e "-c \t Delete and reclone all services" 1>&2;
	exit 1;
}

# Iterate through the flags passed in
while getopts :npscc: opt; do
	case $opt in
		n)
			echo "Install NPM modules..."
			NPM_INSTALL=1
		;;
		p)
			echo "Pull latest from git for each project..."
			GIT_PULL=1
		;;
		c)
			echo "Blow away existing directories and clone fresh..."
			FRESH_CLONE=1
		;;
		*)
			usage
		;;
	esac
done

#### REPOSITORY STUFF
# Blow away existing repos and start fresh
if [[ $FRESH_CLONE ]]; then
        echo "Removing existing local repos (may require sudo)..."
        sudo rm -r $PROJECT_ROOT/$STATIC_DIR \
                   $PROJECT_ROOT/$HARPER_DIR \
        ls -l
fi

# git clone the repos if they dont exist
if [ ! -e $STATIC_DIR ]; then
        git clone --recursive $GIT_URL/golftv.git $STATIC_DIR
fi
if [ ! -e $HARPER_DIR ]; then
        git clone --recursive $GIT_URL/harperdb-client.git $HARPER_DIR
fi

if [ ! -e $CONFIG_DIR ]; then
        git clone --recursive $GIT_URL/golftv_config.git $CONFIG_DIR
fi

## We want to pull changes for the repos
if [[ $GIT_PULL ]]; then
        echo "Pulling changes down..."
        cd $PROJECT_ROOT/$STATIC_DIR; git pull $GIT_URL/golftv.git
        cd $PROJECT_ROOT/$HARPER_DIR; git pull $GIT_URL/harperdb-client.git
        cd $PROJECT_ROOT/$CONFIG_DIR; git pull $GIT_URL/golftv_config.git
fi

#### END REPOSITORY STUFF


# Install all the node modules our harper-db client, if they do not exist
# if [[ ! -e "$PROJECT_ROOT/$HARPER_DIR/app/node_modules" || $NPM_INSTALL ]]; then
#         echo Installing npm modules...
#         docker run --rm \
#                 -v $PROJECT_ROOT/$HARPER_DIR/app:/noderoot \
#                 -e UID=1000 \
#                 -e GID=1000 \
#                 npm:$NODE_VERSION
# fi

#########################################
### Everything in the project directories 
### should be in the right spot by this
### point.  Let's run the kubernetes
### Related stuff
#########################################

###
# minikube is up. Setup our environment to setup our docker environment in the minikube vm
###
# Create our namespace
## Look for a namespace that we've defined.  If it doesn't, create it and set the context
if [[ ! $(kubectl --ignore-not-found=true get namespace $KUBE_NAMESPACE) ]]; then
    # Build our namespace
    kubectl create namespace $KUBE_NAMESPACE;
fi

# Set the namespace preference to be the one we just created
kubectl config set-context $(kubectl config current-context) --namespace=$KUBE_NAMESPACE
eval $(minikube docker-env);

###
# minikube is up, and so is our repository.  Now we can 
# build the individual images for our projects.
# loop through the services and build all of the images
# We'll specify "shaw-home" as our namespace just to be extra sure.
###
for SERVICE in ${SERVICES[@]}
do
    # Let's kill all of the active deployments in minikube, if there are any
    # This will spit out an error message when you first run this script, since
    # they don't exist yet
    kubectl delete deployments ${SERVICE} --namespace=$KUBE_NAMESPACE
    kubectl delete services ${SERVICE} --namespace=$KUBE_NAMESPACE

    # Deleted the deployments; now we should build and tag all of the images
    build_and_tag ${SERVICE}
done

###
# The images are now in our local repository.  
# Use kubectl to run the images locally
###

# We have to run the interface containers first BEFORE the nginx container
# since minikube's DNS will add the necessary entries after the interfaces
# have started up, which the nginx definition relies on.

# HarperDB Client
kubectl create -f $PROJECT_ROOT/$CONFIG_DIR/minikube/harperdb-client-service.yaml
kubectl create -f $PROJECT_ROOT/$CONFIG_DIR/minikube/harperdb-client-deployment.yaml   

# HarperDB
kubectl create -f $PROJECT_ROOT/$CONFIG_DIR/minikube/harperdb-service.yaml
kubectl create -f $PROJECT_ROOT/$CONFIG_DIR/minikube/harperdb-deployment.yaml   

# NGINX / Static container
kubectl create -f $PROJECT_ROOT/$CONFIG_DIR/minikube/golftv-static-service.yaml
kubectl create -f $PROJECT_ROOT/$CONFIG_DIR/minikube/golftv-static-deployment.yaml    

## Our minikube cluster is set up!
## Spit out the URL for our interface, so we know what the IP address/port are
## This call also forces us to wait for the appropriate services to be up, so we can run our clients and
## ensure that they have the necessary endpoints to talk to
minikube service golftv-static --namespace=$KUBE_NAMESPACE --url

kubectl get pods

echo "Done! Make sure you add a local host entry using the minikube IP for local.golf.tv";
echo "Once you've done that, you can view the frontend at http://local.golf.tv:30080/"