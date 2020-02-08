# What is this?
This is a quick and dirty guide to setting up a Linux-on-Windows Dev environment. This guide assumes you're using Windows 10 Pro or Enterprise.
### FAQ:
1. **Why?**
There's many reasons to run Windows as a host. IT managed machine? You want to use your gaming rig at home? You're rocking an MS Surface device? Etc. And (atleast in the opinion of the author) doing web development in Linux is arguably better. I prefer to dev in Linux so I can run the same versions of GoLang, Node, dotnet etc. that will run in my Docker containers.

2. **So this is Windows Subsystem for Linux?**
No. The performance of WSL is trash. We'll be using Hyper-V, which allows you to create a VM and "forget about it" (it runs in the background, automatically starts/stops when you start/stop your machine, doesn't pester you for updates, etc)

3. **What if I want Linux GUI apps?**
The only GUI app I need for development _on Linux_ is VS Code, and it's Remote SSH extension allows us to easily use our Windows VS Code install to tunnel into Linux, and work as if we're on the Linux machine. The filesytem, terminal, debugging etc. are all running on the Linux VM. For my workflow, this is all that's needed because the few other UI tools I run (postman, pgadmin, etc) aren't really impacted by running on Windows. If you have other Linux GUI apps you want/need, x forwarding is an option (via installing vcxsrv on Windows and setting your display in your user profile). I used to use VS Code this way but it has some warts. 

-----------------------------------
Enable client hyper-v in Windows 10
-----------------------------------
https://blogs.technet.microsoft.com/canitpro/2015/09/08/step-by-step-enabling-hyper-v-for-use-on-windows-10/
**Note:** VMWare, Virtualbox etc. will NO LONGER WORK once hyper-v is enabled!

-------------------------------------------
Powershell (on host - run as Administrator)
-------------------------------------------
```
New-VMSwitch –SwitchName "NAT-Switch" –SwitchType Internal –Verbose

Get-NetAdapter
<find index for "Nat-Switch" we just created>

New-NetIPAddress –IPAddress 192.51.100.1 -PrefixLength 24 -InterfaceIndex <index> –Verbose

New-NetNat –Name NATNetwork –InternalIPInterfaceAddressPrefix 192.51.100.0/24 –Verbose
```

---
Install Ubuntu Server
---
http://lmgtfy.com/?q=install+ubuntu+18.04+server+in+hyper-v
- Make sure to install Ubuntu *Server*
- Don't forget to set reasonable memory/CPU settings (match your number of machine cores and 1/2 RAM?)
- Assign the VM to "Default Switch" to start
- Since we're installing Linux, you will need to disable Secure boot in Settings -> Hardware -> Security -> Enable Secure boot (uncheck)

Make sure you have An SSH server running. After installing, configure /etc/netplan as follows:
```
network:
    ethernets:
        eth0:
            addresses: [192.51.100.11/24]
            gateway4: 192.51.100.1
            nameservers:
              addresses: [172.16.0.6,192.168.12.250,192.168.120.250,1.1.1.1]
            dhcp4: no
    version: 2
```
Then power down, assign the VM to the NAT-Switch you configured earlier, and power it back up.
Confirm you have network access by doing something like:
```
wget https://google.ca
```

---
Configure passwordless SSH login
---
- Open Powershell (not as Administrator) on your windows host
- Type `ssh-keygen`
- Press enter to use all the default options
- Run `scp .\.ssh\id_rsa.pub username@192.51.100.11:~/host_id_rsa.pub`
- _In the VM_ run `cat ~/host_id_rsa.pub >> ~/.ssh/authorized_keys`

---
VS Code configuration
---
- Download and install VSCode on your Windows host machine: https://code.visualstudio.com/docs/setup/windows
- After installing, search for and install the Remote - WSL extension. Click the "Reload required" button to enable it.
- Press Ctrl+Shift+P and enter Remote-WSL: New Window into the command palette, and then hit enter
- Verify your new Window is open within your Ubuntu instance by pressing Ctrl+\` to open a terminal, and then enter some commands

---
Install & configure the Windows Terminal
---
- Open the Microsoft Store
- Search for and install "Windows Terminal (Preview)"
- Open Windows Terminal
- Click on the down arrow icon and then Settings (gear icon)
- Add a new profile that looks like this (just ensure the guid is unique amongs the other profiles):
```
        {
            // custom
            "guid": "{61c54bbd-c2c6-5271-96e7-009a87ff4400}",
            "name": "name@<your-vm-here>",
			"commandline": "powershell.exe -ExecutionPolicy Bypass -NoLogo -NoExit -Command \"ssh name@<your-vm-here>\"",
            "hidden": false
        }
```
- Paste the guid into the defaultProfile property at the top of the file and save, so that when you open the Windows Terminal it defaults to WSL
- Test this out by pressing Ctrl+Shift+T to open a new tab. This should open a terminal that's already SSH'd into your VM

---
Configure Samba & Windows Network drive
---
Ensure samba is installed (sudo apt install samba). Then run:
```
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
```
to back up your samba configuration. Then add the following lines to your smb.conf (right above the `[printers]` section):
```
[HOME]
        comment = dev VM home dir
        path = /home/<your-user-name>
        force user = <your-user-name>
        guest ok = yes
        public = yes
        read only = no
```
Now run `sudo systemctl restart smbd && sudo systemctl nmbd`
You can now map a network drive on your Windows host to the following address: `\\192.51.100.11\HOME`
Now when you click on this drive in explorer it will open your Linux home directory in windows explorer. 

---------------------------
Run hvinstall.sh in the VM
---------------------------
This will install some common dev tools the author uses.
Review this script before running, and if it's not to your liking modify it or install your dev tools manually. 
