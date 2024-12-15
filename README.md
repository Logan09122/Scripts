MongoDB Script: To execute correctly, you need Java installed. This script creates a daily backup, compresses it, and deletes all previous backups. 
On the last day of the month, it performs a final backup and deletes all backups from that month. Every Monday, it 'resets' the backups by removing all backups from the weekend.
