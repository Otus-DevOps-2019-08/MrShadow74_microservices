variable app_disk_image {
  description = "Disk image for docker-app"
  default     = "docker-host-base"
}
variable "zone" {
  default = "europe-west1-b"
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
variable counter {
  description = "Count"
  default     = "3"
}