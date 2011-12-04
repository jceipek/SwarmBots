import pygame
import serial

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

  def __repr__(self):
    return (self.x, self.y)


class Robot(object):

  FWD = 1
  BKWD = -1
  OFF = 0

  def __init__(self,x,y):
    self.path = []
    self.position = Vect(x,y)
    self.light = True
    self.lightColor = (255,0,0)
    self.motL = Robot.OFF
    self.motR = Robot.OFF

    self.lEnc = 0
    self.rEnc = 0

  def update(self, lEnc, rEnc):
    delta = Vect(lEnc-self.lEnc, rEnc-self.rEnc)
    self.lEnc = lEnc
    self.rEnc = rEnc

    self.position += delta

    if self.light:
      self.path.append(self.position)

  def draw(self, surf):
    pygame.draw.lines(surf, self.lightColor, False, self.path)


def readEncVals():
  return 0,0

#ser = serial.Serial('/dev/tty.usbserial', 9600) #TODO: Fix this to point to the correct device

pygame.init()
screen = pygame.display.set_mode(Vect(600,600))
running = True

lb0 = Robot()

while running:
  for event in pygame.event.get():
    if event.type == pygame.KEYDOWN:

      if event.key == pygame.K_ESCAPE:
        running = False

      elif event.key == pygame.K_UP:
        print "Up"
      elif event.key == pygame.K_DOWN:
        print "Down"
      elif event.key == pygame.K_LEFT:
        print "Left"
      elif event.key == pygame.K_RIGHT:
        print "Right"

    elif event.type == pygame.QUIT:
      running = False

  l,r = readEncVals()
  lb0.update(l,r)

  lb0.draw(screen)
  screen.fill((0,0,0))

  pygame.display.flip()
