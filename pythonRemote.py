'''
Displays robot position based on dead reckoning computed onboard. 
'''

import pygame
import serial
import math
from multiprocessing import Process, Queue, Pipe

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

  def updateAbs(self, x, y, a):
    self.position.x = x
    self.position.y = y
    self.angle = a

    if self.light:
      self.path.append(Vect(x,y))

  def update(self, lEnc, rEnc):
    print (lEnc,rEnc)
    Rw = 17.9
    T1,T2 = lEnc-self.lEnc,rEnc-self.rEnc
    D = 12.0
    TR = 12.0

    self.lEnc,self.rEnc = lEnc,rEnc

    # Based on equation from Wikipedia
    dTheta = (2*math.pi)*(Rw/D)*(T1-T2)/TR
    dx = Rw*math.cos(self.angle)*(T1+T2)*(math.pi/TR)
    dy = Rw*math.sin(self.angle)*(T1+T2)*(math.pi/TR)
    
    self.position += Vect(dx,dy)
    self.angle += dTheta

    if self.light:
      self.path.append(self.position)

  def draw(self, surf, scale, offset):
    if len(self.path) > 1:
      path = [p*scale+offset for p in self.path]
      pygame.draw.lines(surf, self.lightColor, False, path)

    verts = [(self.position+v.getRot(self.angle))*scale+offset for v in self.verts]
    pygame.draw.polygon(surf, (255,255,255), verts, 1)


class SerialReader(object):
  def __init__(self, port='/dev/tty.usbmodem411'):
    self._port = port
    self.lEnc = 0
    self.rEnc = 0

    self.posX = 0;
    self.posY = 0;
    self.angle = 0;

  def run(self):
    print "Running"
    self._queue = Queue()
    receiver,sender = Pipe(False)
    self._procTerm = sender
    self._proc = Process(target=self.monitor,args=(receiver,))
    self._proc.start()

  def readPosVals(self):
    if not self._queue.empty():
      try:
        tup = self._queue.get(timeout=1)
      except Exception as e:
        print "Read err"
        print e
      self.posX,self.posY,self.angle = tup
    return self.posX,self.posY,self.angle

  def monitor(self,closePipe):
    self._ser = serial.Serial(self._port, 9600,timeout=1)  
    self._running = True
    #print temp
    while self._running:
      if closePipe.poll():
        self._running = False
      try:
        orig = self._ser.readline()
        print orig
        temp = orig[orig.find('(')+1:]
        temp = temp[:temp.find(')')]
        temp = temp.strip()
        if temp.count(',') == 2:
          temp = temp.split(',')
          x = int(temp[0])
          y = int(temp[1])
          a = int(temp[2]) 
          print (x,y,a)
          self._queue.put((x,y,a*math.pi/180.0))
          #print "Transl:",self.lEnc,self.rEnc
        #return 0.0,0.0
      except Exception as e:
        print orig, temp
        print e
      #return self.lEnc,self.rEnc
    self._ser.close()

  def close(self):
    self._procTerm.send(1)


pygame.init()
screen = pygame.display.set_mode(Vect(1000,800))
pygame.key.set_repeat(50, 5)
running = True


reader = SerialReader()
reader.run()
lb0 = Robot()

scale = 1.0
panspeed = 20.0
offset = Vect(600,600)

clock = pygame.time.Clock()
l,r = 0,0
while running:
  for event in pygame.event.get():
    if event.type == pygame.KEYDOWN:

      if event.key == pygame.K_ESCAPE:
        running = False

      elif event.key == pygame.K_w:
        offset.y -= scale*panspeed
      elif event.key == pygame.K_s:
        offset.y += scale*panspeed
      elif event.key == pygame.K_a:
        offset.x -= scale*panspeed
      elif event.key == pygame.K_d:
        offset.x += scale*panspeed

      elif event.key == pygame.K_UP:
        print '++'
      elif event.key == pygame.K_DOWN:
        print '00'
      elif event.key == pygame.K_LEFT:
        print "+-"
      elif event.key == pygame.K_RIGHT:
        print "-+"
      elif event.key == pygame.K_MINUS:
        scale *= 0.99
      elif event.key == pygame.K_EQUALS:
        scale *= 1.01


    elif event.type == pygame.QUIT:
      running = False

  x,y,a = reader.readPosVals()
  lb0.updateAbs(x,y,a)
  #l+=1.0
  #r+=1.0
  screen.fill((0,0,0))
  lb0.draw(screen, scale, Vect(-300*scale,-300*scale)+offset)

  pygame.display.flip()

  clock.tick(60)

print "Program closed successfully"
reader.close()

