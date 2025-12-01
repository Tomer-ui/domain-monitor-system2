resource "local_file" "ansible_inventory" {
  content = <<EOT
[master]
${aws_instance.jenkins_master.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${abspath("../my-key.pem")} ansible_ssh_common_args='-o StrictHostKeyChecking=no' private_ip=${aws_instance.jenkins_master.private_ip}

[node]
${aws_instance.jenkins_node.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${abspath("../my-key.pem")} ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOT
  filename = "../ansible/inventory.ini"
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins_master.public_ip}:8080"
}