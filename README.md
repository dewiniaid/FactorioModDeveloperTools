# ModDeveloperTools

This is a set of rudimentary tools for mod developers, which may be expanded in the future.

Currently, there's an entity information panel and an item information panel, both of which are toggled with **F10** 
by default.

The entity information panel shows information on your currently selected entity, and the item information panel
shows information on your current cursor stack.

### 0.1.5 (2020-01-31)
 * Add a speculative fix for a case where GUI frames might not exist when they should, causing a crash.
   - This may cause the GUI frame to display in the wrong order, which can be fixed by toggling them off and back on 
     again.
 * Add a German translation, courtesy mrbesen and tiriscef.

### 0.1.4 (2019-02-27)
 * Add new entity and item prototype flags.
 * Fix a flag being renamed in 0.17.2 that caused all entity flags to report `**Error**`
 * Add `belt_speed`
 * List the technology required to unlock an item's recipes (or the item that builds an entity).
  
### 0.1.3 (2019-02-26)
 * Update for Factorio 0.17
 * Add `group`, `subgroup`, `order`, `fast_replaceable_group` and `collision_mask` to entity info.
 * Minor bugfixes.

### 0.1.2 (2018-10-26)
 * Add a new "magic map seed" feature.  If a new game is started and has this seed, all worldgen will be replaced with
   a pattern of lab tiles.  The default map seed for this feature is 701; it can be disabled by setting it to 0.
 * Add unit_number
 * Add some entity fields concerning connected rail.
 * Fix a possible desync issue.
 * Fix issue causing debugging to need to be toggled twice to be functional when loading a game.
 
### 0.1.1 (2018-10-25)
 
* Add more item fields
* Fix issue that broke the mod for everyone using it in a zip (oops...)

### 0.1.0 (2018-10-25)
 
* First release
