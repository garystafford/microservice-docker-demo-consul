output "consul_server_1.public_ip" {
  value = "${aws_instance.consul_server_1.public_ip}"
}

output "consul_server_2.public_ip" {
  value = "${aws_instance.consul_server_2.public_ip}"
}

output "consul_server_3.public_ip" {
  value = "${aws_instance.consul_server_3.public_ip}"
}
