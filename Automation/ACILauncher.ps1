Param
(
    [String] $ContainerRegistryName,
    [String] $ContainerRegistryGroupName,
    [String] $AWS_SOURCE_BUCKET,
    [String] $AWS_SOURCE_FILE,
    [String] $AWS_SECRET_ID,
    [String] $AWS_SECRET_ACCESS_KEY,
    [String] $AZ_DESTINATION_ACCOUNT,
    [String] $AZ_DESTINATION_SAS,
    [String] $AZ_DESTINATION_CONTAINER,
    [String] $AZ_DESTINATION_FILE
)

$Conn = Get-AutomationConnection -Name 'AzureRunAsConnection'

$Env=@{'AWS_SOURCE_BUCKET'=$AWS_SOURCE_BUCKET;'AWS_SOURCE_FILE'=$AWS_SOURCE_FILE;'AWS_SECRET_ID'=$AWS_SECRET_ID;'AWS_SECRET_ACCESS_KEY'=$AWS_SECRET_ACCESS_KEY;'AZ_DESTINATION_ACCOUNT'=$AZ_DESTINATION_ACCOUNT;'AZ_DESTINATION_SAS'=$AZ_DESTINATION_SAS;'AZ_DESTINATION_CONTAINER'=$AZ_DESTINATION_CONTAINER;'AZ_DESTINATION_FILE'=$AZ_DESTINATION_FILE }

Connect-AzureRmAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

New-AzureRmResourceGroup -Name testgroup1234 -Location northeurope -Force

Remove-AzureRmContainerGroup -ResourceGroupName testgroup1234 -Name mycontainer

$credentials=Get-AzureRmContainerRegistryCredential -ResourceGroupName $ContainerRegistryGroupName -Name $ContainerRegistryName
$secpasswd = ConvertTo-SecureString $credentials.Password -AsPlainText -Force
$securecred = New-Object System.Management.Automation.PSCredential ($credentials.Username, $secpasswd)
New-AzureRmContainerGroup  -ResourceGroupName testgroup1234 -Name mycontainer -Image juanserv.azurecr.io/s3toaz -OsType Linux -DnsNameLabel aci-demo-win2156 -RegistryCredential $securecred -RestartPolicy Never -EnvironmentVariable $Env