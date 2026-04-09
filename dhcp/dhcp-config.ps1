# Instalar DHCP
Install-WindowsFeature -Name DHCP -IncludeManagementTools

# Crear rango
Add-DhcpServerv4Scope `
-Name "RangoRed" `
-StartRange 192.168.0.26 `
-EndRange 192.168.0.100 `
-SubnetMask 255.255.255.0

# Excluir IPs reservadas
Add-DhcpServerv4ExclusionRange `
-ScopeId 192.168.0.0 `
-StartRange 192.168.0.1 `
-EndRange 192.168.0.25