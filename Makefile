
DFHACK=/Applications/Games/DwarfFortress.app/Contents/Resources/hack
SCRIPTDEST=${DFHACK}/scripts/jl
LIBDEST=${DFHACK}/lua

main:
	cp lua/*.lua ${LIBDEST}
	cp scripts/*.lua ${SCRIPTDEST}

