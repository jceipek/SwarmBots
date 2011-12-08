from BeautifulSoup import BeautifulSoup

f = open('lb.svg')

txt = f.read()
soup = BeautifulSoup(txt, selfClosingTags=['defs','sodipodi:namedview'])

#print soup.prettify()

for p in soup.findAll('path'):
  print p['d']


