T:
	if n >= 2,  goto recur
	else store c in v0

recur:
	implement 2*T(n/2,c) + c*n:
	save n in stack
	sra is for n >> 1
	jump and link to T to calculate T(n/2)
	sll is for T(n/2) << 1
	retrieve n from stack
	use mult and mflo for c*n
	add 2*T(n/2) + c*n and store it in v0
