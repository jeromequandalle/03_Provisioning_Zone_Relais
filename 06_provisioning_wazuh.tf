
# Utiliser un null_resource avec for_each pour chaque serveur
resource "null_resource" "install_index" {

  # Connexion SSH pour exécuter les commandes à distance
  connection {
    type        = "ssh"
    host        = "10.42.10.70"
    user        = var.ssh_user
    private_key = file(var.ssh_key)  # Chemin vers la clé privée SSH
  }
  
  
  # Provisioner pour exécuter des commandes à distance
  provisioner "remote-exec" {
    inline = [
      "curl -sO https://packages.wazuh.com/4.9/wazuh-install.sh",
      "sudo bash wazuh-install.sh -a"
      ]
  }

depends_on = [null_resource.install_guaca]
}
