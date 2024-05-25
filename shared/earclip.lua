--[[
Adapted from https://github.com/vrld/HC/blob/master/polygon.lua
License: https://hc.readthedocs.io/en/latest/license.html

Copyright (c) 2011-2015 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders shall not be used in advertising or otherwise to promote the sale, use or other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local function det(x1,y1, x2,y2)
	return x1*y2 - y1*x2
end

-- returns true if three vertices lie on a line
local function areCollinear(p, q, r, eps)
	-- if not p then return false end
	return math.abs(det(q.x-p.x, q.y-p.y,  r.x-p.x,r.y-p.y)) <= (eps or 1e-4)
end

-- remove vertices that lie on a line
local function removeCollinear(vertices)
	if #vertices < 3 then return vertices end
	local ret = {}
	local i,k = #vertices - 1, #vertices
	for l=1,#vertices do
		if not areCollinear(vertices[i], vertices[k], vertices[l]) then
			ret[#ret+1] = vertices[k]
		end
		i,k = k,l
	end
	return ret
end

-- get index of rightmost vertex (for testing orientation)
local function getIndexOfleftmost(vertices)
	local idx = 1
	for i = 2,#vertices do
		if vertices[i].x < vertices[idx].x then
			idx = i
		end
	end
	return idx
end

-- returns true if three points make a counter clockwise turn
local function ccw(p, q, r)
	return det(q.x-p.x, q.y-p.y,  r.x-p.x, r.y-p.y) >= 0
end

-- test wether a and b lie on the same side of the line c->d
local function onSameSide(a,b, c,d)
	local px, py = d.x-c.x, d.y-c.y
	local l = det(px,py,  a.x-c.x, a.y-c.y)
	local m = det(px,py,  b.x-c.x, b.y-c.y)
	return l*m >= 0
end

local function pointInTriangle(p, a,b,c)
	return onSameSide(p,a, b,c) and onSameSide(p,b, a,c) and onSameSide(p,c, a,b)
end

-- test whether any point in vertices (but pqr) lies in the triangle pqr
-- note: vertices is *set*, not a list!
local function anyPointInTriangle(vertices, p,q,r)
	for v in pairs(vertices) do
		if v ~= p and v ~= q and v ~= r and pointInTriangle(v, p,q,r) then
			return true
		end
	end
	return false
end

-- test is the triangle pqr is an "ear" of the polygon
-- note: vertices is *set*, not a list!
local function isEar(p,q,r, vertices)
	return ccw(p,q,r) and not anyPointInTriangle(vertices, p,q,r)
end

local function segmentsIntersect(a,b, p,q)
	return not (onSameSide(a,b, p,q) or onSameSide(p,q, a,b))
end

local function selfIntersects(vertices)
	-- assert polygon is not self-intersecting
	-- outer: only need to check segments #vert;1, 1;2, ..., #vert-3;#vert-2
	-- inner: only need to check unconnected segments
	local q,p = vertices[#vertices], nil
	for i = 1,#vertices-2 do
		p, q = q, vertices[i]
		for k = i+1,#vertices-1 do
			local a,b = vertices[k], vertices[k+1]
			if segmentsIntersect(p,q, a,b) then
				return true
			end
		end
	end
	return false
end

function CleanPolygon(rawVertices)
    local vertices = removeCollinear(rawVertices)

	if #vertices < 3 then
		return vertices
	end

    -- assert polygon is oriented counter clockwise
	local r = getIndexOfleftmost(vertices)
	local q = r > 1 and r - 1 or #vertices
	local s = r < #vertices and r + 1 or 1
	if not ccw(vertices[q], vertices[r], vertices[s]) then -- reverse order if polygon is not ccw
		local tmp = {}
		for i=#vertices,1,-1 do
			tmp[#tmp + 1] = vertices[i]
		end
		vertices = tmp
	end

    return vertices
end

function TriangulatePolygon(vertices)
	if #vertices < 3 then return {} end
    if #vertices == 3 then
		return {{ vertices[1], vertices[2], vertices[3] }}
	end

	if selfIntersects(vertices) then
		print('Warning:  triggerzone failed to triangulate polygon because it self-intersects')
		return {}
	end

	local next_idx, prev_idx = {}, {}
	for i = 1,#vertices do
		next_idx[i], prev_idx[i] = i+1,i-1
	end
	next_idx[#next_idx], prev_idx[1] = 1, #prev_idx

	local concave = {}
	for i, v in ipairs(vertices) do
		if not ccw(vertices[prev_idx[i]], v, vertices[next_idx[i]]) then
			concave[v] = true
		end
	end

	local triangles = {}
	local n_vert, current, skipped, next, prev = #vertices, 1, 0, 0, 0
	while n_vert > 3 do
		next, prev = next_idx[current], prev_idx[current]
		local p,q,r = vertices[prev], vertices[current], vertices[next]
		if isEar(p,q,r, concave) then
			if not areCollinear(p, q, r) then
				triangles[#triangles+1] = {p, q, r}
				next_idx[prev], prev_idx[next] = next, prev
				concave[q] = nil
				n_vert, skipped = n_vert - 1, 0
			end
		else
			skipped = skipped + 1
			if skipped > n_vert then
				print('Warning:  triggerzone failed to triangulate polygon due to weird complexity')
				return {}
			end
		end
		current = next
	end

	next, prev = next_idx[current], prev_idx[current]
	local p,q,r = vertices[prev], vertices[current], vertices[next]
	triangles[#triangles+1] = {p, q, r}
	return triangles
end

function Triangulate(rawVertices)
    local vertices = CleanPolygon(rawVertices)
	local triangles = TriangulatePolygon(vertices)
    return vertices, triangles
end