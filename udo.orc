/*
	Start and kill utilities
*/

instr KillImpl
  Sinstr = p4
  if (nstrnum(Sinstr) > 0) then
    turnoff2(Sinstr, 0, 0)
  endif
  turnoff
endin

opcode kill, 0, S
	Sinstr xin
	schedule("KillImpl", 0, .05, Sinstr)
endop

opcode start, 0, S
	Sinstr xin
	if (nstrnum(Sinstr) > 0) then
		kill(Sinstr)
		schedule(Sinstr, ksmps / sr, -1)
	endif
endop

opcode nst, i, Si
	Sname, ifrac xin
	iinst = nstrnum(Sname) + ifrac
	xout iinst
endop

/*
	Rhythm UDOS 
*/

opcode euclidian, k, kkkkk
        konset, kdiv, kpulses, krot, kphasor xin

        kph = int( ( ( (kphasor + krot)  * kdiv) / 1) * kpulses)
        keucval = int((konset / kpulses) * kph)
        kold_euc init i(keucval)
        kold_ph init i(kph)

        kres = ((kold_euc != keucval) && (kold_ph != kph)) ? 1 : 0

        kold_euc = keucval
        kold_ph = kph

        printk2 kres
        xout kres
endop
