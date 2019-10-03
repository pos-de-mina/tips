# tips
Some command tips

# Suppress first char of a file
awk 'NR==1 {print substr($0,2)} {print $0}' /var/log/dpkg.log
