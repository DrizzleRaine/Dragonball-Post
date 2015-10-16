mob
	var/randDir
	var/kbChance
	var/lastDir
	var/mob/grabbedMob
	var/mob/B
	var/mob/init_speed

	verb
		Attack(mob/M as mob in get_step(src,dir))
			set popup_menu = 0
			if (attacking == 0)
				attacking = 1
				if (rand(1,2) == 1)
					flick("Attack",src)
				else
					flick("Ishina",src)
				if (flying == 		1)
					icon_state = "Flight"
				else
					icon_state = ""
				kbChance = src.strength

				var/offroll = (roll(src.offense, 3) * rand(2, 10) / 10) * src.bp
				var/defroll = (roll(M.defense, 3) * rand(3, 12) / 10) * M.bp

				if (offroll >= defroll) // Accuracy algorithm
					NotifyWorld("[src.key] hit [M.key]! ([offroll] / [src.offense * 3 * src.bp] offense)  ([defroll] / [M.defense * 3 * 1.2 * M.bp] defense)")
					Hit(src, M, offroll, defroll)
				else // If they dodge
					if(prob(3)) // Lucky Strike
						Hit(src, M)
						NotifyWorld("Lucky Strike!")
						return

					flick("Zanzo",M)
					NotifyWorld("[src.key] missed [M.key]! ([offroll] / [src.offense * 3 * src.bp] offense)  ([defroll] / [M.defense * 3 * 1.2 * M.bp] defense)")

				sleep(50 / src.speed)
				attacking = 0


		Grab(mob/M as mob in get_step(src,dir))
			set popup_menu = 0
			world << "[src] grabs [M]!"
			M.grabbed = 1
			isGrabbing = 1
			grabbedMob = M

		Blast()
			if (attacking == 0)
				attacking = 1
				B = new /mob/blast(src.loc)
				walk(B,src.dir,0,0.1)
				if(Bump(B))
					del(B)
				src.icon_state = "Attack"
				sleep(2)
				src.icon_state = ""
				sleep(0)
				attacking = 0

	proc
		Throw(mob/M as mob in get_step(src,dir))
			world << "[src] throws [M]!"
			walk(M,src.dir,0,0)
			spawn(5)
			walk(M,0)
			src.isGrabbing = 0
			M.grabbed = 0
			grabbedMob = 0

		randomDir()
			randDir = pick (
			NORTH,
			SOUTH,
			EAST,
			WEST,
			NORTHEAST,
			NORTHWEST,
			SOUTHEAST,
			SOUTHWEST,
			)
	 	return randDir


		Hit(mob/a, mob/d)
			var/offroll = (roll(a.strength, 3) * rand(8, 10) / 10) * a.bp
			var/defroll = (roll(d.endurance, 3) * rand(8, 10) / 10) * d.bp

			d.c_health -= (offroll / defroll) * 5
			d.c_health -= (d.health / 1000)
			NotifyWorld("<font color = blue>[d.name] took [abs((offroll / defroll) * 5 - d.health / 1000)] damage!</font>")

			d.bp = (d.c_health / d.health) * base

			init_speed = d.speed
			if((offroll / defroll) * 5 > 5)
				d.speed = (offroll / defroll) * 10
				flick("KB",d)
				for(var/i in 1 to a.strength/d.endurance)
					walk(d,a.dir, 0, 32)
				spawn(2)
				walk(d,0, 0, 0)
				spawn(2)
				d.speed = init_speed
			if (warping == 1)
				a.Move(get_step(d,randomDir()))
				if (randDir != a.dir)
					flick("Zanzo",a)
				else
					a.icon_state = ""
			src.dir = (get_dir(a,d))

			sleep(100 / src.speed)
			attacking = 0

			return

