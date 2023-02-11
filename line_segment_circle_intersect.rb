# ---- ---- ---- ---- Infinite line

def line_intersect_circle? line, circle
  # where: line has {x:, y:, x2:, y2:} and circle has {cx:, cy:, radius:}
  # An infinite line defined by two points x,y & x2,y2.
  #
  # Mathematics from:
  #   https://mathworld.wolfram.com/Circle-LineIntersection.html

  cx, cy = circle.cx, circle.cy
  r = circle.radius
   
  # We must shift to the origin, as the formula is based on the circle being at (0,0)
  x1, y1 = line.x-cx, line.y-cy
  x2, y2 = line.x2-cx, line.y2-cy

  dx = x2-x1
  dy = y2-y1
  dr_sqrd = dx*dx + dy*dy   # dr = sqrt(dx^2+dy^2); we don't need dr, but we do need dr^2
  big_D = x1*y2 - x2*y1
  
  intersect = (r*r)*dr_sqrd - (big_D*big_D)
  intersect >= 0    # no intersect <0; tangent==0; intersect >0
end

# ---- ---- ---- ---- Line segment

def triangle_area line, cx,cy
  # where: line has two points {x:,y:, x2:,y2:} and cx,cy is the other corner
  ax, ay = line.x, line.y
  bx, by = line.x2, line.y2
  abx, aby = bx-ax, by-ay    # vector ab
  acx, acy = cx-ax, cy-ay    # vector ac
  cross_product = abx*acy - aby*acx
  cross_product.abs/2
end

def dist_sqrd ax,ay, bx,by
  dx = bx-ax
  dy = by-ay
  dx*dx + dy*dy
end

def dot ax,ay, bx,by, cx,cy, dx,dy    # dot product of (ab,cd)
  abx,aby = bx-ax,by-ay    # vector ab
  cdx,cdy = dx-cx,dy-cy    # vector cd
  abx*cdx + aby*cdy        # dot(ab,cd)
end

def segment_intersect_circle? segment, circle
  # where: segment has endpoints {x:, y:, x2:, y2:} and circle has {cx:, cy:, radius:}
  #
  # Mathematics from:
  #   https://www.baeldung.com/cs/circle-line-segment-collision-detection
  #
  # The two segment endpoints and the circle center make three points of a triangle 'p', 'q', 'o'
  r = circle.radius
  radius_sqrd = r*r

  ox, oy = circle.cx, circle.cy        # O
  px, py = segment.x, segment.y        # P
  qx, qy = segment.x2, segment.y2      # Q

  dist_op_sqrd = dist_sqrd(ox,oy, px,py)  # distance (or line length) between O and P
  dist_oq_sqrd = dist_sqrd(ox,oy, qx,qy)  # distance (or line length) between O and Q
  dist_pq_sqrd = dist_sqrd(px,py, qx,qy)  # distance (or line length) between P and Q

  return true if dist_op_sqrd < radius_sqrd && dist_oq_sqrd < radius_sqrd  # intersection includes segment inside circle

  max_dist_sqrd = [dist_op_sqrd, dist_oq_sqrd].max

  if dot(ox,oy, px,py, qx,qy, px,py) > 0 && dot(ox,oy, qx,qy, px,py, qx,qy) > 0
    tri_area = triangle_area(segment, ox,oy)
    min_dist_sqrd = (4*tri_area*tri_area) / dist_pq_sqrd
  else
    min_dist_sqrd = [dist_op_sqrd, dist_oq_sqrd].min
  end

  (min_dist_sqrd <= radius_sqrd) && (max_dist_sqrd >= radius_sqrd)
end

# ---- ---- ---- ---- Test/Demo Harness

def move_endpoint line, aim
  [line.x=aim.x, line.y=aim.y] if aim.button_left
  [line.x2=aim.x, line.y2=aim.y] if aim.button_right
  line
end

CAX = 640 + 200
CBX = 640 - 200
CY  = 360
CR  = 50
CIRCLE_A = {x:CAX-CR,y:CY-CR,w:CR*2,h:CR*2,path:'sprites/circle.png',r:0,g:255,b:0,radius:CR,cx:CAX,cy:CY,}
LABEL_A  = {x:CIRCLE_A.x,y:CIRCLE_A.y,text:'Infinite Line',}
CIRCLE_B = {x:CBX-CR,y:CY-CR,w:CR*2,h:CR*2,path:'sprites/circle.png',r:0,g:255,b:0,radius:CR,cx:CBX,cy:CY,}
LABEL_B  = {x:CIRCLE_B.x,y:CIRCLE_B.y,text:'Line Segment',}

$line = {x:CAX-300,y:360,x2:CAX-100,y2:360,r:255,g:255,b:255,}

def tick args
  red,green = 0,255
  $outputs.background_color = [100,100,100]

  $line = move_endpoint($line, args.inputs.mouse)

  red_A,green_A = (line_intersect_circle?($line, CIRCLE_A)) ? [255,0] : [0,255]
  red_B,green_B = segment_intersect_circle?($line, CIRCLE_B) ? [255,0] : [0,255]
  
  $outputs.sprites << ({} << CIRCLE_A << {r:red_A, g:green_A})
  $outputs.borders << ({} << CIRCLE_A << {r:0, g:0})  # bounding border
  $outputs.borders << ({} << CIRCLE_A << {x:CIRCLE_A.cx,y:CIRCLE_A.cy,w:1,h:1,r:0, g:0})  # circle center
  $outputs.labels << LABEL_A

  $outputs.sprites << ({} << CIRCLE_B << {r:red_B, g:green_B})
  $outputs.borders << ({} << CIRCLE_B << {r:0, g:0})  # bounding border
  $outputs.borders << ({} << CIRCLE_B << {x:CIRCLE_B.cx,y:CIRCLE_B.cy,w:1,h:1,r:0, g:0})  # circle center
  $outputs.labels << LABEL_B

  $outputs.lines << $line

  label = {x:640,y:720,text: "Seg_Circle(cx,cy,radius): #{CIRCLE_B.cx},#{CIRCLE_B.cy},#{CIRCLE_B.radius}" +
          "   Line(x,y,x2,y2): #{$line.x},#{$line.y},#{$line.x2},#{$line.y2}" +
          "   Inf_Circle(cx,cy,radius): #{CIRCLE_A.cx},#{CIRCLE_A.cy},#{CIRCLE_A.radius}",alignment_enum:1,}
  $outputs.labels << label
end

