import os
#Repository configuration
os.system("curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -")
os.system("sudo apt-add-repository 'deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main'")
#install terraform using apt package manager
os.system("sudo apt install terraform")

#Check terraform version
os.system("terraform -v ")
print ("[+] Terraform Was Successfully Installed")