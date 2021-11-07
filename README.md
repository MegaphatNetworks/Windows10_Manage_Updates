# Windows 10 Manage Updates
Gives you - the user the power to turn on and of Windows Updates without affecting the WU services.

```
Windows 10 Update Fix Menu
==========================

0 - Quit
1 - Allow Updates
2 - Prevent Updates
Enter Selection:
```

It really is THAT simple!

Now if you want to add a little something special, then check this out.  
`regSet "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoRebootWithLoggedOnUsers" 0 `  
Adding this line in your execution will prevent Windows from performing an automatic reboot even with automatic updates configured.  
You know how sometimes you have a bunch of work loaded on your desktop and then suddenly Windows decides  
*hey, I just remembered that updates were done and I never rebooted!  NOW seems like a good time!*  
This will only work if a user is logged in.

Q: Will this damage my system?
---
A: No.

Q: Will this change any other part of my system?
---
A: No.

Q: Are you making money at this?
---
A: No but I would appreciate any donations for all of my time and effort.

Q: Do you have a website?
---
A: You can check out [my personal site](http://www.megaphat.info)

Q: Can I contact you with any questions or for a custom script?
---
A: Sure, just go to [my personal site](http://www.megaphat.info) to reach out to me.

Share the love and buy me some coffee!
