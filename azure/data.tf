data "azurerm_resource_group" "existingrg" {
    name = "testrg2"
  
}

resource "azurerm_virtual_network" "tesvnet2" {
  name     = "testvnet2"
  location = data.azurerm_resource_group.existingrg.location
  address_space = ["192.0.0.0/16"]
  resource_group_name = data.azurerm_resource_group.existingrg.name
  subnet {
    name           = "subnet2"
    address_prefix = "192.0.2.0/24"
  }
  }
  
  resource "azurerm_network_interface" "tesnic2" {
  name                = "test-nic2"
  location            = data.azurerm_resource_group.existingrg.location
  resource_group_name = data.azurerm_resource_group.existingrg.name

  ip_configuration {
    name                          = "internal2"
    subnet_id                     = "${azurerm_virtual_network.tesvnet2.subnet.*.id[0]}"
    private_ip_address_allocation = "Dynamic"
  }
  
}
#dynamic block

/*
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-westus2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["192.168.0.0/16"]
 
  dynamic "subnet" {
    for_each = local.subnets
 
    content {
      name           = subnet.value.name
      address_prefix = subnet.value.address_prefix
    }
  }
}
*/

/* #to use custom image - need to try

data "azurerm_image" "search" {
  name                = "AZDEVOPS01_Image"
  resource_group_name = "testrg2"
}

output "image_id" {
  value = "/subscriptions/xxxxxx/resourceGroups/testrg2/providers/Microsoft.Compute/images/AZLXDEVOPS01_Image"
}

resource "azurerm_virtual_machine" "vm" {
  name                             = "AZLXDEVOPS01"
  location                         = "${azurerm_resource_group.main.location}"
  resource_group_name              = "${azurerm_resource_group.main.name}"
  network_interface_ids            = ["${azurerm_network_interface.main.id}"]
  vm_size                          = "Standard_DS12_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = "${data.azurerm_image.search.id}"
  }
storage_os_disk {
    name              = "AZLXDEVOPS01-OS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
}

  os_profile {
    computer_name  = "APPVM"
    admin_username = "devopsadmin"
    admin_password = "Cssladmin#2019"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
} */