# Usage: iex (new-object net.webclient).downloadstring('https://git.io/')

echo "Installing deps..."
iex (new-object net.webclient).downloadstring('https://git.io/v9sLK')
scoop install nodejs

npm install -g minecraft-cli
