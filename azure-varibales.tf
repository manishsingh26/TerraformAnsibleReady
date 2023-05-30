
variable "rg_name" {
	type = string
    description = "Resource Group Name"
}

variable "rg_location" {
	type = string
    description = "Resource Group Location"
}

variable "vm_count" {
	type = number
    description = "VM Count"
}

variable "vm-details" {
  type = list(map(any))
  default = [
    {
        vm_name       = "ansible-master"
        vm_username   = "ansible"
        vm_password   = "ansible@123"
    },
    {
        vm_name       = "master-node"
        vm_username   = "ansible"
        vm_password   = "ansible@123"
    },
    {
        vm_name       = "data-node-1"
        vm_username   = "ansible"
        vm_password   = "ansible@123"
    },
    {
        vm_name       = "data-node-2"
        vm_username   = "ansible"
        vm_password   = "ansible@123"
    }
  ]
}
