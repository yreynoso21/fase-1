# ============================================================
#  RECURSOS COMPARTIDOS - servidor1.com
#  Practicas Iniciales - USAC Ingenieria
#  Punto 3: File System Server
# ============================================================

# ── 1. Crear usuario "privado" para CarpetaPrivada ───────────
New-LocalUser `
    -Name "privado" `
    -Password (ConvertTo-SecureString "privado" -AsPlainText -Force) `
    -FullName "Usuario Privado" `
    -PasswordNeverExpires $true

Write-Host "Usuario 'privado' creado." -ForegroundColor Green

# ── 2. Crear las carpetas fisicas ────────────────────────────
New-Item -Path "C:\CarpetaPrivada" -ItemType Directory -Force
New-Item -Path "C:\CarpetaPublica" -ItemType Directory -Force

Write-Host "Carpetas creadas en C:\" -ForegroundColor Green

# ── 3. CARPETA PRIVADA ───────────────────────────────────────
# Solo el usuario "privado" puede leer, modificar y eliminar.
# Nadie mas tiene acceso.

# Quitar herencia de permisos y limpiar ACL existente
$ACLPrivada = Get-Acl "C:\CarpetaPrivada"
$ACLPrivada.SetAccessRuleProtection($true, $false)

# Dar control total SOLO al usuario privado
$ReglaPrivado = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "privado",
    "FullControl",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)

# Dar control total al Administrador (para gestionar el servidor)
$ReglaAdmin = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "Administrators",
    "FullControl",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)

$ACLPrivada.AddAccessRule($ReglaPrivado)
$ACLPrivada.AddAccessRule($ReglaAdmin)
Set-Acl -Path "C:\CarpetaPrivada" -AclObject $ACLPrivada

# Compartir en red con acceso SOLO al usuario privado
New-SmbShare `
    -Name "CarpetaPrivada" `
    -Path "C:\CarpetaPrivada" `
    -NoAccess "Everyone" `
    -FullAccess "privado" `
    -Description "Carpeta privada - acceso restringido"

Write-Host "CarpetaPrivada compartida (solo usuario 'privado')." -ForegroundColor Green

# ── 4. CARPETA PUBLICA ───────────────────────────────────────
# Todos los usuarios pueden leer, copiar, modificar y eliminar.

$ACLPublica = Get-Acl "C:\CarpetaPublica"
$ACLPublica.SetAccessRuleProtection($true, $false)

$ReglaEveryone = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "Everyone",
    "FullControl",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)

$ACLPublica.AddAccessRule($ReglaEveryone)
Set-Acl -Path "C:\CarpetaPublica" -AclObject $ACLPublica

# Compartir en red con acceso total a todos
New-SmbShare `
    -Name "CarpetaPublica" `
    -Path "C:\CarpetaPublica" `
    -FullAccess "Everyone" `
    -Description "Carpeta publica - acceso para todos"

Write-Host "CarpetaPublica compartida (acceso para todos)." -ForegroundColor Green

Write-Host "=== Recursos Compartidos configurados correctamente ===" -ForegroundColor Cyan
