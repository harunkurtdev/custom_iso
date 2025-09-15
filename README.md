# Custom ISO Editor and Docker Server

The main goal of this project is to provide faster `up2 squared` installations and support for rapid deployment.

Throughout this work, it is assumed that we have ```our own .iso file on USB```.
Our `grub.cfg` file determines which menu section we enter during the installation phase.
By default, we aim to connect through the docker server. This way, rather than using the one-time written ISO file, the server running on docker will be more active.

### Installation by editing `pressed/user-data` through ISO file

The goal is to provide a quick installation by specifying the user-data path in the grub.cfg file found in Ubuntu 22.04 Server. By editing the Ubuntu 22.04 server `pressed/user-data` file, the installation of all files we expect to come by default is provided.

### Installation by editing `user-data` through Docker Server

Since the ```grub.cfg``` inside our initially edited .iso file will remain fixed in any case, it is sufficient to just run the server during the installation phase. If new code is added to user-data, it needs to be built and the server needs to be restarted.

The defined IP address for our docker server is `subnet=172.20.0.1`
Our docker server port is `port 3003`

#### NOTE

```user-data``` sample code is from github subiquity example.
`early-commands` - the first codes that will run at the beginning start from here in this code script.
`packages` - adding packages to be used in the written operating system.
`late-commands` - our final commands while writing the iso file.
`identity` - must be in every file.

You can find more content in your own examples [example link](https://github.com/canonical/subiquity/tree/main/examples/autoinstall)

```yaml
version: 1
early-commands:
  - echo a
  - sleep 1
  - echo a
debconf-selections: eek
packages:
  - package1
  - package2
late-commands:
  - echo a
  - sleep 1
  - echo a
keyboard:
  layout: gb
source:
  id: ubuntu-server-minimal
updates: security
user-data:
  users:
    - name: ubuntu
      passwd: '$6$wdAcoXrU039hKYPd$508Qvbe7ObUnxoj15DRCkzC3qO7edjH0VV7BPNRDYK4QR8ofJaEEF2heacn0QgD.f8pO8SNp83XNdWG6tocBM1'
```

#### NOTE:

Password generation code required for creating passwords.

```bash
openssl passwd -6 -salt $(openssl rand -hex 8) "ubuntu" #string
openssl passwd -6 -salt $(openssl rand -hex 8) 1
```

# Automatic ISO Configuration

The codes in this section have been automated within the makefile.
Our commands:

Our code generics are written to be compatible with APU/APU2 systems for flight information. Since the APU system runs at high clock speeds, performance is quite good. To be compatible with this, call the codes named `isolinux` in your codes.
```Intel's APU systems tend to have higher clock speeds and more cores. These features enable Intel's APU systems to perform well on the CPU side. Secondly, AMD's APU systems have gained more popularity than Intel's.```

`make iso_depends` downloads the missing files in the operating system.
`make iso_download` downloads ubuntu 22.04 server directly into the defined file structure.
`make iso_init` extracts the downloaded iso file into the defined `iso_root` folder.
`make iso_setup` integrates our codes in the config folder into the system.
`make iso_setup-isolinux` edits our codes according to apu/apu2.
`make iso_geniso` compresses the `iso_root` file in iso format.
`make iso_geniso-isolinux` produces the iso file according to apu/apu2 system from the `iso_root` file.

`make iso_write_usb` enables automatic loading of the latest produced iso file into connected USBs. `Be careful about this - don't have USB connected to your device`

![iso_write_usb](./images/iso_write_usb_hub.jpg)

If the codes are being run for the first time, you should say `make iso_depends`.
    
    $ make iso_depends
    $ make iso_download
    $ make iso_init
    
    $ make iso_setup
    $ make iso_setup-isolinux
    
    $ make iso_geniso-isolinux
    
If no errors are received as a result of these operations:

    $ make iso_write_usb
This provides direct automatic installation to USBs.

![share_internet_for_up2.jpg](./images/share_internet_for_up2.jpg)
Image taken from the internet.

By connecting your computer to any router, we must build our docker server and then run it.

    $ make iso_server_build
    $ make iso_server_run

No settings are needed for the server. After the main computer is connected to the switch, it performs the automatic installation itself.
```
server ip address 172.20.0.2 
port: 3003 - there was no issue of conflict with the host computer's port.
```
To connect to the server shell:

    $ make iso_server_shell