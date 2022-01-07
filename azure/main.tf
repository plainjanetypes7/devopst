resource "azurerm_resource_group" "tesresgrp" {
  name     = var.resource_group_name
  location = "eastus"
}
resource "azurerm_virtual_network" "tesvnet" {
  name     = "testvnet"
  location = azurerm_resource_group.tesresgrp.location
  address_space = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.tesresgrp.name
  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
  }

  subnet {
    name           = "subnet3"
    address_prefix = "10.0.3.0/24"
  }
    /*subnet = {
                name = "subnet4"
                address_space = ["10.0.20.0/24"]
                }    */       
    tags = {
      "lab" = "0401"
    }

}
resource "azurerm_network_interface" "tesnic" {
  name                = "test-nic"
  location            = azurerm_resource_group.tesresgrp.location
  resource_group_name = azurerm_resource_group.tesresgrp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "${azurerm_virtual_network.tesvnet.subnet.*.id[0]}"
    private_ip_address_allocation = "Dynamic"
  }
    ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_virtual_network.tesvnet.subnet.*.id[0]}"
    private_ip_address_allocation = "Dynamic"
  }
}


#${azurerm_virtual_network.tesvnet.subnet.*.id[0]}
 
resource "azurerm_virtual_machine" "tesmachine" {
  name     = "testvm"
  location = azurerm_resource_group.tesresgrp.location
  network_interface_ids = [azurerm_network_interface.tesnic.id]
  resource_group_name = azurerm_resource_group.tesresgrp.name
    storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
   os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
 os_profile_windows_config {
    #delete_os_disk_on_termination = false
  }
  /*storage_os_disk = { - gave error 
    name              = "testosdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }*/
  vm_size = "Standard_DS1_v2"

    provisioner "local-exec" {
    command = "echo first"
  }

  provisioner "local-exec" {
    command = "az vm start"
  }
}
#### adding a load balancer

resource "azurerm_public_ip" "lbpip" {
  name                = "lb-pip"
  location            = azurerm_resource_group.tesresgrp.location
  resource_group_name = azurerm_resource_group.tesresgrp.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb1" {
  name                = "1-lb"
  location            = azurerm_resource_group.tesresgrp.location
  resource_group_name = azurerm_resource_group.tesresgrp.name

  frontend_ip_configuration {
    name                 = "primary"
    public_ip_address_id = azurerm_public_ip.lbpip.id
  }
}

resource "azurerm_lb_backend_address_pool" "bepool" {
  resource_group_name = azurerm_resource_group.tesresgrp.name
  loadbalancer_id     = azurerm_lb.lb1.id
  name                = "acctestpool"
}

/*
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.tesresgrp.location
  resource_group_name = azurerm_resource_group.tesresgrp.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}*/

resource "azurerm_network_interface_backend_address_pool_association" "nicaasoc" {
  network_interface_id    = azurerm_network_interface.tesnic.id
  ip_configuration_name   = "testconfiguration1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bepool.id
}
