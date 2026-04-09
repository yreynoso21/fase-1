# Crear carpetas
New-Item -Path "C:\CarpetaPrivada" -ItemType Directory
New-Item -Path "C:\CarpetaPublica" -ItemType Directory

# Compartir carpeta privada
New-SmbShare -Name "CarpetaPrivada" -Path "C:\CarpetaPrivada" -FullAccess "Everyone"

# Compartir carpeta pública
New-SmbShare -Name "CarpetaPublica" -Path "C:\CarpetaPublica" -FullAccess "Everyone"