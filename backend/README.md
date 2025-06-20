# Backend Directory Development Instructions

- As this backend is meant to run on Linux only due to integration with Docker, please use VSCode to connect via its built-in SSH feature to your vm. To start the VM, first run `VBoxManage startvm "MC_Admin_Dev" --type headless`. To shut down the VM after you're finished, run `VBoxManage controlvm "MC_Admin_Dev" acpipowerbutton`.
- To get SSH to show up as an option correctly configured in VSCode, add the following lines to your `~/.ssh/config`. Be sure to replace the identity file path to the corresponding path on your machine to the auto-generated private key.
```
Host MC_Admin_Dev
  HostName localhost
  User root
  Port 2222
  IdentityFile "/PATH/TO/mc_admin_dev/in/project/root/development/ssh"
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
```