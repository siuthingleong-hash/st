<#
  Draws the home-screen app icon. Default (-Style text): the word "festival" (two Chinese characters) in red on a plain cream ground.
  Characters: bauble (golden bauble in a Santa hat), reindeer, snowman, gift.

  Make the app icons (all sizes, into this folder):  powershell -ExecutionPolicy Bypass -File make-icons.ps1 -Style reindeer
  Preview one design only:                            powershell -ExecutionPolicy Bypass -File make-icons.ps1 -Style snowman -PreviewTo C:\some\folder

  Everything important stays inside the central safe circle, so Android can crop the icon to a circle or squircle ("maskable").
#>
param(
  [ValidateSet('text', 'bauble', 'reindeer', 'snowman', 'gift')][string]$Style = 'text',
  [string]$Font = 'Noto Serif SC Black',   # for -Style text
  [string]$PreviewTo = ''
)
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'
$out = $PSScriptRoot
$S = 1024
function C([string]$hex, [int]$a = 255) { $c = [Drawing.ColorTranslator]::FromHtml($hex); [Drawing.Color]::FromArgb($a, $c.R, $c.G, $c.B) }
function P([double]$x, [double]$y) { [Drawing.PointF]::new([float]$x, [float]$y) }
function Brush([string]$hex, [int]$a = 255) { New-Object Drawing.SolidBrush (C $hex $a) }
function Pen([string]$hex, [double]$w, [int]$a = 255) { $p = New-Object Drawing.Pen (C $hex $a), ([float]$w); $p.StartCap = 'Round'; $p.EndCap = 'Round'; $p.LineJoin = 'Round'; $p }
function Grad([double]$x1, [double]$y1, [double]$x2, [double]$y2, [string]$a, [string]$b) { New-Object Drawing.Drawing2D.LinearGradientBrush (P $x1 $y1), (P $x2 $y2), (C $a), (C $b) }
function Circle([double]$cx, [double]$cy, [double]$r) { $p = New-Object Drawing.Drawing2D.GraphicsPath; $p.AddEllipse([float]($cx - $r), [float]($cy - $r), [float](2 * $r), [float](2 * $r)); $p }

$bmp = New-Object Drawing.Bitmap $S, $S
$g = [Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'; $g.InterpolationMode = 'HighQualityBicubic'; $g.PixelOffsetMode = 'HighQuality'

function Sparkle([double]$x, [double]$y, [double]$r, [string]$hex) {
  $path = New-Object Drawing.Drawing2D.GraphicsPath
  $k = $r * 0.22
  $path.AddPolygon([Drawing.PointF[]]@((P $x ($y - $r)), (P ($x + $k) ($y - $k)), (P ($x + $r) $y), (P ($x + $k) ($y + $k)), (P $x ($y + $r)), (P ($x - $k) ($y + $k)), (P ($x - $r) $y), (P ($x - $k) ($y - $k))))
  $g.FillPath((Brush $hex), $path)
}

if ($Style -eq 'text') {
  # ---------- plain cream (beige) ground, a little lighter in the middle ----------
  $g.FillRectangle((Grad 0 0 0 $S '#f7ecd8' '#ecdcbf'), 0, 0, $S, $S)
  $lightPath = Circle 512 512 520
  $light = New-Object Drawing.Drawing2D.PathGradientBrush $lightPath
  $light.CenterColor = C '#fffaf0' 230; $light.SurroundColors = @((C '#fffaf0' 0))
  $g.FillPath($light, $lightPath)
} else {
  # ---------- festive ground: bright cherry red, warm glow, confetti, sparkles ----------
  $g.FillRectangle((Grad 0 0 0 $S '#e8364f' '#7a0f22'), 0, 0, $S, $S)
  $glowPath = Circle 512 572 422
  $glow = New-Object Drawing.Drawing2D.PathGradientBrush $glowPath
  $glow.CenterColor = C '#ffd56b' 120; $glow.SurroundColors = @((C '#ffd56b' 0))
  $g.FillPath($glow, $glowPath)
  $rnd = New-Object Random 11
  $confetti = '#ffd56b', '#ffffff', '#3fbf7f', '#ff9ec7', '#7fd3ff'
  for ($i = 0; $i -lt 46; $i++) {
    $x = $rnd.Next($S); $y = $rnd.Next($S)
    if ([Math]::Sqrt([Math]::Pow($x - 512, 2) + [Math]::Pow($y - 560, 2)) -lt 330) { continue }   # keep the character clear
    $g.TranslateTransform($x, $y); $g.RotateTransform($rnd.Next(180))
    $g.FillRectangle((Brush $confetti[$rnd.Next($confetti.Count)] 230), -11, -5, 22, 10)
    $g.ResetTransform()
  }
  Sparkle 190 300 46 '#fff3c4'
  Sparkle 850 520 38 '#fff3c4'
  Sparkle 230 760 30 '#ffffff'
  Sparkle 815 790 44 '#ffd56b'
}

# ---------- shared cute face: big sparkly eyes, rosy cheeks, open smile ----------
function Face([double]$cx, [double]$cy, [double]$s = 1, [switch]$NoMouth) {
  foreach ($dx in -82, 82) {
    $ex = $cx + $dx * $s
    $g.FillEllipse((Brush '#3a1a0c'), [float]($ex - 34 * $s), [float]($cy - 44 * $s), [float](68 * $s), [float](88 * $s))
    $g.FillEllipse((Brush '#ffffff'), [float]($ex - 16 * $s), [float]($cy - 29 * $s), [float](26 * $s), [float](30 * $s))
    $g.FillEllipse((Brush '#ffffff' 220), [float]($ex + 8 * $s), [float]($cy + 11 * $s), [float](12 * $s), [float](12 * $s))
  }
  foreach ($dx in -140, 140) { $g.FillEllipse((Brush '#ff6f8f' 150), [float]($cx + $dx * $s - 42 * $s), [float]($cy + 51 * $s), [float](84 * $s), [float](52 * $s)) }
  if ($NoMouth) { return }
  $mouth = New-Object Drawing.Drawing2D.GraphicsPath
  $mouth.AddArc([float]($cx - 60 * $s), [float]($cy + 11 * $s), [float](120 * $s), [float](120 * $s), 0, 180)
  $mouth.CloseFigure()
  $g.FillPath((Brush '#8e1b2a'), $mouth)
  $g.SetClip($mouth)
  $g.FillEllipse((Brush '#ff7d93'), [float]($cx - 30 * $s), [float]($cy + 83 * $s), [float](60 * $s), [float](50 * $s))
  $g.ResetClip()
}
function Shadow([System.Drawing.Drawing2D.GraphicsPath]$path) {
  $g.TranslateTransform(14, 26); $g.FillPath((Brush '#4a0a16' 90), $path); $g.ResetTransform()
}

# ---------- characters ----------
function Draw-Bauble {
  $cx = 512; $cy = 610; $R = 262
  $ball = Circle $cx $cy $R
  Shadow $ball
  $g.FillPath((Grad ($cx - $R) ($cy - $R) ($cx + $R) ($cy + $R) '#ffe9a8' '#c8902e'), $ball)
  $g.SetClip($ball)
  $g.DrawBezier((Pen '#ffffff' 26 200), 250, 800, 400, 870, 624, 870, 774, 800)
  $g.TranslateTransform(318, 560); $g.RotateTransform(18); $g.FillEllipse((Brush '#ffffff' 130), -26, -62, 52, 124); $g.ResetTransform()
  $g.ResetClip()
  $g.DrawPath((Pen '#9a6a1f' 7 170), $ball)
  Face 512 589
  # floppy Santa hat
  $hat = New-Object Drawing.Drawing2D.GraphicsPath
  $hat.AddBezier((P 300 410), (P 330 250), (P 470 140), (P 640 150))
  $hat.AddBezier((P 640 150), (P 720 155), (P 770 210), (P 768 270))
  $hat.AddBezier((P 768 270), (P 735 240), (P 700 250), (P 690 300))
  $hat.AddBezier((P 690 300), (P 690 340), (P 705 380), (P 718 410))
  $hat.CloseFigure()
  $g.FillPath((Grad 300 150 760 410 '#ff3b4f' '#b3122a'), $hat)
  $g.DrawPath((Pen '#4a0612' 12), $hat)
  $fur = New-Object Drawing.Drawing2D.GraphicsPath
  $g.TranslateTransform(510, 410); $g.RotateTransform(-4)
  $fur.AddArc(-245, -48, 96, 96, 90, 180); $fur.AddArc(149, -48, 96, 96, 270, 180); $fur.CloseFigure()
  $g.FillPath((Brush '#ffffff'), $fur); $g.DrawPath((Pen '#e6dccb' 5), $fur)
  $g.ResetTransform()
  $g.FillEllipse((Brush '#ffffff'), 712, 232, 104, 104); $g.DrawEllipse((Pen '#e6dccb' 5), 712, 232, 104, 104)
}

function Draw-Reindeer {
  # antlers first, so the head sits in front of them
  $ant = Pen '#7a4a22' 34
  foreach ($side in -1, 1) {
    $bx = 512 + $side * 120
    $g.DrawBezier($ant, $bx, 420, $bx + $side * 30, 330, $bx + $side * 110, 270, $bx + $side * 150, 170)
    $g.DrawLine($ant, $bx + $side * 62, 318, $bx + $side * 10, 230)
    $g.DrawLine($ant, $bx + $side * 118, 250, $bx + $side * 205, 225)
  }
  # ears
  foreach ($side in -1, 1) {
    $g.TranslateTransform(512 + $side * 238, 470); $g.RotateTransform($side * 35)
    $g.FillEllipse((Brush '#a8693a'), -46, -78, 92, 156); $g.FillEllipse((Brush '#f2b8a0'), -24, -50, 48, 100)
    $g.ResetTransform()
  }
  $head = New-Object Drawing.Drawing2D.GraphicsPath
  $head.AddEllipse(282, 380, 460, 470)
  Shadow $head
  $g.FillPath((Grad 282 380 742 850 '#d9a06a' '#8a5530'), $head)
  $g.DrawPath((Pen '#5a3417' 7 170), $head)
  $g.FillEllipse((Brush '#f3d9b8'), 362, 640, 300, 190)                 # muzzle
  Face 512 575 0.92 -NoMouth
  # smile under the nose
  $g.DrawArc((Pen '#5a2a10' 12), 462, 700, 100, 80, 20, 140)
  # big shiny red nose
  $nose = Circle 512 680 54
  $g.FillPath((Grad 458 626 566 734 '#ff5a6e' '#c4142e'), $nose)
  $g.FillEllipse((Brush '#ffffff' 200), 482, 646, 30, 20)
  # little scarf knot of holly
  $g.FillEllipse((Brush '#2f9e5b'), 300, 410, 70, 40); $g.FillEllipse((Brush '#2f9e5b'), 340, 380, 40, 70)
  $g.FillEllipse((Brush '#e8364f'), 342, 412, 30, 30)
}

function Draw-Snowman {
  $head = Circle 512 620 258
  Shadow $head
  $g.FillPath((Grad 300 380 740 880 '#ffffff' '#cfdceb'), $head)
  $g.DrawPath((Pen '#9fb3c8' 7 200), $head)
  Face 512 585 -NoMouth
  # carrot nose, pointing out to the side, with the smile below it
  $carrot = New-Object Drawing.Drawing2D.GraphicsPath
  $carrot.AddPolygon([Drawing.PointF[]]@((P 496 640), (P 496 674), (P 618 662)))
  $g.FillPath((Grad 496 640 618 670 '#ff9a3c' '#e8641c'), $carrot)
  $mouth = New-Object Drawing.Drawing2D.GraphicsPath
  $mouth.AddArc(457, 650, 110, 110, 0, 180); $mouth.CloseFigure()
  $g.FillPath((Brush '#8e1b2a'), $mouth)
  $g.SetClip($mouth); $g.FillEllipse((Brush '#ff7d93'), 485, 722, 54, 44); $g.ResetClip()
  # green knitted beanie with a pom-pom
  $hat = New-Object Drawing.Drawing2D.GraphicsPath
  $hat.AddArc(290, 300, 444, 300, 180, 180)
  $hat.CloseFigure()
  $g.FillPath((Grad 290 300 734 450 '#3fbf7f' '#1f7a48'), $hat)
  $g.SetClip($hat)
  foreach ($x in 330, 400, 470, 540, 610, 680) { $g.DrawLine((Pen '#ffffff' 8 70), $x, 300, $x + 10, 460) }
  $g.ResetClip()
  $rim = New-Object Drawing.Drawing2D.GraphicsPath
  $rim.AddArc(276, 418, 72, 72, 90, 180); $rim.AddArc(676, 418, 72, 72, 270, 180); $rim.CloseFigure()
  $g.FillPath((Brush '#e8364f'), $rim); $g.DrawPath((Pen '#a8102a' 5), $rim)
  $g.FillEllipse((Brush '#ffffff'), 462, 238, 100, 100); $g.DrawEllipse((Pen '#d9e2ec' 5), 462, 238, 100, 100)
  # striped scarf peeking at the bottom
  $g.SetClip($head)
  $g.FillRectangle((Brush '#e8364f'), 250, 820, 524, 70)
  foreach ($x in 290, 380, 470, 560, 650, 740) { $g.FillRectangle((Brush '#ffffff'), $x, 820, 34, 70) }
  $g.ResetClip()
}

function Draw-Gift {
  $box = New-Object Drawing.Drawing2D.GraphicsPath
  $box.AddRectangle((New-Object Drawing.RectangleF 300, 470, 424, 380))
  Shadow $box
  $g.FillPath((Grad 300 470 724 850 '#45c983' '#1f7a48'), $box)
  $g.FillRectangle((Brush '#ffd56b'), 476, 470, 72, 380)                # ribbon down the front
  $g.DrawPath((Pen '#14532f' 7 170), $box)
  # lid, popped up and tilted
  $g.TranslateTransform(512, 430); $g.RotateTransform(-8)
  $g.FillRectangle((Grad -250 -50 250 50 '#5ad693' '#228a52'), -250, -52, 500, 104)
  $g.FillRectangle((Brush '#ffd56b'), -38, -52, 76, 104)
  $g.DrawRectangle((Pen '#14532f' 7 170), -250, -52, 500, 104)
  # bow
  foreach ($side in -1, 1) {
    $g.TranslateTransform($side * 70, -88); $g.RotateTransform($side * 25)
    $g.FillEllipse((Brush '#ffd56b'), -70, -40, 140, 80); $g.FillEllipse((Brush '#e0a92e'), -34, -18, 68, 36)
    $g.RotateTransform(-$side * 25); $g.TranslateTransform(-$side * 70, 88)
  }
  $g.FillEllipse((Brush '#e0a92e'), -34, -122, 68, 68)
  $g.ResetTransform()
  # sparkles escaping from the box
  Sparkle 330 260 34 '#ffffff'
  Sparkle 700 250 28 '#fff3c4'
  # face on the front, either side of the ribbon
  Face 512 650 0.95
}

function Draw-Text {
  # the two characters for "festival" (U+8282 U+65E5), centred and sized to sit well inside the safe circle
  $word = [string][char]0x8282 + [string][char]0x65E5
  $family = New-Object Drawing.FontFamily $Font
  $path = New-Object Drawing.Drawing2D.GraphicsPath
  $path.FillMode = 'Winding'   # overlapping strokes stay solid instead of cutting holes
  $path.AddString($word, $family, [int][Drawing.FontStyle]::Regular, 400, (P 0 0), [Drawing.StringFormat]::GenericTypographic)
  $b = $path.GetBounds()
  $scale = [Math]::Min(600 / $b.Width, 330 / $b.Height)
  $m = New-Object Drawing.Drawing2D.Matrix
  $m.Translate([float](512 - ($b.X + $b.Width / 2) * $scale), [float](512 - ($b.Y + $b.Height / 2) * $scale))
  $m.Scale([float]$scale, [float]$scale)
  $path.Transform($m)
  $g.TranslateTransform(0, 10); $g.FillPath((Brush '#c8a25a' 110), $path); $g.ResetTransform()   # soft gold shadow
  $nb = $path.GetBounds()
  $g.FillPath((Grad 0 $nb.Top 0 $nb.Bottom '#d4223f' '#9a1328'), $path)
}

switch ($Style) {
  'text' { Draw-Text }
  'bauble' { Draw-Bauble }
  'reindeer' { Draw-Reindeer }
  'snowman' { Draw-Snowman }
  'gift' { Draw-Gift }
}
$g.Dispose()

function Save([int]$size, [string]$path) {
  $small = New-Object Drawing.Bitmap $size, $size
  $sg = [Drawing.Graphics]::FromImage($small)
  $sg.InterpolationMode = 'HighQualityBicubic'; $sg.SmoothingMode = 'AntiAlias'; $sg.PixelOffsetMode = 'HighQuality'
  $sg.DrawImage($bmp, 0, 0, $size, $size)
  $sg.Dispose()
  $small.Save($path, [Drawing.Imaging.ImageFormat]::Png)
  $small.Dispose()
  Write-Host "Saved $path ($size x $size)"
}
if ($PreviewTo) {
  if (-not (Test-Path $PreviewTo)) { New-Item -ItemType Directory -Path $PreviewTo | Out-Null }
  Save 512 (Join-Path $PreviewTo "$Style.png")
} else {
  Save 512 (Join-Path $out 'icon-512.png')
  Save 192 (Join-Path $out 'icon-192.png')
  Save 180 (Join-Path $out 'apple-touch-icon.png')
  Save 32 (Join-Path $out 'favicon-32.png')
}
$bmp.Dispose()
