<#
.SYNOPSIS
    DevOps Assessment Script - Generates 10 files with timestamp and prints their content.
.DESCRIPTION
    Requisito 5b: Script que cree 10 archivos con la fecha y luego lo imprima en consola.
#>

[CmdletBinding()]
param (
    [string]$OutputDir = "./output-files"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Iniciando generación de 10 archivos con fecha y hora actual" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Crear directorio temporal si no existe
if (-not (Test-Path -Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$CurrentTimestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# 1. Crear 10 archivos
1..10 | ForEach-Object {
    $index = $_
    $FileName = "archivo_${index}_${CurrentTimestamp}.txt"
    $FilePath = Join-Path -Path $OutputDir -ChildPath $FileName
    $Content = "Archivo #$index generado exitosamente el $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss.fff')"

    Set-Content -Path $FilePath -Value $Content
    Write-Host "[CREADO] $FileName" -ForegroundColor Green
}

Write-Host "`n==========================================================" -ForegroundColor Yellow
Write-Host "Imprimiendo contenido de los 10 archivos en consola:" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Yellow

# 2. Imprimir contenido de cada archivo en consola
Get-ChildItem -Path $OutputDir -Filter "archivo_*_${CurrentTimestamp}.txt" | ForEach-Object {
    Write-Host "`n--- Contenido de $($_.Name) ---" -ForegroundColor Magenta
    Get-Content -Path $_.FullName
}

Write-Host "`n[COMPLETADO] Proceso finalizado con éxito." -ForegroundColor Green
