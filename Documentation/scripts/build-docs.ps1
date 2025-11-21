# Store the original directory
$originalLocation = Get-Location

try {
    # Change to Documentation directory (parent of scripts)
    Set-Location $PSScriptRoot/..
    
    # Build documentation
    docfx metadata
    docfx build
}
finally {
    # Always return to original directory, even if build fails
    Set-Location $originalLocation
}