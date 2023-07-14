(
~n = 500;

SynthDef(\addy, {
    var n, harms, det, sig, saw, square, tri, three, amps, freqs, base, minHarm, maxHarm;
    n = ~n;
    harms = (1..n);
    base = harms.reciprocal;
    // saw = base * \saw.kr(0);
    // square = base * [1, 0] * \square.kr(0);
    // tri = base.pow(2) * [1, 0] * \tri.kr(0);
    // three = base * [1, 0, 0] * \three.kr(0);
    // amps = saw + square + tri + three;
    // amps = amps.normalizeSum * base.sum;
    amps = \amps.kr((1..n).reciprocal);//.poll;
    freqs = \freq.kr(40, \lg.kr(0.0)) * (harms.pow(\stretch.kr(1.0)) + \harmOffset.kr(0));
    det = LFNoise2.kr(0.5!2).bipolar(\det.kr(0.3)).midiratio;
    minHarm = \minHarm.kr(1);
    maxHarm = \maxHarm.kr(~n);
    sig = freqs.collect{|freq, i|
        SinOsc.ar(freq * det) * ((i >= minHarm) * (i <= maxHarm) * amps[i] * (freq < 22050)).max(0.000001)
    };
    sig = sig.sum * \amp.kr(0.1) * Env.asr(0.01, 1, 0.01, 0).ar(2, \gate.kr(1));
    sig = RLPF.ar(sig, \ffreq.kr(1000, \lg.kr), \rq.kr(0.5, \lg.kr));
    sig = Pan2.ar(sig, \pan.kr(0));
    Out.ar(\out.kr(0), sig);
}).add;
)

(
SynthDef(\kick, {
    var sig, nois, mod, env;
    mod = SinOsc.ar(\modFreq.kr(4.55), \modPhase.kr(pi/7)) * Env([1, 0], 0.3, -4).ar * \idx.kr(50);
    sig = SinOsc.ar(\freq.kr(50) * Env([10, 1], 0.3, -16).ar, mod);
    env = Env.perc(0.01, 0.6, 1, -12).ar(2);
    nois = LPF.ar(WhiteNoise.ar(0.5), 4000) * Env([1, 0], 0.1, -4).ar;
    sig = sig + nois;
    sig = sig.blend((sig * \tanh.kr(10)).tanh, \dist.kr(0.5));
    sig = sig * env * \amp.kr(0.3);
    sig = Pan2.ar(sig, \pan.kr(0));
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\snare, {
    var sig, env, freqenv;
    sig = RHPF.ar(WhiteNoise.ar, 4000, 0.6);
    freqenv = Env([0.03, 0.02], 0.2, -10).ar;
    sig = sig.blend(MembraneCircle.ar(WhiteNoise.ar(0.1), freqenv, 0.99999), 0.7);
    sig = LPF.ar(sig, 9000);
    env = Env.perc(0.001, 0.3, 1, \curve.kr(1)).ar(2);
    sig = sig.blend((sig * \tanh.kr(10)).tanh, \dist.kr(0.5));
    sig = sig * env * \amp.kr(0.9);
    sig = Pan2.ar(sig, \pan.kr(0));
    Out.ar(\out.kr(0), sig);
}).add;
)

(
// ~synth = Synth(\addy, [amp: 0.016, freq: 55]);
// ~synth2 = Synth(\addy, [amp: 0.016, freq: 55]);
~root = 4;
~odds = [1, 0];
~evens = [0, 1];
~two3 = [0, 1, 1];
~two3zero = [1, 1, 0];
~three0 = [1, 0, 0];
~three1 = [0, 1, 0];
~three2 = [0, 0, 1];
~three5 = [0, 0, 1, 0, 1];
~three4 = [0, 0, 1, 1, 0];

Pdef(\synth2pat,
    Pbind(
        \instrument, \addy,
        \yes, Pn(Plazy{Pbjorklund(5, 16, 4, 16.rand)}).collect{|i| if(i == 0){\}{1}},
        \dur, 1/8,
        \legato, Ptri.range(0.2, 0.9, 7.1, 1.0.rand),
        \octave, Pwhite(3, 6).dupEach(16),
        \root, ~root,
        \maxHarm, 40,
        // \stretch, Ptri(6.28, 1.0.rand, 0.001, 1),
        \mod, Pn(Pseries(1, 1, 17), inf),
        \car, Pn(Pseries(2, 1, 23), inf).dupEach(2),
        \amps, Pfunc{|ev|
            var diff, sum;
            diff = ~n.collect{|j| (ev.car - (ev.mod * j)).abs};
            sum = ~n.collect{|j| ev.car + (ev.mod * j)};
            [(1..~n).collect{|i|
                if((sum ++ diff ++ [1]).includesEqual(i)) {i.reciprocal.pow(0.3)} {0}
            }]
        },
        \det, Ptri.range(0.0, 1.0, 5, 1.0.rand),
        \n, Pwhite(1, 8),
        \harmOffset, Pn(Pseries(0, 0.5, 5), inf) * Pfunc{|ev| [{|i| i + 1} ! ev.n, ({|i| i + 1} ! ev.n).reverse].choose},
        \amp, 0.03 * Pfunc{|ev| {|i| 1 / 2.pow(i)} ! ev.n * ev.legato.linlin(0, 4, 1, 0.2)},
        \lag, Pfunc{|ev| {|i| i / 2} ! ev.n}
    )
).play;

Pdef(\synth3pat,
    Pbind(
        \instrument, \addy,
        \dur, 1/8,
        \legato, 0.2,
        \octave, 3,
        \root, ~root,
        \maxHarm, 20,
        // \stretch, Ptri(6.28, 1.0.rand, 0.001, 1),
        \mod, 1,
        \car, 1,
        \amps, Pfunc{|ev|
            var diff, sum;
            diff = ~n.collect{|j| (ev.car - (ev.mod * j)).abs};
            sum = ~n.collect{|j| ev.car + (ev.mod * j)};
            [(1..~n).collect{|i|
                if((sum ++ diff ++ [1]).includesEqual(i)) {i.reciprocal.pow(0.3)} {0}
            }]
        },
        \det, 0,
        \n, Pwhite(1, 8),
        \amp, 0.02,
    )
).play;

Pdef(\harms,
    Pbind(
        \type, \set,
        \dur, 1/64,
        \id, ~synth.nodeID,
        \args, #[\minHarm, \maxHarm],
        \minHarm, 1, //Pn(Pseries(1, 1, 4)),
        \maxHarm, Pn(Pseries(16, 4, 128)),
    )
).play;

Pdef(\amps,
    Pbind(
        \type, \set,
        \id, ~synth.nodeID,
        \dur, 1/8,
        \args, #[\amps, \det],
        \det, Ptri.range(0.0, 1.0, 7, 1.0.rand),
        // \amps, Pseq([~three2, ~two3zero, ~three4, ~three5], inf).collect{|i| [i * (1..~n).reciprocal]},
        \mod, Pn(Pseries(1, 1, 5), inf),
        \car, Pn(Pseries(2, 1, 7), inf).dupEach(2),
        \amps, Pfunc{|ev|
            var diff, sum;
            diff = ~n.collect{|j| (ev.car - (ev.mod * j)).abs};
            sum = ~n.collect{|j| ev.car + (ev.mod * j)};
            [(1..~n).collect{|i|
                if((sum ++ diff ++ [1]).includesEqual(i)) {i.reciprocal.pow(0.9)} {0}
            }]
        },
    )
).play;

Pdef(\stretch,
    Pbind(
        \type, \set,
        \id, ~synth.nodeID,
        \dur, 1/8,
        \args, #[\stretch, \harmOffset],
        // \stretch, Pn(Pseries(0.992, 0.001, 16)),
        // \stretch, Pgauss(1.0, 0.03),
        \stretch, Ptri(6.28, 1.0.rand, 0.01, 1),
        \harmOffset, Pn(Pseries(0, 0.99, 4), inf)
    )
).play;

Pdef(\freq,
    Pbind(
        \type, \set,
        \dur, 1/4,
        \id, ~synth.nodeID,
        \args, #[\freq, \lg],
        \scale, Scale.minorPentatonic,
        \dummy, Pn(Pshuf((0..5), 4), inf, \deg),
        \root, ~root,
        \degree, Pshuf((0..5), inf),
        \octave, Pgate(Pwhite(3, 4), inf, \deg) - 1,
        \lag, Pwhite(0, 1) / 4,
        \lg, Pexprand(0.01, 0.1),
    )
).play;

Pdef(\ffreq,
    Pbind(
        \type, \set,
        \dur, 1/8,
        \id, ~synth.nodeID,
        \args, #[\ffreq, \rq],
        \ffreq, Pexprand(400, 18000),
        \rq, Pexprand(0.05, 0.5)
    )
).play;

Pdef(\kickpat,
    Pbind(
        \instrument, \kick,
        \dur, 1/2,
        \octave, 2,
        \root, ~root,
        \modFreq, Pn(Pseries(3, 0.1, 32)),
        \tanh, Psine.range(1.0, 4, 3.14, 1.0.rand),
        \dist, Psine.range(0.2, 0.6, 4, 1.0.rand) / 4,
        \amp, 0.54 * Pfunc{|ev| ev.dist.linlin(0, 1, 1, 0.4)},
        \lag, Pfunc{[0, [0, 1]].wchoose([4, 1].normalizeSum)} * Prand([1, 3], inf) / 4
    )
).play;

Pdef(\snarepat,
    Pbind(
        \instrument, \snare,
        \dur, 1/2,
        \yes, Pseq([\, 1], inf),
        \octave, 2,
        \root, ~root,
        \tanh, Psine.range(1.0, 4, 3.14, 1.0.rand),
        \dist, Psine.range(0.2, 0.6, 4, 1.0.rand),
        \amp, 0.22 * Pfunc{|ev| ev.dist.linlin(0, 1, 1, 0.4)},
        \lag, Pfunc{[[0], [0, 1, 3], [0, 0, 3], [0, 1, 0]].wchoose([4, 1, 1, 1].normalizeSum)} / 8,
        \curve, Pfunc{|ev| if(ev.lag.size == 3) {[-1, -3, -3]} {-1}}
    )
).play;
)
