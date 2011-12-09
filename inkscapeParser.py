import pygame
from BeautifulSoup import BeautifulStoneSoup
import BeautifulSoup

f = open('lightBot.svg')
o = open('output.pde','w')

txt = f.read()
soup = BeautifulStoneSoup(txt, selfClosingTags=['defs','sodipodi:namedview','path'])

#print soup.prettify()

width = float(soup.find('svg')['width'])
height = float(soup.find('svg')['height'])
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
    elif p[coordI] == 'z':
      lines.append[lines[0]]
    else:
      p[coordI] = p[coordI].split(',')
      p[coordI] = tuple([float(c) for c in p[coordI]])
      if controlChar == 'M' or controlChar == 'L':
        lastPoint = (p[coordI][0]+offset[0],p[coordI][1]+offset[1])
        lines.append(lastPoint)
      elif controlChar == 'm' or controlChar == 'l':
        if coordI == 1:
          lastPoint = (p[coordI][0]+offset[0],p[coordI][1]+offset[1])
        else:
          m = (lastPoint[0]+p[coordI][0],lastPoint[1]+p[coordI][1])
          lastPoint = m
        lines.append(lastPoint)


  #print lines
  return lines


allPoints = []
for g in soup.findAll('g'):
  lastPoint=(0,0)  
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
    lastPoint = currLines[1]
    print "LAST PT:",lastPoint

'''
print "HERE"
stuff = [(tag.find('<path'),str(tag)) for tag in soup.find('svg')]
for i in stuff:
  print i
'''

for p in soup.find('svg').findNextSiblings('path'):
  print "PATHS ARE HURR"
  try:
    ltranslate = p['transform']
    ltranslate = ltranslate[len('translate('):-1]
    ltranslate = ltranslate.split(',')
    ltranslate = float(ltranslate[0])+float(translate[0]),float(ltranslate[1])+float(translate[1])
  except KeyError:
    ltranslate = translate
  currLines = parsePoint(p['d'],lastPoint,offset=ltranslate)
  allPoints.append(currLines)



scale = 800.0/height
turnOffListVals = [str(len(pList)) for pList in allPoints]
xListCoords = []
yListCoords = []

for pList in allPoints:
  rPList = [(p[0]*scale,p[1]*scale) for p in pList]
  xListCoords.extend([str(r[0]) for r in rPList])
  yListCoords.extend([str(r[1]) for r in rPList])

o.write("int pathLen = ")
o.write(str(sum([len(pList) for plist in allPoints])))
o.write(';\n\n')

o.write("byte lightPath[] = {\n  ")
o.write(',\n  '.join(turnOffListVals))
o.write("\n};\n\n")

o.write("float xPath[] = {\n  ")
o.write(',\n  '.join(xListCoords))
o.write("\n};\n\n")

o.write("float yPath[] = {\n  ")
o.write(',\n  '.join(yListCoords))
o.write("\n};\n")

o.close()
f.close()


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
         
  for pList in allPoints:
    rPList = [(p[0]*scale+pan[0],p[1]*scale+pan[1]) for p in pList]
    pygame.draw.lines(screen, (255,255,0), False, rPList)
    

  pygame.display.flip();




