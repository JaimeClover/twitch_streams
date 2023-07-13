// Hello!
// Welcome to my stream!

// today, I'm going to be experimenting with recursive phrasing in SuperCollider...
// ...wish me luck!

(
SynthDef(\ping, {
    var sig, env, amp, mod, freq;
    freq = \freq.kr(440);
    env = Env.perc(\atk.kr(0.01), \rel.kr(0.5), curve: -4).ar(2);
    mod = SinOsc.ar(freq * \ratio.kr(2)) * env.pow(\damp.kr(1.5)) * \index.kr(1);
    mod = DelayN.ar(mod, 0.2, \del.kr(0.05));
    sig = SinOsc.ar(freq, mod.mod(8pi));
    amp = \amp.kr(0.3) * AmpCompA.kr(freq, 20);
    sig = sig * env * amp;
    sig = Pan2.ar(sig, \pan.kr(0));
    Out.ar(\out.kr(0), sig);
}).add;
)

(
// phrase patterns:
Pdef(\dup, {arg n=4, sustain, atk, rel, pan, direction = 1;
    Pbind(
        \instrument, \ping,
        \dur, sustain.value / n,
        \atk, atk / n.pow(1/2),
        \rel, rel / n.pow(1/2),
        \pan, pan + (Pseq(Array.interpolation(n, -0.5, 0.5), inf) * direction)
    )
});

Pdef(\rise, {arg freq, amount=2;
    Pbind(
        \instrument, \ping,
        \rati, Pseries(0, amount),
        \freq, (freq.value * Pkey(\rati).midiratio).clip(20, 20000)
    )
});

Pdef(\fall, {arg freq, amount=2;
    Pbind(
        \freq, (freq.value * Pkey(\rati).neg.midiratio).clip(20, 20000)
    ) <> Pdef(\rise)
});

Pdef(\bjork, {arg k=3, n=4, offset=0;
    Pbind(
        \instrument, \ping,
        \amp, Pkey(\amp) * Pbjorklund(k, n, inf, offset).collect{|i| if(i == 0){\}{1}}
    )
});

Pdef(\fade, {arg n=4, grow=0.5;
    Pbind(
        \amp, Pkey(\amp) * Pgeom(1, grow, n)
    )
});

Pdef(\dupBjork, {
    Pdef(\dup) <> Pdef(\bjork)
});

Pdef(\bjorkRise, Pdef(\bjork) <> Pdef(\rise) <> Pdef(\dup));
Pdef(\bjorkFall, Pdef(\bjork) <> Pdef(\fall) <> Pdef(\dup));

Pdef(\dupRise, {
    Pdef(\rise) <> Pdef(\dup)
});

Pdef(\dupFall, {
    Pdef(\fall) <> Pdef(\dup)
});

Pdef(\dupFade, Pdef(\dup) <> Pdef(\fade));
Pdef(\dupFadeRise, Pdef(\dupFade) <> Pdef(\rise));
Pdef(\dupFadeFall, Pdef(\dupFade) <> Pdef(\fall));
Pdef(\bjorkRiseFade, Pdef(\fade) <> Pdef(\bjorkRise));
Pdef(\bjorkFallFade, Pdef(\fade) <> Pdef(\bjorkFall));
Pdef(\bjorkFade, Pdef(\fade) <> Pdef(\dupBjork));
)


(
// main pattern:
Pdef(\pingpat, Pbind(
    \type, \phrase,
    \yes, Pwrand([1, \], [9, 1].normalizeSum, inf),
    \scale, Scale.harmonicMinor,
    \instrument, Pseq(
        [\dupBjork, \dupFadeFall, \dupFadeRise, \bjorkFade, \bjorkRiseFade, \bjorkFallFade],
        inf
    ),
    \direction, Prand([1, -1], inf),
    \grow, Pwhite(0.5, 0.8),
    \legato, Prand([1,2,4], inf),
    \n, Prand([2, 4, 8, 16, 32], inf),
    \k, Pfunc{|ev| ev.n.rand},
    \offset, Pwhite(0, 32),
    \recursionLevel, 0, //Pwhite(0, 1),
    \amount, Pwhite(1, 9),
    \del, Pexprand(0.001, 0.2),
    \ratio, Pseq([1,2,3, 1/2, 2/3, 3/4], inf),
    \index, Pwhite(0.0, 3.0),
    \damp, Pexprand(0.5, 5),
    \atk, Pexprand(0.01, 0.2),
    \rel, 2.6,
    \octave, Pseq([4, 6, 5, 6, 5, 6], inf) + 1,
    \pan, Pwhite(-1.0, 1.0) * 0.5,
    \degree, Pn(Pshuf([0,1,2,3,4,6], 4)),
    \dur, 1/3,
    \delays, Pwrand([Pwhite(2, 8, 1), 1], [1, 3].normalizeSum, inf),
    \lag, Pfunc{|ev| Array.series(ev.delays, 0, 1/2) * TempoClock.default.beatDur},
    \amp, 0.1 * Pseq([0.7, 2, 2, 3, 2, 2], inf) * Pfunc{|ev|
        if(ev.lag == 0){1}{Array.geom(ev.delays, 1, 0.5)}
    },
)).play;
)

(
~verb.free; ~verb = {
    var sig = In.ar(0, 2);
    var verb = JPverb.ar(sig, 6, 0.5, 1);
    sig = sig.blend(verb, \wet.kr(0.2));
    ReplaceOut.ar(0, sig)
}.play(addAction: \addToTail);
)
~verb.set(\wet, 0.05)

TempoClock.default.tempo = 0.4;

// ok, I think that's enough for today. Peace