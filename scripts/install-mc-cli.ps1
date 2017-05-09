#requires -v 3
# remote install:
#   iex (new-object net.webclient).downloadstring('https://git.io/v9sLj')
$erroractionpreference='stop' # quit if anything goes wrong

echo "Installing deps..."
if ((Get-Command "scoop" -ErrorAction SilentlyContinue) -eq $null) 
{ 
   Write-Host "Installing Scoop..."
   iex (new-object net.webclient).downloadstring('https://git.io/v9sLK')
}
if ((Get-Command "node" -ErrorAction SilentlyContinue) -eq $null) 
{ 
   Write-Host "Installing Node.js..."
   scoop install nodejs
}
if ((Get-Command "java" -ErrorAction SilentlyContinue) -eq $null) 
{ 
   Write-Host "Installing OpenJDK..."
   scoop install openjdk
}

echo "Installing mc-cli..."
npm install -g minecraft-cli
