
# naneINF Mobile Installation (Android)
This set of instructions is for installation of the modloader on Android devices

## Requirements:
* Access to a Mac/Windows/Linux PC
* Balatro Mobile Maker: https://github.com/blake502/balatro-mobile-maker
* A Steam copy of Balatro installed.

## Balatro Mobile Maker
1. Download the latest exe release of Balatro Mobile Maker and run the EXE file.
2. If Balatro is installed, BMM should be prompting you to build for Android & iOS.
3. It should start asking you to apply some patches (e.g. *Would you like to apply FPS Cap?*) Stop here.
![image](https://github.com/user-attachments/assets/f749c390-f743-45be-abdc-08306951dab7)
4. You now need to edit the "conf.lua" file which is located in a folder called "*Balatro*" in the directory of where your BMMM EXE is located.
![confluafile](https://github.com/user-attachments/assets/07606796-b4ac-4747-8c38-54db2e898bd0)
5. You should add the line *t.externalstorage = true* and save the file. It should now look something like the image below
* (This makes the save location in the *android/data* folder rather than the root folder)
 ![confedit](https://github.com/user-attachments/assets/fed150ef-855e-4cec-9f82-d67edd314312)
6. You can now continue the rest of the installation as normal and install the balatro.apk onto your android device.





# Modloader Installation
Now that we have BMM Balatro installed on your phone, we will now install the ModLoader onto Balatro, which should be quick and simple.
**The rest of these instructions will be followed on your phone.**
1. You should launch the game first, so that a save folder is created
2. Download the latest Mod Loader release from this github page
3. Now go onto your File Explorer app
4. Extract the Zip File, and drag both the "originalmain.lua", "main.lua" and "EmbeddedModLoader" into *android/data/com.unofficial.balatro/file/save/game* 
5. Launch the game, the mods folder will be created automatically
6. Now you can start adding mods in the mods folder! (smods alongside other mods) Keep in mind that it may take a while to load as lovely isn't being used

## Can't access android/data folder?
*In Android 11 and 12, folders can be accessed by granting access. Starting with Android 13, the restrictions have become stricter.*
This is an android limitation, newer android versions restrict android/data access, so you need to either root your device or use shizuku to make it accessible on file explorers like Zarchiver.
You can read more about it [here](https://zdevs.ru/en/za/android_data_obb.html)

[Shizuku Setup instructions](https://shizuku.rikka.app/guide/setup/)

Troubleshooting

[Discord Server](https://discord.gg/2pjsG3u2wm)

[Github](https://github.com/3XPLwastaken/naneINF-Balatro-Modloader)
