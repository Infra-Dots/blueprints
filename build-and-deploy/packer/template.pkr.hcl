variable "go_binary" {
  type    = string
  default = "build/infradots"
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "infradots-ami-{{timestamp}}"
  instance_type = "t2.micro"
  region        = var.region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
    source      = var.go_binary
    destination = "/tmp/infradots"
  }

  provisioner "shell" {
    inline = [
      # Move binary
      "sudo mv /tmp/infradots /usr/local/bin/infradots",
      "sudo chmod +x /usr/local/bin/infradots",

      # Create systemd service
      "echo '[Unit]' | sudo tee /etc/systemd/system/infradots.service",
      "echo 'Description=My Go App Service' | sudo tee -a /etc/systemd/system/infradots.service",
      "echo 'After=network.target' | sudo tee -a /etc/systemd/system/infradots.service",

      "echo '[Service]' | sudo tee -a /etc/systemd/system/infradots.service",
      "echo 'ExecStart=/usr/local/bin/infradots' | sudo tee -a /etc/systemd/system/infradots.service",
      "echo 'Restart=always' | sudo tee -a /etc/systemd/system/infradots.service",
      "echo 'User=ubuntu' | sudo tee -a /etc/systemd/system/infradots.service",

      "echo '[Install]' | sudo tee -a /etc/systemd/system/infradots.service",
      "echo 'WantedBy=multi-user.target' | sudo tee -a /etc/systemd/system/infradots.service",

      # Enable and start the service
      "sudo systemctl daemon-reexec",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable infradots.service"
    ]
  }
}
