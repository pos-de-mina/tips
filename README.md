# tips
Some command tips

# Suppress first char of a file
awk 'NR==1 {print substr($0,2)} {print $0}' /var/log/dpkg.log

# Linux | export multiple variables
export {http,https,ftp}_proxy='http://user:password@proxy-server:80'
