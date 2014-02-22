jldf
====

Miscellaneous scripts for Dwarf Fortress + dfhack

Dwarf Fortress: http://www.bay12games.com/dwarves/
DF Hack: https://github.com/DFHack/dfhack


To use these scripts, edit the makefile so that the paths point to the appropriate dfhack directory, then run `make` to copy the scripts over.


A few of the more useful scripts:

*jldf.lua*: A module containing miscellaneous helper functions shared by scripts. (Note that this goes in $DFHACK/lua, not scripts.)

*age.lua*: List dwarves by age. 

>     age >10 <13
> 
> Lists dwarves who are greater than 10 years old and less than 13.

*clothes.lua*: Inventory clothing by type and wear level, with an option to dump.

>     clothes XX
> 
> List counts of all clothes and mark anything with wear level XX for dumping.

*dumps.lua*: Inventory items marked for dumping. Give any argument to break down the list in greater depth.

*labors.lua*: List skill levels for active laborers. Not a replacement for Dwarf Therapist, but good for quickly checking up on things.

> Arguments:
> 
> * `<` -- List unit/labor pairs with level less than the given.
> * `>` -- List unit/labor pairs with level greater than the given.
> * `!` -- List unit/labor pairs with a demotion counter greater than the given.
> 
> Any other string is a search pattern.
> 
>     labors >11 <15 carp
> 
> List units active in carpentry with skill level from 12 to 14.

*legends.lua*: List legendary units. Also list non-legends and the skills they're best at.

*melts.lua*: Inventory items marked for melting.

*plants.lua*: Inventory agriculture and derived products.

*stocks.lua*: List contents of a stockpile in GUI, allowing you to dump, forbid, etc. items.

*textile.lua*: Inventory the textile industry (plants, thread, dye, cloth)

