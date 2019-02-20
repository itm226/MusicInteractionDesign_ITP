~isSynthDefMade = false;

(
var makeSynthDef = {
	if(~isSynthDefMade==false){
		SynthDef.new(\playBuf, {
			var buf = \buf.kr(0);
			var env = XLine.kr(dur:0.05) - 1.0;
			var sig = PlayBuf.ar(buf.numChannels, buf, BufRateScale.kr(buf), startPos: BufFrames.kr(buf) * \startPos.kr(0.0),
				doneAction: Done.freeSelf);
			var outSig = sig * env * \amp.kr(0.5);
			Out.ar(\out.kr(0), Splay.ar(outSig))
		}).add;
		~isSynthDefMade = true;
	};
	nil;
}.value;

var w = Window.closeAll.new("Aural Mood Board", Rect(0, 0, 922.0, 245.0))
.background_(Color.white).front.alwaysOnTop_(true);

var constructButtons = {|buffer|
	var synth;
	var button = Button()
	.states_([
		["Play", Color.white, Color.blue],
		["Stop", Color.red, Color.yellow]
	])
	.action_({|obj|
		if(obj.value==1){
			synth = Synth(\playBuf, [\buf, buffer, \startPos, 0.05, \amp, 1]).register;
			synth.onFree({
				defer{button.valueAction_(0)};
			})
		}{
			if(synth.isPlaying){
				synth.free;
			};
		}
	}).font_(Font("Monaco", 24));

	var text = StaticText().string_(PathName(buffer.path).fileNameWithoutExtension)
	.font_(Font("Monaco", 8));

	var view = CompositeView(w.view, 150@100).layout_(VLayout(button, text));
	view;
};

var clearBuffers = {
	Buffer.freeAll;
	nil;
}.value;

var buffers = PathName(PathName(thisProcess.nowExecutingPath).pathOnly++"Audio").files.collect({|item|
	var name = item.fullPath;
	Buffer.read(s, name);
});

w.view.decorator = FlowLayout(w.view.bounds, 10@10, 20@2.5);
buffers.do({|buffer| constructButtons.value(buffer)});
)

//Play output:
OSCdef(\info, {arg ...args; args.postln}, "/b_info")
x= play{var b = 4; PlayBuf.ar(2, b, BufRateScale.kr(b),doneAction: Done.freeSelf)};