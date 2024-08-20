# ------------------------------------------------------------------------------------------------
# crAPIVagrantDeployer.ps1
# Author: Oscar Guerra Rodríguez 
# Github: https://github.com/Ejjee22
# ------------------------------------------------------------------------------------------------

param (
    [switch]$Destroy,
    [string]$HostIP
)

# ------------------------------------- Global variables -----------------------------------------
$vmIP = "192.168.33.20"
$ports = @(80, 8025)
$repo = "https://github.com/OWASP/crAPI"

# ----------------------------------- Functions definition ----------------------------------------

# Display usage instructions
function Show-Usage {
    Write-Output "`nUsage: .\crAPIVagrantDeployer.ps1 -HostIP <host_ip_address> [-Destroy]`n"
    Write-Output "Options:"
    Write-Output "  -HostIP   (Required) The IP address of the host machine."
    Write-Output "  -Destroy  (Optional) If specified, destroys the VM and removes port forwarding and firewall rules.`n"
    Write-Output "Examples:"
    Write-Output "  Deploy mode:   .\crAPIVagrantDeployer.ps1 -HostIP 192.168.1.92"
    Write-Output "  Destroy mode:  .\crAPIVagrantDeployer.ps1 -HostIP 192.168.1.92 -Destroy`n"
    exit 1
}

# Configure port forwarding and firewall rules
function Set-ProxyAndPortForwarding {
    Write-Output "`n[+] Configuring port forwarding and firewall rules...`n"
    foreach ($port in $ports) {
        Write-Output "  [*] Setting up port $port..."
        netsh interface portproxy add v4tov4 listenport=$port listenaddress=$HostIP connectport=$port connectaddress=$vmIP
        netsh advfirewall firewall add rule name="Allow Port $port" protocol=TCP dir=in localport=$port action=allow
    }
}

# Remove port forwarding and firewall rules
function Remove-ProxyAndPortForwarding {
    Write-Output "`n[+] Removing port forwarding and firewall rules...`n"
    foreach ($port in $ports) {
        Write-Output "  [*] Removing configuration for port $port..."
        netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$HostIP
        netsh advfirewall firewall delete rule name="Allow Port $port"
    }   
}

# ------------------------------------- Main Function -------------------------------------------

# Dependencies check
try {
    git --version | Out-Null
} catch {
    Write-Output "`n[+] Having git installed is compulsory, quitting...`n"
    exit 1 
}
try {
    vagrant --version | Out-Null
} catch {
    Write-Output "`n[+] Having vagrant installed is compulsory, quitting...`n" 
    exit 1
}

# Check if HostIP is provided
if (-not $HostIP) {
    Write-Output "`n`n[!] Error: HostIP is required."
    Show-Usage
}

if ($Destroy) {
    Write-Output "`n`n[+] Destroy mode activated."
    
    # Destroy the VM with Vagrant
    Write-Output "`n[+] Destroying the virtual machine..."
    Set-Location crAPI/deploy/vagrant
    vagrant destroy -f
    Set-Location ../../../

    Remove-ProxyAndPortForwarding
} else {
    Write-Output "`n`n[+] Deploy mode activated."
    
    # Clone the repository and deploy with Vagrant
    Write-Output "`n[+] Cloning the repository"
    git clone $repo
    Write-Output "`n[+] Deploying the machine"
    Set-Location crAPI/deploy/vagrant
    vagrant up
    if (! $?) {
        Write-Output "`n[!] Virtual machine deployment failed, quitting...`n"
        exit 1
    } else {
        Write-Output "`n[+] Virtual machine deployed!"
    }
    Set-Location ../../../

    Set-ProxyAndPortForwarding
    Write-Output "`n[+] crAPI Lab was succesfully deployed, you can access it from your VM visiting http://$HostIP. Mailhog server runs on http://${HostIP}:8025`n"
}

