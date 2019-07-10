variable "serverip" {
#  default = "9.37.194.71"
  description = "IP of host to ssh"
}

variable "root_password" {
  default = "passw0rd"
  description = "ssh root password"
}

variable "pvname" {
  description = "name of pv"
}
variable "pvsize" {
  description = "size of pv"
}

resource "null_resource" "CreatePV" {
  provisioner "remote-exec" {
      inline = [
      	"cp /tmp/createPV.yaml /tmp/PV_orig.yaml",
      	"pvdir=/export/${var.pvname}/",
      	"mkdir $pvdir",
      	"chmod 777 $pvdir",
      	"echo $pvdir",
      	"echo $pvdir \"*(rw,nohide,insecure,no_subtree_check,async,no_root_squash)\" >> /etc/exports",
      	"service nfs-kernel-server restart",
        "chmod +x /tmp/createPV.yaml",
        "sed -i -e 's/<pvname>/${var.pvname}/g' /tmp/createPV.yaml",
        "sed -i -e 's/<pvsize>/${var.pvsize}/g' /tmp/createPV.yaml",
        "sed -i -e 's/<serverip>/${var.serverip}/g' /tmp/createPV.yaml",
        "sed -i -e \"s|<nfspath>|$${pvdir}|g\" /tmp/createPV.yaml",
        "kubectl create -f /tmp/createPV.yaml",
        "cp /tmp/PV_orig.yaml /tmp/createPV.yaml"
      ]
  connection {
    host = "${var.serverip}"
    type     = "ssh"
    user     = "root"
    password = "${var.root_password}"
  }
 }
}
