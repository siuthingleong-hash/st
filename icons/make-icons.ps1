<#
  Draws the home-screen app icon (a gold Christmas bauble on the red-gold ground of the home page) and saves it in every size
  phones need. Re-run after changing the design:  powershell -ExecutionPolicy Bypass -File make-icons.ps1
  The bauble stays inside the central safe zone, so Android can crop the icon to a circle or squircle ("maskable").
#>
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'
$out = $PSScriptRoot
$S = 1024
function C([string]$hex, [int]$a = 255) { $c = [Drawing.ColorTranslator]::FromHtml($hex); [Drawing.Color]::FromArgb($a, $c.R, $c.G, $c.B) }

$bmp = New-Object Drawing.Bitmap $S, $S
$g = [Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'; $g.InterpolationMode = 'HighQualityBicubic'; $g.PixelOffsetMode = 'HighQuality'

# background: wine-red gradient with a warm glow behind the bauble
$bg = New-Object Drawing.Drawing2D.LinearGradientBrush ([Drawing.Point]::new(0, 0)), ([Drawing.Point]::new(0, $S)), (C '#b8323f'), (C '#3d0a14')
$g.FillRectangle($bg, 0, 0, $S, $S)
$glowPath = New-Object Drawing.Drawing2D.GraphicsPath
$glowPath.AddEllipse(112, 160, 800, 800)
$glow = New-Object Drawing.Drawing2D.PathGradientBrush $glowPath
$glow.CenterColor = C '#e9c46a' 90; $glow.SurroundColors = @((C '#e9c46a' 0))
$g.FillPath($glow, $glowPath)

# snow
$rnd = New-Object Random 7
$snow = New-Object Drawing.SolidBrush (C '#fff6e8' 170)
for ($i = 0; $i -lt 40; $i++) { $r = 3 + $rnd.Next(7); $g.FillEllipse($snow, $rnd.Next($S), $rnd.Next($S), $r, $r) }

# hanging string and ring
$gold = C '#e9c46a'
$pen = New-Object Drawing.Pen $gold, 10
$g.DrawLine($pen, 512, 120, 512, 214)
$g.DrawEllipse($pen, 486, 200, 52, 52)

# bauble body
$cx = 512; $cy = 575; $R = 270
$ball = New-Object Drawing.Drawing2D.GraphicsPath
$ball.AddEllipse($cx - $R, $cy - $R, 2 * $R, 2 * $R)
$body = New-Object Drawing.Drawing2D.LinearGradientBrush ([Drawing.Point]::new($cx - $R, $cy - $R)), ([Drawing.Point]::new($cx + $R, $cy + $R)), (C '#f7dc92'), (C '#a8792e')
$g.FillPath($body, $ball)

# cream bands, clipped to the ball
$g.SetClip($ball)
$band = New-Object Drawing.Pen (C '#fbf3e4' 235), 30
$g.DrawBezier($band, 220, 520, 400, 440, 624, 440, 804, 520)
$g.DrawBezier($band, 220, 650, 400, 730, 624, 730, 804, 650)
$dot = New-Object Drawing.SolidBrush (C '#b8323f')
foreach ($x in 370, 512, 654) { $g.FillEllipse($dot, $x - 26, 562, 52, 52) }
$hl = New-Object Drawing.SolidBrush (C '#ffffff' 110)
$g.TranslateTransform(410, 410); $g.RotateTransform(-35); $g.FillEllipse($hl, -70, -36, 140, 72); $g.ResetTransform()
$g.ResetClip()
$rim = New-Object Drawing.Pen (C '#7e5a21' 160), 6
$g.DrawPath($rim, $ball)

# cap
$capPath = New-Object Drawing.Drawing2D.GraphicsPath
$capPath.AddRectangle((New-Object Drawing.Rectangle 452, 252, 120, 70))
$cap = New-Object Drawing.Drawing2D.LinearGradientBrush ([Drawing.Point]::new(452, 0)), ([Drawing.Point]::new(572, 0)), (C '#a8792e'), (C '#f3d68a')
$g.FillPath($cap, $capPath)
$capLine = New-Object Drawing.Pen (C '#7e5a21'), 5
foreach ($x in 482, 512, 542) { $g.DrawLine($capLine, $x, 258, $x, 316) }

$g.Dispose()

function Save([int]$size, [string]$name) {
  $small = New-Object Drawing.Bitmap $size, $size
  $sg = [Drawing.Graphics]::FromImage($small)
  $sg.InterpolationMode = 'HighQualityBicubic'; $sg.SmoothingMode = 'AntiAlias'; $sg.PixelOffsetMode = 'HighQuality'
  $sg.DrawImage($bmp, 0, 0, $size, $size)
  $sg.Dispose()
  $small.Save((Join-Path $out $name), [Drawing.Imaging.ImageFormat]::Png)
  $small.Dispose()
  Write-Host "Saved icons\$name ($size x $size)"
}
Save 512 'icon-512.png'
Save 192 'icon-192.png'
Save 180 'apple-touch-icon.png'
Save 32 'favicon-32.png'
$bmp.Dispose()
