@echo off

:: Link to settings etc.
mklink /J %AppData%\Code\User\snippets .\vscode\snippets
mklink /H %AppData%\Code\User\settings.json .\vscode\settings.json
mklink /H %AppData%\Code\User\keybindings.json .\vscode\keybindings.json

:: Install plugins
for /F "tokens=*" %%A in (.\vscode\extensions.txt) do code --install-extension %%A

Pause&Exit
