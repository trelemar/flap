import "graphics" for Canvas, Color, ImageData, Point, Font
import "io" for FileSystem
import "dome" for Platform


class Grid {
	construct new(framewidth, frameheight, imagewidth, imageheight) {
		_frameWidth = framewidth
		_frameHeight = frameheight
		_imageWidth = imagewidth
		_imageHeight = imageheight
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
		_grid = Grid.new(framewidth, frameheight, _image.width, _image.height)
	}
	image {_image}
	grid {_grid}
}

class Animation {
	construct new(grid, frames, rate) {
		_grid = grid
		//frames is Range && (_frames = frames.toList)
		//frames is List && (_frames = frames)
		_frames = frames is Range && frames.toList || frames
		_rate = rate
		_loops = 0
		_lastFrame = 0
	}

	update() {
		_frame = _frames[((System.clock / (_rate/1000)) % _frames.count).floor]
		var loop = (_frame != _lastFrame) && (_frame == _frames[_frames.count -1])
		_loops = _loops + (loop && 1 || 0)
		if (_frame != _lastFrame) System.print(_loops)
		_lastFrame = _frame
	}

	draw(image, x, y) {image.drawArea(_grid.getX(_frame), _grid.getY(_frame), _grid.frameWidth, _grid.frameHeight, x, y)}

	draw(image, x, y, flipH, flipV) {
		image.transform({
			"srcX"		:	_grid.getX(_frame),
			"srcY"		:	_grid.getY(_frame),
			"srcW"		:	_grid.frameWidth,
			"srcH"		:	_grid.frameHeight,
			"angle" 	:	0,
			"scaleX"	:	flipH == true && -1 || 1,
			"scaleY"	:	flipV == true && -1 || 1,
		}).draw(x, y)
	}
}