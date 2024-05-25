function Centroid(vertices)
    local n = #vertices

    if n == 1 then
        return vertices[1]
    end

    if n == 2 then
        local xc = (vertices[1].x + vertices[2].x) / 2
        local yc = (vertices[1].y + vertices[2].y) / 2
        return vec2(xc, yc)
    end

    local x_sum, y_sum, area = 0, 0, 0

    for i, vertex in ipairs(vertices) do
      local x1, y1 = vertex.x, vertex.y
      local x2, y2 = vertices[(i % n) + 1].x, vertices[(i % n) + 1].y
      local term = x1 * y2 - x2 * y1
      x_sum = x_sum + (x1 + x2) * term
      y_sum = y_sum + (y1 + y2) * term
      area = area + term
    end

    area = math.abs(area) / 2
    local x_c = x_sum / (6 * area)
    local y_c = y_sum / (6 * area)

    return vec2(x_c, y_c)
end

function Radius(centroid, points)
    local radius = 0.0
    for _, point in ipairs(points) do
        local dist = #(centroid - point)
        if dist > radius then
            radius = dist
        end
    end
    return radius
end

function IsInside(point, zone)
    if point.z < zone.altitude then return false end
    if point.z > zone.altitude + zone.height then return false end

    if not zone.centroid then
        zone.centroid = Centroid(zone.points)
    end

    if not zone.radius then
        zone.radius = Radius(zone.centroid, zone.points)
    end

    if #zone.points < 3 then
        return false
    end

    if #(point.xy - zone.centroid) > zone.radius then
        return false
    end

    local crossings = 0
    local polygon = zone.points
    local n = #polygon
    for i = 1, n do
        local x1, y1 = polygon[i].x, polygon[i].y
        local x2, y2 = polygon[(i % n) + 1].x, polygon[(i % n) + 1].y
        if (
            (y1 <= point.y and point.y < y2)
            or (y2 <= point.y and point.y < y1)) and (point.x < (x2 - x1) * (point.y - y1) / (y2 - y1) + x1
        ) then
            crossings = crossings + 1
        end
    end
    return crossings % 2 == 1
end

function LineSide(a, b, c)
        return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - c.x)
end

function CrossProduct(v1, v2)
    return vec3(
        v1.y * v2.z - v1.z * v2.y,
        v1.z * v2.x - v1.x * v2.z,
        v1.x * v2.y - v1.y * v2.x
    )
end

function CrossProduct2D(v1, v2)
    return v1.x * v2.y - v1.y * v2.x
end

function DotProduct(normal, firstPoint, outsidePoint)
    return normal.x * (outsidePoint.x - firstPoint.x) + normal.y * (outsidePoint.y - firstPoint.y) + normal.z * (outsidePoint.z - firstPoint.z)
end

function PlaneSide(v1, v2, v3, p)
    local vec1 = vec3(v2.x - v1.x, v2.y - v1.y, v2.z - v1.z)
    local vec2 = vec3(v3.x - v1.x, v3.y - v1.y, v3.z - v1.z)
    local normal = CrossProduct(vec1, vec2)
    local dot = DotProduct(normal, v1, p)
    return dot
end

function IsConvex(vertices)
    for i = 1, #vertices do
        local p1 = vertices[i]
        local p2 = vertices[(i % #vertices) + 1]
        local p3 = vertices[((i + 1) % #vertices) + 1]
        if CrossProduct2D(p2 - p1, p3 - p2) < 0 then
            return false
        end
    end
    return true
end

function ClosestOnSegment(p1, p2, p)
    local v = vec2(p2.x - p1.x, p2.y - p1.y)
    local w = vec2(p.x - p1.x, p.y - p1.y)

    local t = (v.x * w.x + v.y * w.y) / (v.x * v.x + v.y * v.y)
    t = math.max(0, math.min(1, t))

    local cx = p1.x + t * v.x
    local cy = p1.y + t * v.y
    return vec2(cx, cy)
end

function Closest(vertices, point)
    local closestDistance, closestSegment, closestPoint, closestIndices = math.huge, {vec2(0,0),vec2(0,0)}, vec2(0,0), {0,0}
    for i = 1, #vertices do
        local p1 = vertices[i]
        local p2 = vertices[(i % #vertices) + 1]

        local closestPointThisSegment = ClosestOnSegment(p1, p2, point.xy)

        local distance = #(point.xy - closestPointThisSegment)
        if distance <= closestDistance then
            closestDistance = distance
            closestSegment = {p1, p2}
            closestIndices = {i, (i % #vertices) + 1}
            closestPoint = closestPointThisSegment
        end
    end
    return closestDistance, closestPoint, closestSegment, closestIndices
end

function ClosestVertex(vertices, point)
    local closestDistance, closestPoint, closestIndex = math.huge, vec2(0,0), 0
    for i, vertex in ipairs(vertices) do
        local distance = #(vertex - point)
        if distance < closestDistance then
            closestDistance = distance
            closestPoint = vertex
            closestIndex = i
        end
    end
    return closestDistance, closestPoint, closestIndex
end

--- 40, 48, 50 -> 0.5 -> 8 / 10 = 0.8
function LerpFactor(fullyFadedIn, actualDistance, drawDistance)
    if actualDistance >= drawDistance then return 0.0 end
    if actualDistance <= fullyFadedIn then return 1.0 end
    return 1.0 - (actualDistance - fullyFadedIn) / (drawDistance - fullyFadedIn)
end