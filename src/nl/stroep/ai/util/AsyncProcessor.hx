package nl.stroep.ai.util;
import haxe.Timer;
import nl.stroep.ai.util.FpsMeter;

/**
 * ...
 * @author Mark Knol
 */
class AsyncProcessor
{
	public var isRunning(get, never):Bool;
	public var isReady(get, never):Bool;
	public var fps(get, set):Int;
	
	private var _priority = 0.1;

	private var _totalTimeAllocation = 0.0;
	private var _timeError = 0.0;

	private var _processTimer:Timer = new Timer(0);

	private var _fps:Int;
	private var _fpsMeter:FpsMeter;

	private var _processes:Array<Void->Void> = [];

	private var _isReady:Bool = false;
	private var _isRunning:Bool = false;
	private var _isMeasuringFPS:Bool = false;

	public function new(priority:Float = 1, fps:Int = 0)
	{
		_priority = priority;
		_fps = fps;

		if (_fps != 0)
		{
			updateAllocation();
		}
		else
		{
			startFPSMeasurement();
		}
	}

	public function addProcess( process:Void->Void )
	{
		var numProcesses:Int = _processes.length;
		for (i in 0 ... numProcesses)
		{
			if (_processes[i] == process)
			{
				return;
			}
		}

		_processes.push( process );
	}

	public function removeProcess( process:Void->Void )
	{
		var numProcesses:Int = _processes.length;
		for (i in 0 ... numProcesses)
		{
			if (_processes[i] == process)
			{
				_processes.splice(i, 1);
				return;
			}
		}
	}

	public function removeAllProcesses()
	{
		_processes = [];
		stop();
	}

	public function start()
	{
		if (_isRunning) return;

		_isRunning = true;
		_processTimer.run = processTimerTickHandler;
	}

	public function stop()
	{
		if (!_isRunning) return;

		_isRunning = false;
		_processTimer.stop();
		_timeError = 0;
	}

	private function updateAllocation()
	{
		var timePerFrame:Float = 1000 / _fps;

		if (_isRunning)
		{
			_processTimer.stop();
			_processTimer = new Timer(Std.int(timePerFrame));
			_processTimer.run = processTimerTickHandler;
		}
		_totalTimeAllocation = timePerFrame * _priority;

		_isReady = true;
	}

	private function process()
	{
		var startTime = Timer.stamp();

		if ( _timeError < _totalTimeAllocation )
		{
			var numProcesses:Int = _processes.length;
			var processTimeAllocation = ( _totalTimeAllocation - _timeError ) / numProcesses;

			for (i in 0 ... numProcesses)
			{
				var processStartTime = Timer.stamp();
				
				do
				{
					if (!_isRunning)
					{
						// The AsyncProcessor has been stopped while processing
						return;
					}

					_processes[i]();
				}
				while ((Timer.stamp() - processStartTime) < processTimeAllocation);
			}
		}

		_timeError += (Timer.stamp() - startTime) - _totalTimeAllocation;
		if (_timeError < 0)
		{
			_timeError = 0;
		}
	}

	private function startFPSMeasurement()
	{
		_fpsMeter = new FpsMeter(30);
		_fpsMeter.onMeasureComplete = fpsMeasureCompleteHandler;
		_fpsMeter.startMeasure();
		
		_isMeasuringFPS = true;

		//dispatchEvent( new AsyncProcessorEvent( AsyncProcessorEvent.FPS_MEASURE_START ) );
	}

	private function endFPSMeasurement()
	{
		_fpsMeter.stopMeasure();
		_fpsMeter.onMeasureComplete = null;
		_fpsMeter = null;

		_isMeasuringFPS = false;

		//dispatchEvent( new AsyncProcessorEvent( AsyncProcessorEvent.FPS_MEASURE_COMPLETE ) );

		if (_isRunning)
		{
			_processTimer.stop();
			_processTimer.run = processTimerTickHandler;
		}
	}

	inline function get_isRunning():Bool return _isRunning;
	inline function get_isReady():Bool return _isReady;

	inline private function get_fps():Int return _fps;
	private function set_fps(value:Int):Int
	{
		if (_fps == value || value == 0) return value;
		_fps = value;
		updateAllocation();

		if (_isMeasuringFPS)
		{
			endFPSMeasurement();
		}
		return value;
	}

	private function fpsMeasureCompleteHandler(measuredFps:Int)
	{
		if ( measuredFps == 0 )
		{
			_fpsMeter.startMeasure();
			return;
		}

		_fps = measuredFps;
		updateAllocation();
		endFPSMeasurement();
	}

	private function processTimerTickHandler()
	{
		if (_isReady)
		{
			process();
		}
	}
}