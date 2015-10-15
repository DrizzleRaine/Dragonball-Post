var
	const   // constants
	ACTION_RATE = 10 // how high the accumulator must go to allow movement
	NO_ACTION = 0
mob
	var
		action_speed = 5 // rate the mob's accumulator increases
		action_count = 0
		tmp
			action = 0 // stores the direction the player wants to move
			 // the movement accumulator

	New()
		..() // perform the default New()
		spawn(1) lifecycle() // begin the lifecycle loop

	proc
		lifecycle()
			action_count += action_speed
			if(action_count >= ACTION_RATE)
				action_count -= ACTION_RATE

                // perform movement/action here
                // I will provide more interesting methods
                // of movement later in this article
				if(action && !src.grabbed)
					step(src,action)

				if(action && src.isGrabbing)
					throw(grabbedMob)

				action = NO_ACTION  // reset the action
			spawn(1) lifecycle() // repeat the lifecycle in one tick

// override client directions to use the action
client
	North()
		mob.action = NORTH
	South()
		mob.action = SOUTH
	East()
		mob.action = EAST
	West()
		mob.action = WEST
	Northeast()
		mob.action = NORTHEAST
	Northwest()
		mob.action = NORTHWEST
	Southeast()
		mob.action = SOUTHEAST
	Southwest()
		mob.action = SOUTHWEST