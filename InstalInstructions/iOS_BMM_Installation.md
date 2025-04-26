# naneINF Mobile Installation (iOS)
This set of instructions is for installation of the modloader on ios devices,

For installation on android devices, ~~[Refer to this tutorial](https://a.com/)~~
##Android is supported, but does not have installation instructions yet.

For installation on PC, [Refer to this tutorial](https://a.com/)


## Requirements:
* Access to a Mac/Windows/Linux PC
* Sideloadly: https://sideloadly.io/
* Balatro Mobile Maker: https://github.com/blake502/balatro-mobile-maker
* Target iPhone set to Developer Mode
* A Steam copy of Balatro installed.



## Sideloadly Installation
Download and install Sideloadly as instructed on the website,
- **If you are on Windows PLEASE make sure to read the "Important Windows Task" above the download button.**



## Balatro Mobile Maker
1. Download the latest exe release of Balatro Mobile Maker and run the EXE file.
2. If Balatro is installed, BMM should be prompting you to build for Android & iOS (with suggested patches)
3. Review and confirm or deny patches to the iOS build of balatro, Once built BMM should have spit out a file called "balatro.ipa" in its root directory
4.



## Sideloading
> do **NOT** press the tempting start button until instructed to do so, otherwise your modloader installation will suffer a functionality hit.
1. Turn on Sideloadly and connect your device to your computer (via usb or wifi), select your phone from this dropdown.
   ![Sideloadly](https://files.catbox.moe/ve2qdl.png)

2. Drag the "balatro.ipa" file onto the sideloadly application or select it through the file selector, once selected your window should look like this:
   ![DraggingExample](https://files.catbox.moe/ezm5w9.gif)

3. Click Advanced Options, and **enable File Sharing.**
> enabling File Sharing will allow you to edit your save files through the iOS files App, this step is absolutely *mandatory* for this installation method.

4. **(OPTIONAL)** Change the app name to "naneINF" or another name of your choosing
5. **(OPTIONAL)** Disable "Use automatic bundle ID" and set the new bundle ID to "org.naneinf.balatro"
> setting the bundle ID will allow you to keep the naneINF version of Balatro seperate from any other potential balatro installations, including ones from the app store.
6. Press the start button.
   <img src="https://files.catbox.moe/apqbfd.gif" alt="drawing" width="500"/>

7. If prompted, sign into your Apple ID, and trust the device on your phone.

8. Once sideloadly says "Done!" the BMM version of Balatro should be installed on your phone, and should be findable by searching for the app name.
> You may need to trust the App in settings before being able to run the app. [Instructions to trust the app are located here](https://support.apple.com/en-us/118254)



# Modloader Installation
Now that we have BMM Balatro installed on your phone, we will now install the ModLoader onto Balatro, which should be quick and simple.
**The rest of these instructions will be followed on your phone.**

1. Download the latest Mod Loader release from this github page
2. Extract the Zip File, and drag both "main.lua" and "EmbeddedModLoader" into *On My iPhone/(balatro app name)/game/*
3. Launch the game, the mods folder will be created automatically.

## Congratulations! The Mod Loader has successfully been installed, consider checking out the links below.
Mod installation/downloading

Troubleshooting

[Discord Server](https://discord.gg/2pjsG3u2wm)

Github
