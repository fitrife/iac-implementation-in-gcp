output "vm_program" {
  value = google_compute_instance.program.name
}
output "vm_webserver" {
  value = google_compute_instance.webserver.name
}
output "zone_program" {
  value = google_compute_instance.program.zone
}
output "zone_webserver" {
  value = google_compute_instance.webserver.zone
}
output "ip_private_program" {
  value = google_compute_instance.program.network_interface
}
output "ip_private_webserver" {
  value = google_compute_instance.webserver.network_interface
}