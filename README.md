# BattlegroundTargets-WotLK
BattlegroundTargets is a legacy addon created by kunda during Cataclysm.  
This a modified version of Nobrainx's extended backport for WotLK.

## Features
- Creates clickable pseudo unit frames for battleground enemies.
- Allows targeting (left-click) and focusing (right-click) directly from the frame.
- Special indicators for target, focus, role and other statuses.
- Flag Carrier Tracking System for Warsong Gulch and Eye of the Storm.
- Support for Cross-Faction Battlegrounds and Mercenary Mode.
- Integrated Healer Detection System, including a persistent database.
- Incorporates [BattleGroundHealers](https://github.com/KhalGH/BattleGroundHealers-WotLK)’ combatlog-based method for improved detection

<p align="center">
  <img src="https://raw.githubusercontent.com/KhalGH/BattlegroundTargets-WotLK/refs/heads/assets/assets/BGT_img.png" 
       alt="ItemLevel UI Preview" width="90%">
</p>

## Chat Commands
- **`/bgt`** &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; → &nbsp; Opens the configuration panel.  
- **`/bgt help`** &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; → &nbsp; Prints all available commands.
- **`/bgt hdlog`** &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; → &nbsp; Announces each healer detection in your local chat.
- **`/bgt hdlogAlways`** &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; → &nbsp; Enables persistent detection announcements (survives relogs).
- **`/bgt hdreport`** &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; → &nbsp; Reports all detected unit roles in your local chat.
- **`/bgt dbStoragePeriod <#>`** &nbsp; → &nbsp; Sets how long healer detections are retained in the DB (# in months, 0–11)

## Installation
1. [Download](https://github.com/KhalGH/BattlegroundTargets-WotLK/releases/download/v1.2.1/BattlegroundTargets-v1.2.1.zip) the addon
2. Extract the **BattlegroundTargets** folder into `World of Warcraft/Interface/AddOns/`.  
3. Restart the game and enable the addon.

## Information  
- **Addon Version:** CF-HD v1.2.1  
- **Game Version:** 3.3.5a (WotLK)
- **Original Author:** kunda
- **Modified by:** Nobrainx, Khal
