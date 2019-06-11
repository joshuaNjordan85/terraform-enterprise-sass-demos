variable "ARM_TENANT_ID" {
  type = string
}

variable "ARM_SUBSCRIPTION_ID" {
  type = string
}

variable "ARM_CLIENT_SECRET" {
  type = string
}

variable "ARM_CLIENT_ID" {
  type = string
}

variable "app_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "instance_count" {
  type = number
}

provider "azurerm" {
  subscription_id = "${var.ARM_SUBSCRIPTION_ID}"
  client_id       = "${var.ARM_CLIENT_ID}"
  client_secret   = "${var.ARM_CLIENT_SECRET}"
  tenant_id       = "${var.ARM_TENANT_ID}"
}

resource "azurerm_resource_group" "resource_gp" {
  name     = "${var.app_name}-rg"
  location = "${var.location}"
}

resource "azurerm_virtual_machine" "app_vm" {
  name                          = "${var.app_name}-vms-${count.index + 1}"
  location                      = "${azurerm_resource_group.resource_gp.location}"
  resource_group_name           = "${azurerm_resource_group.resource_gp.name}"
  network_interface_ids         = ["${element(azurerm_network_interface.netint.*.id, count.index)}"]
  vm_size                       = "${var.vm_size}"
  count                         = "${var.instance_count}"
  delete_os_disk_on_termination = true

  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1-${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.app_name}-${count.index + 1}"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "demo"
  }
}
