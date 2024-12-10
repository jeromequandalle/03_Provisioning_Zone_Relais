# Boucle pour créer une VM pour chaque entrée dans la variable vm_list
resource "proxmox_vm_qemu" "guaca" {
  name       = "guacamole"
  agent      = 1
  target_node = "horizon"   # Spécifiez le nom de votre nœud Proxmox ici
  clone      = "debian.template"
  scsihw     = "virtio-scsi-pci"
  full_clone   = true
  #system
  vmid       = 5002
  cores      = 2
  memory     = 2048
  cpu        = "kvm64"
  os_type    = "cloud-init"
  tags       = "guacamole"
  pool = "zone-relais"
  #boot option
  bootdisk   = "scsi0"
  
  # Configuration du disque
    #disk
    disks {
      scsi {
      scsi0 {
       disk {
     size = "20G"
     storage = "production"
     format  = "raw"
            }
       } 
      }
      ide {
        ide2 {
          cloudinit {
            storage = "production"
          }
        }
      }
    
    }

  # Configuration du réseau
network {
    model            = "e1000"
    bridge           = "vmbr2"
    tag             = "10"
    }
network {
    model            = "e1000"
    bridge           = "vmbr2"
    tag             = "20"
    }


# Utiliser Cloud-Init pour configurer l'IP et le nom d'hôte unique
  ciuser      = var.ci_user       # Utilisateur configuré via Cloud-Init
  cipassword  = var.ci_mdp      # Mot de passe pour l'utilisateur
  sshkeys     = file(var.ssh_key_pub)  # Ajouter une clé SSH pour accéder aux VMs (optionnel)
  ipconfig0 = "ip=10.42.10.50/24,gw=10.42.10.1"  # Remplacez par votre passerelle réseau
  ipconfig1 = "ip=10.42.20.50/24"
  searchdomain = "mynet.net"
  nameserver = "10.42.10.1"

depends_on = [proxmox_vm_qemu.reverse]
  
}






















































  
