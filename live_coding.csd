<CsoundSynthesizer>
<CsOptions>
-odac 
--port=10000
</CsOptions>
; ==============================================
<CsInstruments>

sr      =       48000
ksmps   =       32
nchnls =       2
0dbfs   =       1

#include"udo.orc"

gifaust_instr faustcompile {{
    import("stdfaust.lib");
    freq = hslider("freq", 100, 80, 5000, 0.1) : si.smoo;
    amp = hslider("amp", 0.3, 0, 1, 0.01) : si.smoo;
    cutoff = hslider("cutoff", 1,0,1, 0.01) : si.smoo;
    sig = os.sawtooth(freq) + os.osc(freq*0.5) + os.square(freq*0.125)*0.1;
    filtered = sig : ve.korg35LPF(cutoff, 4) : fi.dcblocker;
    process = filtered * amp;
}}, "-vec -lv 1", 0

instr faust_instr 
    iinst faustdsp gifaust_instr
    asig faustplay iinst
    
    kamp init p4
    kfq init p5

    kenv = expseg(1.01, p3, 0.01) - 0.01
    kcut = kenv * 0.7 + 0.3

    faustctl iinst, "freq", kfq
    faustctl iinst, "amp", kamp
    faustctl iinst, "cutoff", kcut

    asig *= 0.1 * kenv
    
    ipan init p6
    a1, a2 pan2 asig, ipan
    outs a1, a2
endin

</CsInstruments>
; ==============================================
<CsScore>
f 0 z

;i "chords" 0 -1 5

</CsScore>
</CsoundSynthesizer>
