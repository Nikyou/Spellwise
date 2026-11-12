## Download link

https://www.curseforge.com/wow/addons/spellwise

## Introduction

**Spellwise** adds lines to spell tooltips in Forever. They show what a spell does for its time and cost:

* **DPS** - damage per second
* **DPM** - damage per mana
* **HPS** - healing per second
* **HPM** - healing per mana

The numbers come from the tooltip, so your gear bonuses are included.

## Usage

* `/sp` (or `/spw`, `/spellwise`) - open the settings
* `/sp reset` - move the settings window to the middle of the screen
* `/sp help` - list all commands
* Minimap button and addon compartment - open the settings
* Hold **Shift** on a spell to see how the numbers are worked out. The Details tab sets the key and which lines show.

## Key Features

* DPS, DPM, HPS and HPM, each with its own option.
* DoTs and HoTs get their own line, like "DoT: 3.3   DPM: 1.43". Spells with both parts also get a "Total per cast" line.
* Channeled spells use their channel time.
* Absorbs, spells that damage and heal, charges and attacking totems work too. Area spells show the value per target.
* The direct part is divided by the cast time, at least the global cooldown. You can use the cooldown instead when it's longer.
* "Include crit" (off by default) adds your crit chance and crit talents. The details also show targets up to 3 levels higher.
* Values per rage, energy and focus (DPR, DPE, DPF), and a cost line in percent, amount or both.
* Costs update on every hover. A free cast (Clearcasting) shows "DPM: Free". Druid forms don't change DPM.
* Works on action bars (macros too), in the spellbook and on other spell tooltips. Each can be turned off.
* Pet abilities, with their own options.
* Finishers use the number of combo points you pick (5 by default). The details list every number.
* Execute and Ferocious Bite: the details show what extra rage or energy deals.
* Spell rules: hide a spell's lines or set its average damage. Use the Spell rules tab or `/sp hide`, `/sp pin` and `/sp show`.
* Colours, school tint, font, size, outline, decimals and thousands separator, with a live preview.
* Profiles with export and import.

## Notes

* Weapon abilities (Heroic Strike, Sinister Strike) are skipped. Their damage isn't in the tooltip.
* A finisher's DPS doesn't count the time spent building combo points.
* Hit chance and resistances aren't counted. Crit isn't counted for totems. Pets use your crit.

## Localisation

Spellwise works in every Forever language: English, German, French, Spanish, Portuguese, Russian, Korean and Chinese.

If a number looks wrong in your language:

1. Type `/sp dump all`.
2. Wait until the spells finish loading.
3. Press Ctrl+A, then Ctrl+C. Paste the text into a GitHub issue or send it to me on Discord.

To improve a translation, open a pull request on [GitHub](https://github.com/Nikyou/Spellwise/pulls).

## Issues & Feedback

Found a bug or have an idea? Open an issue on [GitHub](https://github.com/Nikyou/Spellwise/issues) or message me on Discord.

💬 Discord: Nikyou ☕ Support: [buymeacoffee.com/nikyou](https://buymeacoffee.com/nikyou)
