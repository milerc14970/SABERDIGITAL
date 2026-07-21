# Servidor local para los juegos de lectoescritura
# Funciona sin Node.js ni Python - solo PowerShell

$port = 3000
$root = $PSScriptRoot

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()

Write-Host ""
Write-Host "========================================"
Write-Host "  SERVIDOR LECTOESCRITURA 4° GRADO"
Write-Host "========================================"
Write-Host ""
Write-Host "  Abre en tu navegador:"
Write-Host "  -> http://localhost:$port/"
Write-Host ""
Write-Host "  Presiona CTRL+C para detener."
Write-Host "========================================"
Write-Host ""

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    $path = $request.Url.LocalPath.TrimStart('/').Replace('/', '\')
    if ([string]::IsNullOrEmpty($path)) {
        $path = "index.html"
    }

    $fullPath = Join-Path $root $path
    if (Test-Path $fullPath -PathType Container) {
        $fullPath = Join-Path $fullPath "index.html"
    }

    if (Test-Path $fullPath) {
        $content = [System.IO.File]::ReadAllBytes($fullPath)
        $ext = [System.IO.Path]::GetExtension($fullPath)
        $mime = switch ($ext) {
            '.html' { 'text/html; charset=utf-8' }
            '.css'  { 'text/css; charset=utf-8' }
            '.js'   { 'application/javascript; charset=utf-8' }
            '.png'  { 'image/png' }
            '.jpg'  { 'image/jpeg' }
            '.svg'  { 'image/svg+xml' }
            '.ico'  { 'image/x-icon' }
            default { 'application/octet-stream' }
        }
        $response.ContentType = $mime
        $response.OutputStream.Write($content, 0, $content.Length)
    } else {
        $response.StatusCode = 404
        $msg = [System.Text.Encoding]::UTF8.GetBytes("404 - Archivo no encontrado")
        $response.OutputStream.Write($msg, 0, $msg.Length)
    }
    $response.Close()
}

$listener.Stop()
