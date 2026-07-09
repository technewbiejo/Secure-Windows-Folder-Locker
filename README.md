# Secure-Windows-Folder-Locker
A dynamic Windows Batch folder locker with master key recovery.
##########
This script is a lightweight, local Security Directory Vault built using Windows Batch (.bat) syntax. It allows you to dynamically create a custom storage folder, load it with sensitive documents, and instantly camouflage it from your Windows file structure.

# Key Features
Zero Plain-Text Hardcoding: Unlike classic batch lockers, this version completely removes your secret passwords from the .bat file itself, saving them in a protected, system-hidden local configuration dataset (.sys_locker_config.dat) to keep hackers out.

# Master Recovery Gate: Includes an integrated recovery mode. If you fail to log in, you can input a separate Master Key to reset your password on the fly.

# Native GUI Windows: Dynamically generates graphical error pop-ups and success dialogue boxes using a temporary VBScript backend.

# Instant Explorer Camouflage: 
Leverages the native Windows attrib +h +s flags combined with a system GUID shortcut string to make your folder completely invisible. It automatically forces your active File Explorer windows to refresh upon exit so the visual changes take effect instantly.

# How to Use the Script
Setup: Place the secure_locker.bat file into the folder where you want your vault to live.

First Run (Creation): * Double-click secure_locker.bat and select Option 2 (Create a Brand New Folder).

Type your desired folder name. The script will immediately create this folder right next to the script file.

Populate Your Vault: Go to your normal Windows File Explorer, open your newly created folder, and move all your private files inside it.

Locking: * Go back to the script window, confirm you want to lock it (Y), and the script will prompt you to create a Password (entered twice for confirmation) and a Recovery Master Key.

The script will automatically save these settings securely, hide your folder out of sight, refresh your screen, and close down.

Unlocking: Next time you open the script, select Option 1. It will detect your hidden vault and require your password to bring it back to visibility.
