-----------------------------------
Enable client hyper-v in Windows 10
-----------------------------------
https://blogs.technet.microsoft.com/canitpro/2015/09/08/step-by-step-enabling-hyper-v-for-use-on-windows-10/
**Note:** VMWare, Virtualbox etc. will NO LONGER WORK once hyper-v is enabled!

---------------------
Install openssh-win32
---------------------
See: https://github.com/PowerShell/Win32-OpenSSH/wiki/Install-Win32-OpenSSH
	
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
Install Ubuntu
---
http://lmgtfy.com/?q=install+ubuntu+18.04+in+hyper-v
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
TODO: configure ssh pubkey in vm
---
TODO

---
Install cmder in Windows
---
http://cmder.net/
After installing, go to Settings and configure:
- Startup -> Startup Options -> Specified named task -> {PowerShell::PowerShell}
- Startup -> Tasks -> 4 {PowerShell::PowerShell} ->  (<paste code below in the bottom right text box>)
```
PowerShell -ExecutionPolicy Bypass -NoLogo -NoExit -Command "ssh username@192.51.100.11"
```

---------------------------
Run hvinstall.sh in the VM
---------------------------
This will install some common dev tools the author uses, including VS Code. 
Only the latter is needed for testing the following steps, so if you wish to install your 
own dev tools, simply install VSCode here. 

-------------------------------------------------
Install VCXSrv
-------------------------------------------------
Download version 1.19.6.0 from here: https://sourceforge.net/projects/vcxsrv/files/vcxsrv/
(you can try a newer version but YMMV - 1.20 had some bugs causing it to hang on Windows 10)
Once installed add the following IP address to your C:\Program Files\VcXsrv\X0.hosts file:
```192.51.100.11```
Then add the following to C:\Program Files\VcXsrv\config.xlaunch (you may need to create the file):
```
<?xml version="1.0" encoding="UTF-8"?>
<XLaunch WindowMode="MultiWindow" ClientMode="NoClient" LocalClient="False" Display="0" LocalProgram="xcalc" RemoteProgram="xterm" RemotePassword="" PrivateKey="" RemoteHost="" RemoteUser="" XDMCPHost="" XDMCPBroadcast="False" XDMCPIndirect="False" Clipboard="True" ClipboardPrimary="True" ExtraParams="" Wgl="True" DisableAC="False" XDMCPTerminate="False"/>
```

-----------------------
Start Xserver when you start the computer
-----------------------
Create shortcut to xlaunch.exe with the following params added to the target (right click on the shortcut to edit the target):
``` -run config.xlaunch```
 
Move the shortcut to:
```%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup```

-----------------------
Configure your new Xserver in the VM
-----------------------
Add the following to your ~/.bashrc file:
```export DISPLAY="192.51.100.1:0"```
then run: 
```source ~/.bashrc```

---
TODO: configure Samba & Windows Network drive
---
TODO

-----
TEST!
-----
- Open cmder (this should automatically ssh you to your VM and give you a bash prompt). Now run:
  $ mkdir test
  $ cd test
  $ touch test.txt
  $ code .
- _Linux_ VS Code should open _in Windows_ .. Magic!