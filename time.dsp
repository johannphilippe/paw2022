
simple_metro(fq) = (_, ma.SR/fq : fmod) ~+(1.0) : <=(1.0);

// Better implementation
metro_impl(fq, phase) = incr<=1.0
with {
    offset = (1.0-phase) * smps;
    incr = _~+(1.0) : +(offset) : _,smps : fmod;
    smps = ma.SR/fq; 
};

metro(fq) = metro_impl(fq, 0);
metro_swing(fq, swing) = metro_impl(fq,0) | metro_impl(fq, swing);

drunk_metro(fq, noise_amount) = metro(freq)
with {
    trig = metro(fq)|(fq!=fq')|os.impulse;
    freq = fq + (no.noise*noise_amount) : ba.sAndH(trig);
};

accent(modulo, beat) = _~+( is ) : %(modulo) : ==(0) : &(is)
with {
    is = beat > beat';
};

// Same with accent
drunk_metro_acc(fq, noise_amt) = bt, acc
with {
    trig = metro(fq)|(fq!=fq')|os.impulse;
    frq = fq + (no.noise * noise_amt) : ba.sAndH(trig);
    bt = metro(frq);
    acc_mod = int(abs(no.noise*noise_amt))+1;
    acc = accent(acc_mod, bt);
};

/* 
    PHASOR
*/
phasor_impl(fq, phase) = incr/smps
with {
    incr = _~+(1.0) : +(offset) : _, smps : fmod;
    offset = (1.0 - phase) * smps;
    smps = ma.SR/fq;
};

phasor(fq) = phasor_impl(fq, 0);
phasor_ph(fq, phase) = phasor_impl(fq, phase);


/* 
    EUCLIDIAN RHYTHM
*/
euclidian(onset, div, pulses, rotation, phasor) = (euclid' != euclid) & (phase' != phase)
with {
    phase = ((phasor + rotation) * div), 1.0 : fmod : *(pulses) : int;
    euclid = int((onset/pulses) * phase);
};


/*
    LOOPER 
    - Can be used as a beat looper 
    - or as an audio looper
*/
looper(SIZE, record, read_speed) = looper : *(read_cond)
with {
    looper = rwtable(SIZE, 0.0, recindex, _, readindex);
    recindex = (+(1) : %(SIZE)) ~ *(record);
    read_cond = read_speed>0;
    readindex = read_speed/float(ma.SR) : (+ : ma.frac) ~ _ : *(float(SIZE)) : int : *(read_cond);
};      


/*
    SEQUENCERS
*/
sequencer(t, freq) = (res > 0) * (ph != ph'), res
with {
    sz = t : _,!;
    ph = int(os.phasor(sz, freq)); 
    res = t, ph : rdtable;
};

ctl_sequencer = steps : sum(n, SIZE, res(_,n))
with {
    steps = hgroup("steps", par(n, SIZE, checkbox("%n")));
    beat = ba.beat(speed*60);
    incr = _~+(beat), SIZE : %;
    res(sig, n) = sig : *(incr==n) : *(beat);
};

swing_sequencer(t,tswing, size, freq) = ((res > 0) * (ph != ph')) | swing, res
with {
    ph = int(os.phasor(size, freq / size));
    sw = tswing, ph : rdtable; 
    phstep = os.hs_phasor(1, freq, sw != sw');
    swing = 0, 1 : select2(cond) : ba.impulsify
    with {
        cond = (phstep >= sw) & (phstep' <= sw);
    };
    
    res = t, ph : rdtable;
};

