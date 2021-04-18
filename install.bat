@echo off

:: Link to oh-my-posh theme
mklink /H ~\.oh-my-posh-theme.omp.json .\oh-my-posh\slim_based_theme.omp.json
mklink /H ~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 .\powershell\profile.ps1

Pause&Exit
