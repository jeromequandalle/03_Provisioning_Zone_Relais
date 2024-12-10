

resource "null_resource" "build_reverse" {
    connection {
		type	=	"ssh"
		user	=	var.ssh_user
		host	=	var.ssh_host_revers
		private_key = file(var.ssh_key)
    }


 provisioner "file" {
	 source	=	"conf/site1.conf"
	 destination = "/tmp/site1.conf"
    }

 provisioner "file" {
         source =       "conf/site2.conf"
         destination = "/tmp/site2.conf"
    }

 provisioner "file" {
	 source	=	"sh/01_provisionning_reverse.sh"
	 destination = "/tmp/install_nginx.sh"
    }

 provisioner "remote-exec" {
      inline= [
     "sudo cp /tmp/install_nginx.sh .",
     "sudo chown univers install_nginx.sh",
     "sudo chmod +x install_nginx.sh",
     "./install_nginx.sh"  
      ]
  }
depends_on = [proxmox_vm_qemu.index] 
}

	   
       
