# GolfTV Application
## This document is intended to get you set up in running the GolfTV Application. The application requires number of prerequisites that you'll have to install on your local machine first in order to run it and have the tvOS application delegate control to.


# System Requirements
## This application was built in the following environment:
1. macOS Sierra v10.12.6
2. HarperDB Community Edition Beta Mac 1.0.7
3. Docker Community Edition v17.12.0-ce-mac46
4. minikube version: v0.22.3
5. kubectl v1.8.0
6. git version 2.11.0 (Apple Git-81)

# What does this do?
This application allows you to create your own local setup for a client/server setup for a tvOS application to view your local videos through an Apple TV!

The server will:

1. Store data regarding your videos
2. Allow you to retrieve video data
3. Sets up a JS application framework where your tvOS client will delegate control to
4. Serve out TVML that will be consumed by your tvOS client

The client will:

1. Delegate control to the server JS application
2. Provide an interface for you to browse and play videos stored in the server

# HarperDB Setup
## Run the `harper-init.sh` script to initialize the schema, table and import some demo data into HarperDB

Note that the init script assumes that you have a running instance of HarperDB that's listening on the default port, which is 9925.

# Minikube Setup
## Run the `minikube-run.sh` script to get a local environment set up on your machine.  The script will:

1. Clone all the required repositories into specified directories (if they don't exist already)
2. Create a namespace in your minikube instance and change the context to use that namespace for future kubectl commands
3. Delete any existing services and deployments in the namespace
4. Build and tag the new images for the golftv-static and harperdb-client repos
5. Create the services and deployments using the yaml files, which make use of the images that were created in the previous step

At this point you should have two pods running, one for golftv-static and another for harperdb-client

# tvOS Testing
Once your local kubernetes cluster has the required pods up and running, set up the following host entry:

*minikube-ip* local.golf.tv

Next, create a new tvOS app in XCode, and set the tvBaseURL variable to:

*static let tvBaseURL = "http://local.golf.tv:30080/"*

Finally, RUN your application in XCode and use the interactive simulator to test out your application.  At this point, you're free to make modifications to the golftv-static or harperdb-client repositories in order to customize the XML that gets consumed by the application.