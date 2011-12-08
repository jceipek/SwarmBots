import pygame
from BeautifulSoup import BeautifulSoup

f = open('lb.svg')

txt = f.read()
soup = BeautifulSoup(txt, selfClosingTags=['defs','sodipodi:namedview'])

#print soup.prettify()

width = float(soup.findAll('svg')[0]['width'])
height = float(soup.findAll('svg')[0]['height'])


def parsePoint(p):
  p = p.strip().split(' ')
  print p

allPoints = []
for p in soup.findAll('path'):
  parsePoint(p['d'])

scale = 800.0/height

pygame.init()

screen = pygame.display.set_mode((int(width*scale),int(height*scale)))

running = True
while running:
 
  for event in pygame.event.get():
    if event.type == pygame.QUIT:
      running = False
    elif event.type == pygame.KEYDOWN:
      if event.key == pygame.K_ESCAPE:
        running = False

  screen.fill((0,0,0))
  pygame.display.flip();




