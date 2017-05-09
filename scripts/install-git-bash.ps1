echo "Installing scoop..."
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')

echo "Installing Git-Bash..."
scoop install git-with-openssh
