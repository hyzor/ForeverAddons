# WoW Forever Addons

A collection of addons for **World of Warcraft: Forever** (client 1.60.1).

WoW Forever runs on the **Mainline (retail) UI stack** — internally it is Mainline with a
`Camelot` game overlay — so addons for this client use the modern addon API, not the
Classic one. Practically that means retail addon code usually runs unchanged; what differs
is the interface number in the `.toc`.

## Addons

| Addon | What it does | Interface |
| --- | --- | --- |
| [ForeverUIScale](ForeverUIScale/) | Pushes the global UI scale below Blizzard's slider floor — useful on 1440p and 4K displays. Slider, exact-value box, presets and `/uis`. | `16001`, `120105`, `120000` |

## Install

Each addon lives in its own top-level folder that contains its `.toc`. Copy **that folder**
(not the repository root) into your AddOns directory:

```
World of Warcraft\_forever_\Interface\AddOns\
```

So you end up with `...\Interface\AddOns\ForeverUIScale\ForeverUIScale.toc`. The folder
name must match the `.toc` file name or the client will not see the addon.

Restart the client if you had to create the `Interface` or `AddOns` folder yourself, then
enable the addon in the AddOns list at the character screen.

## Interface versions

| Client | Interface |
| --- | --- |
| WoW Forever 1.60.x | `16001` |
| Midnight 12.1.5 (retail) | `120105` |
| Midnight 12.0.x (retail) | `120000` |

To check what your own client wants, run this in game:

```
/dump select(4, GetBuildInfo())
```

If an addon is flagged out-of-date, its `.toc` does not list your client's number — add it
to the comma-separated `## Interface:` line rather than ticking "Load out of date AddOns".

## Repository layout

```
ForeverAddons/
├── README.md            ← this file
├── .gitattributes       ← pins LF line endings
├── .gitignore
└── ForeverUIScale/
    ├── ForeverUIScale.toc
    └── ForeverUIScale.lua
```

## Policy

**Everything in this repository is code written for it.** Addons by other authors are
linked, not copied — vendoring someone else's addon here would make this collection a
redistribution, and most CurseForge addons are "All Rights Reserved". If an addon exists
elsewhere and is worth recommending, it gets a line in a list, not a folder.

## Credits

- **ForeverUIScale** — the concept of an addon that scales the UI below Blizzard's minimum
  predates this repository. [LowerUIScale](https://www.curseforge.com/wow/addons/loweruiscale)
  by **zamtin** is an earlier take on the same idea and is credited as prior art.
  ForeverUIScale is an independent implementation and shares no code with it.
- **Interface numbers and TOC mechanics** — documented by the
  [Warcraft Wiki TOC format](https://warcraft.wiki.gg/wiki/TOC_format).

## Notes

- Addons here read no combat, aura or unit data, so Midnight's secret-value restrictions do
  not affect them. Anything that needs to *decide* based on combat events cannot be written
  for this client the way Classic addons were.
- Forever installs to `_forever_`, not `_retail_`. The closed beta used `_classic_beta_`;
  the full game only reads its own folder.
