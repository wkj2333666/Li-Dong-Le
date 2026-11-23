$ErrorActionPreference = 'Stop'
$sdk = if ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT } elseif ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
$env:ANDROID_SDK_ROOT = $sdk
$env:ANDROID_HOME = $sdk
$env:Path = (Join-Path $sdk 'platform-tools') + ';' + (Join-Path $sdk 'emulator') + ';' + $env:Path
$sdkmanager = Join-Path $sdk 'cmdline-tools\latest\bin\sdkmanager.bat'
$avdmanager = Join-Path $sdk 'cmdline-tools\latest\bin\avdmanager.bat'
if (!(Test-Path $sdkmanager) -or !(Test-Path $avdmanager)) { throw 'Install Android SDK Command-line Tools first.' }
& $sdkmanager 'platform-tools' 'emulator' 'platforms;android-30' 'system-images;android-30;google_apis;x86_64'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$emulator = Join-Path $sdk 'emulator\emulator.exe'
$avds = & $emulator -list-avds
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
if ($avds -contains 'ldl_win_x64') {
    Write-Host 'Using existing Windows AVD ldl_win_x64. Run .\ldl-windows.ps1 start.'
    exit 0
}
"no" | & $avdmanager create avd -n ldl_win_x64 -k 'system-images;android-30;google_apis;x86_64' --device 'pixel_2'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host 'Windows AVD ldl_win_x64 is ready. Run .\ldl-windows.ps1 start.'
