# Simple PowerShell HTTP Server
$port = 8000
$url = "http://localhost:$port/"

Write-Host "Starting HTTP server on $url" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow

# Create HTTP listener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
$listener.Start()

Write-Host "Server started. Open your browser to: $url" -ForegroundColor Cyan

try {
    while ($listener.IsListening) {
        # Wait for a request
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        # Get the requested file path
        $requestedPath = $request.Url.LocalPath
        if ($requestedPath -eq "/") {
            $requestedPath = "/index.html"
        }
        
        # Build full file path
        $filePath = Join-Path $PWD $requestedPath.TrimStart('/')
        
        try {
            if (Test-Path $filePath -PathType Leaf) {
                # File exists, serve it
                $content = [System.IO.File]::ReadAllBytes($filePath)
                
                # Set content type based on file extension
                $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
                switch ($extension) {
                    ".html" { $response.ContentType = "text/html" }
                    ".css" { $response.ContentType = "text/css" }
                    ".js" { $response.ContentType = "application/javascript" }
                    ".json" { $response.ContentType = "application/json" }
                    ".png" { $response.ContentType = "image/png" }
                    ".jpg" { $response.ContentType = "image/jpeg" }
                    ".gif" { $response.ContentType = "image/gif" }
                    default { $response.ContentType = "text/plain" }
                }
                
                $response.StatusCode = 200
                $response.ContentLength64 = $content.Length
                $response.OutputStream.Write($content, 0, $content.Length)
                
                Write-Host "Served: $requestedPath" -ForegroundColor Green
            } else {
                # File not found
                $response.StatusCode = 404
                $errorMessage = "File not found: $requestedPath"
                $errorBytes = [System.Text.Encoding]::UTF8.GetBytes($errorMessage)
                $response.ContentLength64 = $errorBytes.Length
                $response.OutputStream.Write($errorBytes, 0, $errorBytes.Length)
                
                Write-Host "404: $requestedPath" -ForegroundColor Red
            }
        } catch {
            # Error serving file
            $response.StatusCode = 500
            $errorMessage = "Error serving file: $($_.Exception.Message)"
            $errorBytes = [System.Text.Encoding]::UTF8.GetBytes($errorMessage)
            $response.ContentLength64 = $errorBytes.Length
            $response.OutputStream.Write($errorBytes, 0, $errorBytes.Length)
            
            Write-Host "Error serving $requestedPath : $($_.Exception.Message)" -ForegroundColor Red
        } finally {
            $response.Close()
        }
    }
} finally {
    $listener.Stop()
    Write-Host "Server stopped." -ForegroundColor Yellow
}