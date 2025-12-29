#$nr:	küsimuse number
#$param: mis parameetriga tegemist (võimalikult lühidalt)
#$sisu:	väljastatav sisu
function valjasta{
	param ($nr, $param, $sisu)
	$fail = ".\aleksei_voltsihhin.out.txt"   # <-- väljundfail (muuda vajadusel)
	$aeg = Get-Date -Format "HH:mm:ss.fff"

	if($sisu -eq $null){
		$rida = "$nr.	$aeg	${param}:	NULL"
		Write-Output $rida
		$rida | Out-File -FilePath $fail -Append -Encoding UTF8

	}elseif($sisu.GetType().Name -eq "Object[]"){
		$rida = "$nr.	$aeg	${param}:"
		Write-Output $rida $sisu
		$rida | Out-File -FilePath $fail -Append -Encoding UTF8
		$sisu | Out-File -FilePath $fail -Append -Encoding UTF8

	}else{
		$rida = "$nr.	$aeg	${param}:	$sisu"
		Write-Output $rida
		$rida | Out-File -FilePath $fail -Append -Encoding UTF8
	}
}

#Aja mõõtmine
$start = Get-Date

Valjasta 0 "ALGUS" ("Aeg: "+(Get-Date -Format "dddd MM/dd/yyyy HH:mm K")+" Teostaja: Aleksei Voltšihhin")
Valjasta 1 "host" (hostname)

# 1) Hostname, PowerShell version, Windows version
$psver = $PSVersionTable.PSVersion.ToString()
$os = Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber
Valjasta 1 "PS version" $psver
Valjasta 1 "Windows" ("{0}; Version {1}; Build {2}" -f $os.Caption, $os.Version, $os.BuildNumber)

# 2) Network config (IP, mask, gateway, DHCP, MAC)
$net = Get-NetIPConfiguration |
	Where-Object { $_.IPv4Address -and $_.NetAdapter.Status -eq "Up" } |
	ForEach-Object {
		$alias = $_.InterfaceAlias
		$ip = $_.IPv4Address.IPAddress
		$prefix = $_.IPv4Address.PrefixLength
		$gw = if ($_.IPv4DefaultGateway) { $_.IPv4DefaultGateway.NextHop } else { "-" }
		$mac = $_.NetAdapter.MacAddress

		$dhcp = "-"
		try { $dhcp = (Get-NetIPInterface -InterfaceAlias $alias -AddressFamily IPv4).Dhcp } catch { $dhcp = "-" }

		# PrefixLength -> subnet mask (korrektne)
		$bits = [int]$prefix
		$maskBytes = @(0,0,0,0)
		for ($i=0; $i -lt 4; $i++) {
			$take = [Math]::Min(8, $bits)
			$maskBytes[$i] = if ($take -le 0) { 0 } else { (0xFF -shl (8 - $take)) -band 0xFF }
			$bits -= $take
		}
		$mask = ($maskBytes -join ".")

		[PSCustomObject]@{
			Adapter = $alias
			IP      = $ip
			Mask    = "$mask (/$prefix)"
			Gateway = $gw
			DHCP    = $dhcp
			MAC     = $mac
		}
	}

Valjasta 2 "Network" ($net | Format-Table -AutoSize | Out-String -Width 500)

# 3) CPU + RAM (Win32_ComputerSystem)
$cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name
$cs  = Get-CimInstance Win32_ComputerSystem | Select-Object TotalPhysicalMemory
$ramGB = "{0:N2} GB" -f ($cs.TotalPhysicalMemory / 1GB)
Valjasta 3 "CPU" $cpu
Valjasta 3 "RAM" $ramGB

# 4) GPU info (VideoController)
$gpu = Get-CimInstance Win32_VideoController |
	Select-Object Name, DriverVersion, DriverDate, CurrentHorizontalResolution, CurrentVerticalResolution
Valjasta 4 "VideoController" ($gpu | Format-Table -AutoSize | Out-String -Width 500)

# 5) Disks + partitions + free C:
$diskSizes = Get-CimInstance Win32_DiskDrive |
	Select-Object Model, @{n="SizeGB";e={"{0:N2}" -f ($_.Size/1GB)}}

$parts = Get-CimInstance Win32_DiskPartition |
	Select-Object DiskIndex, Index, @{n="SizeGB";e={"{0:N2}" -f ($_.Size/1GB)}}

$c = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" |
	Select-Object DeviceID, @{n="SizeGB";e={"{0:N2}" -f ($_.Size/1GB)}}, @{n="FreeGB";e={"{0:N2}" -f ($_.FreeSpace/1GB)}}

Valjasta 5 "Disk sizes" ($diskSizes | Format-Table -AutoSize | Out-String -Width 500)
Valjasta 5 "Partitions" ($parts | Format-Table -AutoSize | Out-String -Width 500)
Valjasta 5 "C: free" ($c | Format-Table -AutoSize | Out-String -Width 500)

# 6) PCI drivers info (Description, Manufacturer, Version)
$pci = Get-CimInstance Win32_PnPSignedDriver |
	Where-Object { $_.DeviceID -like "PCI\*" } |
	Select-Object DeviceName, Manufacturer, DriverVersion |
	Sort-Object DeviceName

# Jätan esimesed 80
Valjasta 6 "PCI drivers" ($pci | Select-Object -First 80 | Format-Table -AutoSize | Out-String -Width 500)

# 7) Users (Name, Description, LocalAccount, Disabled)
$users = Get-CimInstance Win32_UserAccount -Filter "LocalAccount=True" |
	Select-Object Name, Description, LocalAccount, Disabled |
	Sort-Object Name

Valjasta 7 "Users" ($users | Format-Table -AutoSize | Out-String -Width 500)

# 8) Running process count
$procCount = (Get-Process).Count
Valjasta 8 "Process count" $procCount

# 9) 10 last started processes (Name, PID, StartTime) sorted by StartTime DESC
$last10 = Get-Process | ForEach-Object {
	$st = $null
	try { $st = $_.StartTime } catch { $st = $null }
	[PSCustomObject]@{ Name=$_.ProcessName; PID=$_.Id; StartTime=$st }
} | Where-Object { $_.StartTime -ne $null } |
Sort-Object StartTime -Descending |
Select-Object -First 10

if (($last10 | Measure-Object).Count -eq 0) {
	Valjasta 9 "Last 10 processes" "StartTime ei olnud kättesaadav. Proovi käivitada PowerShell Admin õigustes."
} else {
	Valjasta 9 "Last 10 processes" ($last10 | Format-Table -AutoSize | Out-String -Width 500)
}

# 10) Date and time in format dd.MM.yyyy HH:mm:ss
$dt = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
Valjasta 10 "DateTime" $dt

# --- Lõpp / ajakulu ---
$end = Get-Date
$ajakulu = [math]::Round(($end - $start).TotalMilliseconds, 0)
Valjasta "*" "TEHTUD" "$ajakulu ms`n`n"
