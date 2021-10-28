import "graphics" for Canvas, Color, ImageData, Point, Font
import "io" for FileSystem
import "dome" for Platform, Window


class Grid {
	construct new(framewidth, frameheight, imagewidth, imageheight) {
		_frameWidth    = framewidth
		_frameHeight   = frameheight
		_imageWidth    = imagewidth
		_imageHeight   = imageheight
		_spritesPerRow = _imageWidth / _frameWidth
	}
	frameWidth {_frameWidth}
	frameHeight {_frameHeight}
	getFrame(frame) {
		return {
			"x" :	(frame % _spritesPerRow) * _frameWidth,
			"y" :	(frame / _spritesPerRow).floor * _frameWidth
		}
	}
	getX(frame) {(frame % _spritesPerRow) * _frameWidth}
	getY(frame) {(frame / _spritesPerRow).floor * _frameWidth}
}

class SpriteSheet {
	construct new(file, framewidth, frameheight) {
		_image = ImageData.loadFromFile(file)
		_grid  = Grid.new(framewidth, frameheight, _image.width, _image.height)
		_animations = {}
	}

	addAnimation(name, frames, rate) {
		_animations[name] = Animation.new(_grid, frames, rate)
	}

	getAnimation(string) {_animations[string]}

	image {_image}
	grid {_grid}
}

class Animation {
	construct new(grid, frames, rate) {
		_grid	   = grid
		_frames    = frames is Range && frames.toList || frames
		_frame     = _frames[0]
		_rate      = rate
		_loops     = 0
		_lastFrame = 0
		_paused    = false
		_timer = 0
		_lastTime = 0
	}
	pause {_paused = true}
	resume {_paused = false}
	onLoop=(value) {_onLoop = value}

	update() {
		if (_paused) return
		_timer = _timer + 1
		_frame = _frames[((_timer / 60) / (_rate/1000) % _frames.count).floor]
		var loop = (_frame != _lastFrame) && (_frame == _frames[_frames.count - 1])
		_loops = _loops + (loop && 1 || 0)
		_lastFrame = _frame
		_lastTime = _timer
		if (loop && _onLoop is Fn) _onLoop.call()
	}

	draw(image, x, y) {image.drawArea(_grid.getX(_frame), _grid.getY(_frame), _grid.frameWidth, _grid.frameHeight, x, y)}

	draw(image, x, y, flipH, flipV) {
		image.transform({
			"srcX"		:	_grid.getX(_frame),
			"srcY"		:	_grid.getY(_frame),
			"srcW"		:	_grid.frameWidth,
			"srcH"		:	_grid.frameHeight,
			"angle" 	:	0,
			"scaleX"	:	flipH && -1 || 1,
			"scaleY"	:	flipV && -1 || 1,
		}).draw(x, y)
	}
}