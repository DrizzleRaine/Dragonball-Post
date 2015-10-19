#define OFF offense
#define DEF defense
#define STR strength
#define END endurance

mob
	Player

		var/turf/coords
		var/MapOn = 0
		var/sensePanel = 0
		var/mob/Player/senseTarget
		var/sparring = 0
		var/meditating = 0
		var/selfTraining = 0
		var/ableToMove = 1

		var/regeneration
		var/recovery
		var/energy
		var/c_energy



		New()
			bp = 10
			base = 10

			offense = 1.0
			defense = 1.0
			strength = 5.0
			endurance = 10.0
			health = 100
			c_health = health
			speed = 5.0

			regeneration = 1
			recovery = 1
			energy = 100
			c_energy = 100

			return ..()

		Stat()
			if(c_health < health)
				if(meditating)
					c_health += regeneration / 10
				else
					c_health += regeneration / 50
			else if(c_health > health)
				c_health = health

			if(c_energy < energy)
				if(meditating)
					c_energy += (recovery / 100) * energy
				else
					c_energy += (recovery / 500) * energy
			else if(c_energy > energy)
				c_energy = energy


			if(selfTraining)
				STR += 0.1
				END += 0.1

			usr << output("Health: [round(c_health)]%", "health")
			usr << output("Energy: [round(c_energy / energy * 100)]%", "energy")
			usr << output("Power: [round(bp / base * 100)]%", "power")

			stat("BP		    ","[commas(num2text(round(bp), 24))]")
			stat("Offense		","[round(offense)]")
			stat("Defense		","[round(defense)]");
			stat("Strength		","[round(strength)]");
			stat("Endurance		","[round(endurance)]");
			stat("Speed			","[round(speed)]");

			statpanel("Inventory")
			stat(new/obj/clothes/shirt, "Shirt")

			if(sensePanel && statpanel(senseTarget.name))
				stat(senseTarget)
				stat("BP		    ", "[commas(num2text(round(senseTarget.bp), 24))]")
				stat("Health		", "[round(senseTarget.c_health)]")

			sleep(10)

		Move()
			if(!ableToMove)
				return
			else
				. = ..()

		Click()
			var/mob/Player/M=usr
			if(!istype(M)) return

			if(M.senseTarget == src)
				M.sensePanel = !M.sensePanel
			if(M.senseTarget == null)
				M.sensePanel = 1

			M.senseTarget = src


			if(M.senseTarget == usr)
				M.sensePanel = 0
		verb
			Meditate()
				meditating = !meditating
				if(meditating)
					icon_state = "Meditate"
					ableToMove = 0
				else
					icon_state = ""
					ableToMove = 1

			Train()
				selfTraining = !selfTraining
				if(selfTraining)
					icon_state = "Train"
					ableToMove = 0
				else
					icon_state = ""
					ableToMove = 1

			XYZ_Teleport()
				var/holdx
				var/holdy
				var/holdz
				var/telex = 0
				var/teley = 0
				var/telez = 0
				telex = input("X Location", "X", telex)
				holdx = telex
				teley = input("Y Location", "Y", teley)
				holdy = teley
				telez = input("Z Location", "Z", telez)
				holdz = telez
				src.loc = locate(holdx, holdy, holdz)

				if(MapOn)
					for(var/MapObj/o in client.maps)
						del o
					client.maps = client.minimap_Place(10,10,11,11,locate(1,1,usr.z),locate(world.maxx,world.maxy,usr.z))

				for(var/MapObj/o in client.maps)
					o.Scan()

				src << output("[src.x], [src.y], [src.z]", "text")
			MiniMap()
				if(!MapOn)
					client.maps = client.minimap_Place(10,10,11,11,locate(1,1,usr.z),locate(world.maxx,world.maxy,usr.z))
					MapOn = 1
					src << output("Map on", "text")
					for(var/MapObj/o in client.maps)
						o.Scan()
				else
					for(var/MapObj/o in client.maps)
						del o
					MapOn = 0
					src << output("Map Off", "text")
			Say(msg as text)
				world << output("<font color =[fcolor]><b>[usr]</b></font>: [msg]", "text")
			Fly()
				if (flying == 1)
					flying = 0
					icon_state = ""
				else
					flying = 1
					icon_state = "Flight"
			Warping()
				if (warping == 1)
					warping = 0;
					usr << "Warping off"
				else if (warping == 0)
					warping = 1;
					usr << "Warping on"

			Red_Text()
				fcolor = "#FF0000"

			Teleport(mob/Player/M as mob in world)
				src.loc = locate(M.x, M.y, M.z)
				usr << output("X:[M.x] Y:[M.y] Z:[M.z]", "text")

			Summon(mob/Player/M as mob in world)
				M.loc = locate(src.x, src.y, src.z)

			Heal(mob/Player/M as mob in world)
				M.c_health = M.health
				M.bp = M.base


			Edit(mob/M as mob in world)
				var/pick_stat = input("Edit") in list("BP", "Offense","Defense", "Strength", "Endurance", "Speed");
				switch(pick_stat)
					if("BP")
						M.bp = input("Set [pick_stat] to what value?", "Value", M.base)
					if("Offense")
						M.offense = input("Set [pick_stat] to what value?", "Value", M.offense)
					if("Defense")
						M.defense = input("Set [pick_stat] to what value?", "Value", M.defense)
					if("Strength")
						M.strength = input("Set [pick_stat] to what value?", "Value", M.strength)
					if("Endurance")
						M.endurance = input("Set [pick_stat] to what value?", "Value", M.endurance)
					if("Speed")
						M.speed = input("Set [pick_stat] to what value?", "Value", M.speed)

			Wear()
				src.overlays += new/obj/clothes/shirt
			Remove()
				src.overlays -= new/obj/clothes/shirt

			Spar_Mode()
				src.sparring = !src.sparring

			RegenMap()
				var/holdmap
				var/map = ""

				map = input("Map", "Map", map)
				holdmap = map

				world.ClearMap(SwapMaps_Find(holdmap))
				NotifyWorld("Loading...")
				sleep(1)
				world.MapGen(SwapMaps_Find(holdmap))
				gblGameOn = 1
				NotifyWorld("Complete.")
				for(var/MapObj/o in client.maps)
					o.Scan()
			TestSave()
				var/i
				/*
				var/holdmap
				var/map = ""
				var/swapmap/sm

				map = input("Map", "Map", map)
				holdmap = map

				sm = SwapMaps_Find(holdmap)

				var/savefile/F = new("saves/[ckey].sav")
				var/txtfile = file("players/[ckey].txt")

				F[ckey] << usr

				fdel(txtfile)
				F.ExportText("/",txtfile)
				*/
				for(i=0, i<2, i++)
					var/swapmap/sm
					sm = SwapMaps_Find("[i + 1]")
					if(sm != null)
						if(SwapMaps_SaveChunk("chunk[i]", sm.LoCorner(), locate(500, 500, sm.z1)))
							if(i > chunks)
								chunks += 1
							src << output("Chunk [i] saved", "text")

			TestLoad()
				var/i
				var/swapmap/sm=new("3", 1000, 1000, 1)
				for(i=0, i<2, i++)
					if(SwapMaps_LoadChunk("chunk[i]", locate(sm.x1 + (500 * i), sm.y1, sm.z1)))
						sleep(1)
						src << output("Chunk [i] loaded succesfully", "text")
					if(SwapMaps_LoadChunk("chunk[i]", locate(sm.x1 + (500 * i), sm.y1 + 500, sm.z1)))
						sleep(1)
						src << output("Chunk [i] loaded succesfully", "text")

		Login()
			return