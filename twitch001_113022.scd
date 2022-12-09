(
SynthDef(\kick, {
    var sig, env;
    env = Env.perc(\atk.kr(0.001), \rel.kr(0.5), 1, \crv.kr(-6)).ar(doneAction: 2);
    sig = SinOsc.ar(env.pow(\envpow.kr(2)).linexp(0, 1, 40, 450));
    sig = sig * env * \amp.kr(0.2);
    sig = Pan2.ar(sig, \pan.kr(0));
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\snare, {
    var sig, env;
    env = Env.perc(\atk.kr(0.001), \rel.kr(0.3), 1, \crv.kr(-6)).ar(doneAction: 2);
    sig = Hasher.ar(Sweep.ar);
    sig = RHPF.ar(sig, 400, 0.1);
    sig = sig.blend(MembraneCircle.ar(
        EnvGen.kr(Env.perc,
            1,
            timeScale: 0.1, doneAction: 0
        ) * PinkNoise.ar(0.4),
        0.05,
        0.999999,
    ), \membrane.kr(0.9));
    sig = sig * env * \amp.kr(0.2);
    sig = Pan2.ar(sig, \pan.kr(0));
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\hat, {
    var sig, env;
    env = Env.perc(\atk.kr(0.001), \rel.kr(0.1), 1, \crv.kr(-6)).ar(doneAction: 2);
    sig = Hasher.ar(Sweep.ar);
    sig = RHPF.ar(sig, 8000, 0.9);
    sig = sig * env * \amp.kr(0.2);
    sig = Pan2.ar(sig, \pan.kr(0));
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\bass, {
    var sig, freq, mod, env, menv;
    env = Env.adsr(\atk.kr(0.01), \dec.kr(0.3), \sus.kr(0.7), \rel.kr(0.1),
        curve: \crv.kr(-5)).ar(2, \gate.kr(1));
    freq = \freq.kr(440);
    freq = freq * SinOsc.kr(\lfrate.kr(8)).bipolar(\vibamt.kr(0.4)).midiratio;
    freq = freq * LFNoise2.kr(1.5!3).bipolar(\detun.kr(0.3)).midiratio;
    menv = Env.adsr(\matk.kr(0.01), \mdec.kr(0.2), \msus.kr(0.3), \mrel.kr(0.1),
        curve: \mcrv.kr(-5)).ar(2, \gate.kr(1));
    mod = SinOsc.ar(freq * \mratio.kr(1)) * menv * \index.kr(8);
    sig = SinOsc.ar(freq * \cratio.kr(1), mod);
    sig = sig.blend(SinOsc.ar(freq), \fund.kr(0.5));
    sig = sig * env * \amp.kr(0.2);
    sig = Splay.ar(sig);
    sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\pad, {
    var sig, freq, mod, env, menv;
    env = Env.asr(\atk.kr(0.1), \sus.kr(0.7), \rel.kr(0.1),
        curve: \crv.kr(-5)).ar(2, \gate.kr(1));
    freq = \freq.kr(440);
    freq = freq * SinOsc.kr(\lfrate.kr(8)).bipolar(\vibamt.kr(0.4)).midiratio;
    freq = freq * LFNoise2.kr(0.3!8).bipolar(\detun.kr(0.5)).midiratio;
    menv = Env.asr(\matk.kr(0.01), \msus.kr(0.3), \mrel.kr(0.1),
        curve: \mcrv.kr(-5)).ar(2, \gate.kr(1));
    mod = SinOsc.ar(freq * \mratio.kr(1)) * menv * \index.kr(8);
    sig = SinOsc.ar(freq * \cratio.kr(1), mod);
    sig = Splay.ar(sig);
    sig = sig * env * \amp.kr(0.2);
    sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\reverb, {
    var sig;
    sig = In.ar(\out.kr(0), 2);
    sig = (sig * \tanh.kr(3)).tanh;
    sig = sig.blend(NHHall.ar(sig), \wet.kr(0.3));
    ReplaceOut.ar(\out.kr(0), sig);
}).add;
)

Pdef.clear;
Pdef.defaultQuant = 2;

(
Pdef(\fill, {|n = 4, synthdef = \default, sustain = 1, atk, matk, octave|
    Pbind(
        \instrument, synthdef,
        \dur, sustain.value / n,
        \atk, 0.001,
        \matk, 0.001,
        \octave, octave + Pseq([0, 1], inf).dupEach(n / 2)
    )
});

Pdef(\fadeout, {|n = 4, synthdef = \default, sustain = 1, amp=0.2|
    Pbind(
        \instrument, synthdef,
        \dur, sustain.value / n,
        \amp, amp.value * Pgeom(1, 0.5, n)
    )
});

Pdef(\bjork, {|n = 8, k = 3, offset = 0, synthdef = \default, sustain = 1, atk, matk, octave|
    Pbind(
        \instrument, synthdef,
        \dur, sustain.value / n,
        \yes, Pbjorklund(k, n, inf, offset).collect{|i|
            if(i == 0){\}{i}
        },
        \atk, 0.001,
        \matk, 0.001,
    )
});

Pdef(\bjorkfadeout, {|n = 8, k = 3, offset = 0, synthdef = \default, sustain = 1, amp=0.2|
    Pbind(
        \instrument, synthdef,
        \dur, sustain.value / n,
        \yes, Pbjorklund(k, n, inf, offset).collect{|i|
            if(i == 0){\}{i}
        },
        \amp, amp.value * Pgeom(1, 0.5, n)
    )
});
)

(
Pdef(\hatpat, Pbind(
    \type, \phrase,
    \instrument, Prand([/*\fill, */\hat, \bjorkfadeout, \fadeout], inf),
    \synthdef, \hat,
    \n, Pwrand([2,4,8], [1,1,1].normalizeSum, inf),
    \k, Pfunc {|ev| ev.n.rrand(1)},
    \offset, Pfunc {|ev| ev.n.rand},
    \legato, 1,
    \dur, 1/2,
    \amp, 0.2,
    \rel, 0.1,
    \pan, 0.4
)).play;

Pdef(\kickpat, Pbind(
    \type, \phrase,
    \instrument, \kick, //Prand([/*\fill, */\kick, \bjork], inf),
    \synthdef, \kick,
    \n, 4, //Pwrand([2,4,8], [1,1,1].normalizeSum, inf),
    \k, Pfunc {|ev| ev.n.rrand(1)},
    \offset, Pfunc {|ev| ev.n.rand},
    \legato, 1,
    \dur, 1/4,
    \yes, Prand([
        Pseq([1,0,0,0,0,0,0,0]),
        Pseq([1,0,0,1,0,0,0,0]),
        Pseq([1,0,0,0,0,0,0,1]),
        Pseq([1,0,0,0,0,1,0,0]),
        Pseq([1,0,1,0,0,0,1,0]),
        Pseq([0,0,1,0,0,0,1,0]),
        Pseq([1,0,1,0,0,0,0,0]),
        Pseq([1,0,0,0,0,0,1,0]),
    ], inf).collect{|i| if(i == 0){\}{i}},
    \amp, 0.2
)).play;

Pdef(\snarepat, Pbind(
    \type, \phrase,
    \instrument, Prand([/*\fill, */\snare, \bjorkfadeout, \fadeout], inf),
    \synthdef, \snare,
    \n, Pwrand([2,4,8], [1,1,1].normalizeSum, inf),
    \k, Pfunc {|ev| ev.n.rrand(1)},
    \offset, Pfunc {|ev| ev.n.rand},
    \dur, Pseq([Rest(1), Pn(2)]),
    \legato, 0.5,
    \amp, 0.7 * [1, 1/2],
    \membrane, 0.9,
    \lag, [0, 1/2],
    \pan, -0.4
)).play;

Pdef(\basspat, Pbind(
    \type, \phrase,
    \instrument, Pwrand([\bass, \fill, \bjork, \fadeout, \bjorkfadeout], [3,1,1,1,1].normalizeSum, inf),
    \synthdef, \bass,
    \n, Pwrand([2,4], [1,1].normalizeSum, inf), //Pwhite(2, 4),
    \k, Pfunc {|ev| ev.n.rrand(1)},
    \offset, Pfunc {|ev| ev.n.rand},
    \scale, Scale.major,
    \yes, Pwrand([1, \], [100, 1].normalizeSum, inf),
    \octave, [6,5,7,4],
    \degree, Pseed(123, Pshuf((0..7), inf)),
    \mtranspose, Pdefn(\mtranspose),
    \dur, 1/4,
    \atk, 0.001,
    \matk, Pexprand(0.001, 0.1),
    \index, Pwhite(4.0, 8.0),
    \mratio, Pwhite(1, 2),
    \cratio, Pwhite(1, 2),
    \legato, 1,//Pwhite(1,2), //Pwrand([0.25, 0.75, 1.0], [2,3,1].normalizeSum, inf)
    \lag, [0, 1/2, 1, 3/2],
    \pan, [0, -1, 1, 0],
    \amp, 0.03 * Array.geom(4, 1, 0.5)
)).play;

Pdef(\padpat, Pbind(
    \instrument, \pad,
    \scale, Scale.major,
    // \yes, Pwrand([1, \], [6, 1].normalizeSum, inf),
    \octave, Pwhite(4, 5).clump(4) - 1,
    \degree, Pseed(234, Pshuf([
        [0,2,4,6], [0,2,4,5]/*[0,1,3,5], [1,2,4,6], [0,2,3,5]*/
    ], inf)),
    \mtranspose, Pseed(234, Pshuf([0,2,-3,-1], inf)).collect{|i| Pdefn(\mtranspose, i); i},
    \dur, 4,
    \matk, Pexprand(1, 6),
    \atk, Pexprand(1, 3),
    \mrel, Pexprand(1, 4),
    \rel, Pexprand(1, 4),
    \index, Pwhite(1.0, 4.0),
    \mratio, Pwhite(1, 8).clump(4),
    \cratio, Pwhite(1, 8).clump(4),
    \legato, 3/4,
    \lfrate, 4,
    \vibamt, 0.1,
    \amp, 0.04,
    \strum, 1,
    \strumEndsTogether, false,
    \pan, Array.interpolation(4, -1.0, 1.0)
)).play;
)

Pdef(\basspat).clear
~verb.free;
~verb = Synth.tail(nil, \reverb);
~verb.set(\wet, 0.1);
