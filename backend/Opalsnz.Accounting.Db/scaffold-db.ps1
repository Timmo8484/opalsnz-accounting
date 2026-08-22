#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Scaffolds Entity Framework database models from MySQL database.

.DESCRIPTION
    Db-first workflow matching the opalsnz reference architecture: Flyway (see ../../db) owns the
    schema via versioned SQL migrations, and this script regenerates the EF Core models/DbContext by
    reverse-engineering that schema. Do not hand-edit files under Models/ - they get overwritten.

.PARAMETER Environment
    The environment name to use for connection string lookup (e.g., "Development").
    Default: "Development"

.PARAMETER ConfigFile
    Path to the scaffold configuration file (copy scaffold-config.template.json to this name first).
    Default: "scaffold-config.json"

.EXAMPLE
    .\scaffold-db.ps1
#>

param(
    [Parameter(Position = 0)]
    [string]$Environment = "Development",

    [Parameter()]
    [string]$ConfigFile = "scaffold-config.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path $ConfigFile)) {
    Write-Host "ERROR: Configuration file not found: $ConfigFile" -ForegroundColor Red
    Write-Host "Copy scaffold-config.template.json to $ConfigFile and update with your credentials." -ForegroundColor Yellow
    exit 1
}

$config = Get-Content $ConfigFile -Raw | ConvertFrom-Json

$connectionString = $config.ConnectionStrings.$Environment
if ([string]::IsNullOrWhiteSpace($connectionString)) {
    Write-Host "ERROR: No connection string found for environment: $Environment" -ForegroundColor Red
    exit 1
}

$contextName = $config.ScaffoldOptions.ContextName
$outputDir = $config.ScaffoldOptions.OutputDir
$provider = $config.ScaffoldOptions.Provider

Write-Host "Scaffolding $contextName from database (environment: $Environment)..." -ForegroundColor Cyan

$scaffoldArgs = @(
    "ef", "dbcontext", "scaffold",
    $connectionString,
    $provider,
    "-o", $outputDir,
    "--context-dir", ".",
    "-c", $contextName,
    "--use-database-names",
    "--no-onconfiguring",
    "-f",
    "--no-build"
)

& dotnet $scaffoldArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Scaffold failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit 1
}

Write-Host "Scaffold completed successfully. Review the diff before committing." -ForegroundColor Green
