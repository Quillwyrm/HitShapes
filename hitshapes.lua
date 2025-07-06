--    _|    _|  _|_|_|  _|_|_|_|_|    _|_|_|  _|    _|    _|_|    _|_|_|    _|_|_|_|    _|_|_|
--    _|    _|    _|        _|      _|        _|    _|  _|    _|  _|    _|  _|        _|
--    _|_|_|_|    _|        _|        _|_|    _|_|_|_|  _|_|_|_|  _|_|_|    _|_|_|      _|_|
--    _|    _|    _|        _|            _|  _|    _|  _|    _|  _|        _|              _|
--    _|    _|  _|_|_|      _|      _|_|_|    _|    _|  _|    _|  _|        _|_|_|_|  _|_|_|
--    HIT DETECTION API                                                          |QUILLWYRM|

local vectools = require("vectools")

local Vec    = vectools.Vec
local len2   = vectools.len2
local cross  = vectools.cross
local sqrt   = math.sqrt
local max    = math.max
local min    = math.min

-- HitShape Types ===========================================================================[

-- HitBox -- Axis-aligned bounding box (AABB)
local HitBox = function(x, y, width, height) -- x, y = top-left corner
  return { type = "box", pos = Vec(x, y), w = width, h = height }
end

-- HitRad -- Circle by center and radius
local HitRad = function(x, y, radius)
  return { type = "rad", pos = Vec(x, y), r = radius }
end

-- HitRay -- Line segment by start and end points
local HitRay = function(x1, y1, x2, y2)
  return { type = "ray", start = Vec(x1, y1), finish = Vec(x2, y2) }
end

-- Collision Detection =======================================================================[

-- Check AABB vs AABB overlap
local checkBoxBox = function(box_a, box_b)
  return  box_a.pos.x < box_b.pos.x + box_b.w and
          box_b.pos.x < box_a.pos.x + box_a.w and
          box_a.pos.y < box_b.pos.y + box_b.h and
          box_b.pos.y < box_a.pos.y + box_a.h
end

-- Check Circle vs Circle overlap
local checkRadRad = function(rad_a, rad_b)
  local delta = rad_a.pos - rad_b.pos
  local dist_sq = len2(delta)
  local radius_sum = rad_a.r + rad_b.r
  return dist_sq <= radius_sum * radius_sum
end

-- Check AABB vs Circle overlap
local checkBoxRad = function(box, rad)
  local cx = math.max(box.pos.x, math.min(rad.pos.x, box.pos.x + box.w))
  local cy = math.max(box.pos.y, math.min(rad.pos.y, box.pos.y + box.h))
  local delta = rad.pos - Vec(cx, cy)
  return len2(delta) <= rad.r * rad.r
end

-- Check Ray vs Ray (segment-segment intersection)
local checkRayRay = function(ray_a, ray_b)
  local cross = function(ax, ay, bx, by) return ax * by - ay * bx end

  local dir_a = ray_a.finish - ray_a.start
  local dir_b = ray_b.finish - ray_b.start
  local parallel_test = cross(dir_a.x, dir_a.y, dir_b.x, dir_b.y)

  if parallel_test == 0 then return false end

  local diff_start = ray_b.start - ray_a.start
  local s = cross(diff_start.x, diff_start.y, dir_b.x, dir_b.y) / parallel_test
  local t = cross(diff_start.x, diff_start.y, dir_a.x, dir_a.y) / parallel_test

  return s >= 0 and s <= 1 and t >= 0 and t <= 1
end

-- Check Circle vs Ray intersection
local checkRadRay = function(rad, ray)
  local dir = ray.finish - ray.start
  local to_circle = ray.start - rad.pos

  local a = dir * dir         -- dot product via __mul
  local b = 2 * (to_circle * dir)
  local c = (to_circle * to_circle) - rad.r * rad.r

  local discriminant = b * b - 4 * a * c
  if discriminant < 0 then return false end

  local sqrt_discriminant = math.sqrt(discriminant)
  local t1 = (-b - sqrt_discriminant) / (2 * a)
  local t2 = (-b + sqrt_discriminant) / (2 * a)

  return (t1 >= 0 and t1 <= 1) or (t2 >= 0 and t2 <= 1)
end

-- Check AABB vs Ray intersection
local checkBoxRay = function(box, ray)
  local inv = function(n) return (n == 0) and 1e10 or 1 / n end

  local dir = ray.finish - ray.start

  local t1 = (box.pos.x - ray.start.x) * inv(dir.x)
  local t2 = (box.pos.x + box.w - ray.start.x) * inv(dir.x)
  local t3 = (box.pos.y - ray.start.y) * inv(dir.y)
  local t4 = (box.pos.y + box.h - ray.start.y) * inv(dir.y)

  local ray_entry = math.max(math.min(t1, t2), math.min(t3, t4))
  local ray_exit  = math.min(math.max(t1, t2), math.max(t3, t4))

  return ray_exit >= 0 and ray_entry <= ray_exit and ray_entry <= 1
end

-- Collision Dispatch =================================================================[

-- Dispatch Table
local collisionChecks = {
  box_box = checkBoxBox,
  rad_rad = checkRadRad,
  box_rad = checkBoxRad,
  rad_box = function(a, b) return checkBoxRad(b, a) end,
  ray_ray = checkRayRay,
  rad_ray = checkRadRay,
  ray_rad = function(a, b) return checkRadRay(b, a) end,
  box_ray = checkBoxRay,
  ray_box = function(a, b) return checkBoxRay(b, a) end,
}

-- Collision Dispatcher 
local hitCheck = function(shape_a, shape_b)
  local type_a, type_b = shape_a.type, shape_b.type
  local key = type_a .. "_" .. type_b

  local collision_function = collisionChecks[key]
  if collision_function then return collision_function(shape_a, shape_b) end

  error("No collision check defined for: " .. type_a .. " vs " .. type_b)
end

-- Return functions to 'require()'
return {
  HitBox = HitBox,
  HitRad = HitRad,
  HitRay = HitRay,
  HitCheck = hitCheck
}
