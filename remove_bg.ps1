Add-Type -AssemblyName System.Drawing
$imgPath = "c:\Users\mdbay\FlutterProjerct\which_win\assets\images\logo.png"
$img = [System.Drawing.Bitmap]::FromFile($imgPath)
$bmp = New-Object System.Drawing.Bitmap -ArgumentList $img.Width, $img.Height
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.DrawImage($img, 0, 0)
$img.Dispose()
$g.Dispose()

for ($x = 0; $x -lt $bmp.Width; $x++) {
    for ($y = 0; $y -lt $bmp.Height; $y++) {
        $color = $bmp.GetPixel($x, $y)
        # Check if the pixel is near black
        if ($color.R -lt 25 -and $color.G -lt 25 -and $color.B -lt 25) {
            $bmp.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
        }
    }
}
$bmp.Save("c:\Users\mdbay\FlutterProjerct\which_win\assets\images\logo.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host "Background removed successfully!"
