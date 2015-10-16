/*
	Based on source code by Gughunter

	ZackBleus Terrain Generator
*/




#define MAP_AREA (world.maxx / 5 * world.maxy / 5)

#define MAX_LANDBOTS_PER_SEED 100
#define MAX_ISLAND_LANDBOTS_PER_SEED 10
#define SEED_FACTOR (10 / MAP_AREA)

#define PERCENT_GREENERY 0.10
#define GREENERY_RANDOM 0.10
#define PERCENT_LAND 4

#define PERCENT_ISLAND 0.8


#define MAP_SCALE world.maxx / 100

#define SEEDS round(MAP_AREA * SEED_FACTOR, 1)
#define LAND_TILES (MAP_AREA * PERCENT_LAND)
#define ISLAND_TILES (MAP_AREA * PERCENT_ISLAND)
#define EXPANSIONS (LAND_TILES) - SEEDS

#define ISLAND_EXPANSIONS (ISLAND_TILES) - SEEDS
#define ISLAND_SEEDS round(MAP_AREA * SEED_FACTOR, 1)

#define GREENERY_TILES LAND_TILES * PERCENT_GREENERY








var/gblGameOn = 0 //you could use this to check whether players can move/act while map generates
var/list/cardinalDirs = list(1, 2, 4, 8)
var/last_time = 0;

var/edgeRadius = world.maxx / 100

var/list/turfList


world

	turf = /turf/water


	New()
		. = ..()
		spawn(2)
			//var/swapmap/map=new("1", 500, 500, 1)
			//setWorldSize(500)
			NotifyWorld("Loading...")
			sleep(1)
			//MapGen(map)
			gblGameOn = 1
			NotifyWorld("Complete.")


/*
mob/verb/map()
	//display a scaled-down text map
	var/scale = MAP_SCALE
	var/outStr = ""

	for(var/cury in world.maxy to 1 step (- scale))
		outStr += "<font face=\"Courier New\">"
		for(var/curx in 1 to world.maxx step scale)
			if(locate(/turf/ground/) in \
			block(locate(curx, cury, 1), locate(curx + scale - 1, cury - scale + 1, 1)))
				outStr += "'"

			else outStr += " "

		outStr += "</font><br>"

	usr << output(outStr, "text")
*/


proc/setWorldSize(size)
	world.maxx = size
	world.maxy = size
	edgeRadius = world.maxx / 100



obj/helper
	landbot
		proc/Roam()
			var/newDir = pick(cardinalDirs)
			var/turf/T = get_step(src, newDir)
			if(T)
				loc = T

				if(istype(T, /turf/water))
					if(rand() > 0.1)
						T = new /turf/ground/dirt(T)
						return 1



world



	proc/MapGen(swapmap/M)
		CreateLand(M.z1)
		CreateIslands(M.z1)
		CreateGreenery(M.z1)
		Cleanup(M.z1)
		CreateCliffs(M.z1)
		Cleanup(M.z1)
		WaterRadius(M.z1)
		CreateEdges(M.z1)
		TurfList(M.z1)



	proc/CreateLand(z)
		//world << output("<font color=red><b>Initial</b></font> [world.time - last_time] s", "text")
		last_time = world.time - last_time
		var
			list/landbots = list()
			turf/T
			obj/helper/landbot/lbot

		for(var/i in 1 to SEEDS)
			//make a new single continent
			while(1)
				T = locate(rand(1, world.maxx - edgeRadius), rand(1, world.maxy - edgeRadius), z)
				if(istype(T, /turf/ground/dirt)) continue
				else
					T = new /turf/ground/dirt(locate(T.x, T.y, z))
					for(var/botCount in 1 to rand(1, MAX_LANDBOTS_PER_SEED))
						lbot = new(T)
						landbots += lbot
					break

		//add on to existing continents
		for(var/j in 1 to EXPANSIONS)
			while(1)
				lbot = pick(landbots)
				if(lbot.Roam()) break

		for(lbot in landbots) del lbot

	proc/CreateIslands(z)
		//world << output("<font color=red><b>Islands</b></font> [world.time] s", "text")
		var
			list/landbots = list()
			turf/T
			obj/helper/landbot/lbot

		for(var/i in 1 to ISLAND_SEEDS)
			//make a new single island
			while(1)
				T = locate(rand(1, world.maxx - edgeRadius), rand(1, world.maxy - edgeRadius), z)
				if(istype(T, /turf/ground/dirt)) continue
				else
					T = new /turf/ground/dirt(locate(T.x, T.y, z))
					for(var/botCount in 1 to rand(1, MAX_ISLAND_LANDBOTS_PER_SEED))
						lbot = new(T)
						landbots += lbot
					break

		//add on to existing islands
		for(var/j in 1 to ISLAND_EXPANSIONS)
			while(1)
				lbot = pick(landbots)
				if(lbot.Roam()) break

		for(lbot in landbots) del lbot

	proc/CreateCliffs(z)
		//world << output("<font color=red><b>Cliffs</b></font> [world.time - last_time] s", "text")
		last_time = world.time - last_time
		var/turf/T
		var/_y = 0
		var/_x = 0
		var/i = world.maxx * world.maxy

		while(i)
			i--

			_x += 1

			if(_x == world.maxx - edgeRadius)
				_x = 1
				_y += 1

			T = locate(_x, _y, 1)

			if(istype(T, /turf/ground))
				if(istype(get_step(T,SOUTH), /turf/water))
					PlaceCliff(locate(T.x, T.y-1, z))

	proc/CreateEdges(z)
		//world << output("<font color=red><b>Edges</b></font> [world.time - last_time] s", "text")
		last_time = world.time - last_time
		var/turf/T
		var/_y = 0
		var/_x = 0
		var/i = world.maxx * world.maxy

		while(i)
			i--

			_x += 1

			if(_x == world.maxx - edgeRadius)
				_x = 1
				_y += 1

			T = locate(_x, _y, z)

			if(istype(T, /turf/ground))

				if(istype(get_step(T,NORTH), /turf/water))
					PlaceEdge(locate(T.x, T.y, z), "N")
				if(istype(get_step(T,EAST), /turf/water))
					PlaceEdge(locate(T.x + 1, T.y, z), "W")
				if(istype(get_step(T,WEST), /turf/water) && !istype(locate(T.x - 2, T.y, z), /turf/ground))
					PlaceEdge(locate(T.x - 1, T.y, z), "E")


			if(istype(T, /turf/water))

				if(istype(get_step(T,EAST), /turf/ground))
					if(istype(get_step(T,WEST), /turf/ground))
						PlaceEdge(locate(T.x, T.y, z), "WE")




	proc/Cleanup(z)
		//world << output("<font color=red><b>Cleanup</b></font> [world.time - last_time] s", "text")
		last_time = world.time - last_time
		var/turf/T
		var/_y = 0
		var/_x = 0
		var/i = world.maxx * world.maxy

		while(i)
			i--

			_x += 1

			if(_x == world.maxx - edgeRadius)
				_x = 1
				_y += 1

			T = locate(_x, _y, z)

			if(istype(T, /turf/ground/grass))
				if(istype(get_step(T,NORTH), /turf/ground/dirt))
					if(istype(get_step(T,SOUTH), /turf/ground/dirt))
						PlaceOneGreenery(locate(T.x, T.y-1, z))

			if(istype(T, /turf/ground/grass))
				if(istype(get_step(T,EAST), /turf/ground/dirt))
					if(istype(get_step(T,WEST), /turf/ground/dirt))
						PlaceOneGreenery(locate(T.x-1, T.y, z))

			if(istype(T, /turf/water))
				if(istype(get_step(T,NORTH), /turf/ground))
					if(istype(get_step(T,SOUTH), /turf/ground))
						if(istype(get_step(T,EAST), /turf/ground))
							if(istype(get_step(T,WEST), /turf/ground))
								PlaceDirt(T)

			if(istype(T, /turf/ground/cliff))
				if(istype(get_step(T,NORTH), /turf/ground/dirt))
					if(istype(get_step(T,SOUTH), /turf/ground/dirt))
						PlaceOneGreenery(locate(T.x, T.y, z))





	proc/CreateGreenery(z)
		//world << output("<font color=red><b>Greenery</b></font> [world.time - last_time] s", "text");
		last_time = world.time - last_time
		var/turf/T

		//sprinkle some random greenery around
		for(var/i in 1 to GREENERY_TILES * GREENERY_RANDOM)
			while(1)
				T = locate(rand(1, world.maxx), rand(1, world.maxy), z)
				if(!istype(T, /turf/ground/dirt)) continue

				PlaceOneGreenery(T)
				break;

		//put the rest of the greenery adjacent to the existing stuff ("clumping" effect)
		for(var/i in 1 to GREENERY_TILES * (1 - GREENERY_RANDOM))
			while(1)
				T = locate(rand(1, world.maxx), rand(1, world.maxy), z)
				if(!istype(T, /turf/ground/dirt)) continue

				if((locate(/turf/ground/grass) in oview(T, 1)))
					PlaceOneGreenery(T)
					break;

	proc/PlaceDirt(turf/T)
		T = new /turf/ground/dirt(T)

	proc/PlaceOneGreenery(turf/T)
		T = new /turf/ground/grass(T)

	proc/PlaceCliff(turf/T)
		T = new /turf/ground/cliff(T)

	proc/PlaceEdge(obj/T, state)
		T.icon_state = state
		T.overlays += new/obj/edge

	proc/PlaceWater(turf/T)
		T = new /turf/water(T)


	proc/WaterRadius(z)
		//world << output("<font color=red><b>Water Radius</b></font>", "text")
		var/turf/T
		var/_y = 0
		var/_x = 0
		var/i = world.maxx * world.maxy

		while(i)
			i--


			if(_x >= world.maxx - edgeRadius || _x <= edgeRadius)
				T = locate(_x, _y, z)
				if(T != null)
					PlaceWater(T)
					//world << output("[_x], [_y]", "text")

			if(_y >= world.maxy - edgeRadius || _y <= edgeRadius)
				T = locate(_x, _y, z)
				if(T != null)
					PlaceWater(T)
					//world << output("[_x], [_y]", "text")

			//world << output("[_x], [_y]", "text")

			_x += 1

			if(_x == world.maxx)
				_x = 1
				_y += 1


	proc/ClearMap(swapmap/M)
		world << output("\n<font color=purple><b>Clearing Map...</b></font>", "text")
		last_time = world.time - last_time
		var/turf/T
		var/_y = 0
		var/_x = 0
		var/i = world.maxx * world.maxy

		while(i)
			i--

			_x += 1

			if(_x == world.maxx)
				_x = 1
				_y += 1

			T = locate(_x, _y, M.z1)
			if(T != null)
				PlaceWater(T)


	proc/TurfList(z)
		var/turf/T
		var/_y = 0
		var/_x = 0
		var/i = world.maxx * world.maxy

		turfList = new/list()

		while(i)
			i--

			_x += 1

			if(_x == world.maxx)
				_x = 1
				_y += 1

			T = locate(_x, _y, z)
			turfList.Add(T)


proc/NotifyWorld(T)
	last_time = world.time;
	world << output("<font color=red><b>[T]</b></font>", "text")


turf
	ground
		dirt
			icon = 'dirt.dmi'
			MapColor=rgb(0,200,0)

		grass
			icon = 'grass.dmi'
			MapColor=rgb(0,155,0)
		cliff
			icon = 'cliff.dmi'
			density = 1;
			MapColor=rgb(102,51,0)

	water
		icon = 'water.dmi'
		MapColor=rgb(0,0,155)

obj
	edge
	icon = 'edges.dmi'

