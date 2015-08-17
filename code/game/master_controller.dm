var/global/datum/controller/game_controller/master_controller //Set in world.New()
var/global/controllernum = "no"

datum/controller/game_controller
	var/processing = 1
	var/timeOfDay = 0
	var/minutesPerTick = 1

	proc
		setup()
		setup_objects()
		process()
		UpdateOutsideLight()
		GetStateOfDay()
		ChangeGlobalWeather()

	setup()
		if(master_controller && (master_controller != src))
			del(src)
			return
			//There can be only one master.

		if(!job_master)
			job_master = new /datum/controller/occupations()
			if(job_master.SetupOccupations())
				world << "\red \b Job setup complete"
				job_master.LoadJobs("config/jobs.txt")

		world.tick_lag = 0.9

		timeOfDay = 720 //start at noon

		setup_objects()

		setupgenetics()

		//syndicate_code_phrase = generate_code_phrase()//Sets up code phrase for traitors, for the round.
		//syndicate_code_response = generate_code_phrase()

		emergency_shuttle = new /datum/shuttle_controller/emergency_shuttle()

		globalweather = new /datum/weather/calm()

		for(var/area/area in world)
			area.UpdateTemperature(1)
			if(area == area.master)
				globalweather.areas += area

		if(!ticker)
			ticker = new /datum/controller/gameticker()

		spawn
			ticker.pregame()

	setup_objects()
		world << "\red \b Initializing objects"
		sleep(-1)

		for(var/obj/object in world)
			object.initialize()

		world << "\red \b Initializations complete."


	process()

		if(!processing)
			return 0
		controllernum = "yes"
		spawn (100) controllernum = "no"

		var/start_time = world.timeofday

		timeOfDay = (timeOfDay+minutesPerTick)%1440

		UpdateOutsideLight()
		if(timeOfDay == 480 || timeOfDay == 1200) //day/night switches
			for(var/area/area in world)
				area.UpdateTemperature(1)

		sleep(1)

		sleep(-1)

		for(var/mob/M in world)
			M.Life()

		sleep(-1)

		for(var/datum/disease/D in active_diseases)
			D.process()

		for(var/obj/machinery/machine in machines)
			if(machine)
				machine.process()
				if(machine && machine.use_power)
					machine.auto_use_power()

		for(var/datum/weather/weather in world)
			weather.Process()

		sleep(-1)
		sleep(1)

		for(var/obj/object in processing_objects)
			object.process()

		for(var/datum/powernet/P in powernets)
			P.reset()

//		for(var/area/area in world)//DEBUG; will later be moved to procs that change temp, so that the check is not run all the time
//			area.CalculateTemperature() //now only gets called when airlocks close/open, monkeys spawn/despawn, and weather changes (never happens yet)

		sleep(-1)

		ticker.process()

		sleep(world.timeofday+10-start_time)

		spawn process()

		return 1

	UpdateOutsideLight()
		switch(timeOfDay/60)
			if(-INFINITY to 4)
				sd_OutsideLight(0)
			if(4 to 6)
				sd_OutsideLight(2)
			if(6 to 8)
				sd_OutsideLight(4)
			if(8 to 10)
				sd_OutsideLight(6)
			if(10 to 16)
				sd_OutsideLight(7)
			if(16 to 18)
				sd_OutsideLight(6)
			if(18 to 20)
				sd_OutsideLight(4)
			if(20 to 22)
				sd_OutsideLight(2)
			if(22 to INFINITY)
				sd_OutsideLight(0)

	GetStateOfDay()
		return (timeOfDay/60 <= 20 && timeOfDay/60 >= 8) ? "day" : "night"

	ChangeGlobalWeather() //placeholder
		return