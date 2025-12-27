Get-Process > $null

Write-Output "Begin CHECKING"

# Check file existing
if (Test-Path -Path testfile.txt) {
    Write-Host "The file exists. Proceeding with operations."
} else {
    Write-Host "Error: The file does not exist."
    $filePath = "testfile.txt"

    # Create the file first
    New-Item -Path $filePath -ItemType File -Force | Out-Null

    # Grant "F" (Full control) permissions to the "Everyone" group
    icacls $filePath /grant Everyone:'(F)'

    Write-Host "File '$filePath' created and permissions set using ICACLS."


Write-Host "File '$filePath' created with FullControl permissions for Everyone."
}

function GetFileByID() {
    param([int]$ID)
    try
    {
        $filePath = "testfile.txt"
        $BASE_URL="https://www.yourURL.com/DownloadPath/download?id="
        $uri = $BASE_URL + $ID
        Write-Host "FULL URL = $uri"
        $response = Invoke-WebRequest -Uri $uri -Method Head -ErrorAction Stop
        Write-Host "File exists. Status Code: $($response.StatusCode)"
        Add-Content -Path $filePath -Value "------- SUCCESS $ID"
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Host "File does not exist (404 Not Found)."
            Add-Content -Path $filePath -Value "404 NOT EXIST - $ID"
            return $false
        } else {
            Write-Host "An error occurred: $($_.Exception.Message)"
            Add-Content -Path $filePath -Value "occurred ERROR - $ID"
            return $false
    }
    }
}

$functionDefinition = ${function:GetFileByID}.ToString()

$results = 1..1000 | ForEach-Object -Parallel {
    # Re-define the function in the parallel runspace using $using:
    ${function:GetFileByID} = $using:functionDefinition

    # Call the function
    GetFileByID -ID $_

} -ThrottleLimit 12 # Controls max concurrent threads
