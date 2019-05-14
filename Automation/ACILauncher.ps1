Param
(
    [String] $ContainerRegistryName,
    [String] $ContainerRegistryGroupName,
    [String] $ContainerImage,
    [String] $AWS_SOURCE_BUCKET,
    [String] $AWS_SOURCE_FILE,
    [String] $AWS_SECRET_ID,
    [String] $AWS_SECRET_ACCESS_KEY,
    [String] $AZ_DESTINATION_ACCOUNT,
    [String] $AZ_DESTINATION_SAS,
    [String] $AZ_DESTINATION_CONTAINER,
    [String] $AZ_DESTINATION_FILE
)

$containername='scheduledcopycontainer'
$rgName='testgroup1234'

$Env=@{'AWS_SOURCE_BUCKET'=$AWS_SOURCE_BUCKET;'AWS_SOURCE_FILE'=$AWS_SOURCE_FILE;'AWS_SECRET_ID'=$AWS_SECRET_ID;'AWS_SECRET_ACCESS_KEY'=$AWS_SECRET_ACCESS_KEY;'AZ_DESTINATION_ACCOUNT'=$AZ_DESTINATION_ACCOUNT;'AZ_DESTINATION_SAS'=$AZ_DESTINATION_SAS;'AZ_DESTINATION_CONTAINER'=$AZ_DESTINATION_CONTAINER;'AZ_DESTINATION_FILE'=$AZ_DESTINATION_FILE }

$Conn = Get-AutomationConnection -Name 'AzureRunAsConnection'

Connect-AzureRmAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

New-AzureRmResourceGroup -Name $rgName -Location northeurope -Force

try{
    $formerLog=Get-AzureRmContainerInstanceLog -ResourceGroupName $rgName -ContainerGroupName $containername
    echo "Previous execution log: " $formerLog
}
catch{
    write-host $_.Exception.Message
}

Remove-AzureRmContainerGroup -ResourceGroupName $rgName -Name $containername

$credentials=Get-AzureRmContainerRegistryCredential -ResourceGroupName $ContainerRegistryGroupName -Name $ContainerRegistryName
$secpasswd = ConvertTo-SecureString $credentials.Password -AsPlainText -Force
$securecred = New-Object System.Management.Automation.PSCredential ($credentials.Username, $secpasswd)
New-AzureRmContainerGroup  -ResourceGroupName $rgName -Name $containername `
    -Image $ContainerImage -OsType Linux -DnsNameLabel aci-scheduled-copy10 `
    -RegistryCredential $securecred -RestartPolicy Never -EnvironmentVariable $Env