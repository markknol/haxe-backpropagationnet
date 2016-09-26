package nl.stroep.ai;
import haxe.Timer;
import nl.stroep.ai.neural.Layer;
import nl.stroep.ai.neural.Synapse;
import nl.stroep.ai.training.Exercise;
import nl.stroep.ai.training.ExercisePattern;
import nl.stroep.ai.training.TrainingResult;
import nl.stroep.ai.training.TrainingState;

/**
 * Ported from https://github.com/dyvoid/imotion-library/tree/master/nl/imotion/neuralnetwork (MIT)
 *
 * @author Mark Knol
 */
class BackPropagationNet
{
	public var layers:Array<Layer> = [];
	public var onTrainingComplete:TrainingResult->Void;
	public var onEpochComplete:TrainingResult->Void;
	
	public var fps(default, set):Int = 5;
	
	
	var jitterEpoch:Float;
	var trainingPriority:Float = .1;
	var learningRate:Float;
	var momentumRate:Float;
	var error:Float = 1;
	
	var trainingState:TrainingState = TrainingState.STOPPED;
	var _currExercise:Exercise;
	var _currTrainingResult:TrainingResult;
	#if async
	var _asyncProcessor:nl.stroep.ai.util.AsyncProcessor;
	#end
	
	
	public function new(learningRate:Float = 0.25, momentumRate:Float = 0.5, jitterEpoch:Int = 1000)
	{
		this.learningRate = learningRate;
		this.momentumRate = momentumRate;
		this.jitterEpoch = jitterEpoch;
		
		#if async
		_asyncProcessor = new nl.stroep.ai.util.AsyncProcessor(trainingPriority, fps);
		_asyncProcessor.addProcess(doExercise);
		#end
	}
	
	public function reset()
	{
		stopTraining();
		
		layers = [];
		
		error = 1;
		trainingPriority 	= 1;
		learningRate = 0.25;
		momentumRate = 0.5;
		jitterEpoch = 1000;
	}
	
	public function create(nrOfInputNeurons:Int, nrOfOutputNeurons:Int, nrOfHiddenLayers:Int = 0, nrOfNeuronsPerHiddenLayer:Int = 0)
	{
		#if debug
		if (nrOfInputNeurons == 0)
			throw "Cannot create a BackPropagationNet with less than 1 input neuron";

		if (nrOfOutputNeurons == 0)
			throw "Cannot create a BackPropagationNet with less than 1 output neuron";
		#end
		
		layers = [];

		//Build input layer
		layers.push(new Layer(nrOfInputNeurons));

		//Build hidden layers
		for (i in 0 ... nrOfHiddenLayers)
		{
			layers.push(new Layer(nrOfNeuronsPerHiddenLayer, layers[i]));
		}

		//Build output layer
		layers.push(new Layer(nrOfOutputNeurons, layers[layers.length-1]));
	}

	public function run(pattern:Array<Float>)
	{
		var result:Array<Float> = null;
		for (i in 0 ... layers.length)
		{
			var layer = layers[i];
			if (i == 0) 
			{
				layer.setValues(pattern);
			}
			else
			{
				result = layer.calcValues();
			}
		}
		return result;
	}
	
	public function startTraining(exercise:Exercise)
	{
		if (trainingState == TrainingState.STARTED || trainingState == TrainingState.PAUSED)
		{
			stopTraining();
		}
		
		trainingState = TrainingState.STARTED;
		_currExercise = exercise;
		_currTrainingResult = new TrainingResult(error, 0);
		#if async
		_asyncProcessor.start();
		#else 
		while (!doExercise()) { }
		#end
	}
	
	
	public function pauseTraining():TrainingResult
	{
		if (trainingState != TrainingState.STARTED) return null;

		#if async
		_asyncProcessor.stop();
		#end
	
		trainingState = TrainingState.PAUSED;

		return _currTrainingResult;
	}


	public function resumeTraining()
	{
		if (trainingState != TrainingState.PAUSED) return;

		#if async
		_asyncProcessor.start();
		#end 
	
		trainingState = TrainingState.STARTED;
	}
	
	public function stopTraining() 
	{
		if (trainingState != TrainingState.STARTED && trainingState != TrainingState.PAUSED || _currTrainingResult == null)
		{
			return null;
		}
		#if async
		if (_asyncProcessor == null) return null;
		if (trainingState == TrainingState.STARTED)
		{
			 _asyncProcessor.stop();
		}
		#end

		var finalTrainingResult:TrainingResult = _currTrainingResult;
		_currTrainingResult = null;
		_currExercise = null;

		trainingState = TrainingState.STOPPED;

		return finalTrainingResult;
	}
	
	public function resetWeights()
	{
		for (layer in layers)
		{
			for (neuron in layer.neurons())
			{
				for (synapse in neuron.synapses)
				{
					synapse.resetWeight();
				}
			}
		}
	}
	
	public function doExercise()
	{
		var startTime = Timer.stamp();
		if (_currTrainingResult == null) return true;
		//Apply jitter if the jitterEpoch is reached
		var jitter:Float = 0.0;
		if (jitterEpoch != 0 && _currTrainingResult.epochs != 0 && _currTrainingResult.epochs % jitterEpoch == 0)
		{
			jitter = Math.random() * 0.02 - 0.01;
		}
		
		//trace("result", _currTrainingResult.toString());
		while (_currExercise.hasNext())
		{
			//Grab next exercise patterns
			var patterns:ExercisePattern = _currExercise.next();

			//Run the neural network, using the exercise patterns
			var result:Array<Float> = run(patterns.inputPattern);
			error = 0;

			//Calculate errors
			var i = layers.length - 1;
			while(i > 0)
			{
				var layer = layers[i];
				if (i == layers.length - 1)
				{
					//First calculate errors for output layers
					for (j in 0 ... layer.neurons().length)
					{
						var resultVal = result[j];
						var targetVal = patterns.targetPattern[j];
						var delta = (targetVal - resultVal);
						layer.neurons()[j].error = delta * resultVal * (1 - resultVal);
						error += delta * delta;
					}
				}
				else
				{
					//Calculate errors for hidden layers
					var nextLayer:Layer = layers[i + 1];
					for (j in 0 ... layer.neurons().length)
					{
						var sum = 0.0;
						for (nextLayerNeuron in nextLayer.neurons())
						{
							sum += nextLayerNeuron.error * nextLayerNeuron.synapses[j].weight;
						}
						var neuronValue = layer.neurons()[j].value;
						layer.neurons()[j].error = neuronValue * (1 - neuronValue) * sum;
						//trace("other:", sum, neuronValue, layer.neurons[j].error);
					}
				}
				i--;
			}

			//Update all weights
			for (i in 1 ... layers.length)
			{
				var layer = layers[i];
				
				for (neuron in layer.neurons())
				{
					for (synapse in neuron.synapses)
					{
						var weightChange = (learningRate * synapse.endNeuron.error * synapse.startNeuron.value) + synapse.momentum;
						synapse.momentum = weightChange * momentumRate;
						synapse.weight += weightChange + jitter;
						//trace("synapse:", learningRate, synapse.endNeuron.error, synapse.startNeuron.value, synapse.momentum, weightChange, synapse.momentum, synapse.weight);
					}
				}
			}

			//Reset jitter. If it was set it only needed to be applied once this epoch
			jitter = 0;
		}

		_currExercise.reset();

		_currTrainingResult.epochs++;
		_currTrainingResult.endError = error;
		_currTrainingResult.trainingTime += Timer.stamp() - startTime;

		if (onEpochComplete != null)
		{
			onEpochComplete(_currTrainingResult);
		}
		
		if ((_currExercise.maxEpochs > 0 && _currTrainingResult.epochs >= _currExercise.maxEpochs) || error <= _currExercise.maxError)
		{
			var trainingResult:TrainingResult = stopTraining();
			
			if (onTrainingComplete != null)
			{
				onTrainingComplete(trainingResult);
				return true;
			}
		}
		return false;
	}
	
	private function set_fps(value:Int)
	{
		#if async
		if (_asyncProcessor != null) _asyncProcessor.fps = value;
		#end
		return fps = value;
	}
}
