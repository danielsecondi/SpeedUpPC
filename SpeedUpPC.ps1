Add-Type -AssemblyName PresentationFramework

function Show-Message($text, $title = "SpeedUpPC") {
    [System.Windows.MessageBox]::Show($text, $title, 'OK', 'Information') | Out-Null
}

function Avvia-Pulizia {
    $output.Text = "Inizio pulizia e ottimizzazione..." + "`n"

    Start-Sleep -Seconds 1
    $output.AppendText("1. Controllo componenti di sistema...`n")
    dism /online /Cleanup-Image /RestoreHealth | Out-Null
    sfc /scannow | Out-Null

    $output.AppendText("2. Pulizia file temporanei...`n")
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:SystemDrive\$Recycle.Bin" -Recurse -Force -ErrorAction SilentlyContinue

    $output.AppendText("3. Pulizia disco...`n")
    Start-Process -FilePath cleanmgr.exe -ArgumentList '/verylowdisk' -Wait

    $output.AppendText("4. Reset rete e DNS...`n")
    ipconfig /flushdns | Out-Null
    netsh int ip reset | Out-Null
    netsh winsock reset | Out-Null

    $output.AppendText("5. Ottimizzazione disco...`n")
    $media = (Get-PhysicalDisk)[0].MediaType
    if ($media -eq "HDD") {
        defrag C: /O | Out-Null
    } else {
        Optimize-Volume -DriveLetter C -ReTrim | Out-Null
    }

    $output.AppendText("6. Verifica TRIM...`n")
    $trim = fsutil behavior query DisableDeleteNotify
    if ($trim -match "0") {
        $output.AppendText("   ➤ TRIM già attivo.`n")
    } else {
        fsutil behavior set DisableDeleteNotify 0 | Out-Null
        $output.AppendText("   ➤ TRIM attivato!`n")
    }

    $output.AppendText("7. Timeout di avvio ridotto a 3 secondi...`n")
    bcdedit /timeout 3 | Out-Null

    $output.AppendText("8. Verifica disco con chkdsk...`n")
    chkdsk /scan | Out-Null

    $output.AppendText("Pulizia completata. Riavvia il PC per applicare tutte le modifiche.`n")
    Show-Message "Pulizia completata. Riavvia il PC per applicare tutte le modifiche." "SpeedUpPC"
}

# GUI
[xml]$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="SpeedUpPC" Height="420" Width="500" WindowStartupLocation="CenterScreen" ResizeMode="NoResize">
    <Grid Margin="10">
        <Button x:Name="btnStart" Content="Avvia Pulizia e Ottimizzazione" HorizontalAlignment="Center" VerticalAlignment="Top" Margin="0,10,0,0" Height="40" Width="300"/>
        <TextBox x:Name="output" Margin="0,60,0,0" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto" IsReadOnly="True" TextWrapping="Wrap" AcceptsReturn="True"/>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $XAML)
$window = [Windows.Markup.XamlReader]::Load($reader)

$btnStart = $window.FindName("btnStart")
$output = $window.FindName("output")

$btnStart.Add_Click({
    $btnStart.IsEnabled = $false
    Start-Job -ScriptBlock {
        Start-Sleep -Milliseconds 500
        powershell -ExecutionPolicy Bypass -Command "& { `"$($MyInvocation.MyCommand.Definition)`" -gui }"
    }
    Avvia-Pulizia
    $btnStart.IsEnabled = $true
})

$window.ShowDialog() | Out-Null
