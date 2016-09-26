package nl.stroep.ai.neural;

/**
 * @author Mark Knol
 */
@:forward
abstract Layer(Array<Neuron>) 
{
	public inline function neurons():Array<Neuron> return this;

	public inline function new(numNeurons:Int, ?inputLayer:Layer) 
	{
		this = [];
		for (i in 0 ... numNeurons)
		{
			var neuron = new Neuron();
			if (inputLayer != null)
			{
				for (inputNeuron in inputLayer.neurons())
				{
					neuron.synapses.push(new Synapse(inputNeuron, neuron));
				}
			}
			this.push(neuron);
		}
	}
	
	public function calcValues():Array<Float>
	{
		return [for (neuron in this) neuron.calcActivation()];
	}
	
	public function setValues(values:Array<Float>)
	{
		#if debug
		if (values.length != this.length) throw "Number of input values do not match the amount of neurons in the layer";
		#end
		
		for (i in 0 ... this.length)
		{
			this[i].value = values[i];
		}
	}
	
}