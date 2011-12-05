import pygame
import serial
import math

class Vect(object):
  def __init__(self, x, y):
    self.x = x
    self.y = y

  def __len__(self):
    return 2

  def __getitem__(self, key):
    if key == 0: return self.x
    if key == 1: return self.y
    raise ValueError('Invalid key: '+str(key))

  def __setitem__(self, key, value):
    if key == 0: self.x = value
    if key == 1: self.y = value
    raise ValueError('Invalid key: '+str(key))

  def __add__(self, other):
    return Vect(self.x+other.x, self.y+other.y)

  def __sub__(self, other):
    return Vect(self.x-other.x, self.y-other.y)

  def __mul__(self, other):
    return Vect(self.x*other,self.y*other)

  def __repr__(self):
    return str((self.x, self.y))

  def makePerp(self):
    temp = -self.x
    self.x = self.y
    self.y = temp
    return self

  def rot(self, radAngle):
    x,y = self.x,self.y
    self.x = x*math.cos(radAngle) - y*math.sin(radAngle)
    self.y = x*math.sin(radAngle) + y*math.cos(radAngle)
    return self

  def getRot(self, radAngle):
    xp = self.x*math.cos(radAngle) - self.y*math.sin(radAngle)
    yp = self.x*math.sin(radAngle) + self.y*math.cos(radAngle)
    return Vect(xp,yp)


class Robot(object):

  FWD = 1
  BKWD = -1
  OFF = 0

  def __init__(self,x=300,y=308):
    self.path = []
    self.position = Vect(x,y)
    #self.verts = [Vect(300,300),Vect(290,330),Vect(310,330)]
    self.verts = [Vect(0,5),Vect(-5,-10),Vect(5,-10)]

    self.angle = 0

    self.light = True
    self.lightColor = (255,0,0)
    self.motL = Robot.OFF
    self.motR = Robot.OFF

    self.lEnc = 0
    self.rEnc = 0

  def update(self, lEnc, rEnc):

    h1 = lEnc-self.lEnc
    h2 = rEnc-self.rEnc
    w = 1.0 #Robot Width

    dist = (h1+h2)/2.0

    if abs(h1-h2) <= 0.0000001:
      angle = 0.0
    else:
      if h1<h2:
        inside = h1/((w*h1)/(h1-h2)-(w/2.0))
        angle = inside/abs(inside)*math.asin(abs(inside))
      else:
        inside = h2/((w*h2)/(h2-h1)-(w/2.0))
        angle = -1*inside/abs(inside)*math.asin(abs(inside))

    self.angle += angle
    self.angle %= 2*math.pi

    self.lEnc = lEnc
    self.rEnc = rEnc
   
    delta = Vect(0,dist).rot(self.angle) 

    self.position += delta    
    if self.light:
      self.path.append(self.position)

  def draw(self, surf, scale, offset):
    if len(self.path) > 1:
      path = [p*scale+offset for p in self.path]
      pygame.draw.lines(surf, self.lightColor, False, path)

    verts = [(self.position+v.getRot(self.angle))*scale+offset for v in self.verts]
    pygame.draw.polygon(surf, (255,255,255), verts, 1)


def readEncVals():
  return 0,0

#ser = serial.Serial('/dev/tty.usbserial', 9600) #TODO: Fix this to point to the correct device

pygame.init()
screen = pygame.display.set_mode(Vect(1000,800))
running = True

lb0 = Robot()

l,r = 0,0
scale = 5.0

clock = pygame.time.Clock()

while running:
  for event in pygame.event.get():
    if event.type == pygame.KEYDOWN:

      if event.key == pygame.K_ESCAPE:
        running = False

      elif event.key == pygame.K_UP:
        print '++'
      elif event.key == pygame.K_DOWN:
        print '00'
      elif event.key == pygame.K_LEFT:
        print "+-"
      elif event.key == pygame.K_RIGHT:
        print "-+"

    elif event.type == pygame.QUIT:
      running = False

  #l,r = readEncVals()
  l+=0.95
  r+=1.0
  lb0.update(l,r)

  screen.fill((0,0,0))
  lb0.draw(screen, scale, Vect(-300*scale+300,-300*scale+300))

  pygame.display.flip()

  clock.tick(25)
