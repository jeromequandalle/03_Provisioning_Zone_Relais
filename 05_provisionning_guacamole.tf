
# Utiliser un null_resource avec for_each pour chaque serveur
resource "null_resource" "install_guaca" {

  # Connexion SSH pour exécuter les commandes à distance
  connection {
    type        = "ssh"
    host        = "10.42.10.50"
    user        = var.ssh_user
    private_key = file(var.ssh_key)  # Chemin vers la clé privée SSH
  }
  
  provisioner "file" {
     source = "conf/tomcat9"
     destination = "/tmp/tomcat9"
     }
 provisioner "file" {
     source = "conf/bullseye.list"
     destination = "/tmp/bullseye.list"
     }
 provisioner "file" {
     source = "conf/guacamole.properties"
     destination = "/tmp/guacamole.properties"
     }

 provisioner "file" {
     source = "conf/user-mapping.xml"
     destination = "/tmp/user-mapping.xml"
     } 
  
 provisioner "file" {
     source = "sh/02_guacamole.sh"
     destination = "/tmp/guacamol.sh"
     }

  # Provisioner pour exécuter des commandes à distance
  provisioner "remote-exec" {
    inline = [
      "cp /tmp/guacamol.sh .",
      "sudo chmod +x guacamol.sh",
      "sudo bash guacamol.sh"
      ]
  }

depends_on = [null_resource.build_reverse]
}
