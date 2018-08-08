#
# Variables
#
variable "cluster_description" {
    default = "General purpose container execution for IT experiments and services"
}

variable "cluster_name" {
    default = "momentlabs-it"
}

variable "cluster_project" {
    default = "momentlabs-it"
}
variable "cluster_zone" {
    default = "us-west1-a"
}

variable "cluster_machine_type" {
    default = "f1-micro"
}
variable "cluster_initial_node_count" {
    default = 3
}

variable "cluster_admin_user" {
    default = "david@momentlabs.io"
}
variable "enable_helm" {
    description = "Install helm in to the cluster if enabled."
    default = true
}


#
# Resources
#
provider "google" {
    credentials = "${file("account.json")}"
    project = "${var.cluster_project}"
    zone = "${var.cluster_zone}"
}

# TODO: It probably makes more sense to move this somewhere
# internal so it can try and get the cluster variables right after the cluster
# is created rather than pull them from kubectl config as set up by gcloud. 
provider "kubernetes" {
    host = "${module.gke.endpoint}"
    # client_certificate
    # client_key
    # cluster_ca_certificate
}
#
# Create the cluster
#
module "gke" {
    # source = "./gke"
    source = "git@github.com:Momentlabs/terraform-modules.git//gke"
    cluster_name = "${var.cluster_name}"
    description = "${var.cluster_description}"
    zone = "${var.cluster_zone}"
    machine_type = "${var.cluster_machine_type}"
    initial_node_count = "${var.cluster_initial_node_count}"
    cluster_admin_user = "${var.cluster_admin_user}"
    enable_helm = "${var.enable_helm}"
}

# data "google_client_config" "default" {}
data "google_container_cluster" "new_cluster" {
    name = "${module.gke.cluster_name}"
}


#
# Outputs
#

output "cluster_name" {
    value = "${data.google_container_cluster.new_cluster.name}"
}

output "description" {
    value = "${data.google_container_cluster.new_cluster.description}"
}

# It's completely unclear to me why this doesn't work in the case
# where we have no cluster at first, but the others ones (e.g. machine_type) do.
# output "zone" {
#     value = "${data.google_container_cluster.new_cluster.zone}"
# }

output "machine_type" {
    value = "${data.google_container_cluster.new_cluster.node_config.0.machine_type}"
}

output "initial_node_count" {
    value = "${data.google_container_cluster.new_cluster.initial_node_count}"
}

output "endpoint" {
    value = "${data.google_container_cluster.new_cluster.endpoint}"
}
