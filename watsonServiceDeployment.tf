variable "org" {
  type                        = "string"
  description                 = "Your Bluemix ORG"
  default					  =	"CAM DevOps"
}

variable "space" {
  type                        = "string"
  description                 = "Your Bluemix Space"
  default					  = "dev"
}

variable "servicename" {

  type                        = "string"
  description                 = "Specify the service name you want to create"
  default					  =	"tone_analyzer"
}

variable "plan" {
  type                        = "string"
  description                 = "Specify the corresponding plan for the service you selected"
  default					  = "lite"
}

variable "region" {
  type                        = "string"
  description                 = "Bluemix region"
  default                     = "us-south"
}

################################################
# Load org data
################################################
data "ibm_org" "orgData" {
  org                         = "${var.org}"
}

################################################
# Load space data
################################################
data "ibm_space" "spaceData" {
  space                       = "${var.space}"
  org                         = "${data.ibm_org.orgData.org}"
}

################################################
# Load account data
################################################
data "ibm_account" "accountData" {
  org_guid                    = "${data.ibm_org.orgData.id}"
}

################################################
# Create cloudant instance
################################################
resource "ibm_service_instance" "service" {
  name                        = "${var.servicename}-${random_pet.service.id}"
  space_guid                  = "${data.ibm_space.spaceData.id}"
  service                     = "${var.servicename}"
  plan                        = "${var.plan}"
}

################################################
# Generate access info
################################################
resource "ibm_service_key" "serviceKey" {
  name                        = "${var.servicename}-${random_pet.service.id}"
  service_instance_guid       = "${ibm_service_instance.service.id}"
}

################################################
# Generate a name
################################################
resource "random_pet" "service" {
  length                      = "2"
}
# Configure the IBM Cloud Provider
provider "ibm" {
  # bluemix_api_key             = "${var.ibm_bmx_api_key}"
  region                      = "${var.region}"
}

################################################
# outputs
################################################
output "access_urls" {
 value = "${lookup(ibm_service_key.serviceKey.credentials,"url")}"
}
output "access_password" {
  value = "${lookup(ibm_service_key.serviceKey.credentials,"password")}"
}
output "access_username" {
  value = "${lookup(ibm_service_key.serviceKey.credentials,"username")}"
}

output "IBM Cloud Dashboard" {
  value = "https://console.bluemix.net/dashboard/apps/?search=tone"
}
