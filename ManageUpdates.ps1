# # # # # # # # # # # # # # # # # 
# # CORE FUNCTION DEFINITIONS # # 
# # # # # # # # # # # # # # # # # 

Function doIntro($something) {
	foreach ($ThisLine in $Intro) {
		Write-Host "$ThisLine" -ForegroundColor yellow -BackgroundColor darkblue
	}
}

Function Wait ($secs) {
	if (!($secs)) {$secs = 1}
	Start-Sleep $secs
}

Function SetConsoleSize {
	$ThisHost = Get-Host
	$CurWin = $ThisHost.UI.RawUI
	$CurSize = $CurWin.BufferSize 
	$CurSize.Width = 130
	$CurSize.Height = 40
	$CurWin.BufferSize = $CurSize 
	$CurSize = $CurWin.WindowSize 
	$CurSize.Width = 130  
	$CurSize.Height = 40
	$CurWin.WindowSize = $CurSize
}

Function Say($something) {
	#Say something, anything!
	Write-Host $something 
}

Function SayB($something) {
	#Say something, anything!
	Write-Host $something -ForegroundColor darkblue -BackgroundColor white
}

Function isOSTypeHome {
	$ret = (Get-WmiObject -class Win32_OperatingSystem).Caption | select-string "Home"
	Return $ret
}

Function isOSTypePro {
	$ret = (Get-WmiObject -class Win32_OperatingSystem).Caption | select-string "Pro"
	Return $ret
}

Function isOSTypeEnt {
	$ret = (Get-WmiObject -class Win32_OperatingSystem).Caption | select-string "Ent"
	Return $ret
}

Function getWinVer {
	$ret = (Get-WMIObject win32_operatingsystem).version
	Return $ret
}

Function isAppInstalled ($AppName) {
	If ((Get-AppxPackage | where {$_.Name -like "*$AppName*"}).length -gt 0) {
		Return True
	} Else {
		Return False
	}
}

Function isAppInManifest ($AppName) {
	If ((Get-AppxProvisionedPackage -online | where {$_.DisplayName -like "*$AppName*"}).length -gt 0) {
		Return True
	} Else {
		Return False
	}
}

Function isProcess ($procName) {
	(Get-Process $procName -ErrorAction SilentlyContinue).Name
}

Function isAdminLocal {
	$ret = (new-object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole("Administrators")
	Return $ret
}

Function isAdminDomain {
	$ret = (new-object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole("Domain Admins")
	Return $ret
}

Function isElevated {
	$ret = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')
	Return $ret
}

Function regSet ($KeyPath, $KeyItem, $KeyValue) {
	$Key = $KeyPath.Split("\")
	ForEach ($level in $Key) {
		If (!($ThisKey)) {
			$ThisKey = "$level"
		} Else {
			$ThisKey = "$ThisKey\$level"
		}
		If (!(Test-Path $ThisKey)) {New-Item $ThisKey -Force -ErrorAction SilentlyContinue | out-null}
	}
	Set-ItemProperty $KeyPath $KeyItem -Value $KeyValue -ErrorAction SilentlyContinue 
}

Function regGet($Key, $Item) {
	If (!(Test-Path $Key)) {
		Return
	} Else {
		If (!($Item)) {$Item = "(Default)"}
		$ret = (Get-ItemProperty -Path $Key -Name $Item -ErrorAction SilentlyContinue).$Item
		Return $ret
	}
}

Function regDelKey($KeyPath) {
	Remove-Item $KeyPath -Force -ErrorAction SilentlyContinue | Out-Null
}

Function regDelKeyR($KeyPath) {
	Remove-Item $KeyPath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}

Function regDelItem($KeyPath, $KeyItem) {
	Remove-ItemProperty -Path $KeyPath -Name $KeyItem -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}

Function Enable-Updates() {
	regDelKeyR "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" 
	regDelKey "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
	regSet "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" 0
}

Function Disable-Updates {
	regSet "HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" "AutoDownload" 5 
	regSet "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode" 100 
	regSet "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" "DoNotConnectToWindowsUpdateInternetLocations" 1 
	regSet "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" "DisableWindowsUpdateAccess" 1 
	regSet "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" "WUServer" " " 
	regSet "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" "WUStatusServer" " " 
	regSet "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" "UpdateServiceUrlAlternate" " " 
	regSet "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "UseWUServer" 1 
	regSet "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" 1
}

Function Get-Selection() {
	SayB "Windows 10 Update Fix Menu"
	SayB "=========================="
	Say ""
	Say "0 - Quit"
	Say "1 - Allow Updates"
	Say "2 - Prevent Updates"
	Say "Enter Selection: "
	#Return Read-Host
	$ki = Get-KeyInput
	Return $ki
	#Return $Host.UI.RawUI.ReadKey()
}

Function Get-KeyInput() {
	$key = ([string]($Host.UI.RawUI.ReadKey()).character).ToLower()
	Say ""
	Return $key
}

	If (!(isAdminLocal)) {
		Say "Attempting to elevate priviledges..."
		Wait
		Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`" elevate" -f $PSCommandPath) -Verb RunAs
		Exit
	} else {
		Say "Script has been executed with Elevated permissions.  Continuing..."
	}

	Say "Check if Admin execution has been performed..."
	If (isAdminLocal -Or isAdminDomain) {
		Say "  Account is a SysAdmin.  Checking for previous administrative execution..."
		If (!(isElevated)) {
			Say "      Script was not launched with Elevated permissions, attempting now."
			Wait 2
			Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`" elevate" -f $PSCommandPath) -Verb RunAs
		} Else {
			Say "      Script executed with elevated rights - continuing."

			$CanDo = "x"
			cls
			While ($CanDo -ne "z") {
				$CanDo = Get-Selection
				switch ($CanDo) {
					0 {
						Say "Exiting..."
						$CanDo = "z"
						}
					1 {
						Say "Enabling Updates..."
						Enable-Updates
						Say "Done."
						Say "Your system has been modified and requires a restart."
						$CanDo = "z"
						$rs = 1
						}
					2 {
						Say "Disabling Updates..."
						Disable-Updates
						Say "Your system has been modified and requires a restart."
						$CanDo = "z"
						$rs = 1
						}
				}
			}			
			if ($rs -eq 1) {
				Say "Do you want to restart the computer now?  (Y/N)"
				$inp = Get-KeyInput
				if ($inp -eq "y") {Restart-Computer -Force}
			}
		}
	}

