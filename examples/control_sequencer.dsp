import("stdfaust.lib");

amp = hslider("amp", 0.2, 0, 1, 0.01);
speed = hslider("speed", 1, 0.1, 10, 0.01) : si.smoo;

SIZE = 8;

ctl_sequencer = steps : sum(n, SIZE, res(_,n))
with {
    steps = hgroup("steps", par(n, SIZE, checkbox("%n")));
    beat = ba.beat(speed*60);
    incr = _~+(beat), SIZE : %;
    res(sig, n) = sig : *(incr==n) : *(beat);
};

trigger = steps : par(i,SIZE, _<: (_>_@1) : _) :> 1-_ ;
playhead = (1:+~_*trigger: _*1); // _*1 is speed

bt = ctl_sequencer : en.ar(0,0.2);

process = os.sawtooth(100) * amp * bt;

