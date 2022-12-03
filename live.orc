instr livecode
    kph = phasor:k(0.4)
    keu = euclidian(3, 2, 19, 0, kph)
    keu2 = euclidian(2,7,7,0, kph)
    
    kbassnotes[] fillarray 1009, 1500, 1020
    khighnotes[] fillarray 3000, 3500, 4000, 4025, 5000
    
    kbass init 0
    khigh init 0

    if(keu ==  1 ) then 
        kbass = (kbass + 1) % lenarray(kbassnotes)
        kamp = random:k(0,1)
        kfreq = kbassnotes[kbass]
        printk2 kfreq
        schedulek("faust_instr", 0, 2, kamp, kfreq, 0)
    endif
    if(keu2 ==  1 ) then 
        khigh = (khigh+1) % lenarray(khighnotes)
        kamp = random:k(0,1)
        kfreq = khighnotes[khigh]
        printk2 kfreq
        schedulek("faust_instr", 0, 2, kamp, kfreq, 1)
    endif
endin
start("livecode")

instr chords
    kph_fq = 0.02;rspline:k(0.01, 0.1, 0.02, 0.1)
    kph = phasor:k(kph_fq)
    keu = euclidian(3, 5, 8, 0, kph)
    inum_notes init 5
    if(keu == 1) then 
        kfqinit = random:k(100, 300)
        kcnt = 0
        kfreq = random:k(100, 300)
        kdur = random:k(8, 50)
        while kcnt < inum_notes do
            kamp = 0.2
            kfreq = kfqinit * ((kcnt +1)*1.9)
            schedulek("faust_instr", 0, kdur, kamp, kfreq, random:k(0,1))
            kcnt += 1
        od
    endif
endin
start("chords")


instr bach
    gkpchs1[] fillarray 60, 64, 67, 72, 76, 67, 72, 76
    gkpchs2[] fillarray 60, 62, 69, 74, 77, 69, 74, 77
    kmet = metro:k(5)

    kpcharr[] = gkpchs2
    kindx init 0
    if(kmet == 1) then 
        kpch = kpcharr[kindx]
        kfq = mtof(kpch)
        schedulek("faust_instr", 0, 1, 0.2, kfq, random:k(0,1))
        kindx = (kindx+1) % lenarray(kpcharr)
    endif
endin
start("bach")