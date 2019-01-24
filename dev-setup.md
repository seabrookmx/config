# What is this?
This is a quick and dirty guide to setting up a Linux-on-Windows Dev environment. This guide assumes you're using Windows 10 Pro or Enterprise.
### FAQ:
1. **Why?**
There's many reasons to run Windows as a host. IT managed machine? You want to use your gaming rig at home? You're rocking an MS Surface device? Etc. And (atleast in the opinion of the author) doing web development in Linux is arguably better. I prefer to dev in Linux so I can run the same versions of GoLang, Node, dotnet etc. that will run in my Docker containers.

2. **So this is Windows Subsystem for Linux?**
No. The performance of WSL is trash. We'll be using Hyper-V, which allows you to create a VM and "forget about it" (it runs in the background, automatically starts/stops when you start/stop your machine, doesn't pester you for updates, etc)

3. **What if I want Linux GUI apps?**
We'll be configuring the _Linux_ version of VSCode (via x-remoting), so that you can debug your Linux apps using it's integrated debugger. The guide asssumes this is the _only_ Linux GUI app you need, though in theory other GUI apps could/should work similarly. YMMV!

4. **What other tech is used for this franken-environment?**
You'll be running a Windows X-server via VcxSrv, and using cmder as your terminal emulator. It will be configured such that when you open it you'll be immediately taken to your Linux shell (thanks to Powershell now including ssh support!).

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

---------------------------------------------------------------------------------------------------
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

---------------------------
Run hvinstall.sh in the VM
---------------------------
This will install some common dev tools the author uses, including VS Code.
Only the latter is needed for testing the following steps, so if you wish to install your
own dev tools, simply install VSCode here.

---
Configure passwordless SSH login
---
- Open Powershell (not as Administrator) on your windows host
- Type `ssh-keygen`
- Press enter to use all the default options
- Run `scp .\.ssh\id_rsa.pub username@192.51.100.11:~/host_id_rsa.pub`
- _In the VM_ run `cat ~/host_id_rsa.pub >> ~/.ssh/authorized_keys`

-----------------------
Configure your VM's Xserver
-----------------------
Add the following to your VM's `~/.bashrc` file:
```export DISPLAY="192.51.100.1:0"```

-------------------------------------------------
Install VCXSrv (Xserver on Windows)
-------------------------------------------------
Download version 1.19.6.0 from here: https://sourceforge.net/projects/vcxsrv/files/vcxsrv/
(you can try a newer version but YMMV - 1.20 had some bugs causing it to hang on Windows 10)
Once installed add the following IP address to your `C:\Program Files\VcXsrv\X0.hosts file`:
```192.51.100.11```
Then add the following to `C:\Program Files\VcXsrv\config.xlaunch` (you may need to create the file):
```
<?xml version="1.0" encoding="UTF-8"?>
<XLaunch WindowMode="MultiWindow" ClientMode="NoClient" LocalClient="False" Display="0" LocalProgram="xcalc" RemoteProgram="xterm" RemotePassword="" PrivateKey="" RemoteHost="" RemoteUser="" XDMCPHost="" XDMCPBroadcast="False" XDMCPIndirect="False" Clipboard="True" ClipboardPrimary="True" ExtraParams="" Wgl="True" DisableAC="False" XDMCPTerminate="False"/>
```

-----------------------
Start Xserver when you start the computer
-----------------------
Create shortcut (right click -> create shortcut) to `C:\Program Files\VcXsrv\xlaunch.exe` with the following params added to the target (right click on the shortcut to edit the target):
``` -run config.xlaunch```

Move the shortcut to:
```%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup```

---
Install cmder in Windows
---
http://cmder.net/
After installing, go to Settings and configure:
- Startup -> Startup Options -> Specified named task -> {PowerShell::PowerShell}
- Startup -> Tasks -> 4 {PowerShell::PowerShell} ->  ..code below..
```
PowerShell -ExecutionPolicy Bypass -NoLogo -NoExit -Command "ssh username@192.51.100.11"
```

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
Now when you click on this drive in explorer it will open your _Linux home directory_!
-----
TEST!
-----
- Open cmder (this should automatically ssh you to your VM and give you a bash prompt). Now run:
    -  $ `mkdir test`
    -  $ `cd test`
    -  $ `touch test.txt`
    -  $ `code .`
- _Linux_ VS Code should open _in Windows_ .. Magic!
