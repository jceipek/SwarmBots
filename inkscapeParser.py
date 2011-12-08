import pygame
from BeautifulSoup import BeautifulSoup

f = open('lb.svg')

txt = f.read()
soup = BeautifulSoup(txt, selfClosingTags=['defs','sodipodi:namedview'])

#print soup.prettify()

width = float(soup.findAll('svg')[0]['width'])
height = float(soup.findAll('svg')[0]['height'])
print width,height

def parsePoint(p,lastPoint,offset=(0,0)):
  print "orig,",p
  print "offset",offset
  p = p.strip().split(' ')
  lines = []
  controlChar = ''
  for coordI in range(len(p)):
    if p[coordI] == 'M':
      controlChar = 'M'
    elif p[coordI] == 'm':
      controlChar = 'm'
    elif p[coordI] == 'l':
      controlChar = 'l'
    elif p[coordI] == 'L':
      controlChar = 'L'
    else:
      p[coordI] = p[coordI].split(',')
      p[coordI] = tuple([float(c) for c in p[coordI]])
      if controlChar == 'M' or controlChar == 'L':
        lastPoint = (p[coordI][0]+offset[0],p[coordI][1]+offset[1])
        lines.append(lastPoint)
      elif controlChar == 'm' or controlChar == 'l':
        m = (lastPoint[0]+p[coordI][0],lastPoint[1]+p[coordI][1])
        lastPoint = m
        lines.append(lastPoint)


  print lines
  return lines


allPoints = []
lastPoint=(0,0)
for g in soup.findAll('g'):
  try:
    translate = g['transform']
    translate = translate[len('translate('):-1]
    translate = translate.split(',')
    translate = float(translate[0]),float(translate[1])
  except KeyError:
    translate = (0,0)
  for p in g.findAll('path'):
    try:
      ltranslate = p['transform']
      ltranslate = ltranslate[len('translate('):-1]
      ltranslate = ltranslate.split(',')
      ltranslate = float(ltranslate[0])+float(translate[0]),float(ltranslate[1])+float(translate[1])
    except KeyError:
      ltranslate = translate
    currLines = parsePoint(p['d'],lastPoint,offset=ltranslate)
    allPoints.append(currLines)
    lastPoint = currLines[-1]
    print "LAST PT:",lastPoint

scale = 800.0/height

pygame.init()

screen = pygame.display.set_mode((int(width*scale),int(height*scale)))

running = True
pan = [0,0]
while running:
  screen.fill((0,0,0))
   
  for event in pygame.event.get():
    if event.type == pygame.QUIT:
      running = False
    elif event.type == pygame.KEYDOWN:
      if event.key == pygame.K_ESCAPE:
        running = False
      elif event.key == pygame.K_MINUS:
        scale *= 0.9
      elif event.key == pygame.K_EQUALS:
        scale *= 1.1
      elif event.key == pygame.K_UP:
        pan[1] += 10
      elif event.key == pygame.K_DOWN:
        pan[1] -= 10
      elif event.key == pygame.K_LEFT:
        pan[0] -= 10
      elif event.key == pygame.K_RIGHT:
        pan[0] += 10
         
  blah = 0
  for pList in allPoints:
    rPList = [(p[0]*scale+pan[0],p[1]*scale+pan[1]) for p in pList]
    pygame.draw.lines(screen, (255,(255*blah),0), False, rPList)
    blah += 1
    

  pygame.display.flip();




