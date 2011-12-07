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
    print (lEnc,rEnc)
    Rw = 17.9
    T1,T2 = lEnc-self.lEnc,rEnc-self.rEnc
    D = 12.0
    TR = 12.0

    self.lEnc,self.rEnc = lEnc,rEnc

    dTheta = (2*math.pi)*(Rw/D)*(T1-T2)/TR
    dx = Rw*math.cos(self.angle)*(T1+T2)*(math.pi/TR)
    dy = Rw*math.sin(self.angle)*(T1+T2)*(math.pi/TR)
    
    self.position += Vect(dx,dy)
    self.angle += dTheta

    """
    h1 = lEnc-self.lEnc
    h2 = rEnc-self.rEnc

    print h1,h2

    w = 12.0 #Robot Width

    dist = (h1+h2)/2.0

    PREC = 0.0000001

    if abs(h1-h2) <= PREC: # Handle cases where robot moves fwd or back perfectly
      angle = 0.0
    elif abs(h1) > abs(h2):
      sign = 
    elif abs(h1) < abs(h2):


    
    elif h1>=0.0 and h2>=0.0:
      if h1>h2:
        inside = h1/((w*h1)/(h1-h2)-(w/2.0))
        angle = inside/abs(inside)*math.asin(abs(inside))
      else:
        inside = h2/((w*h2)/(h2-h1)-(w/2.0))
        angle = -1*inside/abs(inside)*math.asin(abs(inside))
    elif h1 < 0 and h2 < 0:
      if abs(h1)>abs(h2):
        h1 = abs(h1)
        h2 = abs(h2)
        inside = h1/((w*h1)/(h1-h2)-(w/2.0))
        angle = -1*inside/abs(inside)*math.asin(abs(inside))
      else:
        inside = h2/((w*h2)/(h2-h1)-(w/2.0))
        angle = -inside/abs(inside)*math.asin(abs(inside))      
    elif h1 < 0:
      if abs(h1)>h2:
        inside = abs(h1)/((w*abs(h1))/(abs(h1)-h2)-(w/2.0))
        angle = -1*inside/abs(inside)*math.asin(abs(inside))
      else:
        inside = h2/((w*h2)/(h2-abs(h1))-(w/2.0))
        angle = inside/abs(inside)*math.asin(abs(inside))
    elif h2 < 0:
      if h1>abs(h2):
        inside = h1/((w*h1)/(h1-abs(h2))-(w/2.0))
        angle = -1*inside/abs(inside)*math.asin(abs(inside))
      else:
        inside = abs(h2)/((w*abs(h2))/(abs(h2)-h1)-(w/2.0))
        angle = -inside/abs(inside)*math.asin(abs(inside))
        """
      

    #self.angle += angle
    #self.angle %= 2*math.pi

    #self.lEnc = lEnc
    #self.rEnc = rEnc
   
    #delta = Vect(0,dist).rot(self.angle) 

    #self.position += delta    
    if self.light:
      self.path.append(self.position)

  def draw(self, surf, scale, offset):
    if len(self.path) > 1:
      path = [p*scale+offset for p in self.path]
      pygame.draw.lines(surf, self.lightColor, False, path)

    verts = [(self.position+v.getRot(self.angle))*scale+offset for v in self.verts]
    pygame.draw.polygon(surf, (255,255,255), verts, 1)


class SerialReader(object):
  def __init__(self, port='/dev/tty.usbmodem411',timeout=1):
    self._ser = serial.Serial(port, 9600, timeout=timeout)
    self.lEnc = 0
    self.rEnc = 0

  def readEncVals(self):
    temp = self._ser.readline()
    #print temp
    try:
      if temp[0] == '(' and temp[-3:-1] == ')\r':
        temp = temp[1:len(temp)-3].split(',')
        self.lEnc = int(temp[0])
        self.rEnc = int(temp[1])
        #print "Transl:",self.lEnc,self.rEnc
      #return 0.0,0.0
    except:
      pass
    return self.lEnc,self.rEnc

  def close(self):
    self._ser.close()


pygame.init()
screen = pygame.display.set_mode(Vect(1000,800))
running = True


reader = SerialReader()
lb0 = Robot()

scale = 10.0

clock = pygame.time.Clock()
l,r = 0,0
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
      elif event.key == pygame.K_MINUS:
        scale *= 1.01
      elif event.key == pygame.K_EQUALS:
        scale *= 0.99


    elif event.type == pygame.QUIT:
      running = False

  l,r = reader.readEncVals()
  lb0.update(l,r)
  #l+=1.0
  #r+=1.0
  screen.fill((0,0,0))
  lb0.draw(screen, scale, Vect(-300*scale+300,-300*scale+300))

  pygame.display.flip()

  clock.tick(60)

reader.close()
