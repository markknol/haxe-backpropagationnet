package nl.stroep.ai.neural;

/**
 * @author Mark Knol
 */
class Synapse
{
	public var startNeuron:Neuron;
	public var endNeuron:Neuron;
	
	/**
	 * The weight of the connection
	 */
	public var weight:Float;
	
	/**
	 * The current momentum of this synapse's weight correction
	 */
	public var momentum:Float = 0;
	
	public function new(startNeuron:Neuron, endNeuron:Neuron, weight:Float = null) 
	{
		this.startNeuron = startNeuron;
		this.endNeuron = endNeuron;
		
		if (weight == null) 
		{
			resetWeight();
		}
		else
		{
			this.weight = weight;
		}
	}
	
	public inline function resetWeight() 
	{
		weight = Math.random() * 2 - 1;
	}
	
	public function getOutput():Float
	{
		//trace("startNeuron ", startNeuron.value, weight); 
		return startNeuron.value * weight;
	}
	
}