output "dn" {
  value       = aci_rest.aaaUser.id
  description = "Distinguished name of `aaaUser` object."
}

output "username" {
  value       = aci_rest.aaaUser.content.name
  description = "Username."
}
