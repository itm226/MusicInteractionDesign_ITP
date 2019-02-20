o = NodeProxy.audio(s, 2);
o.play;
o.fadeTime_(2)

a = Array.fill(16, {NodeProxy.audio})
(
a.do{|item|
	item.source = {
		var freq = rrand(3000, 6000);
		var sig = SinOsc.ar(freq) * [
			SinOsc.ar(freq * LFNoise1.kr(0.05.bilinrand).range(0.25, 1.25)), 1

		].wchoose([1, 9].normalizeSum)
		* Impulse.kr(exprand(0.25, 35.0)
			* LFNoise1.kr(LFNoise2.kr(exprand(0.0625, 0.25))
				.exprange(0.05, 0.25))
			.exprange(0.75, 1.25))
		* (exprand(0.0075, (3/a.size)));
		sig = [sig, BMoog.ar(sig, SinOsc.kr(0.05.rand, 8.0.rand * pi).range(2000, 8000), LFNoise1.kr(0.05).range(0.3, 0.7))].wchoose([0.7, 0.3]);
		sig;
	};
	item.fadeTime_(rrand(8.0, 25.0));
}
)

d = NodeProxy.audio;
d.fadeTime_(4.0);

(
d.source = {
	var sigArray = a.collect({|item| item.ar});
	var output = Array.newClear(4);
	var out, everyOther = 0, everyOther2 = 0;
	var makePan = {|in|
		var sig = Pan2.ar(in, LFNoise1.kr(LFNoise2.kr(0.05).range(0.06, 0.125)).range(-1.0, 1.0));
		BMoog.ar(sig, LFNoise2.kr(LFNoise1.kr(0.1.rand + 0.001)
			.exprange(0.025, 0.25)).exprange(400, 8000), LFNoise2.kr(0.05).range(0.25, 0.75)) * 0.9
	};
	output[0] = sigArray[0];
	output[1] = sigArray[1];
	output[2] = sigArray[2];
	output[3] = sigArray[3];

	sigArray[2..(sigArray.size -1)].do{|item, i|
		if(i.even){
			if(everyOther==0){
				everyOther = everyOther + 1 % 2;
				output[0] = output[0] + item;
			}{
				output[2] = output[2] + item;
				everyOther = everyOther + 1 % 2;
			}
		}{
			if(everyOther2==0){
				everyOther2 = everyOther2 + 1 % 2;
				output[1] = output[1] + item;
			}{
				everyOther2 = everyOther2 + 1 % 2;
				output[3] = output[3] + item;
			}
		}
	};


	output = output.collect({|item|
		item.sum;
	});

	out = output.collect({|item|
		makePan.value(item);
	});

	out = out.sum;
	out = out*0.9;
	out;
}
)


w = Array.fill(4, {NodeProxy.audio});

(
w.do{|item, index|
	item.source = {
		var in = d.ar;
		FreeVerb.ar(in, 1.0, 1.0.rand, 1.0.rand) * (exprand(0.05, 2/w.size));
	};
	item.fadeTime_(rrand(18.0, 45.0));
}
)

r = NodeProxy.audio;
r.fadeTime_(3.0);

(
r.source = {
	var wet = LFNoise1.kr(LFNoise2.kr(0.05).exprange(0.06666, 0.1)).range(0.01, 2/3);
	var dry = 1 - wet;
	var ws = w.collect({|item| item.ar});
	var sig = (d.ar * dry) + (ws * wet);
	var delayWet = LFNoise1.kr(LFNoise2.kr(0.05).range(0.051, 0.3333)).range(0.0, 0.125);
	var delayDry = 1 - delayWet;
	var delay = (CombC.ar(sig, 0.1, LFNoise1.kr(0.05).range(1/200, 0.1), LFNoise1.kr(0.0125).range(0.0, 1.0)) * delayWet)
	+ (sig * delayDry);
	var newSigWet = LFNoise1.kr(LFNoise2.kr(0.05).range(0.051, 0.3333)).range(0.0, 1.0);
	var newSigDry = 1 - newSigWet;
	var newSig = (newSigWet * delay * SinOsc.ar(40)) + (delay * newSigDry);
	var anotherSigWet = LFNoise1.kr(LFNoise2.kr(0.05).range(0.051, 0.3333)).range(0.0, 1.0);
	var anotherSigDry = 1 - anotherSigWet;
	var oneMoreSig = (anotherSigWet * newSig * SinOsc.ar(2000)) + (anotherSigDry * newSig);
	var oneMoreSigWet = LFNoise1.kr(LFNoise2.kr(0.05).range(0.051, 0.3333)).range(0.0, 0.25);
	var oneMoreSigDry = 1 - oneMoreSigWet;
	(oneMoreSig * oneMoreSigDry) + (oneMoreSigWet * GVerb.ar(oneMoreSig.flat.sum * 0.5, 25.0, 1.0, drylevel:0,
		spread: LFNoise1.kr(LFNoise2.kr(0.05).range(0.051, 0.3333)).range(3.0, 25.0)));
};
)

o.source = r;

(
~remakeDrips = {
	a.do{|item, index|
		if((1.0.rand).coin){
			item.source = {
				var freq = rrand(2500, 6000);
				var sig = SinOsc.ar(freq) * [
					SinOsc.ar(freq * LFNoise1.kr(0.05.bilinrand).range(0.25, 1.25)), 1

				].wchoose([1, 9].normalizeSum)
				* Impulse.kr(exprand(0.25, 35.0)
					* LFNoise1.kr(LFNoise2.kr(exprand(0.0625, 0.25))
						.exprange(0.05, 0.25))
					.exprange(0.75, 1.25))
				* (exprand(0.0075, (3/a.size)));
				sig = [
					sig,
					BMoog.ar(sig, SinOsc.kr(0.1.rand, 8.0.rand * pi).range(2000, 8000), LFNoise1.kr(0.05).range(0.3, 0.7))
				].wchoose([0.7, 0.3]);
				sig * 0.5;
			};
			item.fadeTime_(exprand(3.0, 14.0));
		};
	};
}
)

(
~remakeReverb = {
	var newRoom = 1.0.rand;
	var newDamp = 1.0.rand;
	var whateverIndex = w.size.rand;
	var whatever = w[whateverIndex];
	var newFadeTime = exprand(3.0, 12.0);
	whatever.source = {
		var in = d.ar;
		FreeVerb.ar(in, 1.0, newRoom, newDamp) * (exprand(0.005, (0.5/w.size)));
	};
	whatever.fadeTime_(newFadeTime);

	/*format("Reverb % Remade!", whateverIndex).postln;
	['New Room', newRoom, 'New Damp', newDamp, 'New Fade Time', newFadeTime].postln;
	"".postln;*/
};
)

(
~reRemakeDrips.stop;
~reRemakeDrips = Routine({
	loop{
		(rrand(12.0, 25.0)).wait;
		~remakeDrips.value;
		[nil, ~remakeReverb.value].wchoose([4, 1].normalizeSum);
	}
}).play;
)
