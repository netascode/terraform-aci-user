terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    aci = {
      source  = "netascode/aci"
      version = ">=0.2.0"
    }
  }
}

module "main" {
  source = "../.."

  username         = "USER1"
  password         = "PASSWORD1"
  status           = "inactive"
  certificate_name = "CERT1"
  description      = "My Description"
  email            = "aa.aa@aa.aa"
  expires          = true
  expire_date      = "2031-01-20T10:00:00.000+00:00"
  first_name       = "First"
  last_name        = "Last"
  phone            = "1234567"
  domains = [{
    name = "all"
    roles = [{
      name           = "admin"
      privilege_type = "write"
    }]
  }]
}

data "aci_rest" "aaaPwdProfile" {
  dn = "uni/userext/pwdprofile"

  depends_on = [module.main]
}

resource "test_assertions" "aaaPwdProfile" {
  component = "aaaPwdProfile"

  equal "historyCount" {
    description = "historyCount"
    got         = data.aci_rest.aaaPwdProfile.content.historyCount
    want        = "0"
  }
}

data "aci_rest" "aaaUser" {
  dn = "uni/userext/user-USER1"

  depends_on = [module.main]
}

resource "test_assertions" "aaaUser" {
  component = "aaaUser"

  equal "name" {
    description = "name"
    got         = data.aci_rest.aaaUser.content.name
    want        = "USER1"
  }

  equal "accountStatus" {
    description = "accountStatus"
    got         = data.aci_rest.aaaUser.content.accountStatus
    want        = "inactive"
  }

  equal "descr" {
    description = "descr"
    got         = data.aci_rest.aaaUser.content.descr
    want        = "My Description"
  }

  equal "email" {
    description = "email"
    got         = data.aci_rest.aaaUser.content.email
    want        = "aa.aa@aa.aa"
  }

  equal "expires" {
    description = "expires"
    got         = data.aci_rest.aaaUser.content.expires
    want        = "yes"
  }

  equal "expiration" {
    description = "expiration"
    got         = data.aci_rest.aaaUser.content.expiration
    want        = "2031-01-20T10:00:00.000+00:00"
  }

  equal "firstName" {
    description = "firstName"
    got         = data.aci_rest.aaaUser.content.firstName
    want        = "First"
  }

  equal "lastName" {
    description = "lastName"
    got         = data.aci_rest.aaaUser.content.lastName
    want        = "Last"
  }

  equal "phone" {
    description = "phone"
    got         = data.aci_rest.aaaUser.content.phone
    want        = "1234567"
  }

  equal "certAttribute" {
    description = "certAttribute"
    got         = data.aci_rest.aaaUser.content.certAttribute
    want        = "CERT1"
  }
}

data "aci_rest" "aaaUserDomain" {
  dn = "${data.aci_rest.aaaUser.id}/userdomain-all"

  depends_on = [module.main]
}

resource "test_assertions" "aaaUserDomain" {
  component = "aaaUserDomain"

  equal "name" {
    description = "name"
    got         = data.aci_rest.aaaUserDomain.content.name
    want        = "all"
  }
}

data "aci_rest" "aaaUserRole" {
  dn = "${data.aci_rest.aaaUserDomain.id}/role-admin"

  depends_on = [module.main]
}

resource "test_assertions" "aaaUserRole" {
  component = "aaaUserRole"

  equal "name" {
    description = "name"
    got         = data.aci_rest.aaaUserRole.content.name
    want        = "admin"
  }

  equal "privType" {
    description = "privType"
    got         = data.aci_rest.aaaUserRole.content.privType
    want        = "writePriv"
  }
}
