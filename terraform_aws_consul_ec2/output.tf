output "consul-server-1.public_ip" {
  value = "${aws_instance.consul-server-1.public_ip}"
}

output "consul-server-2.public_ip" {
  value = "${aws_instance.consul-server-2.public_ip}"
}

output "consul-server-3.public_ip" {
  value = "${aws_instance.consul-server-3.public_ip}"
}
