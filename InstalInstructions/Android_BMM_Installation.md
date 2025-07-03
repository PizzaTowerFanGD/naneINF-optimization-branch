# naneINF Mobile Installation (Android)
This set of instructions is for installation of the modloader on Android devices

## Requirements:
* • Access to a Mac/Windows/Linux PC
* • Balatro Mobile Maker: https://github.com/blake502/balatro-mobile-maker
* • A Steam copy of Balatro installed.

## Balatro Mobile Maker
1. • Download the latest exe release of Balatro Mobile Maker and run the EXE file.
2. • If Balatro is installed, BMM should be prompting you to build for Android & iOS.
3. • It should then start asking you to apply some patches, as shown below - pause here.
![image](https://github.com/user-attachments/assets/f749c390-f743-45be-abdc-08306951dab7)
4. • You'll first need to edit the `conf.lua` file. This is located in a folder called `Balatro` in the directory of where your BMM EXE is located.
![confluafile](https://github.com/user-attachments/assets/07606796-b4ac-4747-8c38-54db2e898bd0)
5. • Now, add the line `t.externalstorage = true` and save the file. It should now look something like the image below:
 ![confedit](https://github.com/user-attachments/assets/fed150ef-855e-4cec-9f82-d67edd314312)
> This makes the save location in the `android/data` folder rather than the root folder
6. • You can now continue the rest of the installation as normal and install the `balatro.apk` onto your android device!

* **The rest of these instructions will be followed on your phone.**
## Accessing Balatro Save Location
We now need to follow the following steps in order for us to be able to edit the save file location
1. • Hold the icon of the Balatro app, and press *App Info*
2. • Then clear the game's cache and storage </br>
![image](https://github.com/user-attachments/assets/0c14031d-8d98-421a-8d6e-920dda21c0a2)
3. • Then you go to `android/data/com.unofficial.balatro`, it should now be empty.
4. • Create the following folders in this order:
   `"files" -> "save" -> "game"
     -> "mods" , "patched"`
6. • Your folder structure should now look like `android/data/com.unofficial.balatro/files/save/game`
 * the `game` folder should now have 2 folders called `mods` and `patched`
7. • Launch the game, this will create a save file.


# Modloader Installation
Now that we have the folders set up, we will now install the ModLoader onto Balatro, which should be quick and simple.
1. • Download the latest Mod Loader release from this github page
2. • Now go onto your File Explorer app
3. • Extract the Zip File, and drag the `originalmain.lua`, `main.lua` and `EmbeddedModLoader` into `android/data/com.unofficial.balatro/files/save/game` 
4. • Launch the game, some folders will now be created
5. • Now you can start adding mods in the mods folder!

> * Keep in mind that it may take a while to load as lovely isn't being used natively.
> * SMODS is a requirement for naneINF to work properly.
  
## Can't access android/data folder?
*In Android 11 and below, folders can be accessed by granting access. Starting with Android 12, the restrictions have become stricter.*
This is an android limitation, newer android versions restrict android/data access, so you need to either root your device or use shizuku to make it accessible on your file explorer.

You can read more about this limitation [here](https://zdevs.ru/en/za/android_data_obb.html)

Shizuku grants file explorers access to restricted folders without the need for root access. Follow [this](https://shizuku.rikka.app/guide/setup/) to set it up.

## Troubleshooting

[Discord Server](https://discord.gg/2pjsG3u2wm)

[Github](https://github.com/3XPLwastaken/naneINF-Balatro-Modloader)
