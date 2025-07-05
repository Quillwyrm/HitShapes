```
    _|    _|  _|_|_|  _|_|_|_|_|    _|_|_|  _|    _|    _|_|    _|_|_|    _|_|_|_|    _|_|_|
    _|    _|    _|        _|      _|        _|    _|  _|    _|  _|    _|  _|        _|
    _|_|_|_|    _|        _|        _|_|    _|_|_|_|  _|_|_|_|  _|_|_|    _|_|_|      _|_|
    _|    _|    _|        _|            _|  _|    _|  _|    _|  _|        _|              _|
    _|    _|  _|_|_|      _|      _|_|_|    _|    _|  _|    _|  _|        _|_|_|_|  _|_|_|
                                                                                BY QUILLWYRM
```

A lightweight 2D collision detection module for LÖVE.

## Features

- Supports Axis-Aligned Bounding Boxes (AABB), Radials (Circle), and Rays (line).
- Collision checks for all shape combinations:
  - Box vs Box
  - Circle vs Circle
  - Box vs Circle
  - Ray vs Ray
  - Circle vs Ray
  - Box vs Ray
- Simple API for creating shapes and performing collision tests.
- Uses `hump.vector` for [vector math](https://github.com/vrld/hump).
- Made with [LÖVE](https://love2d.org).

## Installation

Place `hitshapes.lua` in your project directory. Make sure `hump/vector.lua` is accessible via `require("hump.vector")`.

## Usage

```lua
local HitShapes = require("hitshapes")

local box = HitShapes.HitBox(10, 10, 50, 50)
local circle = HitShapes.HitRad(30, 30, 10)

local isColliding = HitShapes.HitCheck(box, circle)
```

## API

- `HitBox(x, y, width, height)` — Create an AABB.
- `HitRad(x, y, radius)` — Create a circle.
- `HitRay(x1, y1, x2, y2)` — Create a line segment.
- `HitCheck(shapeA, shapeB)` — Returns `true` if shapes collide, else `false`.

## License

MIT License
