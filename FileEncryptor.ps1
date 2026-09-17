Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "File Encoder/Decoder"
$form.Size = New-Object System.Drawing.Size(500, 550)
$form.StartPosition = "CenterScreen"

$label = New-Object System.Windows.Forms.Label
$label.Text = "Select Mode:"
$label.Location = New-Object System.Drawing.Point(20, 20)
$label.AutoSize = $true
$form.Controls.Add($label)

$modeBox = New-Object System.Windows.Forms.ComboBox
$modeBox.Location = New-Object System.Drawing.Point(20, 50)
$modeBox.Size = New-Object System.Drawing.Size(200, 25)
$modeBox.Items.Add("Encode File to Base64")
$modeBox.Items.Add("Decode Base64 to File")
$modeBox.SelectedIndex = 0
$form.Controls.Add($modeBox)

$fileLabel = New-Object System.Windows.Forms.Label
$fileLabel.Text = "Select File:"
$fileLabel.Location = New-Object System.Drawing.Point(20, 90)
$fileLabel.AutoSize = $true
$form.Controls.Add($fileLabel)

$fileBrowser = New-Object System.Windows.Forms.TextBox
$fileBrowser.Location = New-Object System.Drawing.Point(20, 120)
$fileBrowser.Size = New-Object System.Drawing.Size(300, 25)
$fileBrowser.ReadOnly = $true
$form.Controls.Add($fileBrowser)

$browseBtn = New-Object System.Windows.Forms.Button
$browseBtn.Text = "Browse..."
$browseBtn.Location = New-Object System.Drawing.Point(330, 118)
$browseBtn.Size = New-Object System.Drawing.Size(80, 29)
$browseBtn.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Filter = "All Files (*.*)|*.*"
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $fileBrowser.Text = $dlg.FileName
    }
})
$form.Controls.Add($browseBtn)

$outputLabel = New-Object System.Windows.Forms.Label
$outputLabel.Text = "Output File:"
$outputLabel.Location = New-Object System.Drawing.Point(20, 160)
$outputLabel.AutoSize = $true
$form.Controls.Add($outputLabel)

$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(20, 190)
$outputBox.Size = New-Object System.Drawing.Size(300, 25)
$form.Controls.Add($outputBox)

$outputBrowseBtn = New-Object System.Windows.Forms.Button
$outputBrowseBtn.Text = "Browse..."
$outputBrowseBtn.Location = New-Object System.Drawing.Point(330, 188)
$outputBrowseBtn.Size = New-Object System.Drawing.Size(80, 29)
$outputBrowseBtn.Add_Click({
    $dlg = New-Object System.Windows.Forms.SaveFileDialog
    $dlg.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
    $dlg.FileName = [System.IO.Path]::GetFileNameWithoutExtension($fileBrowser.Text) + ".out.txt"
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $outputBox.Text = $dlg.FileName
    }
})
$form.Controls.Add($outputBrowseBtn)

$hashLabel = New-Object System.Windows.Forms.Label
$hashLabel.Text = "Output / MD5 Hash:"
$hashLabel.Location = New-Object System.Drawing.Point(20, 230)
$hashLabel.AutoSize = $true
$form.Controls.Add($hashLabel)

$resultBox = New-Object System.Windows.Forms.TextBox
$resultBox.Location = New-Object System.Drawing.Point(20, 255)
$resultBox.Size = New-Object System.Drawing.Size(400, 60)
$resultBox.Multiline = $true
$resultBox.ScrollBars = "Vertical"
$resultBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$resultBox.ReadOnly = $true
$form.Controls.Add($resultBox)

$decodeLabel = New-Object System.Windows.Forms.Label
$decodeLabel.Text = "DECODE COMMAND (run on target system):"
$decodeLabel.Location = New-Object System.Drawing.Point(20, 325)
$decodeLabel.AutoSize = $true
$decodeLabel.Font = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($decodeLabel)

$decodeBox = New-Object System.Windows.Forms.TextBox
$decodeBox.Location = New-Object System.Drawing.Point(20, 350)
$decodeBox.Size = New-Object System.Drawing.Size(400, 50)
$decodeBox.Multiline = $true
$decodeBox.ReadOnly = $true
$decodeBox.Font = New-Object System.Drawing.Font("Consolas", 8)
$decodeBox.Text = ""
$form.Controls.Add($decodeBox)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(20, 420)
$statusLabel.Size = New-Object System.Drawing.Size(400, 30)
$statusLabel.ForeColor = [System.Drawing.Color]::Green
$statusLabel.Text = ""
$form.Controls.Add($statusLabel)

$processBtn = New-Object System.Windows.Forms.Button
$processBtn.Text = "Process"
$processBtn.Location = New-Object System.Drawing.Point(20, 460)
$processBtn.Size = New-Object System.Drawing.Size(100, 30)
$processBtn.Add_Click({
    $modeBox.Enabled = $false
    $browseBtn.Enabled = $false
    $processBtn.Enabled = $false
    $statusLabel.Text = ""
    $resultBox.Text = ""
    $decodeBox.Text = ""
    
    try {
        $mode = $modeBox.SelectedItem.ToString()
        $inputFile = $fileBrowser.Text
        
        if ([string]::IsNullOrEmpty($inputFile) -or -not (Test-Path $inputFile)) {
            throw "Please select a valid input file"
        }
        
        $outputFile = $outputBox.Text
        if ([string]::IsNullOrEmpty($outputFile)) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($inputFile)
            $outputFile = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($inputFile), "$baseName.out.txt")
            $outputBox.Text = $outputFile
        }
        
        if ($mode -eq "Encode File to Base64") {
            $bytes = [System.IO.File]::ReadAllBytes($inputFile)
            $base64 = [Convert]::ToBase64String($bytes)
            $base64 | Export-Clixml -Path $outputFile
            $inputHash = Get-FileHash -Path $inputFile -Algorithm MD5
            $outputHash = Get-FileHash -Path $outputFile -Algorithm MD5
            $resultBox.Text = "Input MD5:  $($inputHash.Hash)`n`nOutput MD5: $($outputHash.Hash)"
            $statusLabel.Text = "Encoded successfully to $outputFile"
            $statusLabel.ForeColor = [System.Drawing.Color]::Green
            $outFileName = [System.IO.Path]::GetFileName($outputFile)
            $inFileName = [System.IO.Path]::GetFileName($inputFile)
            $decodeBox.Text = "[Convert]::FromBase64String((Import-Clixml '$outFileName'))|Set-Content '$inFileName.decoded' -encoding byte"
        }
        else {
            $base64 = Import-Clixml -Path $inputFile
            $bytes = [Convert]::FromBase64String($base64)
            [System.IO.File]::WriteAllBytes($outputFile, $bytes)
            
            $inputHash = Get-FileHash -Path $inputFile -Algorithm MD5
            $outputHash = Get-FileHash -Path $outputFile -Algorithm MD5
            
            $resultBox.Text = "Input MD5:  $($inputHash.Hash)`n`nOutput MD5: $($outputHash.Hash)"
            $statusLabel.Text = "Decoded successfully to $outputFile"
            $statusLabel.ForeColor = [System.Drawing.Color]::Green
        }
    }
    catch {
        $statusLabel.Text = "Error: $_"
        $statusLabel.ForeColor = [System.Drawing.Color]::Red
    }
    finally {
        $modeBox.Enabled = $true
        $browseBtn.Enabled = $true
        $processBtn.Enabled = $true
    }
})
$form.Controls.Add($processBtn)

$cancelBtn = New-Object System.Windows.Forms.Button
$cancelBtn.Text = "Close"
$cancelBtn.Location = New-Object System.Drawing.Point(370, 460)
$cancelBtn.Size = New-Object System.Drawing.Size(100, 30)
$cancelBtn.Add_Click({ $form.Close() })
$form.Controls.Add($cancelBtn)

$form.ShowDialog()
