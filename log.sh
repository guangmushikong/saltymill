# Adds a line of log output into the log HTML file
echo "$1" > /var/log/salt/buildlog.html
sed -i 's/<!-- logend -->/$1\n<!-- logend -->/' /var/log/salt/index.html