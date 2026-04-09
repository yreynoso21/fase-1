# Instalar servicio DNS
Install-WindowsFeature -Name DNS -IncludeManagementTools

# Crear zona directa
Add-DnsServerPrimaryZone -Name "servidor1.com" -ZoneFile "servidor1.com.dns"

# Crear registros A
Add-DnsServerResourceRecordA -Name "www" -ZoneName "servidor1.com" -IPv4Address "192.168.0.10"
Add-DnsServerResourceRecordA -Name "cliente" -ZoneName "servidor1.com" -IPv4Address "192.168.0.20"