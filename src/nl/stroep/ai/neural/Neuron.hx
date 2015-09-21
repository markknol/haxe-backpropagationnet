package nl.stroep.ai.neural;

/**
 * @author Mark Knol
 */
class Neuron
{
	public var synapses:Array<Synapse> = [];
	public var value:Float = 0;
	public var error:Float = 1;
	
	public function new() 
	{
		
	}
	
	public function calcActivation():Float
	{
		#if debug
		if ( synapses.length == 0 ) throw "Unable to calculate a value. Neuron has no synapses connected to it";
		#end
		
		value = 0.0;
		for (synapse in synapses)
		{
			value += synapse.getOutput();
		}
		//trace("Neuron",value);
		value = getSigmoid(value);
		return value;
	}
	
	inline function getSigmoid(value:Float):Float
	{
		return 1 / (1 + Math.exp(-value));
	}
	
#if debug
	public function toString():String
	{
		return ["value=" + value, "error=" + error].join(", ");
	}
#end
}