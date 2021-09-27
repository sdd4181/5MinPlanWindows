# 5MinPlanWindows
The 5 minute plan for windows

This script goes through each user and asks the person who ran the script if they want to disable certain users and also changes the password for everyone.  It also makes it so that users can't change their own passwords so it will hopefully make it more difficult for red team to setup a password that we don't know

It then goes through all users in the administrator group and asks the person running the script to remove a user from the admin group or not. 

make sure you run set-ExecutionPolicy -ExecutionPolicy “unrestricted”
and then back to restricted after you run the script
set-ExecutionPolicy -ExecutionPolicy “restricted”
