## delight is a simple, but efficient 2D light raycaster.
## See the readme for a detailed tutorial on how to use this.

# This library is based on the following article:
# https://ncase.me/sight-and-light/

import algorithm
import math
import options

import glm

type
  LineSegment* = tuple
    a, b: Vec2[float]  ## The segment's points.
  Triangle* = tuple
    a, b, c: Vec2[float]  ## The triangle's vertices.
  Intersection* = tuple
    pos: Vec2[float]  ## The position where the intersection occured.
    t: float          ## The magnitude of the casted ray.

proc intersect*(ray, seg: LineSegment): Option[Intersection] =
  ## Compute the intersection between the given ray and line segment.
  ## Returns some if the intersection was found, or none if there was no
  ## intersection.
  let
    rp = ray.a
    rd = ray.b - ray.a
    sp = seg.a
    sd = seg.b - seg.a
    rmag = sqrt(dot(rd, rd))
    smag = sqrt(dot(sd, sd))
  if rd / rmag == sd / smag:
    return none(Intersection)
  let
    t2 = (rd.x * (sp.y - rp.y) + rd.y * (rp.x - sp.x)) /
         (sd.x * rd.y - sd.y * rd.x)
    t1 = (sp.x + sd.x * t2 - rp.x) / rd.x
  if t1 < 0 or t2 < 0 or t2 > 1:
    return none(Intersection)
  result = some (pos: rp + rd * t1, t: t1)

proc findIntersection*(ray: LineSegment,
                       segs: seq[LineSegment]): Option[Intersection] =
  ## Find the intersection closest to the ray's origin (`a`) from the given
  ## sequence of line segments.
  result = none(Intersection)
  for seg in segs:
    let intersection = ray.intersect(seg)
    if intersection.isSome:
      if result.isNone or intersection.get.t < result.get.t:
        result = intersection

proc angleBetween(a, b: Vec2[float]): float =
  result = arctan2(b.y - a.y, b.x - a.x)

iterator raycast*(light: Vec2[float], segs: seq[LineSegment]): Triangle =
  ## Cast rays in towards the segments' vertices, and yield triangles depicting
  ## the visible area lit by the light.
  ##
  ## This casts 3 rays per each vertex, each one slightly offset from each
  ## other, to prevent glitchy blinking. This also properly handles fully
  ## vertical rays (with angles of 90° or 270°), which would normally cause
  ## floating point errors because of divisions by zero.
  ##
  ## You usually want to use the proc version of this to make baking easier, but
  ## calling this every frame is fast enough to be useful in prototyping.
  var intersections: seq[Intersection]
  for seg in segs:
    for vertex in [seg.a, seg.b]:
      var baseAngle = angleBetween(light, vertex)
      if baseAngle.abs in [PI / 2, 3 * PI / 2]:
        baseAngle += 0.00001
      for angle in [baseAngle - 0.0001, baseAngle, baseAngle + 0.0001]:
        let
          rayDir = vec2(cos(angle), sin(angle))
          ray = LineSegment (light, light + rayDir)
          intersection = ray.findIntersection(segs)
        if intersection.isSome:
          intersections.add(intersection.get)
  intersections.sort do (a, b: Intersection) -> int:
    let
      angleA = angleBetween(light, a.pos)
      angleB = angleBetween(light, b.pos)
    result = cmp(angleA, angleB)
  for i, intersection in intersections:
    let
      pos1 = intersection.pos
      pos2 = intersections[(i + 1) mod intersections.len].pos
    yield (a: vec2(light.x, light.y),
           b: vec2(pos1.x, pos1.y),
           c: vec2(pos2.x, pos2.y))

proc raycast*(light: Vec2[float], segs: seq[LineSegment]): seq[Triangle] =
  ## Cast rays towards the segments' vertices, and get a sequence of triangles
  ## depicting the visible area lit by the light.
  ##
  ## This casts 3 rays per each vertex, each one slightly offset from each
  ## other, to prevent glitchy blinking. This also properly handles fully
  ## vertical rays (with angles of 90° or 270°), which would normally cause
  ## floating point errors because of divisions by zero.
  ##
  ## This proc version computes the triangles only once and returns a sequence
  ## as the result. You should only call this when any of the parameters change,
  ## to improve performance. There is also an iterator version of this
  ## procedure, which can be used to save memory when baking is not needed.
  for tri in raycast(light, segs):
    result.add(tri)
