# This script performs the following actions:
# 1. Ensures the file /etc/frr/vtysh.conf exists, which is used to configure vtysh, the integrated shell for managing FRRouting.
# 2. Changes the ownership of /etc/frr/vtysh.conf to the user and group 'frr'.
# 3. Sets the file permissions of /etc/frr/vtysh.conf to 640 (read/write for owner, read for group, no access for others).
# 4. Starts the FRRouting (FRR) service using the frrinit.sh script located in /usr/lib/frr/.
# 5. Opens an interactive Bash shell after starting the FRR service.
#!/bin/bash
touch /etc/frr/vtysh.conf && \
chown frr:frr /etc/frr/vtysh.conf && \
chmod 640 /etc/frr/vtysh.conf && \
/usr/lib/frr/frrinit.sh start && \
/bin/bash