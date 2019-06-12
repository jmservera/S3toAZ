#Requires -Modules AzureRM.ContainerInstance
#Requires -Modules AzureRM.ContainerRegistry
#Requires -Modules AzureRM.Profile
<#
.SYNOPSIS
    A command for launching an ACI container for scheduled works.
.DESCRIPTION
    The command waits until the container work finishes and shows the output of the container.
.PARAMETER ContainerRegistryName
    The short name of the container registry, the one in [name].azurecr.io
.PARAMETER ContainerRegistryGroupName
    The resource group name where the ACR is, it will be used to get the credentials automatically.
.PARAMETER ContainerImage
    Name of the Container Image you want to launch, remember to prepend the ACR name in the form [name].azurecr.io/[imagename]:[version]
.PARAMETER containername
    Name for the ACI that will be created, if it exists it will be deleted.
.PARAMETER rgName
    Name of the Resource Group where the ACI will be created, if it doesn't exist it will be created.
.PARAMETER containerParams
    A JSON string with the environment variables you want to send to the container
.PARAMETER location
    The location for the resource group. Default=northeurope
.PARAMETER CPU
    Number of CPU you want for the container. Default=1
.PARAMETER MemoryInGB
    GB of memory you want for the container. Default=0.5
#>
Param
(
    [Parameter(Position=0,Mandatory=$true,HelpMessage="The short name of the container registry, the one in [name].azurecr.io")]
    [String] $ContainerRegistryName,
    [Parameter(Position=1,Mandatory=$true,HelpMessage="The resource group name where the ACR is, it will be used to get the credentials automatically")]
    [String] $ContainerRegistryGroupName,
    [Parameter(Position=2,Mandatory=$true,HelpMessage="Name of the Container Image you want to launch, remember to prepend the ACR name in the form [name].azurecr.io/[imagename]:[version]")]
    [String] $ContainerImage,
    [Parameter(HelpMessage="Name for the ACI that will be created, if it exists it will be deleted")]
    [String] $containername='acicontainer',
    [Parameter(HelpMessage="Name of the Resource Group where the ACI will be created, if it doesn't exist it will be created")]
    [String] $rgName='testgroup1234',
    [Parameter(HelpMessage="A JSON string with the environment variables you want to send to the container")]
    [String] $containerParams,
    [Parameter(HelpMessage="The location for the resource group")]
    [String] $location='northeurope',
    [Parameter(HelpMessage="Number of CPU you want for the container")]
    [int] $CPU=1,
    [Parameter(HelpMessage="GB of memory you want for the container")]
    [float] $MemoryInGB=0.5
)

function ConvertTo-Hastable-From-Json ($jsonString){
    $hashtable = @{}
    (ConvertFrom-Json $jsonString).psobject.properties | Foreach-Object { $hashtable[$_.Name] = $_.Value }
    return $hashtable
}

$Env=ConvertTo-Hastable-From-Json($containerParams)

# You can create a dns name just in case you need it
# $dnsName=$containername+[System.Convert]::ToBase64String([System.Text.Encoding]::UNICODE.GetBytes([guid]::NewGuid())).SubString(0,12)

#Get the RunAs credentials
$Conn = Get-AutomationConnection -Name 'AzureRunAsConnection'

Connect-AzureRmAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

New-AzureRmResourceGroup -Name $rgName -Location $location -Force

try{
    $formerLog=Get-AzureRmContainerInstanceLog -ResourceGroupName $rgName -ContainerGroupName $containername
    Write-Output "Previous execution log: " $formerLog
}
catch{
    Write-Error $_.Exception.Message
}

Write-Output "Removing old containers"
try{
    Remove-AzureRmContainerGroup -ResourceGroupName $rgName -Name $containername
}
catch{
    Write-Error $_.Exception.Message
}

Write-Output "Creating new container"
$credentials=Get-AzureRmContainerRegistryCredential -ResourceGroupName $ContainerRegistryGroupName -Name $ContainerRegistryName
$secpasswd = ConvertTo-SecureString $credentials.Password -AsPlainText -Force
$securecred = New-Object System.Management.Automation.PSCredential ($credentials.Username, $secpasswd)
New-AzureRmContainerGroup  -ResourceGroupName $rgName -Name $containername `
    -Image $ContainerImage -OsType Linux  `
    -Cpu $CPU -MemoryInGB $MemoryInGB ` 
    -RegistryCredential $securecred -RestartPolicy Never -EnvironmentVariable $Env # -DnsNameLabel $dnsName

Write-Output "Container created"

do{
    start-sleep -Seconds 5
    $container=Get-AzureRmContainerGroup -ResourceGroupName $rgName -Name $containername
    Write-Output ($container.State)
}while( ($container.State -eq "Pending") -or ($container.State -eq "Running") )

try{
    $formerLog=Get-AzureRmContainerInstanceLog -ResourceGroupName $rgName -ContainerGroupName $containername
    Write-Output "Current execution log: " $formerLog
}
catch{
    Write-Error $_.Exception.Message
}