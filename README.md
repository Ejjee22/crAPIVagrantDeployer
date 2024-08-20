# crAPIVagrantDeployer Utility

## Introduction

The `crAPIVagrantDeployer` utility is designed to simplify the deployment of the OWASP crAPI (a vulnerable API lab) using Vagrant on a Windows host. This script ensures that the virtual machine (VM) deployed by Vagrant is not only accessible from the Windows host but also from any other device on the network, such as a Linux virtual machine or another computer.

## Dependencies

To use this utility, you will need to have the following software installed on your Windows machine:

- **Git**: Required for cloning the crAPI repository.
- **Vagrant**: Essential for managing the VM. Vagrant requires a provider to run the VM. The default provider is VirtualBox, but there is also an option to use VMware if available.

Ensure that both Git and Vagrant are installed and properly configured in your system's PATH.

## Usage

The script has two modes: **deployment** (default) and **destruction**. You can use the following commands to operate the script:

### Deployment Mode (Default)

To deploy the crAPI VM and set up port forwarding along with firewall rules, run the script with the host's IP address:

```powershell
.\crAPIVagrantDeployer.ps1 -HostIP <your_host_ip>
```
Example
```powershell
.\crAPIVagrantDeployer.ps1 -HostIP 192.168.1.92
```
### Destruction Mode
To destroy the crAPI VM and remove all associated port forwarding and firewall rules, use the -Destroy switch along with the host's IP address:
```powershell
.\crAPIVagrantDeployer.ps1 -HostIP <your_host_ip> -Destroy
```

Example:
```powershell
.\crAPIVagrantDeployer.ps1 -HostIP 192.168.1.92 -Destroy
```
## Notes:
- The script requires the -HostIP parameter to be provided.
- If the -HostIP parameter is missing, the script will display usage instructions.
