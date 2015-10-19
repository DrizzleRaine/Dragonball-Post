/*
	These are simple defaults for your project.
 */

/var/global/chunks = 0

world
	fps = 24		// 24 frames per second
	icon_size = 32	// 32x32 icon size by default

	view = 6		// show up to 6 tiles outward from center (13x13 view)


client
	var/maps
	var/swapmap/map=new("1", 500, 500, 1)
	var/swapmap/map2=new("2", 500, 500, 1)
	New()

		// This draws the map on the screen and scans the entire map.
		maps = null
		for(var/MapObj/o in maps)
			o.Scan()

		swapmaps_mode = 1

		var/mob/Player/M = new;
		M.loc = locate(5, 5, 1);
		M.key = src.key;
		M.name = src.key;
		NotifyWorld("[M.name]")
		//M = src;

		return ..()

	Move()
		. =..()
		// When the mob moves, we have to make all the maps on his screen rescan


mob
	step_size = 32;
	icon = 'player.dmi'

	MapColor=rgb(0,255,255)

	Login()
		var/mob/Player/M = new;
		M.loc = locate(5, 5, 1);
		//M.key = src.key;
		M.client = src.client;
		M.name = src.ckey;
		NotifyWorld("[M.name]")
		//M = src;
		..()

	Logout()
		del src;

	var/grabbed = 0
	var/isGrabbing = 0
	var/fcolor = "#555555"
	var/attacking = 0
	var/warping = 0
	var/flying = 0
	var
		bp = 1
		base = 1
		offense = 1
		defense = 1
		strength = 1
		endurance = 1
		health = 100
		c_health = 100
		speed = 1

	dummy
		icon = 'player.dmi'
		AttackAI()
	blast
		icon = 'blast.dmi'
		density = 0
		speed = 500
		New()
			..()
			pixel_y = rand(-16,16)
			pixel_x = rand(-16,16)
			spawn(10)
			del src

	proc
		AttackAI()
			usr << "Hi"
			src.dir = (get_dir(src,src))
			//spawn(10) Attack()









turf
	floor
		icon = 'floor.dmi'
	wall
		icon = 'wallDOOR.dmi'
		density = 1;
		opacity = 1;
	foundation
		icon = 'foundation.dmi'
		density = 1;
turf/Click()
	var/preDir = usr.dir
	usr.icon_state = "Zanzo"
	preDir = usr.dir
	sleep(2)
	usr.Move(src)
	usr.dir = preDir
	usr.icon_state = ""


proc/commas(T)
    // Account for decimals
    var/result=""
    var/dotpos=findtext(T,".")
    if (dotpos)
        result=copytext(T,dotpos)
        T=copytext(T,1,dotpos)
    // Insert commas
    var/addednum=0
    while(length(T))
        if (addednum && T!="-" && T!="+") result="'"+result
        addednum=1
        result=copytext(T,max(1,length(T)-2))+result
        T=copytext(T,1,max(1,length(T)-2))
    return result