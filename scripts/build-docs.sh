cp README.md docs/index.md
mkdocs --version
mkdocs build
echo cli.mcpr.io >> docs-site/CNAME
