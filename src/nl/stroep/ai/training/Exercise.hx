package nl.stroep.ai.training;

/**
 * from: https://code.google.com/p/imotionproductions/source/browse/trunk/nl/imotion/neuralnetwork/training/Exercise.as
 * @author Mark Knol
 */
class Exercise
{
	public var maxEpochs:Int;
	public var maxError:Float;
	//public var useAsync:Bool;
	
	var _index:Int = 0;
	var _patterns:Array<ExercisePattern> = [];
	
	public function new( maxEpochs:Int = 0, maxError:Float = 0.0/*, useAsync:Bool = true*/ )
	{
		this.maxEpochs = maxEpochs;
		this.maxError = maxError;
		//this.useAsync = useAsync;
	}
	
	public inline function addPatterns(inputPattern:Array<Float>, targetPattern:Array<Float>)
	{
		_patterns.push(new ExercisePattern(inputPattern, targetPattern));
	}

	public inline function next():ExercisePattern
	{
		return _patterns[_index++];
	}

	public inline function reset()
	{
		_index = 0;
	}

	public inline function hasNext():Bool
	{
		return _index < _patterns.length;
	}
}