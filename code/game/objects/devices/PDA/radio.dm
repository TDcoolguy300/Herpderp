/obj/item/radio/integrated
	name = "PDA radio module"
	desc = "An electronic radio system of nanotrasen origin."
	icon = 'module.dmi'
	icon_state = "power_mod"
	var/obj/item/device/pda/hostpda = null

	var/on = 0 //Are we currently active??
	var/menu_message = ""

	New()
		..()
		if (istype(loc.loc, /obj/item/device/pda))
			hostpda = loc.loc

	proc/post_signal(var/freq, var/key, var/value, var/key2, var/value2, var/key3, var/value3, s_filter)

		//world << "Post: [freq]: [key]=[value], [key2]=[value2]"
		var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)

		if(!frequency) return

		var/datum/signal/signal = new()
		signal.source = src
		signal.transmission_method = 1
		signal.data[key] = value
		if(key2)
			signal.data[key2] = value2
		if(key3)
			signal.data[key3] = value3

		frequency.post_signal(src, signal, filter = s_filter)

	proc/print_to_host(var/text)
		if (isnull(src.hostpda))
			return
		src.hostpda.cart = text

		for (var/mob/M in viewers(1, src.hostpda.loc))
			if (M.client && M.machine == src.hostpda)
				src.hostpda.cartridge.unlock()

		return

	proc/generate_menu()

/obj/item/radio/integrated/signal
	var/frequency = 1457
	var/code = 30.0
	var/last_transmission
	var/datum/radio_frequency/radio_connection

	New()
		..()
		if(radio_controller)
			initialize()

	initialize()
		if (src.frequency < 1441 || src.frequency > 1489)
			src.frequency = sanitize_frequency(src.frequency)

		set_frequency(frequency)

	proc/set_frequency(new_frequency)
		radio_controller.remove_object(src, frequency)
		frequency = new_frequency
		radio_connection = radio_controller.add_object(src, frequency)

	proc/send_signal(message="ACTIVATE")

		if(last_transmission && world.time < (last_transmission + 5))
			return
		last_transmission = world.time

		var/time = time2text(world.realtime,"hh:mm:ss")
		var/turf/T = get_turf(src)
		lastsignalers.Add("[time] <B>:</B> [usr.key] used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]")

		var/datum/signal/signal = new
		signal.source = src
		signal.encryption = code
		signal.data["message"] = message

		radio_connection.post_signal(src, signal)

		return
