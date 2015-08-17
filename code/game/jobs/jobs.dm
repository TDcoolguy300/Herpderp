var/const
	CIVILIAN	=(1<<2)

	LEADER			=(1<<0)
	LOGKEEPER		=(1<<1)
	MECHANIC		=(1<<2)
	CHEF			=(1<<3)
	RESEARCHER		=(1<<4)
	ASSISTANT		=(1<<13)

/proc/guest_jobbans(var/job)
	return	// ((job in command_positions) || (job in nonhuman_positions) || (job in security_positions))
