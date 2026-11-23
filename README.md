## Download link

https://www.curseforge.com/wow/addons/spellwise

## Introduction

**Spellwise** adds lines to spell tooltips in Forever. They show what a spell does for its time and cost:

* **DPS** - damage per second
* **DPM** - damage per mana
* **HPS** - healing per second
* **HPM** - healing per mana

Rage, energy and focus get DPR, DPE and DPF. The numbers come from the tooltip, so your gear bonuses are included.

## Usage

* `/sp` (or `/spw`, `/spellwise`) - open the settings. The minimap button and addon compartment do too.
* `/sp reset` - move the settings window to the middle of the screen
* `/sp help` - list all commands

Hold **Shift** on a spell to see how the numbers are worked out. The Details tab sets the key and which lines show.

## Key Features

### Spells

DoTs and HoTs get their own line, like "DoT: 3.3   DPM: 1.43", and spells with both parts also get a "Total per cast" line. Channeled spells use their channel time. The direct part is divided by the cast time, at least the global cooldown, or by the cooldown when it's longer if you want.

Absorbs, spells that damage and heal, charges and attacking totems work too. Area spells show the value per target.

"Include crit" (off by default) adds your crit chance and crit talents. The details also show targets up to 3 levels higher.

### Costs

Costs update on every hover. A free cast (Clearcasting) shows "DPM: Free", and druid forms don't change DPM. You can add a cost line in percent, amount or both.

### Weapons

Weapon abilities like Mortal Strike, Backstab and Aimed Shot use your weapon damage and attack power. Attack, Auto Shot and wand Shoot show your weapons' DPS.

Heroic Strike, Cleave, Maul and Raptor Strike show "Added DPS" and per rage on what they add to your swing, plus "Total DPS" if you want it. Shaman imbues and rogue poisons show the DPS they add. Poisons show it on the item, for each hand.

### Finishers and pets

Finishers use the number of combo points you pick (5 by default), and the details list every number. For Execute and Ferocious Bite the details show what extra rage or energy deals. Pet abilities have their own options.

### Settings

Every line can be turned on or off, and so can each place: action bars (macros too), the spellbook and other spell tooltips. Spell rules hide a spell's lines or set its average damage, from the Spell rules tab or with `/sp hide`, `/sp pin` and `/sp show`.

You can change colours, school tint, font, size, outline, decimals and thousands separator with a live preview. Profiles can be exported and imported.

## Notes

Hit chance and resistances aren't counted, and weapon damage is before the target's armor. Weapon abilities need a weapon in the hand they use. Imbues and poisons only count procs from auto attacks, though abilities can proc them too. Seals are skipped. A finisher's DPS doesn't count the time spent building combo points. Pets use your crit.

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
