
import os 
import ast
import paramiko
import subprocess

class vm_automation():

    def __init__(self):
        self.vm_details = {}
        self.inventery_file = str(os.path.dirname(os.path.realpath(__file__))) + str(os.path.sep) + "hosts"
        print(self.inventery_file)
        # self.key_gen_command = '''ssh-keygen -t rsa -b 4096 -C "" -P "" -f "/home/ansible/.ssh/ansible.key" -q'''
        # self.key_copy_command = '''ssh-copy-id -i ~/.ssh/ansible.key ansible@server_ip'''

    def ip_extraction(self):
        vm_details = subprocess.Popen(["terraform","output"], stdout=subprocess.PIPE)
        output = ast.literal_eval(vm_details.communicate()[0].decode("utf-8").split("=")[1].strip())
        for i in range(0, len(output[0])):
            self.vm_details[output[0][i]] = output[1][i]
        print(self.vm_details)

    def ansible_installation(self):
        ansible_ip = self.vm_details["ansible-master"]
        print(ansible_ip)
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(ansible_ip, 22, "ansible", "ansible@123")

        ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("sudo apt update", get_pty=True)
        for line in iter(ssh_stdout.readline, ""):
            print(line, end="")
        
        ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("sudo apt install software-properties-common", get_pty=True)
        for line in iter(ssh_stdout.readline, ""):
            print(line, end="")
        
        ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("sudo add-apt-repository --yes --update ppa:ansible/ansible", get_pty=True)
        for line in iter(ssh_stdout.readline, ""):
            print(line, end="")
        
        ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("sudo apt --assume-yes install ansible", get_pty=True)
        for line in iter(ssh_stdout.readline, ""):
            print(line, end="")
        
        ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("sudo ansible --version", get_pty=True)
        for line in iter(ssh_stdout.readline, ""):
            print(line, end="")


if __name__ == "__main__":

    obj = vm_automation()
    obj.ip_extraction()
    obj.ansible_installation()
    