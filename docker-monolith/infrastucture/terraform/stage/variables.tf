variable app_disk_image {
  description = "Disk image for docker-app"
  default     = "docker-host-base"
}
variable "project" {
  description = "global-incline-258416"
}
variable "zone" {
  default = "europe-west1-b"
}
variable "region" {
  description = "Region"
  default     = "europe-west1"
}
variable "public_key_path" {
  description = "~/.ssh/appuser.pub"
}
variable "private_key_path" {
  description = "~/.ssh/appuser"
}
variable provision_count {
  description = "1"
}