package nl.stroep.ai.neural;

/**
 * @author Mark Knol
 */
class Layer
{
	public var neurons:Array<Neuron> = [];
	public var inputLayer:Layer;
	public var numNeurons:Int;
	
	public function new(numNeurons:Int, ?inputLayer:Layer) 
	{
		this.numNeurons = numNeurons;
		this.inputLayer = inputLayer;
		
		for (i in 0 ... numNeurons)
		{
			var neuron = new Neuron();
			if (inputLayer != null)
			{
				for (inputNeuron in inputLayer.neurons)
				{
					neuron.synapses.push(new Synapse(inputNeuron, neuron));
				}
			}
			neurons.push(neuron);
		}
	}
	
	public function calcValues():Array<Float>
	{
		var result = [];
		for (neuron in neurons)
		{
			result.push(neuron.calcActivation());
		}
		return result;
	}
	
	public function setValues(values:Array<Float>)
	{
		#if debug
		if (values.length != neurons.length) throw "Number of input values do not match the amount of neurons in the layer";
		#end
		
		for (i in 0 ... neurons.length)
		{
			neurons[i].value = values[i];
		}
	}
	
}