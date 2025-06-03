resource "azurerm_resource_group" "terraformgroup" {
    name = "myResourceGroupTK"
    location = "westeurope"  

    lifecycle {
      prevent_destroy = true
    }
}
resource "azurerm_virtual_network" "myterraformnetwork" {
  name = "myVnet-demo"
  address_space = [ "10.0.0.0/16" ]
  location = "westeurope"
  resource_group_name = azurerm_resource_group.terraformgroup.name

  lifecycle {
    create_before_destroy = true
  }

}

resource "azurerm_subnet" "myterraformsubnet" {
    name = "mySubnet-demo"
    resource_group_name = azurerm_resource_group.terraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes = ["10.0.1.0/24"]
  
}

resource "azurerm_network_security_group" "myterraformsg" {
    name = "myNetworkSecGroup"
    location = "westeurope"
    resource_group_name = azurerm_resource_group.terraformgroup.name

    security_rule {
        name = "SSH"
        priority = 1002
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_public_ip" "myterraformpublic" {
    name = "myPublicIP-demo"
    resource_group_name = azurerm_resource_group.terraformgroup.name
    location = "westeurope"
    allocation_method = "Dynamic"

    lifecycle {
      ignore_changes = [ tags ]
    }
}


resource "azurerm_network_interface" "myterraformic" {
    name = "myNIC"
    location = "westeurope"
    resource_group_name = azurerm_resource_group.terraformgroup.name
  ip_configuration {
    name = "myNICConf"
    subnet_id = azurerm_subnet.myterraformsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.myterraformpublic.id
  }
}

resource "random_password" "password" {
    length = 16
    special = true
    override_special = "_%@"
}

resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name = "myVM"
    location = "westeurope"
    resource_group_name = azurerm_resource_group.terraformgroup.name
    network_interface_ids = [azurerm_network_interface.myterraformic.id]
    disable_password_authentication = false
    computer_name = "vmdemo"
    admin_username = "vmdemo"
    admin_password = random_password.password.result
    size = "Standard_B1ms"

    os_disk {
      name = "myOsDisk"
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }
    source_image_reference {
      publisher = "Canonical"
      offer = "UbuntuServer"
      sku = "19_10-daily-gen2"
      version = "latest"
    }
  lifecycle {
    ignore_changes = [ admin_password ]
  }
}