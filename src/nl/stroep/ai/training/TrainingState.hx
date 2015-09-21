package nl.stroep.ai.training;

/**
 * From: https://code.google.com/p/imotionproductions/source/browse/trunk/nl/imotion/neuralnetwork/training/TrainingState.as
 * 
 * @author Mark Knol
 */
@:enum abstract TrainingState(Int)
{
	var STARTED = 1;
	var PAUSED = 2;
	var STOPPED = 3;
}