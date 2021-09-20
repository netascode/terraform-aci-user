locals {
  roles = flatten([
    for domain in var.domains : [
      for role in coalesce(domain.roles, []) : {
        key = "${domain.name}/${role.name}"
        value = {
          domain_name    = domain.name
          name           = role.name
          privilege_type = lookup(role, "privilege_type", "readPriv") == "write" ? "writePriv" : "readPriv"
        }
      }
    ]
  ])
}

resource "aci_rest" "aaaPwdProfile" {
  dn         = "uni/userext/pwdprofile"
  class_name = "aaaPwdProfile"
  content = {
    historyCount = 0
  }
}

resource "aci_rest" "aaaUser" {
  dn         = "uni/userext/user-${var.username}"
  class_name = "aaaUser"
  content = {
    name          = var.username
    pwd           = var.password
    accountStatus = var.status
    descr         = var.description
    email         = var.email
    expires       = var.expires == true ? "yes" : "no"
    expiration    = var.expire_date
    firstName     = var.first_name
    lastName      = var.last_name
    phone         = var.phone
    certAttribute = var.certificate_name
  }

  lifecycle {
    ignore_changes = [content["pwd"]]
  }

  depends_on = [
    aci_rest.aaaPwdProfile
  ]
}

resource "aci_rest" "aaaUserDomain" {
  for_each   = { for domain in var.domains : domain.name => domain }
  dn         = "${aci_rest.aaaUser.id}/userdomain-${each.value.name}"
  class_name = "aaaUserDomain"
  content = {
    name = each.value.name
  }
}

resource "aci_rest" "aaaUserRole" {
  for_each   = { for role in local.roles : role.key => role.value }
  dn         = "${aci_rest.aaaUserDomain[each.value.domain_name].id}/role-${each.value.name}"
  class_name = "aaaUserRole"
  content = {
    name     = each.value.name
    privType = each.value.privilege_type
  }
}

resource "aci_rest" "aaaUserCert" {
  for_each   = { for cert in var.certificates : cert.name => cert }
  dn         = "${aci_rest.aaaUser.id}/usercert-${each.value.name}"
  class_name = "aaaUserCert"
  content = {
    name = each.value.name
    data = each.value.data
  }
}

resource "aci_rest" "aaaSshAuth" {
  for_each   = { for key in var.ssh_keys : key.name => key }
  dn         = "${aci_rest.aaaUser.id}/sshauth-${each.value.name}"
  class_name = "aaaSshAuth"
  content = {
    name = each.value.name
    data = each.value.data
  }
}
