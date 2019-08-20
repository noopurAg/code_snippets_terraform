variable "host" {
#  default = "9.37.194.71"
  description = "IP of host to ssh"
}

variable "root_password" {
  default = "passw0rd"
  description = "ssh root password"
}

variable "namespace" {
  default = "default"
  description = "namespace"
}
resource "null_resource" "WaitingForDb2Pod" {
  provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/waitForPod.sh",
        "bash /tmp/waitForPod.sh ${var.namespace}",
      ]
  connection {
    host = "${var.host}"
    type     = "ssh"
    user     = "root"
    password = "${var.root_password}"
  }
 }
}
