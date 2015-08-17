/obj/machinery/computer
	name = "computer"
	icon = 'computer.dmi'
	density = 1
	anchored = 1.0
	var/obj/item/weapon/circuitboard/circuit = null //if circuit==null, computer can't disassemble


	New()
		..()
		spawn(2)
			power_change()

	emp_act(severity)
		if(prob(20/severity)) set_broken()
		..()


	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				return
			if(2.0)
				if (prob(25))
					del(src)
					return
				if (prob(50))
					for(var/x in verbs)
						verbs -= x
					set_broken()
			if(3.0)
				if (prob(25))
					for(var/x in verbs)
						verbs -= x
					set_broken()
			else
		return

	power_change()
		if(!istype(src,/obj/machinery/computer/security/telescreen))
			if(stat & BROKEN)
				icon_state = initial(icon_state)
				icon_state += "b"

			else if(powered())
				icon_state = initial(icon_state)
				stat &= ~NOPOWER
			else
				spawn(rand(0, 15))
					//icon_state = "c_unpowered"
					icon_state = initial(icon_state)
					icon_state += "0"
					stat |= NOPOWER

	process()
		if(stat & (NOPOWER|BROKEN))
			return
		use_power(250)


	proc/set_broken()
		icon_state = initial(icon_state)
		icon_state += "b"
		stat |= BROKEN


	attackby(I as obj, user as mob)
		if(istype(I, /obj/item/weapon/screwdriver) && circuit)
			playsound(src.loc, 'Screwdriver.ogg', 50, 1)
			if(do_after(user, 20))
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/M = new circuit( A )
				A.circuit = M
				A.anchored = 1
				for (var/obj/C in src)
					C.loc = src.loc
				if (src.stat & BROKEN)
					user << "\blue The broken glass falls out."
					new /obj/item/weapon/shard( src.loc )
					A.state = 3
					A.icon_state = "3"
				else
					user << "\blue You disconnect the monitor."
					A.state = 4
					A.icon_state = "4"
				del(src)
		else
			src.attack_hand(user)
		return






