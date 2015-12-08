(function (console) { "use strict";
Math.__name__ = true;
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
var haxe_Timer = function(time_ms) {
	var me = this;
	this.id = setInterval(function() {
		me.run();
	},time_ms);
};
haxe_Timer.__name__ = true;
haxe_Timer.stamp = function() {
	return new Date().getTime() / 1000;
};
haxe_Timer.prototype = {
	stop: function() {
		if(this.id == null) return;
		clearInterval(this.id);
		this.id = null;
	}
	,run: function() {
	}
};
var js_Boot = function() { };
js_Boot.__name__ = true;
js_Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str2 = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i1 = _g1++;
					if(i1 != 2) str2 += "," + js_Boot.__string_rec(o[i1],s); else str2 += js_Boot.__string_rec(o[i1],s);
				}
				return str2 + ")";
			}
			var l = o.length;
			var i;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js_Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
var nl_stroep_ai_BackPropagationNet = function(learningRate,momentumRate,jitterEpoch) {
	if(jitterEpoch == null) jitterEpoch = 1000;
	if(momentumRate == null) momentumRate = 0.5;
	if(learningRate == null) learningRate = 0.25;
	this.trainingState = 3;
	this.error = 1;
	this.trainingPriority = .1;
	this.fps = 5;
	this.layers = [];
	this.learningRate = learningRate;
	this.momentumRate = momentumRate;
	this.jitterEpoch = jitterEpoch;
	this._asyncProcessor = new nl_stroep_ai_util_AsyncProcessor(this.trainingPriority,this.fps);
	this._asyncProcessor.addProcess($bind(this,this.doExercise));
};
nl_stroep_ai_BackPropagationNet.__name__ = true;
nl_stroep_ai_BackPropagationNet.prototype = {
	create: function(nrOfInputNeurons,nrOfOutputNeurons,nrOfHiddenLayers,nrOfNeuronsPerHiddenLayer) {
		if(nrOfNeuronsPerHiddenLayer == null) nrOfNeuronsPerHiddenLayer = 0;
		if(nrOfHiddenLayers == null) nrOfHiddenLayers = 0;
		this.layers = [];
		this.layers.push(new nl_stroep_ai_neural_Layer(nrOfInputNeurons));
		var _g = 0;
		while(_g < nrOfHiddenLayers) {
			var i = _g++;
			this.layers.push(new nl_stroep_ai_neural_Layer(nrOfNeuronsPerHiddenLayer,this.layers[i]));
		}
		this.layers.push(new nl_stroep_ai_neural_Layer(nrOfOutputNeurons,this.layers[this.layers.length - 1]));
	}
	,run: function(pattern) {
		var result = null;
		var _g1 = 0;
		var _g = this.layers.length;
		while(_g1 < _g) {
			var i = _g1++;
			var layer = this.layers[i];
			if(i == 0) layer.setValues(pattern); else result = layer.calcValues();
		}
		return result;
	}
	,startTraining: function(exercise) {
		if(this.trainingState == 1 || this.trainingState == 2) this.stopTraining();
		this.trainingState = 1;
		this._currExercise = exercise;
		this._currTrainingResult = new nl_stroep_ai_training_TrainingResult(this.error,0);
		this._asyncProcessor.start();
	}
	,stopTraining: function() {
		if(this.trainingState != 1 && this.trainingState != 2 || this._currTrainingResult == null) return null;
		if(this._asyncProcessor == null) return null;
		if(this.trainingState == 1) this._asyncProcessor.stop();
		var finalTrainingResult = this._currTrainingResult;
		this._currTrainingResult = null;
		this._currExercise = null;
		this.trainingState = 3;
		return finalTrainingResult;
	}
	,doExercise: function() {
		var startTime = haxe_Timer.stamp();
		if(this._currTrainingResult == null) return true;
		var jitter = 0.0;
		if(this.jitterEpoch != 0 && this._currTrainingResult.epochs != 0 && this._currTrainingResult.epochs % this.jitterEpoch == 0) jitter = Math.random() * 0.02 - 0.01;
		while(this._currExercise.hasNext()) {
			var patterns = this._currExercise.next();
			var result = this.run(patterns.inputPattern);
			this.error = 0;
			var i = this.layers.length - 1;
			while(i > 0) {
				var layer = this.layers[i];
				if(i == this.layers.length - 1) {
					var _g1 = 0;
					var _g = layer.neurons.length;
					while(_g1 < _g) {
						var j = _g1++;
						var resultVal = result[j];
						var targetVal = patterns.targetPattern[j];
						var delta = targetVal - resultVal;
						layer.neurons[j].error = delta * resultVal * (1 - resultVal);
						this.error += delta * delta;
					}
				} else {
					var nextLayer = this.layers[i + 1];
					var _g11 = 0;
					var _g2 = layer.neurons.length;
					while(_g11 < _g2) {
						var j1 = _g11++;
						var sum = 0.0;
						var _g21 = 0;
						var _g3 = nextLayer.neurons;
						while(_g21 < _g3.length) {
							var nextLayerNeuron = _g3[_g21];
							++_g21;
							sum += nextLayerNeuron.error * nextLayerNeuron.synapses[j1].weight;
						}
						var neuronValue = layer.neurons[j1].value;
						layer.neurons[j1].error = neuronValue * (1 - neuronValue) * sum;
					}
				}
				i--;
			}
			var _g12 = 1;
			var _g4 = this.layers.length;
			while(_g12 < _g4) {
				var i1 = _g12++;
				var layer1 = this.layers[i1];
				var _g22 = 0;
				var _g31 = layer1.neurons;
				while(_g22 < _g31.length) {
					var neuron = _g31[_g22];
					++_g22;
					var _g41 = 0;
					var _g5 = neuron.synapses;
					while(_g41 < _g5.length) {
						var synapse = _g5[_g41];
						++_g41;
						var weightChange = this.learningRate * synapse.endNeuron.error * synapse.startNeuron.value + synapse.momentum;
						synapse.momentum = weightChange * this.momentumRate;
						synapse.weight += weightChange + jitter;
					}
				}
			}
			jitter = 0;
		}
		this._currExercise._index = 0;
		this._currTrainingResult.epochs++;
		this._currTrainingResult.endError = this.error;
		this._currTrainingResult.trainingTime += haxe_Timer.stamp() - startTime;
		if(this.onEpochComplete != null) this.onEpochComplete(this._currTrainingResult);
		if(this._currExercise.maxEpochs > 0 && this._currTrainingResult.epochs >= this._currExercise.maxEpochs || this.error <= this._currExercise.maxError) {
			var trainingResult = this.stopTraining();
			if(this.onTrainingComplete != null) {
				this.onTrainingComplete(trainingResult);
				return true;
			}
		}
		return false;
	}
};
var nl_stroep_ai_TestMath = function() {
	this.data = [[1,0.5,0,0,0.5],[.1,.5],[0.5,1,0.5,0,0],[.2,.4],[0,0.5,1,0.5,0],[.3,.3],[0,0,0.5,1,0.5],[.4,.2],[0.5,0,0,0.5,1],[.5,.1]];
	var _g = this;
	console.log("start exercise");
	var exercise = new nl_stroep_ai_training_Exercise(0,0.000005);
	var index = 0;
	while(index < this.data.length) {
		var input = this.data[index];
		var output = this.data[index + 1];
		exercise._patterns.push(new nl_stroep_ai_training_ExercisePattern(input,output));
		index += 2;
	}
	console.log("data: " + Std.string(this.data));
	this.net = new nl_stroep_ai_BackPropagationNet();
	this.net.create(this.data[0].length,this.data[1].length,2,5);
	this.net.startTraining(exercise);
	this.net.onTrainingComplete = function(result) {
		console.log("training complete: " + Std.string(result));
		var testResult = _g.net.run([0,1,1,1,0]);
		console.log("test result: " + Std.string(testResult));
		_g.reverseTest(testResult);
	};
};
nl_stroep_ai_TestMath.__name__ = true;
nl_stroep_ai_TestMath.main = function() {
	new nl_stroep_ai_TestMath();
};
nl_stroep_ai_TestMath.prototype = {
	reverseTest: function(testResult) {
		console.log("\n\nstart reversed");
		var exercise = new nl_stroep_ai_training_Exercise(0,0.000005);
		var index = 0;
		while(index < this.data.length) {
			var input = this.data[index + 1];
			var output = this.data[index];
			exercise._patterns.push(new nl_stroep_ai_training_ExercisePattern(input,output));
			index += 2;
		}
		console.log("data: " + Std.string(this.data));
		var netReversed = new nl_stroep_ai_BackPropagationNet();
		netReversed.create(this.data[1].length,this.data[0].length,2,5);
		netReversed.run(testResult);
		netReversed.startTraining(exercise);
		netReversed.onTrainingComplete = function(result) {
			console.log("training reversed complete: " + Std.string(result));
			var testResultReversed = netReversed.run(testResult);
			console.log("reversed test result: " + Std.string(testResultReversed));
		};
	}
};
var nl_stroep_ai_neural_Layer = function(numNeurons,inputLayer) {
	this.neurons = [];
	this.numNeurons = numNeurons;
	this.inputLayer = inputLayer;
	var _g = 0;
	while(_g < numNeurons) {
		var i = _g++;
		var neuron = new nl_stroep_ai_neural_Neuron();
		if(inputLayer != null) {
			var _g1 = 0;
			var _g2 = inputLayer.neurons;
			while(_g1 < _g2.length) {
				var inputNeuron = _g2[_g1];
				++_g1;
				neuron.synapses.push(new nl_stroep_ai_neural_Synapse(inputNeuron,neuron));
			}
		}
		this.neurons.push(neuron);
	}
};
nl_stroep_ai_neural_Layer.__name__ = true;
nl_stroep_ai_neural_Layer.prototype = {
	calcValues: function() {
		var result = [];
		var _g = 0;
		var _g1 = this.neurons;
		while(_g < _g1.length) {
			var neuron = _g1[_g];
			++_g;
			result.push(neuron.calcActivation());
		}
		return result;
	}
	,setValues: function(values) {
		var _g1 = 0;
		var _g = this.neurons.length;
		while(_g1 < _g) {
			var i = _g1++;
			this.neurons[i].value = values[i];
		}
	}
};
var nl_stroep_ai_neural_Neuron = function() {
	this.error = 1;
	this.value = 0;
	this.synapses = [];
};
nl_stroep_ai_neural_Neuron.__name__ = true;
nl_stroep_ai_neural_Neuron.prototype = {
	calcActivation: function() {
		this.value = 0.0;
		var _g = 0;
		var _g1 = this.synapses;
		while(_g < _g1.length) {
			var synapse = _g1[_g];
			++_g;
			this.value += synapse.getOutput();
		}
		this.value = 1 / (1 + Math.exp(-this.value));
		return this.value;
	}
};
var nl_stroep_ai_neural_Synapse = function(startNeuron,endNeuron,weight) {
	this.momentum = 0;
	this.startNeuron = startNeuron;
	this.endNeuron = endNeuron;
	if(weight == null) this.weight = Math.random() * 2 - 1; else this.weight = weight;
};
nl_stroep_ai_neural_Synapse.__name__ = true;
nl_stroep_ai_neural_Synapse.prototype = {
	getOutput: function() {
		return this.startNeuron.value * this.weight;
	}
};
var nl_stroep_ai_training_Exercise = function(maxEpochs,maxError) {
	if(maxError == null) maxError = 0.0;
	if(maxEpochs == null) maxEpochs = 0;
	this._patterns = [];
	this._index = 0;
	this.maxEpochs = maxEpochs;
	this.maxError = maxError;
};
nl_stroep_ai_training_Exercise.__name__ = true;
nl_stroep_ai_training_Exercise.prototype = {
	next: function() {
		return this._patterns[this._index++];
	}
	,hasNext: function() {
		return this._index < this._patterns.length;
	}
};
var nl_stroep_ai_training_ExercisePattern = function(inputPattern,targetPattern) {
	this.inputPattern = inputPattern;
	this.targetPattern = targetPattern;
};
nl_stroep_ai_training_ExercisePattern.__name__ = true;
var nl_stroep_ai_training_TrainingResult = function(startError,endError,epochs,trainingTime) {
	if(trainingTime == null) trainingTime = 0;
	if(epochs == null) epochs = 0;
	this.startError = startError;
	this.endError = endError;
	this.epochs = epochs;
	this.trainingTime = trainingTime;
};
nl_stroep_ai_training_TrainingResult.__name__ = true;
nl_stroep_ai_training_TrainingResult.prototype = {
	toString: function() {
		return ["startError=" + this.startError,"endError=" + this.endError,"epochs=" + this.epochs,"trainingTime=" + (this.trainingTime * 1000 | 0) / 1000].join(" - ");
	}
};
var nl_stroep_ai_util_AsyncProcessor = function(priority,fps) {
	if(fps == null) fps = 0;
	if(priority == null) priority = 1;
	this._isMeasuringFPS = false;
	this._isRunning = false;
	this._isReady = false;
	this._processes = [];
	this._processTimer = new haxe_Timer(0);
	this._timeError = 0.0;
	this._totalTimeAllocation = 0.0;
	this._priority = 0.1;
	this._priority = priority;
	this._fps = fps;
	if(this._fps != 0) this.updateAllocation(); else this.startFPSMeasurement();
};
nl_stroep_ai_util_AsyncProcessor.__name__ = true;
nl_stroep_ai_util_AsyncProcessor.prototype = {
	addProcess: function(process) {
		var numProcesses = this._processes.length;
		var _g = 0;
		while(_g < numProcesses) {
			var i = _g++;
			if(this._processes[i] == process) return;
		}
		this._processes.push(process);
	}
	,start: function() {
		if(this._isRunning) return;
		this._isRunning = true;
		this._processTimer.run = $bind(this,this.processTimerTickHandler);
	}
	,stop: function() {
		if(!this._isRunning) return;
		this._isRunning = false;
		this._processTimer.stop();
		this._timeError = 0;
	}
	,updateAllocation: function() {
		var timePerFrame = 1000 / this._fps;
		if(this._isRunning) {
			this._processTimer.stop();
			this._processTimer = new haxe_Timer(timePerFrame | 0);
			this._processTimer.run = $bind(this,this.processTimerTickHandler);
		}
		this._totalTimeAllocation = timePerFrame * this._priority;
		this._isReady = true;
	}
	,process: function() {
		var startTime = haxe_Timer.stamp();
		if(this._timeError < this._totalTimeAllocation) {
			var numProcesses = this._processes.length;
			var processTimeAllocation = (this._totalTimeAllocation - this._timeError) / numProcesses;
			var _g = 0;
			while(_g < numProcesses) {
				var i = _g++;
				var processStartTime = haxe_Timer.stamp();
				do {
					if(!this._isRunning) return;
					this._processes[i]();
				} while(haxe_Timer.stamp() - processStartTime < processTimeAllocation);
			}
		}
		this._timeError += haxe_Timer.stamp() - startTime - this._totalTimeAllocation;
		if(this._timeError < 0) this._timeError = 0;
	}
	,startFPSMeasurement: function() {
		this._fpsMeter = new nl_stroep_ai_util_FpsMeter(30);
		this._fpsMeter.onMeasureComplete = $bind(this,this.fpsMeasureCompleteHandler);
		this._fpsMeter.startMeasure();
		this._isMeasuringFPS = true;
	}
	,endFPSMeasurement: function() {
		this._fpsMeter.stopMeasure();
		this._fpsMeter.onMeasureComplete = null;
		this._fpsMeter = null;
		this._isMeasuringFPS = false;
		if(this._isRunning) {
			this._processTimer.stop();
			this._processTimer.run = $bind(this,this.processTimerTickHandler);
		}
	}
	,fpsMeasureCompleteHandler: function(measuredFps) {
		if(measuredFps == 0) {
			this._fpsMeter.startMeasure();
			return;
		}
		this._fps = measuredFps;
		this.updateAllocation();
		this.endFPSMeasurement();
	}
	,processTimerTickHandler: function() {
		if(this._isReady) this.process();
	}
};
var nl_stroep_ai_util_FpsMeter = function(numMeasurements) {
	this._lastTime = 0;
	this._fpsList = [];
	this._timeList = [];
	this.numMeasurements = numMeasurements;
};
nl_stroep_ai_util_FpsMeter.__name__ = true;
nl_stroep_ai_util_FpsMeter.prototype = {
	startMeasure: function(autoStop) {
		if(autoStop == null) autoStop = true;
		if(this.autoStop != autoStop) {
			this.autoStop = autoStop;
			this._fpsList = [];
		}
		autoStop;
		if(!this.isStarted) {
			this.isStarted = true;
			this._lastTime = haxe_Timer.stamp();
			if(this._timer == null) this._timer = new haxe_Timer(1);
			this._timer.run = $bind(this,this.calcFPS);
		}
	}
	,stopMeasure: function() {
		if(this.isStarted) {
			this.isStarted = false;
			this._timeList = [];
			this._fpsList = [];
			this._lastTime = 0;
			this._timer.stop();
		}
	}
	,calcFPS: function() {
		var newTime = haxe_Timer.stamp();
		this._timeList.push(newTime - this._lastTime);
		var diff = this._timeList.length - this.numMeasurements;
		if(diff > 0) this._timeList.splice(0,diff);
		var totalTime = 0.0;
		var _g = 0;
		var _g1 = this._timeList;
		while(_g < _g1.length) {
			var time = _g1[_g];
			++_g;
			totalTime += time;
		}
		this.fps = Math.round(1000 / (totalTime / this._timeList.length));
		this._lastTime = newTime;
		if(this.autoStop) this.checkStableFPS();
	}
	,checkStableFPS: function() {
		this._fpsList.push(this.fps);
		var fpsDiff = this._fpsList.length - this.numMeasurements;
		if(fpsDiff > 0) this._fpsList.splice(0,fpsDiff);
		if(this._fpsList.length == this.numMeasurements) {
			var fpsCheck = this._fpsList[0];
			var fpsIsStable = true;
			var _g = 0;
			var _g1 = this._fpsList;
			while(_g < _g1.length) {
				var fpsValue = _g1[_g];
				++_g;
				if(fpsValue != fpsCheck) {
					fpsIsStable = false;
					break;
				}
			}
			if(fpsIsStable) {
				this.stopMeasure();
				if(this.onMeasureComplete != null) this.onMeasureComplete(this.fps);
			}
		}
	}
};
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
String.__name__ = true;
Array.__name__ = true;
Date.__name__ = ["Date"];
nl_stroep_ai_TestMath.main();
})(typeof console != "undefined" ? console : {log:function(){}});
