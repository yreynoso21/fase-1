# =========================
# MAIN CONFIG SCRIPT - SERVIDOR1
# =========================

# Ejecutar como administrador

Write-Host "Iniciando configuracion del servidor..."

# =========================
# AD DS
# =========================
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

Install-ADDSForest `
-DomainName "servidor1.com" `
-DomainNetbiosName "SERVIDOR1" `
-InstallDNS `
-Force

# =========================
# USUARIOS AD
# =========================
New-ADUser -Name "usuario1" `
-SamAccountName "usuario1" `
-UserPrincipalName "usuario1@servidor1.com" `
-AccountPassword (ConvertTo-SecureString "password" -AsPlainText -Force) `
-Enabled $true

New-ADUser -Name "usuario2" `
-SamAccountName "usuario2" `
-UserPrincipalName "usuario2@servidor1.com" `
-AccountPassword (ConvertTo-SecureString "password" -AsPlainText -Force) `
-Enabled $true

# =========================
# GPO
# =========================
New-GPO -Name "PoliticaGlobal"
New-GPLink -Name "PoliticaGlobal" -Target "DC=servidor1,DC=com"

Set-GPRegistryValue -Name "PoliticaGlobal" `
-Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
-ValueName "NoControlPanel" `
-Type DWord `
-Value 1

# =========================
# DHCP
# =========================
Install-WindowsFeature DHCP -IncludeManagementTools

Add-DhcpServerv4Scope `
-Name "Scope1" `
-StartRange 192.168.0.26 `
-EndRange 192.168.0.100 `
-SubnetMask 255.255.255.0

# =========================
# DNS MX
# =========================
Add-DnsServerResourceRecordMX `
-ZoneName "servidor1.com" `
-MailExchange "mail.servidor1.com" `
-Priority 10

Add-DnsServerResourceRecordA `
-Name "mail" `
-ZoneName "servidor1.com" `
-IPv4Address "192.168.0.20"

# =========================
# SMTP
# =========================
Install-WindowsFeature SMTP-Server -IncludeManagementTools
Set-Service SMTPSVC -StartupType Automatic
Start-Service SMTPSVC

# =========================
# FIREWALL
# =========================
New-NetFirewallRule -DisplayName "SMTP" -Direction Inbound -Protocol TCP -LocalPort 25 -Action Allow
New-NetFirewallRule -DisplayName "POP3" -Direction Inbound -Protocol TCP -LocalPort 110 -Action Allow

Write-Host "Configuracion completada."
