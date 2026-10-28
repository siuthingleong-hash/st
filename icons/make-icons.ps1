<#
  Draws the home-screen app icon: a cheerful golden bauble character in a floppy Santa hat, with confetti and sparkles,
  on a cherry-red ground. Saves it in every size phones need. Re-run after changing the design:
    powershell -ExecutionPolicy Bypass -File make-icons.ps1
  Everything important stays inside the central safe circle, so Android can crop the icon to a circle or squircle ("maskable").
#>
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'
$out = $PSScriptRoot
$S = 1024
function C([string]$hex, [int]$a = 255) { $c = [Drawing.ColorTranslator]::FromHtml($hex); [Drawing.Color]::FromArgb($a, $c.R, $c.G, $c.B) }
function P([double]$x, [double]$y) { [Drawing.PointF]::new([float]$x, [float]$y) }
function Brush([string]$hex, [int]$a = 255) { New-Object Drawing.SolidBrush (C $hex $a) }

$bmp = New-Object Drawing.Bitmap $S, $S
$g = [Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'; $g.InterpolationMode = 'HighQualityBicubic'; $g.PixelOffsetMode = 'HighQuality'

# ---------- background: bright cherry red with a warm gold glow ----------
$bg = New-Object Drawing.Drawing2D.LinearGradientBrush (P 0 0), (P 0 $S), (C '#e8364f'), (C '#7a0f22')
$g.FillRectangle($bg, 0, 0, $S, $S)
$glowPath = New-Object Drawing.Drawing2D.GraphicsPath
$glowPath.AddEllipse(90, 150, 844, 844)
$glow = New-Object Drawing.Drawing2D.PathGradientBrush $glowPath
$glow.CenterColor = C '#ffd56b' 120; $glow.SurroundColors = @((C '#ffd56b' 0))
$g.FillPath($glow, $glowPath)

# ---------- confetti and snow ----------
$rnd = New-Object Random 11
$confetti = '#ffd56b', '#ffffff', '#3fbf7f', '#ff9ec7', '#7fd3ff'
for ($i = 0; $i -lt 46; $i++) {
  $x = $rnd.Next($S); $y = $rnd.Next($S)
  if ([Math]::Sqrt([Math]::Pow($x - 512, 2) + [Math]::Pow($y - 560, 2)) -lt 330) { continue }   # keep the face clear
  $g.TranslateTransform($x, $y); $g.RotateTransform($rnd.Next(180))
  $g.FillRectangle((Brush $confetti[$rnd.Next($confetti.Count)] 230), -11, -5, 22, 10)
  $g.ResetTransform()
}
function Sparkle([double]$x, [double]$y, [double]$r, [string]$hex) {
  $path = New-Object Drawing.Drawing2D.GraphicsPath
  $k = $r * 0.22
  $path.AddPolygon([Drawing.PointF[]]@((P $x ($y - $r)), (P ($x + $k) ($y - $k)), (P ($x + $r) $y), (P ($x + $k) ($y + $k)), (P $x ($y + $r)), (P ($x - $k) ($y + $k)), (P ($x - $r) $y), (P ($x - $k) ($y - $k))))
  $g.FillPath((Brush $hex), $path)
}
Sparkle 190 300 46 '#fff3c4'
Sparkle 850 520 38 '#fff3c4'
Sparkle 230 760 30 '#ffffff'
Sparkle 815 790 44 '#ffd56b'

# ---------- bauble body ----------
$cx = 512; $cy = 610; $R = 262
$ball = New-Object Drawing.Drawing2D.GraphicsPath
$ball.AddEllipse($cx - $R, $cy - $R, 2 * $R, 2 * $R)
$g.FillEllipse((Brush '#4a0a16' 90), $cx - $R + 14, $cy - $R + 26, 2 * $R, 2 * $R)   # soft drop shadow
$body = New-Object Drawing.Drawing2D.LinearGradientBrush (P ($cx - $R) ($cy - $R)), (P ($cx + $R) ($cy + $R)), (C '#ffe9a8'), (C '#c8902e')
$g.FillPath($body, $ball)
$g.SetClip($ball)
$g.DrawBezier((New-Object Drawing.Pen (C '#ffffff' 200), 26), 250, 800, 400, 870, 624, 870, 774, 800)   # bottom band
$g.TranslateTransform(318, 560); $g.RotateTransform(18)
$g.FillEllipse((Brush '#ffffff' 130), -26, -62, 52, 124)                                                   # shine
$g.ResetTransform()
$g.ResetClip()
$g.DrawPath((New-Object Drawing.Pen (C '#9a6a1f' 170), 7), $ball)

# ---------- face ----------
$ink = Brush '#3a1a0c'
foreach ($ex in 430, 594) {
  $g.FillEllipse($ink, $ex - 34, 545, 68, 88)            # big eyes
  $g.FillEllipse((Brush '#ffffff'), $ex - 16, 560, 26, 30) # sparkle in the eye
  $g.FillEllipse((Brush '#ffffff' 220), $ex + 8, 600, 12, 12)
}
$g.FillEllipse((Brush '#ff6f8f' 150), 330, 640, 84, 52)   # rosy cheeks
$g.FillEllipse((Brush '#ff6f8f' 150), 610, 640, 84, 52)
$mouth = New-Object Drawing.Drawing2D.GraphicsPath        # big open smile
$mouth.AddArc(452, 600, 120, 120, 0, 180)
$mouth.CloseFigure()
$g.FillPath((Brush '#8e1b2a'), $mouth)
$g.SetClip($mouth)
$g.FillEllipse((Brush '#ff7d93'), 482, 672, 60, 50)       # tongue
$g.ResetClip()

# ---------- floppy Santa hat ----------
$hat = New-Object Drawing.Drawing2D.GraphicsPath
$hat.AddBezier((P 300 410), (P 330 250), (P 470 140), (P 640 150))
$hat.AddBezier((P 640 150), (P 720 155), (P 770 210), (P 768 270))
$hat.AddBezier((P 768 270), (P 735 240), (P 700 250), (P 690 300))
$hat.AddBezier((P 690 300), (P 690 340), (P 705 380), (P 718 410))
$hat.CloseFigure()
$hatBrush = New-Object Drawing.Drawing2D.LinearGradientBrush (P 300 150), (P 760 410), (C '#ff3b4f'), (C '#b3122a')
$g.FillPath($hatBrush, $hat)
$g.DrawPath((New-Object Drawing.Pen (C '#4a0612'), 12), $hat)
$fur = New-Object Drawing.Drawing2D.GraphicsPath           # fluffy white brim, slightly tilted
$g.TranslateTransform(510, 410); $g.RotateTransform(-4)
$fur.AddArc(-245, -48, 96, 96, 90, 180); $fur.AddArc(149, -48, 96, 96, 270, 180); $fur.CloseFigure()
$g.FillPath((Brush '#ffffff'), $fur)
$g.DrawPath((New-Object Drawing.Pen (C '#e6dccb'), 5), $fur)
$g.ResetTransform()
$g.FillEllipse((Brush '#ffffff'), 712, 232, 104, 104)      # pom-pom
$g.DrawEllipse((New-Object Drawing.Pen (C '#e6dccb'), 5), 712, 232, 104, 104)

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
